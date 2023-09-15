---
title: "R Tutorial"
weight: 3
type: book
summary: R tutorial on making forecasts from time-series models using the forecast package
show_date: false
editable: true
---

## Video Tutorials

<iframe width="560" height="315" src="https://www.youtube.com/embed/kyPg3jV4pJ8" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

<iframe width="560" height="315" src="https://www.youtube.com/embed/govzki35PIQ" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Text Tutorial

### Setup

```r
library(readr)
library(fable)
library(tsibble) #yearmonth
library(feasts) #ACF
library(dplyr)
library(ggplot2)

raw_data = read_csv("content/data/portal_timeseries.csv", col_types = cols(date = col_date(format = "%m/%d/%Y")))
portal_data <- raw_data |>
  mutate(month = yearmonth(date)) |>
  as_tsibble(index = month)
head(portal_data)
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

```{r}
autoplot(portal_data, NDVI)
```

* Look at the autocorrelation structure

```{r}
portal_data |>
  ACF(NDVI) |>
  autoplot()
```

### Choose and fit models

* Simples model was white noise or the "naive" model:

  > y_t = c + e_t, where e_t ~ N(0, sigma)

* Fit this model using `MEAN()`

```r
avg_model = portal_data |>
  model(MEAN(NDVI)) |>
  report()
```


### Make forecasts

* To make forecasts from a model we ask what the model would predict at the time-step
* For the average model we just need to know what c is, which is just the mean(NDVI_ts)

```r
avg_forecast = avg_model |>
  forecast(h = 12)
```

* Model object has information on
  * Method used for forecasting
  * Values for fitting the model
  * Information about the model
  * Mean values for the forecast

* The expected value, or point forecast, is in `$.mean`

```r
avg_forecast$.mean
```

* Change the number of time-steps in the forecast using h

```r
avg_forecast = forecast(avg_model, h = 50)
```

#### Visualize

* Use the built-in `autoplot` function

```r
autoplot(avg_forecast)
```

* This just shows the forecast
* Let's also add the time series we trained the model on

```r
autoplot(avg_forecast, portal_data)
```

#### Uncertainty

* Important to know how confident our forecast is
* Shaded areas provide this information
* Only variation in e_t is included, not errors in parameters
* We can view these values using `hilo`

```r
avg_forecast |>
  hilo() |>
```
* By default 80% and 95%
* Can change using `level`

```r
hilo(avg_forecast, level = c(50, 95))
autoplot(avg_forecast, level = c(50, 95))
```

* Does it look like 95% of the empirical points will fall within the gray band?
* How do we tell?
* We'll come back to this when we learn how to evaluate forecasts

### Forecasting with more complex models

* Non-seasonal ARIMA
* `y_t = c + b1 * y_t-1 + b2 * y_t-2 + e_t`

> Instructors note: Actually `y_t = (1 - b1 - b2) * c + b1 * y_t-1 + b2 * y_t-2 + e_t` due to non-zero mean

> Have students build a non-seasonal ARIMA model: 36 month horizon, 80 and 99% prediction intervals
> Then discuss.

#### How this forecast works

```r
arima_model = portal_data |>
  model(ARIMA(NDVI ~ pdq(2, 0, 0) + PDQ(0, 0, 0)))
report(arima_model)
arima_forecast = forecast(arima_model)
autoplot(arima_forecast, portal_data)
```

* Forecast one step into the future
* Use the forecast value as `y_t-1` to forecast second step
* Can see the model at work
* First step influenced strongly postively by previous time-step which is high so above mean
* Second step is pulled below negative AR2 parameter
* Gradually reverts to the mean

#### Seasonal ARIMA

* Best model we found last time
* Not much better than non-seasonal when looking at fit to data

```r
seasonal_arima_model = portal_data |>
  model(ARIMA(NDVI ~ pdq(2, 0, 0) + PDQ(1, 0, 0)))
seasonal_arima_forecast = forecast(seasonal_arima_model, h = 36)
autoplot(seasonal_arima_forecast, portal_data)
```
* Do you think it might be a better model for forecasting?
* We'll find out how to tell next week.

### Fitting the best model and forecasting

* If we want to fit the best version of a particular model we can remove the specification of the time lag dependency

```r
best_arima_model = portal_data |>
  model(ARIMA(NDVI))
best_arima_model
```

* So the best model has a third order moving average component and a first order seasonal auto-regressive component
* The predictions are very similar to our other seasonal model

```r
best_arima_forecast = forecast(seasonal_arima_model, h = 36)
autoplot(best_arima_forecast, portal_data)
```

## Incorporating external co-variates

* NDVI should be related to rain, so how do we add NDVI to this kind of model
* Build a model like last time

```r
rain_model = model(portal_data, ARIMA(NDVI ~ rain + pdq(2, 0, 0) + PDQ(1, 0, 0)))
rain_model = model(portal_data, ARIMA(NDVI ~ rain))
```

* To forecast with covariates we need forecasts for those covariates
* The `new_data()` function lets us create a new `tsibble` starting at the end of the time-series from another `tsibble`

TODO: replace with actual future end of time-series rain values
```r
future_rain = new_data(portal_data, 8) |>
  mutate(rain = mean(portal_data$rain))
```

* Error in these forecasts can be an issue can forecasting with covariates harder

```r
rain_forecast = forecast(rain_model, new_data = future_rain)
autoplot(rain_forecast, portal_data)
```




```r
fit <- model(portal_data, ARIMA(NDVI ~ fourier(K=2) + PDQ(0,0,0)))
forecasted <- forecast(fit)
autoplot(forecasted)
autoplot(forecasted, portal_data)
```

## Forecasts from cross-sectional approach

* Just predictor variables, not time-series component
* Predict NDVI based on rain data
* Southern Arizona's vegetation response to precip depends on the season so want to include that in the model

* Visualize the relationship

```r
portal_data <- mutate(portal_data)
ggplot(portal_data, aes(x = rain, y = NDVI)) +
  geom_point() +
  geom_smooth(method = "lm")
```

```r
gg_subseries(portal_data, NDVI)
```

* Fit a linear model

```r
rain_model = lm('monsoon_ndvi ~ monsoon_rain', data = monsoon_data)
```

```r
rain_model = model(portal_data, TSLM(NDVI ~ rain + season()))
```

* Make a forecast using that model
* Requires forecast values for precipition

```r
rain_forecast = forecast(rain_model, newdata = data.frame(monsoon_rain = c(120, 226, 176, 244), ))
plot(rain_forecast)
```

```r
forecasts = tsibble(rain = c(120, 226, 176, 244), month = yearmonth(c("2014-12", "2015-01", "2015-02", "2015-03")))
rain_forecast = forecast(rain_model, new_data = forecasts)
autoplot(rain_forecast, portal_data)
```

