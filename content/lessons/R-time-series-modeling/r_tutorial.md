---
title: "R Tutorial"
weight: 3
type: book
summary: " "
show_date: false
editable: true
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
<iframe width="560" height="315" src="https://www.youtube.com/embed/JUIoMc0isdI" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

11. Use auto.arima() to fit the rain.ts data using the default settings (i.e. just give it the data, do not change any max values)
Examine the model fit using checkresiduals()
Modify the max orders, if needed, and rerun the model.

12. Watch Fitting external predictors using auto.arima()
<iframe width="560" height="315" src="https://www.youtube.com/embed/A72HE1XxX5Y" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

13. Submit your r code (either as a file or cut and paste text) through the assignment for this module in the course canvas site.


# Written version of the videos

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

## ARIMA models

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

We need to start by thinking about how many time steps in the past we may want to fit for our NDVI data, and whether we want to use an AR or an MA model
From our adventures in autocorrelation last week, we know that the acf and pacf plots can give us some insights there:

So, let's remind ourselves of what that autocorrelation structure looks like for NDVI.

```{r}
acf(NDVI.ts)
pacf(NDVI.ts)
```
(You can also do this using tsdisplay())

We learned last week that this signal, which was very different from the rodents, is probably telling us there's a moving average process working here. And since a lag of 1 and a lag of 2 are both significant, let's start off by fitting a MA-2 model (a second order, or lag-2 moving average process). To tell Arima that we want an MA-2 model, it requires an argument that contains the values. If you peek at the code below, you'll see that we give Arima() two things - the data and a list of numbers. Those numbers are the orders for the various components of the Arima model, c(AR,I,MA). Thus we give it zeros for the first two values (no AR or I component) and a 2 for the MA.

```{r}
MA2 = forecast::Arima(NDVI.ts, c(0,0,2))
```

First thing we'll do is peek at the model summary
```{r}
summary(MA2)
```
Across the top we see how the model was specified. Then the fitted coefficients for the orders we told it to fit. Then some information about the model fit, including AIC. The AIC values can be very useful for Arima modeling because adding more terms to our model will increase the fit, just because that's how models work (there's an old addage about being able to draw an elephant with enough terms in an equation). We want to fit the main structures in the data but not necessarily every wiggle. AIC penalizes models for their complexity and comparing AIC values across models will help us understand if the added complexity of adding more and more lags is really yielding meaningful predictive value.

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
Lets pause here and let you practice making an Arima model with the rain data! Check the acf and pacf model for rain and then build an Arima model that you think is a reasonable first start for that data!

```{r}
insert your code here
```
## Seasonal signals with Arima models
Ok, back to NDVI. If our model was a good fit to the time series, we would no longer have autocorrelation in the residuals, but we do.
We have autocorrelation at 1 and 2 years (12 months and 24 months). This is that seasonal signal, that repeated pattern of green and not green that happens every year as part of the seasonal nature of the system.

We can add terms to the ARIMA model that allow us to fit this seasonal signal.

> y_t = constant + b1 * y_t-1 + b2 * yt_2 + b3 * y_t-12 + b4 * y_t-24 + e_t

in this case, y_t-12 and y_t-24 are tell the model to also incorporate those longer term correlations, which emerge from the seasonal signal generating cross-year correlations.

When we put this information into Arima(), however, don't add it 24 AR or MA orders (that would fit everything up to 24 lags, which we don't want!). We tell it the number of annual cycles (or units of 12 months) that we want to model. This will just add y_t-12 or y_t-12 and y_t-24 (depending on the number of annual cycles) and not every lag up to and including 12 or 24.

```{r}
season_MA2 = forecast::Arima(NDVI.ts, c(0,0,2), seasonal=c(0,0,2))
```
Let's plot this model on our data and see how it looks:

```{r}
plot(NDVI.ts)
lines(fitted(season_MA2), col='green')
```
There are differences between this fit and the non-seasonal ARIMA we fit above, but they're subtle (you can flip back and forth between this graph and the plot for MA2 if you'd like).

```{r}
summary(season_MA2)
```
JUst like before, we see the model structure at the top, and the cofficient values that it fit to the data for that model structure. sMA refers to that seasonal MA component that we added to this model.

And, let's check the residuals:
```{r}
forecast::checkresiduals(season_MA2)
```
If we look at our acf of the residuals, our model now accounts for everything but those longest term correlations at > 24 months.

Let's pause here and have you explore whether the rain data needs a seasonal component added to its Arima model. Revisit the checkresiduals() plot for your rain Arima. Does it need a seasonal signal? If yes, generate a seasonal ARIMA for it:

```{r}
Insert your code here
```

## Automating fits
Often our goal is to have the best fitting model, so at this point what we would do it try a variety of different ARIMA models and compete them to see which has the lowest AIC value. We can do this with Arima(), slowly changing the orders and exploring things ourselves. Or we can have the computer do it for us. An automated approach can explore a range of optios more quickly than we can. The forecast packahe includes a function called auto.arima(). It decides on the best model based on Unit root tests, minimization of the AICc and MLE. 

We're going to use auto.arima on our NDVI data and see what *it* thinks the best model is!

```{r}
autoarima = forecast::auto.arima(NDVI.ts)
summary(autoarima)
```
The best model shares similarities with the one we were exploring. It has a seasonal component and an MA, but the seasonal component is modeled as an AR, there's only an MA1, and we also include an AR-2. Let's examine the residuals from this model

```{r}

forecast::checkresiduals(autoarima)
```
Whut?! We still have autocorrelation structure! How is this the best model?? Well, there's something important to know about auto.arima. It doesn't explore ALL possible Arima structures. It has default limits on the maximum number of orders for each component that it explores. And here they are:
Default Max Limits:  c(5,2,5), seasonal=c(2,1,2)

What that means is that auto.arima never checked to see if a seasonal AR of 3 might improve fit. We can force auto.arima to explore higher numbers than the default.

```{r}
autoarima_3 = forecast::auto.arima(NDVI.ts, max.P=3)
```
You might be wondering about max.P. The order for each component of an arima model has a letter that is used to refer to it. P is the seasonal AR order. SO that command it increasing the maximum order for the seasonal AR to 3. The letters used to refer to each of the orders are:
c(p,d,q), seasonal=c(P,D,Q)
So, if we wanted to increase the number of MA orders (non-seasonal) auto.arima explored to 10, we'd just add max.q = 10 to the auto.arima function, just like we did with max.P.

Let's examine the model we get when we increased our maximum seasonal AR order to 3.

```{r}
summary(autoarima_3)
```
And now we have a higher sAR term: sAR3, which means that our best fitting model includes a seasonal correlation structure that spans back for 3 annual cycles.

```{r}
forecast::checkresiduals(autoarima_3)
```

And our residuals now show that the 36 month correlation structure in our data is gone. Yes, we still have that 28 month correlation peak, but I have no idea why that exists and remember that we expect some significant correlations just by chance (even for a time series deliberately constructed to not have autocorrelation!). So, I say let's call it good. As an additional check, look in your console window. You should see results for something called the Ljung-Box test. This test is a test for whether your residuals are significantly different from white noise expectations. It says our residuals are not distinguishable from white noise, so I think we're good!

You do: Run auto.arima on the rain time series using the default values first. Check the residuals and determine whether you need to modify the defaults to explore models with higher order processes.

```{r}
Insert your code here
```

## Incorporating external co-variates
This is fun - making your timeseries predict itself, but often we know there are important predictors of a time series. We can add those to our ARIMA model just like in a normal regression. Technically, the way this works is that the predictor is fit to the data (like with regression) and the arima components are fit to the errors from that regression.

```{r}
rain_arima = forecast::auto.arima(NDVI.ts, max.P=3, xreg=data$rain)
summary(rain_arima)
```
The xreg term is the coefficient for the impact of rain on NDVI in this model. Unlike with the autocorrelation structure, auto,arima() does not automatically explore all the lags of the predictor. The model we ran is examining the impact of rain in the current month on NDVI in the current month. You may remember from last week that this was not our strongest correlation. The strongest correlation between rain and NDVI was occurring at a lag of 1 (the rain from the previous month was correlated with the NDVI in the current month). You can run lagged predictors in auto.arima but you have to generate the lagged data yourself so that the rain from the prvious month is associated with the NDVI for the next month. So, I'm going to end our magical tour of ARIMA models here. 
