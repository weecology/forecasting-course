---
title: "R Tutorial"
weight: 3
type: book
summary: " "
show_date: false
editable: true
---

## Video Tutorials

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


## Text Tutorial

* So far we've learned about time series objects, seasonal and long-term signals, and the influence of the past on current observations
* Now we're going to start taking all that information and turning it into models
* Let's first load the packages we'll need for today

```r
library(readr) # easily read in time-series data
library(tsibble) # convert time-series data in a tsibble
library(fable) # main package for modeling and forecasting with time-series data
library(dplyr) # data manipulation
library(ggplot2) #data visualization
```

```r
library(feasts) # may need for graphing
```

* Then load our data

```r
raw_data = read_csv("content/data/portal_timeseries.csv", col_types = cols(date = col_date(format = "%m/%d/%Y")))
portal_data <- raw_data |>
  mutate(month = yearmonth(date)) |>
  as_tsibble(index = month)
head(portal_data)
```

### White noise model

* We'll start with the simplest time-series model possible - white noise
* The data is normally distributed with a fixed mean and variance
* It takes the form

  > y_t = c + e_t, where e_t ~ N(0, sigma)

* So each time step in our model is a random draw from a normal distribution with a mean of `c``
* We fit time-series models using 
* This model is provided in `fable` by the `MEAN()` function

```r
MEAN()
```

* This output tells us that it is a model definition
* To fit that general model structure to our data we use the `model()` function

```r
avg_model = portal_data |>
  model(MEAN(NDVI))
```

* We can then look at the resulting model information using the `report()` function

```r
report(avg_model)
```

* This shows us that the model is a white noise structure (indicated by `MEAN`), a mean value of 0.1791, and a variance of 0.0031

* To visualize the model with the data we have to first make the fitted values available using `augment()`

```r
avg_model_aug <- augment(avg_model)
avg_model_aug
```

* We can see that this produces a `tsibble` that includes month, NDVI, the fitted values from the model, the the model residuals

* Then we can use `autoplot()` to look at the data and model together
* The predicted values from the model are stored in a special columns `.fitted`

```r
autoplot(avg_model_aug, NDVI) + autolayer(avg_model_aug, .fitted, color = "blue")
```

* This simple model doesn't work very well
* There is clearly autocorrelation and seasonality in the time-series
* We'll address that next, but first

> You do:
> Fit a white noise model to the `rain` data. Plot your data with the model fit on top.

## ARIMA models

* Let's build a model that takes the autocorrelation into account
* Remember that we have lag 1 and lag 2 autocorrelation plus a season signal

```r
autoplot(ACF(portal_data, NDVI))
```

* Let's start with just the lag 1 and lag 2 autocorrelation
* We model this using and autoregressive or AR model where the current value depends on past values

> y_t = c + b1 * y_t-1 + b2 * y_t-2 + e_t, where e_t ~ N(0, sigma)

* c is a constant, like the intercept in regression
* b1 & b2 are coefficients determining how y_t is related to y at previous time steps

* This type of model structure is available in `fable`'s `AR()` model

```r
ar_model = portal_data |>
  model(AR(NDVI ~ order(2)))
report(arima_model)
```

```r
ar_model_aug = augment(ar_model)
ar_model_aug
```

* Note there aren't predictions for the first two time-steps
* Not possible because there are no y values before March 1992 to give the model for prediction

```r
autoplot(ar_model_aug, NDVI) + autolayer(ar_model_aug, .fitted, color = "blue")
```

* This looks a lot better
* Let's take a look at the residuals, which are stored in `.resid`

```r
autoplot(ar_model_aug, .resid)
```

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
SO, just with the information about correlated errors at short time intervals, we are able to generate a plot that doesn't look ridiculously different from the observed data.

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
JUst like before, we see the model structure at the top, and the coefficient values that it fit to the data for that model structure. sMA refers to that seasonal MA component that we added to this model.

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
