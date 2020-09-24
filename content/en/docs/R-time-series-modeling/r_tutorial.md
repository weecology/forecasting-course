---
title: "R Tutorial"
weight: 3
description:
---

## Time Series Modeling in R [in progress!!!]
### Video Tutorial

1. Watch Time series modeling: starting with white noise
<iframe width="560" height="315" src="https://www.youtube.com/embed/OO-KjD1sOBQ" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

2. Import portal_timeseries.csv in R using read.csv. 
Convert the NDVI data column into a time series object using ts(). Name that time series object: NDVI.ts
Convert the rain column into a time series object using ts(). Name that time series object: rain.ts

3. Watch Fitting a white noise model to data
<iframe width="560" height="315" src="https://www.youtube.com/embed/iS5VKoEhJl4" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

4. Use meanf() to fit the whitenoise model to rain.ts
Plot rain.ts
Add the fitted model for rain to that plot using lines()

5. Watch Explaining the ARIMA model
<iframe width="560" height="315" src="https://www.youtube.com/embed/hD13nv8SK6A" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

6. Watch Fitting an Arima model in R
<iframe width="560" height="315" src="https://www.youtube.com/embed/6gmCNGRrRBs" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

7. Generate the acf and pacf plots for rain.ts
Examine those plots and decide what a good initial ARIMA model structure would be (AR vs MA?, How many orders?)
Fit that model using the Arima() function. 
Examine the residuals of the model using checkresiduals()

8. Watch Modeling seasonal signals in ARIMA models
<iframe width="560" height="315" src="https://www.youtube.com/embed/m6fplOpo4qs" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

9. Watch Fitting a seasonal ARIMA in R
<iframe width="560" height="315" src="https://www.youtube.com/embed/Uk9VxIlbj8I" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

10. Examine the acf graph for your rain Arima model that you produced in step 7 above.
Use Arima() to fit a seasonal model to rain.ts based on the information in your acf plot

11. Watch Using auto.arima() in R
11. Watch Exploring lagged correlations between different time series
<iframe width="560" height="315" src="https://www.youtube.com/embed/dKDgihvtZGk" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

12. Plot the lag plot comparing NDVI.ts and rats.ts
Generate the ccf plot comparing NDVI.ts and rats.ts

13. Submit your r code (either as a file or cut and paste text) through the assignment for this module in the course canvas site.



 Over the past few weeks, we've explored how to turn time series into time series objects, how to disentangle the seasonal and long-term signals in a time series, and learned about the influence of the past on current observations. Today we're going to start taking all that information and turn them into models. 

## White noise model - Simplest Time series

## Data setup

Let's start by getting our environment ready to go by loading our rpackage and data.

We're going to be using the rpackage forecast today. Forecast is the package developed by Rob Hyndeman as an aid to learning basic forecasting techniques in R. It makes some of the modeling approaches more user friendly.
---
```{r}
library(forecast)
```
We're going to be modeling the data we've been working with over the past few weeks - the Portal data time series. And today we're going to work with the NDVI data together and then you'll work on applying what we've done to the rain data. 

You do:
Why don't you load up the datafile portal_timeseries.csv and turn both NDVI and rain into time series objects. Call the NDVI time series NDVI.ts and the rain time series rain.ts
```{r}
Insert your code here!
```

Let's also make our white noise time series again. As a reminder white noise is when we have a time series where the data points lack any correlation structure. They are random, independent draws from a distribution. The equation for white noise looks like this:

y_t = constant + Error_t, where the error at time t is assumed to be from a normal distribution with some mean and variance.

We can generate one of these time series in R using the code we played with last week:
```{r}
set.seed(20)
whitenoise = ts(rnorm(273,0.18))
```
Reminder: set.seed is fixing that random draw so we all have the same numbers. rnorm() pulls random draws from a normal distribution. And we've asked it to pull 273 observations from a normal distribution with mean 0.18

## Fit the white noise model
Now let's fit this white noise model (the equation above) to our data. We'll use the meanf function from the forecast package. It fits a model where you have a mean and assumes data are independent and identifcally distributed  (so no time series structure)

```{r}
avg_model_w = forecast::meanf(whitenoise)
plot(whitenoise)
lines(fitted(avg_model_w), col='blue')
```
As you can see, it's not a very exciting model. All it does is fit the mean of the data and then all the variance around that mean is modeled as random error.

For 'fun' let's apply it to our NDVI data.

```{r}
avg_model = forecast::meanf(NDVI.ts)
plot(NDVI.ts)
lines(fitted(avg_model), col='blue')
```
In some ways it looks even worse because we have these obvious systematic excursios from the mean that are maintained for more than one time step. This is because the NDVI is not just random draws from some distribution. It has autocorrelation between the data points. 

You do:
Run the meanf() model on the rain.ts time series object. Plot your data with the model fit on top.
```{r}
Insert your code here
```

## Auto-regressive model

Let's build a model that takes this autocorrelation into account. We'll do this by adding autocorrelation into that base white noise equation.
White noise model:
y_t = constant + Error_t

Autoregressive model (AR):
y_t = constant + b1 * y_t-1 + error_t
where b1 is a coefficient that we fit to the data (like a slope in a regression). y_t-1 is the observation at a 1 time step lag - or the observation one time step before y_t.

Moving average model (MA):
y_t = constant + theta1 * error_t-1 + error_t
where theta1 is a coffiecient fit to the data and error_t-1 is the error value for the observation at the prior time step.

Data doesn't necessarily reflect just an autoregressive or just a moving average process. We can combine the Autoregressive and Moving average processes in the same model, often called an ARMA model. For example:

y_t = constant + theta1 * error_t-1 +  b1 * y_t-1 + error_t
This would be considered an ARMA model with an AR1 process (first order autoregressive or autoregressive with lag of 1) and a MA1 process (a first order moving average or moving average with a lag of 1)

Finally, we can add something to the arma that allows us to deal with any long-term trends in our data (i.e. long-term shifts in the mean value of a time series).That type of model is called an ARIMA.
AR: Autoregression. Uses the mean relationship between one time step and another.
I: Integrated. Is used when there is a trend in the data that needs to be accounted for.
MA: Moving Average (not the same as moving average we discussed for decomposition). This
uses information in the errors, not the means.

The I component changes what data is being fit by the model. Instead of the observation y_t it's the difference between y_t and the value at some point in the past (for example y_t-1). 

For each of these components, we have to tell the model how many time steps in the past do we think influence our observed time point. In this context, we often talk about the 'order' of the process. A first order AR process, A second order MA process, which is just another ways of saying how many lags we want to fit. A lag of 1 is a 1st order process. When we specify an ARIMA model with the orders we want it to fit, we can specify 0 for those aspects of the model we don't want 

So let's start by thinking about how many time steps in the past we may want to fit foro ur NDVI data. 
From our adventures in autocorrelation last week, we know that the acf and pacf plots can give us some insights there:

So, let's remind ourselves of what that autocorrelation structure looks like for NDVI.

```{r}
acf(NDVI.ts)
pacf(NDVI.ts)
```
(You can also do this using tsdisplay())

We learned last week that this signal, which was very different from the rodents, is probably telling us there's a moving average process working here. And since a lag of 1 and a lag of 2 are both significant, let's start off by fitting a MA-2 model (a second order, or lag-2 moving average process)

```{r}
MA2 = forecast::Arima(NDVI.ts, c(0,0,2))
```

Let's see how this model performs relative to the white noise model we plotted before:

```{r}
plot(NDVI.ts)
lines(fitted(MA2), col='blue')
```
SO, just with the information about correlated errors at short time intervals, we are able to generate a plot that doesn't look ridiculuously different from the observed data.

The next step whenever we fit any model is to check how its fitting our data. Are there signals in our residuals that indicate something is amiss. With a time series model, we're often looking to see if we left any autocorrelation unaccounted for. 


```{r}
forecast::checkresiduals(MA2)
```
If our model was a good fit to the time series, we would no longer have autocorrelation in the residuals, but we do.
We have autocorrelation at 1 and 2 years (12 months and 24 months). This is that seasonal signal, that repeated pattern of green and not green that happens every year as part of the seasonal nature of the system.

We can add terms to the ARIMA model that allow us to fit this seasonal signal.

> y_t = constant + b1 * y_t-1 + b2 * yt_2 + b3 * y_t-12 + b4 * y_t-24 + e_t

in this case, y_t-12 and y_t-24 are tell the model to also incorporate those longer term correlations, which emerge from the seasonal signal generating cross-year correlations.

When we put this into Arima(), however, 
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
