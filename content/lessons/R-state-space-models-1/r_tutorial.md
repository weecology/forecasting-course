---
title: "R Tutorial Part 1"
weight: 3
summary: "State space modeling tutorial: Part 1"
show_date: false
---

*Adapted from
the
[state space modeling activity](https://github.com/EcoForecast/EF_Activities/blob/master/Exercise_06_StateSpace.Rmd) from
Michael Dietz's
excellent
[Ecological Forecasting book](https://www.amazon.com/Ecological-Forecasting-Michael-C-Dietze/dp/0691160570)*

> JAGS needs to be installed: https://sourceforge.net/projects/mcmc-jags/files/
> rjags R package needs to be installed

## Video Tutorial

<iframe width="560" height="315" src="https://www.youtube.com/embed/T3ZGhXAO6VY" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Text Tutorial

### State space models

* Time-series model
* Only first order autoregressive component
* Separately model
  * the process model - how the system evolves in time or space
  * the observation model - observation error or indirect observations
* Estimates the true value of the underlying **latent** state variables

### Data

* Google Flu Trends data for Florida
* [https://raw.githubusercontent.com/EcoForecast/EF_Activities/master/data/gflu_data.txt](https://raw.githubusercontent.com/EcoForecast/EF_Activities/master/data/gflu_data.txt)

```{r}
gflu = read.csv("https://raw.githubusercontent.com/EcoForecast/EF_Activities/master/data/gflu_data.txt", skip=11)
time = as.Date(gflu$Date)
y = gflu$Florida
plot(time,y,type='l',ylab="Flu Index",lwd=2,log='y')
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

* Google searches aren't perfect measures of the number of flu cases (which are
  what should be changing in the process model and what we care about)
* So model this imperfect observation

y_t = x_t + e_t

* Can be much more complicated


### rjags

* Models like this are not trivial to fit
* Use [JAGS (Just Another Gibbs Sampler)](http://mcmc-jags.sourceforge.net)
* Gibbs samplers are a way of exploring parameter space to fit the model using
  Bayesian methods.
* The `rjags` library use R to call JAGS.

```{r}
library(rjags)
```

### JAGS Model

* JAGS code to describe the model
* Store as string in R
* Three components
  * data/error model
    * relates observed data (y) to latent variable (x)
    * Gaussian obs error
  * process model
    * relates state of the system at *t* to the state at *t-1*
    * random walk (x_t = x_t-1 + e_t)
  * priors
* Bayesian methods need priors, or starting points for model fitting

```{r}
RandomWalk = "
model{
  
  #### Data Model
  for (t in 1:n){
    y[t] ~ dnorm(x[t], tau_obs)
  }
  
  #### Process Model
  for (t in 2:n){
    x[t]~dnorm(x[t-1], tau_proc)
  }
  
  #### Priors
  x[1] ~ dnorm(x_ic, tau_ic)
  tau_obs ~ dgamma(a_obs, r_obs)
  tau_proc ~ dgamma(a_proc, r_proc)
}
"
```

* Data and priors as a list

```{r}
data <- list(y=y,
             n=length(y),
             x_ic=1000,
             tau_ic=1,
             a_obs=1,
             r_obs=1,
             a_proc=1,
             r_proc=1)
```

* Starting point of parameters

```{r}
init <- list(list(tau_proc=1/var(diff(y)),tau_obs=5/var(y)))
```

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
