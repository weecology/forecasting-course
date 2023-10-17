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

### Hindcasting & Visual Evaluation

<iframe width="560" height="315" src="https://www.youtube.com/embed/ODmOr76QnWc" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

### Quantitative Evaluation of Point Estimates

<iframe width="560" height="315" src="https://www.youtube.com/embed/h0Igk8uOXKc" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

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

### Evaluating forecast model fits

* We can fit multiple models to a single dataset and then compare them

```r
portal_models = model(
  portal_data,
  ma2 = ARIMA(NDVI ~ pdq(0,0,2) + PDQ(0,0,0)),
  arima = ARIMA(NDVI), 
  arima_exog = ARIMA(NDVI ~ rain)
)
portal_models
glance(portal_models)
```

* But comparisons typically rely on IID residuals
* We know we don't have this for TSLM, so it's likelihood and IC values are invalid
* These comparisons also typically tell us about 1 step ahead forecasts and we may care about more steps

* So it's best to evaluate forecasts themselves
* Ideally we make a forecast for the future, collect new data, and then see how well the forecast performed
* This is the gold standard, but it requires waiting for time to pass
* Therefore, most work developing forecasting models focuses on "hindcasting" or "backcasting"

### Hindcasting

* Split existing time-series into 2 pieces
* Fit to data from the first part of an observed time-series
* Test on data from the end of the observed time-series
* For those of you familiar with cross-validation, this is a special form of cross-validation that accounts for autocorrelation and the fact that time is directional

#### Test and training data

* To split the time-series into training data and testing data we use the `filter` function from dplyr
* 1st argument is the tsibble
* 2nd argument is the condition
* Data runs through the end of 2019, so use up to 2017 for training data

```r
train <- filter(portal_data, month < yearmonth("2011 Dec"))
test <- filter(portal_data, month >= yearmonth("2011 Dec"))
```

#### Build model on training data

* We then fit our model to the training data
* Let's start with our non-seasonal MA2 model

```r
ma2_model = model(train, ARIMA(NDVI ~ pdq(0,0,2) + PDQ(0,0,0)))
```

#### Make forecast for the test data

* We then use that model to make forecasts for the test data
* We reserved 3 years of test data so we want to forecasts 36 months into the future

```r
ma2_forecast = forecast(ma2_model, h = 36)
```

### Visual Evaluation

* Start by evaluating the performance of the forecast visually
* Remember that we can plot the data the model is fit to and the forecast using `autoplot`

```r
autoplot(ma2_forecast, train)
```

* If we want to add the observations from the test data we can do this by adding `autolayer`

```r
autoplot(ma2_forecast, train) + autolayer(test, NDVI)
```

* This adds a new layer to our the `ggplot` objection created by `autoplot` with the test data
* How does it look?

### Quantitative Evaluation

#### Point Estimates

* Quantitative evaluation of point estimates is based on forecast errors

{{< math >}}
$$\epsilon_{t+h} = y_{t+h} - \hat{y}_{t+h}$$
{{< /math >}}

* `accuracy` function shows a number of common measures of forecast accuracy
  * 1st argument: forecast object from model on training data
  * 2nd argument: test data time-series

```r
accuracy(ma2_forecast, test)
```

* RMSE is a common method for evaluating forecast performance


> * **Now it's your turn.**
> * Write code to quantify the accuracy of the full ARIMA model

* I'm going to add the full ARIMA in to my existing code

```r
models = model(train,
               ma2 = ARIMA(NDVI ~ pdq(0,0,0) + PDQ(0,0,0),
               arima = ARIMA(NDVI))
forecasts = forecast(models, test)
autoplot(forecasts, train) + autolayer(test, NDVI)
accuracy(forecasts, test)
```

* autoplot graphs both sets of forecasts for comparison 
* accuracy shows all metrics for both forecasts for comparison 
* So the full ARIMA is better on point estimates

#### Incorporating Uncertainty

##### Coverage

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

##### Scores Incorporating Uncertainty

* Scores that incorporate uncertainty
* Reward prediction intervals that are just wide enough

* Winkler Score
* Width of the prediction interval + a penalty for points outside the interval
* The width component rewards models with narrower prediction intervals
* The penalty rewards models without too many points outside the prediction intervals
* Penalties are calibrated to reward models with best coverage

```r
models = model(train,
               ma2 = ARIMA(NDVI ~ pdq(0,0,0) + PDQ(0,0,0),
               arima = ARIMA(NDVI))
forecasts = forecast(models, test)
autoplot(forecasts, train) + autolayer(test, NDVI)
accuracy(forecasts, test, list(winkler = winkler_score), level = 80)
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
