---
title: "R Tutorial Part 1"
weight: 3
type: book
summary: "State space modeling tutorial: Part 1"
show_date: false
editable: true
---

*Heavily influenced by the
the
[state space modeling activity](https://github.com/EcoForecast/EF_Activities/blob/master/Exercise_06_StateSpace.Rmd) from
Michael Dietz's
excellent
[Ecological Forecasting book](https://www.amazon.com/Ecological-Forecasting-Michael-C-Dietze/dp/0691160570)
and Nicholas J Clark's course on [Ecological forecasting with mvgam and brms](https://nicholasjclark.github.io/physalia-forecasting-course/)*

> cmdstan needs to be installed

## Installation

```r
install.packages(c("brms", "dplyr", "gratia", "ggplot2",
          "marginaleffects", "tidybayes", "zoo",
          "viridis", "remotes"))
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
remotes::install_github('nicholasjclark/mvgam', force = TRUE)
```

```r
library(cmdstanr)
check_cmdstan_toolchain()
install_cmdstan()
cmdstan_version()
```

If these returns a version number like `"2.32.2"` then things are working properly.

## Text Tutorial

### State space models

* Time-series model
* Only first order autoregressive component
* Separately model
  * the process model - how the system evolves in time or space
  * the observation model - observation error or indirect observations
* Estimates the true value of the underlying **latent** state variables

### Data

* Data on the population dynamics of the Desert Pocket Mouse

```r
library(mvgam)
data("portal_data")
head(portal_data)
```

### Model

> Draw on board while walking through models

```
y_t-1    y_t    y_t+1
  |       |       |
x_t-1 -> x_t -> x_t+1   Process model
```

#### Process model

* What is actually happening in the system
* First order autoregressive component

x_t+1 = f(x_t) + e_t

* Simple linear model is AR1:

x_t+1 = b0 + b1 * x_t + e_t


#### Observation model

* Counts of rodents in traps aren't perfect measures of the number of number of rodents at the site
  (which are what should be changing in the process model and what we care about)
* So model this imperfect observation

y_t = Pois(x_t)

* Can be much more complicated


### mvgam

* Models like this are not trivial to fit
* Use [STAN][(http://mcmc-jags.sourceforge.net](https://mc-stan.org/))
* Uses MCMC to explore parameter space to fit the model using Bayesian methods
* Typically requires learning a separate language - STAN is it's own language
* This lets you right arbitrarily complex models, but really needs a course in Bayesian methods
* So, we're going to use an R package called `mvgam` to implement our models
* We're going to use it because it's the simplest way to make a state space time-series model in R
* We'll use it again when we learn about GAMs

```r
library(mvgam)
```

* mvgam requires that we modify our data a bit

```r
model_data <- portal_data %>%
  
  # mvgam requires a 'time' variable be present in the data to index
  # the temporal observations. This is especially important when tracking 
  # multiple time series. In the Portal data, the 'moon' variable indexes the
  # lunar monthly timestep of the trapping sessions
  dplyr::mutate(time = moon - (min(moon)) + 1) %>%
  
  # We can also provide a more informative name for the outcome variable, which 
  # is counts of the 'PP' species (Chaetodipus penicillatus) across all control
  # plots
  dplyr::mutate(count = PP) %>%
  
  # The other requirement for mvgam is a 'series' variable, which needs to be a
  # factor variable to index which time series each row in the data belongs to.
  # Again, this is more useful when you have multiple time series in the data
  dplyr::mutate(series = as.factor('PP')) %>%
  dplyr::mutate(ndvi_lag12 = dplyr::lag(ndvi, 12)) %>%
  
  # Select the variables of interest to keep in the model_data
  dplyr::select(series, year, time, count, mintemp, ndvi, ndvi_lag12)
```

* Train/test split

```r
model_data %>%                      
  dplyr::filter(time <= 160) -> data_train 
model_data %>% 
  dplyr::filter(time > 160) -> data_test
```

### Simply time-series models in mvgam

* Start by building something similar to what we've done before with the number of desert pocket mice
* Model has an exogenous driver - minimum temperature
* An autoregressive component
* Gaussian error
* Fit using the `mvgam()` function
* Follows a Base R model structure so start with the model
* Instead of including the AR component in the model we add a separate `trend_model` argument
* We'll use `"AR1"`
* Specify the error `family = gaussian()`
* Then we can specify the data for fitting the model and the data for making/evaluating forecasts 

```r
baseline_model = mvgam(count ~ mintemp,
                       trend_model = "AR1",
                       family = gaussian(),
                       data = data_train,
                       newdata = data_test)
```

#### Bayesian model fitting

* That's a lot of output for fitting a model
* What's going on?
* It is difficult to fit complex models like the state space models we're building towards
* One way to fit these more complex models is using Bayesian methods
* These methods iteratively search parameter space for the best parameter values
* Using something called Markov Chain Monte Carlo (MCMC)
* _Draw 2D parameter search on board_
* The `"Iteration"` lines are telling us that the model is working it's way through this process
* The different "chains" are because we typically go through this process multiple times to check than we are converging to the right values
* We can look at the result of this fitting process using `mcmc_plot`

```r
mcmc_plot(baseline_model, type = "trace", variable = c("mintemp", "ar1[1]", "sigma[1]"))
```

* The red lines at the bottom are providing the same information as the warnings when we fit the model
* Something isn't quite right
* The model isn't converged yet
* We could try running it longer
* But part of what's going on here is that the errors aren't really Gaussian
* So let's look at the forecast and then move on

```r
plot(baseline_model, type = "forecast")
```

* Remember our model looks like this

{{< math >}}
$$y_t = c + \beta_1 x_{1,t} + \beta_2 y_{t-1} + \mathcal{N}(0,\sigma^{2})$$
{{< /math >}}

* Which can also be written as

{{< math >}}
$$y_t = \mathcal{N}(\mu,\sigma^{2})$$
$$u_t =  c + \beta_1 x_{1,t} + \beta_2 y_{t-1}$$
{{< /math >}}

* Prediction intervals are regularly negative because we've assumed normally distributed error
* Actual counts can only be non-negative integers: 0, 1, 2...


### Better distributions

* Let's use Poisson error structure and a log link function to give us only integer predictions

{{< math >}}
$$y_t = \mathrm{Pois}(\mu_t)$$
$$\mathrm{log(\mu_t)} = c + \beta_1 x_{1,t} + \beta_2 y_{t-1} + \mathcal{N}(0,\sigma^{2})$$
{{< /math >}}

* The Poisson distribution generates only integer draws based on a mean
* If the mean is 1.5 sometimes you'll draw a 1, sometimes a 2, etc.
* The log transformation of $\mu$ ensures that $\mu$ is positive

```r
poisson_model = mvgam(count ~ mintemp,
                       trend_model = "AR1",
                       family = poisson(link = "log"),
                       data = data_train,
                       newdata = data_test)
```

* No more warnings at the end
* Look at the model

```r
summary(poisson_model)
```

* And the forecast

```r
plot(poisson_model, type = "forecast", newdata = data_test)
```

* Now all of our predictions are positive!

### State space

* State space model of AR1 + rain w/Poisson error

{{< math >}}
$$y_t = \mathrm{Pois}(\mu_t)$$
$$\mathrm{log(\mu_t)} = c + \beta_1 x_{1,t} + \beta_2 \mu_{t-1} + \mathcal{N}(0,\sigma^{2})$$
{{< /math >}}

```r
state_space_model = mvgam(count ~ 1,
                         trend_formula = ~ mintemp,
                         trend_model = "AR1",
                         family = poisson(link = "log"),
                         data = data_train,
                         newdata = data_test)
plot(state_space_model, type = "forecast", newdata = data_test)
```

### 
* Normally would want several chains with different starting positions to avoid
  local minima

* Send to JAGS

```{r}
j.model   <- jags.model (file = textConnection(RandomWalk),
                         data = data,
                         inits = init,
                         n.chains = 1)
```

* Burn in

```{r}
jags.out   <- coda.samples (model = j.model,
                            variable.names = c("tau_proc","tau_obs"),
                            n.iter = 10000)
plot(jags.out)
```

* Sample from MCMC with full vector of X's
* This starts sampling from the point were the previous run of `coda.samples`
  ends so it gets rid of the burn-in samples

```{r}
jags.out   <- coda.samples (model = j.model,
                            variable.names = c("x","tau_proc","tau_obs"),
                            n.iter = 10000)
```

* Visualize
* Convert the output into a matrix & drop parameters

```{r}
out <- as.matrix(jags.out)
xs <- out[,3:ncol(out)]
```

* Point predictions are averages across MCMC samples

```
predictions <- colMeans(xs)
plot(time, predictions, type = "l")
```

* And this looks very similar to the observed dynamics of y

* Add prediction intervals as range containing 95% of MCMC samples

```
ci <- apply(xs, 2, quantile, c(0.025, 0.975))
lines(time, ci[1,], lty = "dashed", col = "blue")
lines(time, ci[2,], lty = "dashed", col = "blue")
```

* These are very narrow prediction intervals, so the model appears to be very confident
* But it's important to keep in mind that when fitting the value of `x` at time `t`, the model has access to the value of `y` at time `t`
* And the `y` is present it isn't being estimated, it's just the observed value
* So, will this model forecast well?

### Forecasting

* To make forecasts using a JAGS model we include data for `y` that is `NA`
* This tells the model that we don't know the values and therefore the model estimates them as part of the fitting process
* To make a true forecast we would add one `NA` to the end of `y` for each time step we wanted to forecast
* To hindcast or backcast like we replace the values for `y` that are part of the test set with `NA`
* We'll hindcast, so to do this we'll replace the last year of `y` values with `NA` and then compare the final year of data to our predictions

> Make these changes at top of script and rerun

```
data$y[(length(y)-51):length(y)] = NA
jags.out   <- coda.samples (model = j.model,
                            variable.names = c("y","tau_proc","tau_obs"),
                            n.iter = 10000)
```

* We can see from plotting the predictions that the forecast doesn't look promising
* Without the observed data to influence the estimates of `x[t]` the model predicts little change over the forecast year
* We can directly compare this to the empirical data by adding it to the plot

```
lines(time, y)
```

* So the point estimates don't perform well
* This raises the question of whether the model accurately predicts that it is uncertain when making forecasts
* Plotting the prediction intervals suggests that it does
* They very quickly expand towards zero and the upper limits of the data
