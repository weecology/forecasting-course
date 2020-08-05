---
title: "R Tutorial"
weight: 3
description: "State space modeling tutorial: Part 1"
---

*Adapted from
the
[state space modeling activity](https://github.com/EcoForecast/EF_Activities/blob/master/Exercise_06_StateSpace.Rmd) from
Michael Dietz's
excellent
[Ecological Forecasting book](https://www.amazon.com/Ecological-Forecasting-Michael-C-Dietze/dp/0691160570)*

> JAGS needs to be installed: https://sourceforge.net/projects/mcmc-jags/files/
> rjags R package needs to be installed

## State space models

* Time-series model
* Only first order autoregressive component
* Separately model
  * the process model - how the system evolves in time or space
  * the observation model - observation error or indirect observations
* Estimates the true value of the underlying **latent** state variables

## Data

* Google Flu Trends data for Florida
* [https://www.google.org/flutrends/about/data/flu/us/data.txt](https://www.google.org/flutrends/about/data/flu/us/data.txt)

```{r}
gflu = read.csv("http://www.google.org/flutrends/about/data/flu/us/data.txt",skip=11)
time = as.Date(gflu$Date)
y = gflu$Florida
plot(time,y,type='l',ylab="Flu Index",lwd=2,log='y')
```

> Draw on board while walking through models

```
y_t-1    y_t    y_t+1
  |       |       |
x_t-1 -> x_t -> x_t+1   Process model
```


### Process model

* What is actually happening in the system
* First order autoregressive component

x_t+1 = f(x_t) + e_t

* Simple linear model is AR1:

x_t+1 = b0 + b1 * x_t + e_t


### Observation model

* Google searches aren't perfect measures of the number of flu cases (which are
  what should be changing in the process model and what we care about)
* So model this imperfect observation

y_t = x_t + e_t

* Can be much more complicated


## Model Framework

* Models like this are not trivial to fit
* Use [JAGS (Just Another Gibbs Sampler)](http://mcmc-jags.sourceforge.net)
* Gibbs samplers are a way of exploring parameter space to fit the model using
  Bayesian methods.
* The `rjags` library use R to call JAGS.

```{r}
library(rjags)
```

## Model

* JAGS code to describe the model
* Store as string in R
* Three components
  * data/error model
    * relates observed data (y) to latent variable (x)
    * Gaussian obs error
  * process model
    * relates state of the system at *t* to the state at *t-1*
    * random walk (x_t = x_t-1 + e_t)
  * priors
* Bayesian methods need priors, or starting points for model fitting

```{r}
RandomWalk = "
model{
  
  #### Data Model
  for (t in 1:n){
    y[t] ~ dnorm(x[t], tau_obs)
  }
  
  #### Process Model
  for (t in 2:n){
    x[t]~dnorm(x[t-1], tau_proc)
  }
  
  #### Priors
  x[1] ~ dnorm(x_ic, tau_ic)
  tau_obs ~ dgamma(a_obs, r_obs)
  tau_proc ~ dgamma(a_proc, r_proc)
}
"
```

* Data and priors as a list

```{r}
data <- list(y=y,
             n=length(y),
             x_ic=1000,
             tau_ic=1,
             a_obs=1,
             r_obs=1,
             a_proc=1,
             r_proc=1)
```

* Starting point of parameters

```{r}
init <- list(list(tau_proc=1/var(diff(y)),tau_obs=5/var(y)))
```

* Normally would want several chains with different starting positions to avoid
  local minima

* Send to JAGS

```{r}
j.model   <- jags.model (file = textConnection(RandomWalk),
                         data = data,
                         inits = init,
                         n.chains = 1)
```

* Burn in

```{r}
jags.out   <- coda.samples (model = j.model,
                            variable.names = c("tau_proc","tau_obs"),
                            n.iter = 10000)
plot(jags.out)
```

* Sample from MCMC with full vector of X's
* This starts sampling from the point were the previous run of `coda.samples`
  ends so it gets rid of the burn-in samples

```{r}
jags.out   <- coda.samples (model = j.model,
                            variable.names = c("x","tau_proc","tau_obs"),
                            n.iter = 10000)
```

* Visualize
* Convert the output into a matrix & drop parameters

```{r}
out <- as.matrix(jags.out)
xs <- out[,3:ncol(out)]
```

* Point predictions are averages across MCMC samples

```
predictions <- colMeans(xs)
plot(time, predictions, type = "l")
points(time, y)
```

* Add prediction intervals as range containing 95% of MCMC samples

```
ci <- apply(xs, 2, quantile, c(0.025, 0.975))
lines(time, ci[1,], lty = "dashed")
lines(time, ci[2,], lty = "dashed")
```

## Forecasting

* Add NAs for values to be forecast

> Make these changes at top of script and rerun

```
data$y[(length(y)-51):length(y)] = NA
```

## Uncertainty

* The uncertainty is partitioned between process and observation models
* Look at `tau_proc` and `tau_obs` (as standard deviations)

```{r}
hist(1/sqrt(out[,1])
hist(1/sqrt(out[,2])
plot(out[,1],out[,2])
```

## Dynamic linear modeling

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

* Make forecasts in the same was as before

```
out <- as.matrix(dlm$predict)
ci <- apply(exp(out),2,quantile,c(0.025,0.5,0.975))
plot(time, y)
lines(time, ci[2,])
lines(time, ci[1,], lty = "dashed")
lines(time, ci[3,], lty = "dashed")
```
