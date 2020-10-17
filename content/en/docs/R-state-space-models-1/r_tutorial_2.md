---
title: "R Tutorial Part 2"
weight: 3
description: "State space modeling tutorial: Part 2"
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

<iframe width="560" height="315" src="https://www.youtube.com/embed/T3ZGhXAO6VY" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Text Tutorial

### Dynamic linear modeling

* Random walk worked well for one-step ahead
* But not for longer range forecasts
* Add covariates
* "Dynamic linear model"

* Download some weather data

```{r}
# install.packages('daymetr')
library(daymetr)
weather = download_daymet(site = "Orlando",
                               lat = 28.54,
                               lon = -81.34,
                               start = 2003,
                               end = 2016,
                               internal = TRUE)
weather_data = weather$data
head(weather_data)
```

* For date information this data has `year` and `yday`
* `yday` is the Julian day (starts at 1 on Jan 1 and goes to 365)
* Make this into a date column so we can combine with the weekly date data in Google Flu

```{r}
weather_data$date = as.Date(paste(weather_data$year,weather_data$yday,sep = "-"),"%Y-%j")
```

* Add this weather data to our `data` object used by our model

```{r}
#data$Tmin = weather_data$tmin..deg.c.[match(time, weather_data$date)]
data$Tmin = weather_data$tmin..deg.c.[weather_data$date %in% time]
```

* Could expand on our random walk model in JAGS
* But a bit complicated once there are predictors

```{r}
# devtools::install_packages('EcoForecast/ecoforecastR')
library(ecoforecastR)

data$logy = log(data$y)
dlm = ecoforecastR::fit_dlm(model = list(obs="logy", fixed="~ 1 + X + Tmin"), data)
params = dlm$params
params <- window(dlm$params,start=1000) ## remove burn-in
plot(params)
```

* Make forecasts in the same way as before

```
out <- as.matrix(dlm$predict)
ci <- apply(exp(out),2,quantile,c(0.025,0.5,0.975))
plot(time, y)
lines(time, ci[2,])
lines(time, ci[1,], lty = "dashed")
lines(time, ci[3,], lty = "dashed")
```
