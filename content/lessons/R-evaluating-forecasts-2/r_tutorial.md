---
title: "R Tutorial"
weight: 3
type: book
summary: R tutorial on evaluating forecasts and forecast models
show_date: false
editable: true
---

*Video tutorials are based on the old `forecast` package.*
*Text tutorials have been updated to use `fable` and associated packages.*

## Video Tutorials

### Evaluating Uncertainty Using Coverage

<iframe width="560" height="315" src="https://www.youtube.com/embed/hGlnIVYFUgg" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

### Evaluating How Forecast Accuracy Changes With Forecast Horizon

<iframe width="560" height="315" src="https://www.youtube.com/embed/DHOfUYLnshA" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Written Tutorial

### Steps in forecasting

1. Problem definition
2. Gather information
3. Exploratory analysis
4. Choosing and fitting models
5. Make forecasts
6. **Evaluate forecasts**

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
portal_data = read.csv("content/data/portal_timeseries.csv") |>
  mutate(month = yearmonth(date)) |>
  as_tsibble(index = month)
portal_data
```

### Coverage

* How do we think about uncertainty
* We have these blue prediction intervals, but how do we evalute them
* Prediction Interval: range of values in which a percentage of observations
  should occur
* 80% prediction interval is the range of values we expect 80% of observations to fall between

```r
ma2_intervals <- hilo(ma2_forecast, level = 80) |>
  unpack_hilo("80%")
ma2_intervals$`80%_lower`
ma2_intervals$`80%_upper`
```

* We can find the observed points that occur in this range by checking for points that match both conditions
* So we want NDVI to be greater than lower and less than upper

```r
in_interval <- test$NDVI > ma2_intervals$`80%_lower` & test$NDVI < ma2_intervals$`80%_upper`
```

* We can then determine what proportion of these values are `TRUE`, i.e., fall in the prediction interval

```r
length(in_interval[in_interval == TRUE]) / length(in_interval)
```

* We want this value to be as close to the value of the interval as possible, so we want it to be close to 0.8

> * **Now it's your turn.**
> * Write code to evaluate the coverage of the seasonal ARIMA model

* Let's compare this result to the uncertainty of the seasonal model

```r
in_interval <- test$NDVI > arima_intervals$`80%_lower` & test$NDVI < arima_intervals$`80%_upper`
length(in_interval[in_interval == TRUE]) / length(in_interval)
```

* The full ARIMA is better because it is closer to the coverage interval of 0.8

### Scores Incorporating Uncertainty

* Scores that incorporate uncertainty
* Reward prediction intervals that are just wide enough

* Winkler Score
* Width of the prediction interval + a penalty for points outside the interval
* The width component rewards models with narrower prediction intervals
* The penalty rewards models without too many points outside the prediction intervals
* Penalties are calibrated to reward models with best coverage

```r
accuracy(forecasts, test, list(winkler = winkler_score), level = 80)
```

* Winkler requires choosing a single prediction interval
* Ideally we'd include information on lots of prediction intervals
* Instead of evaluting the mean check how closely the entire distribution of the residuals matches the predicted distribution
* _Add two sets of distributions to the axes with modes matching means_
* The best models most closely match the empirical distribution

* Doing this is technically complicated
* Continuous Rank Probability Score
* Scores each value relative to the predicted cumulative distribution function
* A value far from the mean is penalized less if the uncertainty is hight

```r
accuracy(forecasts, test, list(winkler = winkler_score, crps = CRPS), level = 80)
```

### Forecast horizon

* Forecasts generally get worse through time
* Can look at this by comparing the fit at different forecast horizons
* Plot the error for each individual forecast for both models

```r
plot(sqrt((ma2_forecast$.mean - test$NDVI)^2))
lines(sqrt((ma2_forecast$.mean -  test$NDVI)^2), col = 'blue')
```

* General trend towards increasing error with increasing horizon
