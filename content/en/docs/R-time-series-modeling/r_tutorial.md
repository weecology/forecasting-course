---
title: "R Tutorial"
weight: 3
description:
---

 Over the past few weeks, we've explored how to turn time series into time series objects, how to disentangle the seasonal and long-term signals in a time series, and learned about the influence of the past on current observations. Today we're going to start taking all that information and turn them into models. 

## White noise model - Simplest Time series
Last week I introduced you to White noise, where we defined a distribution with a mean and variance and pulled random values from it to produce a time series. 

```{r}
set.seed(20)
whitenoise <- ts(rnorm(273, mean=0.18))           
plot(whitenoise, main="White noise")
abline(h=0.18)
```
From this, we can fit the most basic version of a time series model:
  *  Normally distributed data w/fixed mean and variance
*  No change time-series is just random samples
If we were to fit an equation to this, what would it look like?
** y = c + e_t, where e_t ~ N(0, sigma) **
  
  Let's fit this simple time series model to our data.

## Data setup

Let's start by getting our environment ready to go by loading our rpackage and data.

We're going to be using the rpackage forecast today. Forecast is the package developed by Rob Hyndeman as an aid to learning basic forecasting techniques in R. It makes some of the modeling approaches more user friendly.
---
```{r}
library(forecast)
```
We're going to be modelling the data we've been working with over the past few weeks - the Portal data time series. And today we're going to work with the NDVI data together and then you'll work on applying what we've done to the rain data.

Just like we've been doing, we'll turn the data into a time series object which will work with the functions in forecast.

```{r}
data = read.csv("portal_timeseries.csv", stringsAsFactors = FALSE)
NDVI_ts = ts(data$NDVI, start = c(1992, 3), end = c(2014, 11), frequency = 12)
rain_ts = ts(data$rain, start = c(1992, 3), end = c(2014, 11), frequency = 12)
```

## Plot the data
Let's just remind ourselves what the data look like:

```{r}
plot(NDVI_ts)
```

Now let's fit this white noise model to our data. We'll use the meanf function from
the forecast package. It fits a model where you have a mean and assume data are 
independent and identifcally distributed  (so no time series structure)
```{r}
avg_model = meanf(NDVI_ts)
plot(NDVI_ts)
lines(fitted(avg_model), col = 'red')
summary(avg_model)
```

## Auto-regressive model

* But we know this isn't right. As we learned last week, there is structure in our data. It's not just a random pull from a distribution. We have autocorrelation between our data points.

```{r}
acf(NDVI_ts)
pacf(NDVI_ts)
```

So, let's build a model that takes this autocorrelation into account.
* "Autoregressive model""
* Predict value based on previous states in time-series

> y_t = c + b1 * y_t-1 + b2 * y_t-2 ... + e_t
* Does this remind you of a biological model?
* This model is bascially a Gompertz population model if y is log(N)

This general structure is an approach to time series modelling called an ARIMA model.
* ARIMA: autoregressive, integrated, moving average
These terms define different approaches to modeling the time series. We talked about one of these last week - autocorrelation, which is the AR part of an ARIMA model
AR: Autoregression. Uses the mean relationship between one time step and another.
I: Integrated. Is used when there is a trend in the data that needs to be accounted for.
MA: Moving Average (not the same as moving average we discussed for decomposition). This
uses information in the errors, not the means.

For each of these components, we have to tell the model how many time steps in the past do we think influence our observed time point. 
We are just going to focus on AR models today - ignoring I and MA.
So let's start by thinking about how many time steps in the past we may want to 
* Fit using `Arima()` function
* Can use the Pacf as a starting point for determining the order of the model.
* Our pacf has 2 significant lags.

```{r}
arima_model = Arima(NDVI_ts, c(2, 0, 0))
plot(NDVI_ts)
lines(fitted(arima_model), col = 'red')
summary(arima_model)
```

SO, just with the information about the mean relationship between the observed value and the
value from th eprevious two timesteps, we are able to generate a plot that doesn't look
ridiculuous different from the observed.
* Check fit

```{r}
plot(resid(arima_model))
acf(resid(arima_model))
```
If our model was a good fit to the time series, we would no longer have autocorrelation
in the residuals, but we do.
* Autocorrelation at 1 and 2 years
Why? What kind of signal would generate that? (we talked about this when we
were thinking about autocorrelation last week)
* Seasonal signal
* Seasonal component is modeled in the same way, but in 1 full annual cycle steps

> y_t = constant + b1 * y_t-1 + b2 * yt_2 + b3 * y_t-12 + b4 * y_t-24 + e_t
```{r}
seasonal_arima_model = Arima(NDVI_ts, c(2, 0, 0), seasonal = c(2, 0, 0))
plot(NDVI_ts)
lines(fitted(seasonal_arima_model), col = 'red')
summary(seasonal_arima_model)
acf(resid(seasonal_arima_model))
plot(resid(seasonal_arima_model))
```
If we look at our acf of the residuals, our model now accounts for all the autocorrelation 
in the data. And when we look at the plot we have a closer fit between the values predicted by the model and the observed data.

> CLASS EXERCISE: Build seasonal and non-seasonal ARIMAs for the precipitation data
* do a acf for ppt

```{r}
acf(rain_ts)
```
What AR order seemed reasonable? AR1

```{r}
rain_model = Arima(rain_ts, c(1, 0, 0))
summary(rain_model)
plot(rain_ts)
lines(fitted(rain_model), col = 'red')
acf(resid(rain_model))
```
For the rain, the autoregressive is clearly not capturing as much of the variation.
WHich is not surprising since the autocorrelation strengths are pretty weak.

FOr the seasonal, a 2 year order seems reasonable

```{r}
seasonal_rain_model = Arima(rain_ts, c(2, 0, 0), seasonal = c(2, 0, 0))
plot(rain_ts)
lines(fitted(seasonal_rain_model), col = 'red')
summary(seasonal_rain_model)
acf(resid(seasonal_rain_model))
```
It's better but not great when we add a seasonal component. 

## Automating fits
Often our goal is to have th ebest fitting model, so at this point what we would do it try a variety of different ARIMA models and compete them to see which has thelowest AIC value

We can use an automated approach that Fits lots of models at once, including all possible values of seasonal, AR, differencing, and MA, and pick the best
* It decides on the best based on Unit root tests, minimization of the AICc and MLE

```{r}
arima_model = auto.arima(NDVI_ts)
plot(NDVI_ts)
lines(fitted(arima_model), col='red')
summary(arima_model)
plot(resid(arima_model))
```
The best model is very similar to what we chose - a model with AR(2), sAR(2), but with a MA1
* Moving average: autocorrelated errors
* Differencing: handles strong one-step autocorrelations, like trends

* Can use `seasonal = FALSE` to skip seasonal signal

## Incorporating external co-variates
This is fun - making your timeseries predict itself, but often we know there are
important predictors of a time series. We can add those to an ARIMA model just like
in a normal regression
* Add values of x and associated coefficient to model

> y_t = c + b1 * y_t-1 + b2 * x_t ... + e_t
```{r}
rain_arima_model = auto.arima(NDVI_ts, xreg = rain_ts)
plot(NDVI_ts)
lines(fitted(rain_arima_model), col = 'blue')
lines(fitted(arima_model), col = 'red')
summary(rain_arima_model)
```
It does not automatically explore all the lags of the predictor. Anyone remember
whenwe did the crosscorrelation between rain and NDVI last week what the strongest correlation was?
```{r}
ccf(rain_ts, NDVI_ts)
```
Lag of 1.

To generate lagged predictors you need to generate a new dataframe containing
the different lags you want to examine

```{r}
Rain1 = stats::lag(rain_ts,-1)
Rain0 = rain_ts
rain_lags <- cbind(
    Rain0 = rain_ts,
    Rain1 = stats::lag(rain_ts,1))
head(rain_lags)
```

```{r}
NDVI_rain_0 = auto.arima(NDVI_ts, xreg = Rain1)
plot(NDVI_ts)
lines(fitted(NDVI_rain_0), col = 'blue')
summary(NDVI_rain_0)

```
