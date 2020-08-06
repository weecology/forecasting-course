---
title: "R Tutorial"
weight: 3
description: R tutorial on evaluating forecasts using the forecast package
---

# Evaluating forecasts

## Steps in forecasting

1. Problem definition
2. Gather information
3. Exploratory analysis
4. Choosing and fitting models
5. Make forecasts
6. **Evaluate forecasts**

## Setup

```r
library(forecast)
library(ggplot2)

data = read.csv("data/portal_timeseries.csv", stringsAsFactors = FALSE)
head(data)
NDVI_ts = ts(data$NDVI, start = c(1992, 3), end = c(2014, 11), frequency = 12)
plot(NDVI_ts)
acf(NDVI_ts)
```

## Hindcasting

* Split existing time-series into 2 pieces
* Fit to data from the first part of an observed time-series
* Test on data from the end of the observed time-series

### Test and training data

* Split time-series into pieces using `window`
* First argument is the time-series
* Additional arguments for start and end dates

```r
NDVI_train <- window(NDVI_ts, end = c(2011, 11))
NDVI_test <- window(NDVI_ts, start = c(2011, 12))
```

### Build model on training data

```r
arima_model = auto.arima(NDVI_train, seasonal = FALSE)
```

### Make forecast for the test data

```r
arima_forecast = forecast(arima_model, h = 36)
```

## Visual Evaluation

* Plot the full observed time-series and the forecast

```r
plot(arima_forecast)
lines(NDVI_test)
```

* In the right general area, but doesn't follow ups and downs

* Observed-predicted plots
  * Predict value on x
  * Observed value on y
  * A 1:1 line showing when they are equal

```r
plot(arima_forecast$mean, NDVI_test)
plot(as.vector(arima_forecast$mean), as.vector(NDVI_test))
abline(0, 1)
```

* Predicted value very quickly converges to mean
* Not much relationship between observed and predicted values
* Because no variation in predicted values

## Quantitative Evaluation

* `accuracy` function shows a number of common measures of forecast accuracy
  * 1st argument: forecast object from model on training data
  * 2nd argument: test data time-series

```r
accuracy(arima_forecast, NDVI_test)
```

* Shows errors on both training and test data
* Errors higher on test than training because training data is being fit
* RMSE common method for evaluating forecast performance as is the Brier score
  (RMSE^2)

> Visualize and quantify the accuracy of the seasonal ARIMA model

```
seasonal_arima_model = auto.arima(NDVI_train)
seasonal_arima_forecast = forecast(seasonal_arima_model, h = 36)
plot(seasonal_arima_forecast)
lines(NDVI_test)
plot(as.vector(seasonal_arima_forecast$mean), as.vector(NDVI_test))
abline(0, 1)
accuracy(seasonal_arima_forecast, NDVI_test)
```

* Compare accuracy to non-seasonal ARIMA

```r
accuracy(arima_forecast, NDVI_test)
```

* Looks better, but how do we test the uncertainty estimate

### Coverage

* Prediction Interval: range of values in which a percentage of observations
  should occur
* 80% prediction interval is the range of values we expect 95% of future points
  to fall between

```
arima_forecast$lower
in_interval <- arima_forecast$lower[,1] < NDVI_test & arima_forecast$upper[,1] > NDVI_test
sum(in_interval) / length(NDVI_test)
```

* Compare to seasonal

```
in_interval_season <- seasonal_arima_forecast$lower[,1] < NDVI_test & seasonal_arima_forecast$upper[,1] > NDVI_test
sum(in_interval_season) / length(NDVI_test)
```

* Seasonal is better because it is closer to the coverage interval of 0.8

## Forecast horizon

* Forecasts generally get worse through time
* Can look at this by comparing the fit at different forecast horizons
* Plot the error for each individual forecast for both models

```
plot(sqrt((arima_forecast$mean - NDVI_test)^2))
lines(sqrt((seasonal_arima_forecast$mean -  NDVI_test)^2), col = 'blue')
```

* General trend towards increasing error with increasing horizon