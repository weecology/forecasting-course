---
title: "R Tutorial"
weight: 3
type: book
summary: "Complex Time-Series Models in R 1"
show_date: false
editable: true
---

*Material heavily influenced by [Nicholas J Clark](https://researchers.uq.edu.au/researcher/15140)'s excellent course on
[Ecological forecasting with mvgam and brms](https://nicholasjclark.github.io/physalia-forecasting-course/)*

## Installation

* Check if your installation worked

```r
cmdstan_version()
```

If this returns a version number like `"2.32.2"` then things are working properly.

## Introduction

* So far we've developed relatively simple time-series models
* Linear time-series dependance
* Linear responses to environmental factors
* Normally distributed errors
* No model of observation error
* No interactions between species
* Can't handle missing data
* Most of these are violated in ecological systems
* So start fitting more complex models

## mvgam

* Models like this are not trivial to fit
* Use [STAN](https://mc-stan.org/)
* Uses MCMC to explore parameter space to fit the model using Bayesian methods
* Typically requires learning a separate language - STAN is it's own language
* This lets you write arbitrarily complex models, but really needs a course in Bayesian methods
* So, we're going to use an R package called `mvgam` to implement our models
* We're going to use it because it's the simplest way to make complex time-series model in R

```r
library(mvgam)
library(dplyr)
```

## Data

* Data on the population dynamics of the Desert Pocket Mouse

```r
pp_data <- read.csv("content/data/pp_abundance_timeseries.csv") 
```

* mvgam requires it's own specific data format and doesn't currently work with tsibbles
* Requires a `time` variable be present in the data to index temporal observations starting at 1.
* Our `newmoonnumber` indexes the monthly samples so convert it to a start at 1
* Also requires a a `series` variable, which needs to be a factor
* Helps when analyzing multiple time series at once (e.g., multiple species)

```r
pp_data <- read.csv("content/data/pp_abundance_timeseries.csv") |>
  mutate(time = newmoonnumber - min(newmoonnumber) + 1) |>
  mutate(series = as.factor('PP')) |>
  select(time, series, abundance, mintemp, cool_precip)
```

* 124 months of data
* Reserve 24 for testing

```r
data_train <- filter(pp_data, time <= 100) 
data_test <- filter(pp_data, time > 100)
```

## Simply time-series models in mvgam

* mvgam comes with a time-series visualization function like we had in `fable`

```r
plot_mvgam_series(data = pp_data, y = 'abundance')
```

* Start by building something similar to what we've done before with the number of desert pocket mice
* Model has an exogenous driver - minimum temperature
* An autoregressive component
* Gaussian error

{{< math >}}
$$y_t = c + \beta_1 x_{1,t} + \beta_2 y_{t-1} + \mathcal{N}(0,\sigma^{2})$$
{{< /math >}}

* Which can also be written as

{{< math >}}
$$y_t = \mathcal{N}(\mu,\sigma^{2})$$
$$u_t =  c + \beta_1 x_{1,t} + \beta_2 y_{t-1}$$
{{< /math >}}

* Fit using the `mvgam()` function
* Follows a Base R model structure so start with the model formula
* Instead of including the AR component in the model we add a separate `trend_model` argument
* We'll use `"AR1"`
* Specify the error `family = gaussian()`
* Then we can specify the data for fitting the model and the data for making/evaluating forecasts 

```r
baseline_model = mvgam(abundance ~ mintemp,
                       trend_model = "AR1",
                       family = gaussian(),
                       data = data_train)
```

### Bayesian model fitting

* That's a lot of output for fitting a model
* What's going on?
* It is difficult to fit more complex time-series models
* One way to fit them is using Bayesian methods
* These methods iteratively search parameter space for the best parameter values
* Using something called Markov Chain Monte Carlo (MCMC)
* _Draw 2D parameter search on board_
* The `"Iteration"` lines are telling us that the model is working it's way through this process
* The `"Warmup"` lines are iterations that are used to get in the right parameter space but then thrown away
* The `"Sampling"` lines are iterations that serve as samples for each of the parameters we are fitting
* Having multiple samples gives us the uncertainty in the parameters by looking at how variable those values are
* The different `"chains"` are because we typically go through this process multiple times to check than we are converging to the right values
* We can look at the result of this fitting process using `mcmc_plot`

```r
mcmc_plot(baseline_model, type = "trace", variable = c("mintemp", "ar1[1]", "sigma[1]"))
```

* The red lines at the bottom are providing the same information as the warnings when we fit the model
* Something isn't quite right
* The model isn't converged yet
* We could try running it longer
* But part of what's going on here is that we're using a poorly specified model given the data because we've assumed Gaussian errors
* So let's look at the model & forecast and then keep going

* We can look at the model structure using `summary()`

```r
summary(baseline_model)
```

* If we plot the model we'll get some diagnostic plots

```r
plot(baseline_model)
```

* The residuals are normally distributed
* And the residual autocorrelation isn't significant

### Bayesian model forecasting

* So let's look at the forecasts
* To make forecasts for Bayesian models we include data for `y` that is `NA`
* This tells the model that we don't know the values and therefore the model estimates them as part of the fitting process
* Handy because it means these models can handle missing data
* To make a true forecast one `NA` is added to the end of `y` for each time step we want to forecast
* To hindcast the values for `y` that are part of the test set are replaced with `NA`

* We can do this in mvgam using the `forecast()` function

```r
baseline_forecast = forecast(baseline_model, newdata = data_test)
```

* This is slow because it is refitting the model
* We can then plot the forecast

```r
plot(baseline_forecast)
```
 
* These forecasts look similar to those we generated using `fable`
* Prediction intervals are regularly negative because we've assumed normally distributed error
* Actual counts can only be non-negative integers: 0, 1, 2...


## Modeling count data

* To model count data explicitly we need observations that are integers
* We can use use Poisson error to accomplish this
* Instead of $N(\mu, \sigma^2)$

{{< math >}}
$$y_t = \mathrm{Pois}(\mu_t)$$
{{< /math >}}


* The Poisson distribution generates only integer draws based on a mean
* If the mean is 1.5 sometimes you'll draw a 1, sometimes a 2, sometimes a 0, etc.

* $\mu_t$ can be a decimal
* We could expect an average of 4.5 rodents based on the environment even though we can only observe an integer number
* But $\mu_t$ does have to be positive because we can't reasonably expect to see negative rodents
* To handle this we use a log link function to give us only positive values of $\mu_t$
* The log link means that instead of modeling $\mu_t$ directly we model $log(\mu_t)$

{{< math >}}
$$y_t = \mathrm{Pois}(\mu_t)$$
$$\mathrm{log(\mu_t)} = c + \beta_1 x_{1,t} + \beta_2 y_{t-1} + \mathcal{N}(0,\sigma^{2})$$
{{< /math >}}

```r
poisson_model = mvgam(abundance ~ mintemp,
                      trend_model = "AR1",
                      family = poisson(link = "log"),
                      data = data_train)
```

* No more warnings at the end
* Look at the model

```r
summary(poisson_model)
```

```r
plot(poisson_model)
```

* Model structure looks OK, be we still have some residual seasonal lag we haven't captured

* We can visualize the environmental component of the model using `type = pterms`
* `pterms` is short for "parametric terms"
* Which is what we have since we modeled a linear relationship with a fixed slope

```r
plot(poisson_model, type = 'pterms')
```

* This shows a linear relationship
* But that is the relationship between `log(abundance)` and `mintemp`
* So let's look at the actual relationship

```r
plot_predictions(poisson_model, condition = "mintemp")
```

* Since `log(abundance)` is linearly related to temperature
* This makes the response to untransformed abundance exponential
* That doesn't feel right

* Now let's look at the forecast

```r
poisson_forecast = forecast(poisson_model, newdata = data_test)
plot(poisson_forecast)
```

* Now all of our predictions are positive!
* But while the point estimates seem reasonable the uncertainties see really large

## Non-linear responses

* Linear relationships between abundance and the environment are unlikely to hold over reasonable environmental gradients
* Typically we think of species as have some optimal environmental value
* With decreasing performance as you move away from that environmental value in both directions
* *Draw standard performance response curve*
* We can model using in `mvgam` by using a Generalized Additive Model that fits a smoother to the relationship

```r
poisson_gam_model = mvgam(abundance ~ s(mintemp, bs = 'bs', k = 5),
                          trend_model = "AR1",
                          family = poisson(link = "log"),
                          data = data_train)
```

* Visualizing the environmental component of the model shows that it is now non-linear

```r
plot(poisson_gam_model, type = 'smooths')
```

* It doesn't have an optimal value, but it does saturate
* This means that once it's warm enough then temperature stops influencing abundance
* This is the smooth on `log(abundance)`
* Look at the relationship with raw abundance

```r
plot_predictions(poisson_gam_model, condition = "mintemp")
```

* The GAM now gives us a more realistic response to temperature
* When it's cold abundance is always near zero
* Even if gets a little less cold
* Abundance then increases with temperature
* But starts to asymptote at higher temperatures

* How does this influence the forecasts

```r
poisson_gam_forecast = forecast(poisson_gam_model, newdata = data_test)
plot(poisson_gam_forecast)
```

* The extremely wide prediction intervals have been reduced substantially
* If we look at the diagnostics 

```r
plot(poisson_gam_model)
```

* We can also see that the residual season autocorrelation is improved

## State space models

* To add an explicit observation model we use the 

```r
state_space_model = mvgam(abundance ~ 1,
                          trend_formula = ~ s(mintemp, bs = 'bs', k = 5),
                          trend_model = "AR1",
                          family = poisson(link = "log"),
                          data = data_train)
state_space_forecast = forecast(state_space_model, newdata = data_test)
plot(state_space_forecast)
```

## Some notes on Bayesian forecasting

* Since forecasting and model fitting are all part of the same process in Bayesian models
* We can also just incorporate the test data directly in the model fitting step

```r
poisson_gam_model = mvgam(abundance ~ s(mintemp, bs = 'bs', k = 5),
                      trend_model = "AR1",
                      family = poisson(link = "log"),
                      data = data_train,
                      newdat = data_test)
```

* And then plot forecasts directly from the model object

```r
plot(poisson_gam_model, type = "forecast")
```

* If you want to know why we're using `mvgam`
* Here's what the code to build this model directly in STAN looks like

```r
code(poisson_gam_model)
```

## Evaluation and comparison

* To evaluate the forecasts from `mvgam` we can use the `score` function

```r
scores <- score(poisson_gam_forecast)
```

* The output shows us two things we've seen before
* Whether or not each observed value falls within the prediction interval
* With a default prediction interval of 90%
* And the continuous rank probability score
* Other scores are available by changing the optional `score` argument
* We can also change the prediction interval using the `interval_width` argument

```r
scores <- score(poisson_gam_forecast, interval_width = 0.5)
```

* If we want to calculate the coverage we can sum 

```r
sum(scores$PP$in_interval) / nrow(scores$PP)
```