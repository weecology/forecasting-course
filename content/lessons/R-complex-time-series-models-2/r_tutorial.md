---
title: "R Tutorial"
weight: 3
type: book
summary: "More complex time-series models: Part 2"
show_date: false
editable: true
---

**In development. Not ready for teaching**

## State space models

* Time-series model
* Only first order autoregressive component
* Separately model
  * the process model - how the system evolves in time or space
  * the observation model - observation error or indirect observations
* Estimates the true value of the underlying **latent** state variables

## Model

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

* Counts of rodents in traps aren't perfect measures of the number of rodents
  (which are what should be changing in the process model and what we care about)
* So model this imperfect observation

y_t = Pois(x_t)

* Can be much more complicated

...

* State space model of AR1 + rain w/Poisson error

{{< math >}}
$$y_t = \mathrm{Pois}(\mu_t)$$
$$\mathrm{log(\mu_t)} = c + \beta_1 x_{1,t} + \beta_2 \mu_{t-1} + \mathcal{N}(0,\sigma^{2})$$
{{< /math >}}

```r
state_space_model = mvgam(abundance ~ 1,
                          trend_formula = ~ mintemp,
                          trend_model = "AR1",
                          family = poisson(link = "log"),
                          data = data_train,
                          newdata = data_test)
plot(state_space_model, type = "forecast")
```

```r
output = state_space_model$model_output
```
### 
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
```

* And this looks very similar to the observed dynamics of y

* Add prediction intervals as range containing 95% of MCMC samples

```
ci <- apply(xs, 2, quantile, c(0.025, 0.975))
lines(time, ci[1,], lty = "dashed", col = "blue")
lines(time, ci[2,], lty = "dashed", col = "blue")
```

* These are very narrow prediction intervals, so the model appears to be very confident
* But it's important to keep in mind that when fitting the value of `x` at time `t`, the model has access to the value of `y` at time `t`
* And the `y` is present it isn't being estimated, it's just the observed value
* So, will this model forecast well?

### Forecasting

* To make forecasts using a JAGS model we include data for `y` that is `NA`
* This tells the model that we don't know the values and therefore the model estimates them as part of the fitting process
* To make a true forecast we would add one `NA` to the end of `y` for each time step we wanted to forecast
* To hindcast or backcast like we replace the values for `y` that are part of the test set with `NA`
* We'll hindcast, so to do this we'll replace the last year of `y` values with `NA` and then compare the final year of data to our predictions

> Make these changes at top of script and rerun

```
data$y[(length(y)-51):length(y)] = NA
jags.out   <- coda.samples (model = j.model,
                            variable.names = c("y","tau_proc","tau_obs"),
                            n.iter = 10000)
```

* We can see from plotting the predictions that the forecast doesn't look promising
* Without the observed data to influence the estimates of `x[t]` the model predicts little change over the forecast year
* We can directly compare this to the empirical data by adding it to the plot

```
lines(time, y)
```

* So the point estimates don't perform well
* This raises the question of whether the model accurately predicts that it is uncertain when making forecasts
* Plotting the prediction intervals suggests that it does
* They very quickly expand towards zero and the upper limits of the data
