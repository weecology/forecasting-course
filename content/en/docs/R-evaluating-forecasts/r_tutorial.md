---
title: "R Tutorial"
weight: 3
description: R tutorial on evaluating forecasts using the forecast package
---

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

```r
library(forecast)
library(ggplot2)

data = read.csv("data/portal_timeseries.csv")
NDVI_ts = ts(data$NDVI, start = c(1992, 3), end = c(2014, 11), frequency = 12)
tsdisplay(NDVI_ts)
```

### Hindcasting

* There are two approaches to evaluating forecasts
* One is to make a forecast for the future, collect new data, and then see how well the forecast performed
* This is the gold standard, but it requires waiting for time to pass
* Therefore, most work developing forecasting models focuses on "hindcasting" or "backcasting"
* Split existing time-series into 2 pieces
* Fit to data from the first part of an observed time-series
* Test on data from the end of the observed time-series
* For those of you familiar with cross-validation, this is a special form of cross-validation that accounts for autocorrelation and the fact that time is directional

#### Test and training data

* To split the time-series into training data and testing data we use the `window` function
* First argument is the time-series
* Additional arguments for start and end dates

```r
NDVI_train <- window(NDVI_ts, end = c(2011, 11))
NDVI_test <- window(NDVI_ts, start = c(2011, 12))
```

#### Build model on training data

* We then fit our model to the training data
* Let's start with a non-seasonal ARIMA

```r
arima_model = auto.arima(NDVI_train, seasonal = FALSE)
```

#### Make forecast for the test data

* We then use that model to make forecasts for the test data
* We reserved 3 years of test data so we want to forecasts 36 months into the future

```r
arima_forecast = forecast(arima_model, h = 36)
```

### Visual Evaluation

* Start by evaluating the performance of the forecast visually
* Remember that we can plot the data the model is fit to and the forecast using `autoplot`

```r
autoplot(arima_forecast)
```

* If we want to add the observations from the test data we can do this by adding `autolayer`

```r
autoplot(arima_forecast) + autolayer(NDVI_test)
```

* This adds a new layer to our the `ggplot` objection created by `autoplot` with the test data
* This shows that while the average is in the right general area the forecast doesn't the follow ups and downs

* Another way to visually evaluate forecasts is using observed-predicted plots
  * Predicted value on x
  * Observed value on y

```r
plot(arima_forecast$mean, NDVI_test)
```

* Because the x and y values are time-series `plot` makes a line plot
* Can be useful sometimes but just makes things hard to see in this case
* So let's convert them to regular vectors before plotting

```r
plot(as.vector(arima_forecast$mean), as.vector(NDVI_test))
```

* Finally we want to add a 1:1 line that shows when the observed and predicted values are equal

```r
abline(0, 1)
```

* Predicted value very quickly converges to mean
* Not much relationship between observed and predicted values
* Because no variation in predicted values

> * **Now it's you're turn.**
> * Forecast and visualize a seasonal ARIMA model

### Quantitative Evaluation

* `accuracy` function shows a number of common measures of forecast accuracy
  * 1st argument: forecast object from model on training data
  * 2nd argument: test data time-series

```r
accuracy(arima_forecast, NDVI_test)
```

* Shows errors on both training and test data
* Errors are higher on test than training because training data is being fit
* RMSE is a common method for evaluating forecast performance as is the Brier score
  (RMSE^2)

> * **Now it's your turn.**
> * Write code to quantify the accuracy of the seasonal ARIMA model

* Here's what I would have done

```r
seasonal_arima_model = auto.arima(NDVI_train)
seasonal_arima_forecast = forecast(seasonal_arima_model, h = 36)
autoplot(seasonal_arima_forecast) + autolayer(NDVI_test)

plot(as.vector(seasonal_arima_forecast$mean), as.vector(NDVI_test))
abline(0, 1)

accuracy(seasonal_arima_forecast, NDVI_test)
```

* Compare accuracy to non-seasonal ARIMA

```r
accuracy(arima_forecast, NDVI_test)
```

* So the season model appears to perform better on point estimates

#### Coverage

* How do we test the uncertainty
* We have these blue prediction intervals, but how do we evalute them
* Prediction Interval: range of values in which a percentage of observations
  should occur
* 80% prediction interval is the range of values we expect 80% of observations to fall between
* These values are stored in the forecast object as `$lower` and `$upper`

```r
arima_forecast$lower
arima_forecast$upper
```

* We can find the observed points that occur in this range by checking for points that match both conditions
* So we want `NDVI_test` to be greater than `lower` and less than `upper`

```r
in_interval <- NDVI_test > arima_forecast$lower[,1] & NDVI_test < arima_forecast$upper[,1]
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
in_interval_season <- NDVI_test > seasonal_arima_forecast$lower[,1] & NDVI_test < seasonal_arima_forecast$upper[,1]
length(in_interval_seasonal[in_interval_seasonal == TRUE]) / length(in_interval_seasonal)
```

* Seasonal is better because it is closer to the coverage interval of 0.8

### Forecast horizon

* Forecasts generally get worse through time
* Can look at this by comparing the fit at different forecast horizons
* Plot the error for each individual forecast for both models

```r
plot(sqrt((arima_forecast$mean - NDVI_test)^2))
lines(sqrt((seasonal_arima_forecast$mean -  NDVI_test)^2), col = 'blue')
```

* General trend towards increasing error with increasing horizon