---
title: "R Tutorial Part 2"
weight: 3
summary: "State space modeling tutorial: Part 2"
---

*Adapted from
the
[state space modeling activity](https://github.com/EcoForecast/EF_Activities/blob/master/Exercise_06_StateSpace.Rmd) from
Michael Dietz's
excellent
[Ecological Forecasting book](https://www.amazon.com/Ecological-Forecasting-Michael-C-Dietze/dp/0691160570)*

> JAGS needs to be installed: https://sourceforge.net/projects/mcmc-jags/files/
> rjags R package needs to be installed

## Video Tutorial

<iframe width="560" height="315" src="https://www.youtube.com/embed/kvH05bu_FHc" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Text Tutorial

### Missing data

* As we say at the end of the last video, adding `NA`'s to the end of the time-series produces forecasts from Bayesian state space models
* This happens because the model attempts to determine the most likely value for `NA`'s based on the model and the data
* This means that this type of modeling approach also works naturally with missing data
* This is different from many types of time-series models that require continuously sampled time-series

* To illustrate this we'll add `NA`'s to a portion of our time series as an example of missing data
* Go back to the line where we replaced the end of the time-series with `NA`'s and add some `NA`'s inside the training portion of the data
* We'll use two examples of missing data
* For the first we'll just a have data missing from a few random weeks

```r
data$y[c(26, 50, 90, 260, 261, 262)] = NA
```

* For the second we'll mimic an entire missing year of data

```r
data$y[year(time) == 2008] = NA
```

* Now rerun the modeling and prediction steps
* We can see that the model still fits and makes predictions like before
* Can also see that estimates what the missing values are, along with their uncertainty
* This is called "imputation"
* For the single missing data points we can see that the predictions are consistent with the data and the model is somewhat confident in its imputations
* But when an entire year of data is missing it we see similar behavior to our forecast
* The model predicts basically no change and uncertainty becomes high
* It peaks in the middle of the year because that is where there is the last empirical information to constrain the predictions
* As it gets close to the end of the year the data from the next year starts to constrain it
* And so we can see that this imputation is capturing the models uncertainty within the training data when no observed values are available
* It's actually quite high and this is why our forecasts from the model are highly uncertain, because there are no observations to constrain the model

### What went wrong

* So our first attempt at a forecast didn't look overly promising
* What do we do next
* First let's explore a little more about where the model when wrong
* We've already plotted our observed and predicted time-series
* So evaluate the model in another way we've learned and look at how the error in the point forecast changes with the forecast horizon
* First we need to identify the data that is only for the forecast
* That's the end of the time series

```r
forecast_data = (length(y)-51):length(y)
```

* The we can do the analysis we did before but only with this piece of the time series

```r
plot(time[forecast_data],
     sqrt((predictions[forecast_data] - y[forecast_data])^2))
```

* Random walk worked well for a few time steps, but not for longer range forecasts
* What's interesting is that normally we'd expect the error to keep going up, but it actually comes back down
* That's because the increase in error represents the flu season
* Once that season is over flu levels return to baseline and since that's what the model predicted the error declines to near zero again
* This is kind of pattern can be indicative of a model that is missing cyclic trend
* The kind of thing we would model with either a seasonal effect or a cyclic predictor variable
* In the past we've modeled this kind of cyclic pattern using seasonal lags
* There are two other ways of modeling them
* We can include the date as a predictor
* Or we can identify the drivers generating the seasonal variation and include them as predictors

### Dynamic linear modeling

* Both of these approaches require adding covariates to our models
* We describe models that include both a time-series component and predictors as "Dynamic linear models"

#### Data setup

* Let's start by putting together our predictor data
* First we'll download some weather data

```r
# install.packages('daymetr')
library(daymetr)
weather = download_daymet(site = "Orlando",
                               lat = 28.54,
                               lon = -81.34,
                               start = 2003,
                               end = 2016,
                               internal = TRUE)
weather_data = weather$data
```

* For date information this data has `year` and `yday`
* `yday` is the Julian day (starts at 1 on Jan 1 and goes to 365)
* Make this into a date column so we can combine with the weekly date data in Google Flu

```r
weather_data$date = as.Date(paste(weather_data$year, weather_data$yday, sep = "-"),"%Y-%j")
weather_data = subset(weather_data, weather_data$date %in% time)
```

* Let's add two predictors from `weather_data` to our `data` object used by our model

```r
data$Tmin = weather_data$tmin..deg.c.
data$yday = weather_data$yday
```

* Finally we're also going to log transform our response variable to help the JAGS model fit more effectively

```r
data$logy = log(data$y)
```

#### ecoforecastR

* Now we need to add these to our our random walk model in JAGS
* But this gets even more complicated once there are predictors
* So for today we're going to take a short cut by using a small piece of software to help us do this
* The `ecoforecastR` package will generate and run dynamic linear models using JAGS

```r
library(ecoforecastR)
```

* We'll start by adding minimum temperature to the model
* We can fit the model using `fit_dlm`
* We describe our model using a named list that includes `obs` for our observation and `fixed` for our fixed effects in the model

```r
dlm = fit_dlm(model = list(obs="logy", fixed="~ 1 + X + Tmin"), data)
```

* We can see that JAGS model that was generated

```r
cat(dlm$model)
```

* We can look at the parameters to see if things are converging

```r
params = dlm$params
params <- window(dlm$params,start=1000) ## remove burn-in
x11()
plot(params, ask = TRUE)
```

* We can visualize forecasts in the same way as before

```r
out <- as.matrix(dlm$predict)
ci <- apply(exp(out),2,quantile,c(0.025,0.5,0.975))
plot(time, y)
lines(time, ci[2,])
lines(time, ci[1,], lty = "dashed")
lines(time, ci[3,], lty = "dashed")
```

* This is better, but it's still not great
* We haven't really captured the seasonality with temperature
* So we could try adding in the julian day directly

```r
dlm = fit_dlm(model = list(obs="logy", fixed="~ 1 + X + Tmin + yday"), data)
```

* Now rerun the visualization code
* This looks a lot better!
* So we've got a pretty nice forecast here for the flu
* But, it's a little more complicated than this in most cases because Julian day is circular
* In other words December 31st and January 1st are really close to one another
* But a linear model on Julian Day thinks of them as far apart
* So, this happens to work in our case but generally it won't
* We can fix this by doing a harmonic transformation of the Julian Day
* But that's a subject for another lesson so we'll just stop here as an example