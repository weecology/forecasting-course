---
title: "R Tutorial"
weight: 3
type: book
summary: R tutorial on making forecasts from time-series models using the forecast package
show_date: false
editable: true
---

## Video Tutorials

*Video tutorials are based on the old `forecast` package.*
*Text tutorials have been updated to use `fable` and associated packages.*

<iframe width="560" height="315" src="https://www.youtube.com/embed/kyPg3jV4pJ8" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

<iframe width="560" height="315" src="https://www.youtube.com/embed/govzki35PIQ" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Text Tutorial

### Setup

* Load the packages

```r
library(tsibble)
library(fable)
library(feasts)
library(dplyr)
```

* Load the data

```r
pp_data = read.csv("pp_abundance_by_month.csv") |>
  mutate(month = yearmonth(month)) |>
  as_tsibble(index = month)
pp_data
```

### Steps in forecasting

1. Problem definition
2. Gather information
3. Exploratory analysis
4. Choosing and fitting models
5. Make forecasts
6. Evaluate forecasts

### Exploratory analysis

* Process we went through over the last few weeks
* Look at the time series

```r
gg_tsdisplay(pp_data, abundance)
```

### Choose and fit models

* Start with simple model AR1 model:

{{< math >}}
$$y_t = c + \beta_1 y_{t-1} + \epsilon_t$$
{{< /math >}}

* Fit this model using `ARIMA()`
* Use `pdq()` AR order to 1, differencing to 0, MA to 0
* Use `PDQ()` to set all seasonal components to 0

```r
ar1_model = model(pp_data, ARIMA(abundance ~ pdq(1,0,0) + PDQ(0,0,0)))
report(ar1_model)
```

### Make forecasts

* To make forecasts from a model we ask what the model would predict at the time-step
* For the AR1 model this depends on $c$, $\beta_1$, $y_{t-1}$, and $\epsilon_t$

```r
ar1_forecast = forecast(ar1_model)
ar1_forecast
```

* Forecast object has information on
  * Model used for forecasting
  * Time step being forecast
  * The expected value, or point forecast, is in `$.mean`
  * And information about the error term in `abundance <dist>`

* Change the number of time-steps in the forecast using h (default to 2 seasonal cycles)

```r
ar1_forecast = forecast(ar1_model, h = 36)
```

#### Visualize

* Visualize using `autoplot`

```r
autoplot(ar1_forecast)
```

* This just shows the forecast
* Let's also add the time series we trained the model on

```r
autoplot(ar1_forecast, pp_data)
```

* Forecast one step into the future
* Use the forecast value as $y_{t-1}$ to forecast second step
* Can see the model at work
* First step influenced strongly low value at the previous time-step
* Abundance is zero, so predicted value is $c$, or about 6
* Second step value of $y_{t-1}$ is the value we just forecast, 6
* So our new predict value is roughly 6 + 0.8 * 6, so about 11
* Gradually reverts to the mean

#### Uncertainty

* Lots of possible outcomes for this forecast depending on random error
* We can look at this by using the `bootstrap` setting

```r
ar1_forecast = forecast(ar1_model, bootstrap = TRUE, times = 1)
autoplot(ar1_forecast, pp_data)
```

* This lets us run a single forecast including a randomly chosen value for $epsilon_t$ at teach time step
* Let's run it a few times

* Want to quantify how variable we expect these possible forecast outcomes are
* If we set `times` to `1000`

```r
ar1_forecast = forecast(ar1_model, bootstrap = TRUE, times = 1000)
autoplot(ar1_forecast, pp_data)
```

* Shaded areas provide this information
* These are the "prediction intervals"
* The region within which some percentage of our forecast values will occur
* By default 80% and 95%
* Can change using `level`

```r
autoplot(ar1_forecast, pp_data, level = c(50, 80))
```

* With `bootstrap = TRUE` `fable` makes 1000 individual forecasts
* Drawing an error from the normal distribution at each time step
* Shows the ranges that contain the appropriate percentage of predicts
* For many models the values can be calculated without making separate forecasts
* This is the default behavior

```r
ar1_forecast = forecast(ar1_model)
autoplot(ar1_forecast, pp_data, level = c(50, 80))
```

* Only variation in $\epsilon_t$ is included, not errors in parameters
* We can view access these values using `hilo`

```r
ar1_forecast |>
  hilo() |>
  print(width = 90)
```

```r
ar1_forecast |>
  hilo(level = c(50, 80)) |>
  print(width = 90)
```

* Does it look like 80% of the empirical points will fall within the lighter band?
* How do we tell?
* We'll come back to this when we learn how to evaluate forecasts

#### Full ARIMA

```r
arima_model = model(pp_data, ARIMA(abundance))
report(arima_model)
```

* Best model has a 1st order auto-regressive component and 1st and 2nd order seasonal auto-regressive components

```r
arima_forecast = forecast(arima_model, h = 36)
autoplot(arima_forecast, pp_data, level = 80)
```

#### Incorporating external co-variates

* We know from last time that `mintemp` is a good predictor
* Build a model like last time

```r
arima_exog_model = model(pp_data, ARIMA(abundance ~ mintemp))
report(arima_exog_model)
```

* Our model takes the form

{{< math >}}
$$y_t = c + \beta_1 x_{1,t} + \eta_t$$
$$\eta_t = \beta_2 \eta_{t-1} + \theta_1 \epsilon_{t-1} + \epsilon_t$$
{{< /math >}}

* So we need values of $x_{1,t}$ to make predictions for time step $t$
* To forecast with covariates we need forecasts for those covariates

* Since our time-series ended in 2020 we'll use the observed values for the next two years

```r
climate_forecasts = read.csv("content/data/pp_future_climate.csv") |>
  mutate(month = yearmonth(month)) |>
  as_tsibble(index = month)
climate_forecasts
```

* This data needs to be a `tsibble` with the same index
* But future dates and all of the covariates included in the model

```r
arima_exog_forecast = forecast(arima_exog_model, new_data = climate_forecasts)
autoplot(arima_exog_forecast, pp_data)
```

* Our point estimates now go below 0
* Possible because of the exogenous driver, but not desireable
* Otherwise looks reasonable

* Next time: how do we know if they are good or not?
