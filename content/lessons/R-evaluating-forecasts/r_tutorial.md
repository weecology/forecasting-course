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
* *Draw forecast showing errors*

{{< math >}}
$$\epsilon_{t+h} = y_{t+h} - \hat{y}_{t+h}$$
{{< /math >}}

* This gives us one error for each forecast horizon
* Need a way to combine them
* Easiest is to take the average across all horizons
* Called the Mean Error

{{< math >}}
$$ME = mean(y_{t+h} - \hat{y}_{t+h})$$
{{< /math >}}

* But big positive errors and big negative errors cancel out, so bad predictions could have low ME
* To focus on the magnitude of the error we most commonly use a metric called the Root Mean Squared Error
* Square the error, resulting in all errors having a positive value

{{< math >}}
$$(y_{t+h} - \hat{y}_{t+h})^2$$
{{< /math >}}

* Then take the mean

{{< math >}}
$$mean[(y_{t+h} - \hat{y}_{t+h})^2]$$
{{< /math >}}

* This is the Mean Squared Error
* But the units are now in terms of the response squared, which can be hard to interpret
* So we take the square Root

{{< math >}}
$$RMSE = \sqrt{mean[(y_{t+h} - \hat{y}_{t+h})^2]}$$
{{< /math >}}

* Which gives us a measure of the average error in the units of the response variable

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
               ma2 = ARIMA(NDVI ~ pdq(0,0,2) + PDQ(0,0,0)),
               arima = ARIMA(NDVI))
forecasts = forecast(models, test)
autoplot(forecasts, train, level = 50, alpha = 0.75)
  + autolayer(test, NDVI)
accuracy(forecasts, test)
```

* autoplot graphs both sets of forecasts for comparison 
* accuracy shows all metrics for both forecasts for comparison 
* So the full ARIMA is better on point estimates
