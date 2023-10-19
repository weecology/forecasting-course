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

### Setup

* Starting point from Evaluating Forecasts 1

```r
library(tsibble)
library(fable)
library(feasts)
library(dplyr)

portal_data = read.csv("portal_timeseries.csv") |>
  mutate(month = yearmonth(date)) |>
  as_tsibble(index = month)

train <- filter(portal_data, month < yearmonth("2011 Dec"))
test <- filter(portal_data, month >= yearmonth("2011 Dec"))

ma2_model = model(train, ARIMA(NDVI ~ pdq(0,0,2) + PDQ(0,0,0)))
ma2_forecast = forecast(ma2_model, test)
models = model(train,
               ma2 = ARIMA(NDVI ~ pdq(0,0,2) + PDQ(0,0,0)),
               arima = ARIMA(NDVI))
forecasts = forecast(models, test)
autoplot(forecasts, train) + autolayer(test, NDVI)
accuracy(forecasts, test)
```

### Introduction

* So far we've been dealing with point estimates
* _Draw a time-series forecast with wide and narrow prediction intervals and a point outside the narrow, but inside the wide interval_
* Point estimate comparisons say that these two forecasts are equivalent
* But the forecast with the wider interval is better
* This means we are just comparing the observed value to the mean predicted value
* _Draw a set of axes with two parallel vertical lines_
* _Label 1 prediction and 1 observation_

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

* Called "coverage"
* Want coverage value to be as close to the value of the interval as possible
* So we want it to be close to 0.8

> * **Now it's your turn.**
> * Write code to evaluate the coverage of the seasonal ARIMA model

* Let's compare this result to the uncertainty of the seasonal model

```r
arima_model = model(train, ARIMA(NDVI))
arima_forecast = forecast(arima_model, test)
arima_intervals <- hilo(arima_forecast, level = 80) |>
  unpack_hilo("80%")
in_interval = test$NDVI > arima_intervals$`80%_lower` & test$NDVI < arima_intervals$`80%_upper`
length(in_interval[in_interval == TRUE]) / length(in_interval)
```

* The full ARIMA is better because it is closer to the coverage interval of 0.8

### Scores Incorporating Uncertainty

* Scores that incorporate uncertainty
* Reward prediction intervals that are just wide enough
* Instead of evaluating the mean prediction (point forecast) evaluate the prediction interval
* _Add two sets of intervals on the axes_

* Winkler Score
* Width of the prediction interval + a penalty for points outside the interval

{{< math >}}
\begin{cases}
W = (upper - lower) + \frac{2}{\alpha}(lower - y_t) \mbox{, if } y_t < lower
\\
W = (upper - lower) \mbox{, if } lower < y_t < upper
\\
W = (upper - lower) + \frac{2}{\alpha}(y_t - upper)
\end{cases} \mbox{, if } y_t > upper
{{< /math >}}

* The width component rewards models with narrower prediction intervals
* The penalty rewards models without too many points outside the prediction intervals
* Penalties are calibrated to reward models with best coverage

* Include the Winkler score accuracy by adding two arguments
* A list, with a name for the score a function used to calculate it
* Any arguments that function requires (a prediction interval level in this case)

```r
accuracy(forecasts, test, list(winkler = winkler_score), level = 80)
```

* Winkler requires choosing a single prediction interval
* Ideally we'd include information on lots of prediction intervals
* Instead of evaluting the mean check how likely an observation is given the full predicted distribution
* _Add a distribution to the axes with the mode matching $\hat{y}$_
* The best models most closely match the empirical distribution

* Doing this is technically complicated
* Continuous Rank Probability Score
* Scores each value relative to the predicted cumulative distribution function
* A value far from the mean is penalized less if the uncertainty is high
* We can add this by adding another model to our `list`

```r
accuracy(forecasts, test, list(winkler = winkler_score, crps = CRPS), level = 80)
```

* And if we want to add back some of the other metrics we'd been seeing by default we can do that to

```r
accuracy(forecasts, test, list(winkler = winkler_score, crps = CRPS, mae = MAE), level = 80)
```

### Forecast horizon

* Forecasts generally get worse through time
* Can look at this by comparing the fit at different forecast horizons
* `accuracy` helps us do this with the `by` argument
* Evaluates the score separately for each unique value in a column

```r
accuracies = accuracy(forecasts, test, list(winkler = winkler_score, crps = CRPS, mae = MAE), level = 80, by = c(".model", "month"))
accuracies

ggplot(data = accuracies, mapping = aes(x = month, y = crps, color = .model)) +
  geom_line()
```

* General trend towards increasing error with increasing horizon
