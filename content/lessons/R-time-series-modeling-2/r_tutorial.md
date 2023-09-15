---
title: "R Tutorial"
weight: 3
type: book
summary: " "
show_date: false
editable: true
---

## ARIMA models

* Our simple autoregressive models were a good start
* But both the variables we looked at showed strong seasonal components that they didn't capture
* To add seasonal components to our model we need to learn about a more complex version of AR models
* ARIMA models
* ARIMA stands for AutoRegressive Integrated Moving Average
* We've already learned the AutoRegressive part, so let's talk about the other two

### Moving average models

*  Note that this is not using a moving average like you did when decomposing time-series
*  MA models are like AR models in that they use past observations to predict the next step
*  But instead of using the values themselves they use the past errors
*  So a 1st order MA model looks like this 

> `y_t = c + theta_1 * e_t-1 + error_t`

* If we take out the middle term this is our white noise model where each value is a random draw with a mean of `c`
* But there is an extra term that depends on the error at the previous time step
* So if `theta_1` > 0 then if the observation has greater than the mean at the previous time step it is like to be greater than the mean at the current time step
* `theta_1` is a coefficient fit to the data

* Both AR and MA structures can be present in time-series
* We can combine them in an ARMA model

> `y_t = c + b_1 * y_t-1 + theta_1 * error_t-1 + error_t`

### Accounting for trends

* An assumption when fitting models of this form is that the time-series is "stationary"
* Basically - there is no general trend in the data
* This is handled using "differencing" which is similar to we did when decomposing time-series
* To take out the trend the data is differenced before modeling fitting

> `y_t' = y_t - y_t-1`

* So, if we difference the data we are now modeling the change from time-step to time-step, not the actual values

* Adding AR, MA, and differencing together gives us an ARIMA model
  * AR: Autoregressive - Uses past values to predict future values
  * I: Integrated - Uses differencing to handle trends
  * MA: Moving Average - Uses past errors to predict future errors

### Seasonal models

* One of the things ARIMA models can do easily in R is fit seasonal models
* The ARIMA model structure is available in `fable` in the `ARIMA()` function

```r
arima_model = portal_data |>
  model(ARIMA(NDVI))
```

* If we don't provide it any details on model structure it will try to find the best fitting ARIMA model

```r
report(arima_model)
```

* In ARIMA notation we have 3 numbers, given in parentheses, labeled `(p, d, q)`
* `p` is the AR order, `d` is the degree of differencing, and `q` is the MA order
* So this model is a 3rd order MA model with no differencing and no autoregressive terms

> `y_t = c + theta_1 * e_t-1 + theta_2 * e_t-2 + theta_3 * e_t-3 + e_t`

* This is also shown in the `Coefficients` table by the `ma1`, `ma2`, and `ma3` terms
* So, if NDVI was above average over the last 3 months we expect it to be above average now

* But what is the `sar1` coefficient?
* That's our season signal
* A seasonal autoregressive term of order 1
* The seasonal component is also shown in PDQ notation in the second set of parentheses
* We model season components with lags of the length of a full seasonal cycle
* In this case a full cycle is 1 year, so we could right the SAR1 part of the model as

> `y_t = c + b_12 * y_t-12`

* So, the value in the current month is related to the value observed 1 year ago
* This makes a lot of sense for NDVI
* Ecosystems are typically greener during the summer than in the winter
* So a good piece of information is how green the ecosystem was at this time last year
* Our full model would therefore be

> `y_t = c + theta_1 * e_t-1 + theta_2 * e_t-2 + theta_3 * e_t-3 + b_12 * y_t-12 + e_t`

* What does this look like?

```r
arima_model_aug = augment(arima_model)
autoplot(arima_model_aug, NDVI) + autolayer(arima_model_aug, .fitted, color = "orange")
```

* Looks a lot better
* But if we look carefully the peaks are typically lagged by 1-2 time steps
* There is a high prediction for t because there has a big observation at t-1
* Check the residuals

```r
gg_tsresiduals(arima_model)
```

* The seasonal term was gotten rid of the seasonal autocorrelation

* Let's compare this to just a seasonal model
* We can set the PDQ values using two PDQ functions
* `pdq()` takes the non-seasonal `p`, `d`, and `q` arguments
* `PDQ()` takes the seasonal `p`, `d`, and `q` arguments

```r
season_only_arima_model <- portal_data |>
  model(ARIMA(NDVI ~ pdq(0, 0, 0) + PDQ(1, 0, 0)))
season_only_arima_model_aug = augment(season_only_arima_model)
autoplot(season_only_arima_model_aug, NDVI) + autolayer(season_only_arima_model_aug, .fitted, color = "orange")
gg_tsresiduals(season_only_arima_model)
```

* So the seasonal signal gets some of the locations of the peaks (it's green in the summer) but not how green it is
* And just modeling season gets rid of the seasonal signal in the residuals, but not the short term autocorrelation

> You do:
> * Fit an ARIMA model to the `rain` data
> * Plot your data with the model fit on top
> * Plot the residuals

## External co-variates

### TSLM

* Most ecological models will need to include exogenous covariates
* Let us model a driver, like climate, influences the ecosystem
* We'll look at this with some data on the abundance of the desert pocket mouse

```r
pp_data = read_csv("pp_abundance_timeseries.csv") |>
  as_tsibble(index = newmoonnumber)
gg_tsdisplay(pp_data, abundance)
```

* Traditionally we do this with some sort of regression analysis
* We'll try to predict abundances using the minimum temperature
* Because this species hibernates when it gets cold

| `y_t = c + b_1 * mintemp + e_t`

* We can do this in a time-series context with the `TSLM()` function

```r
linear_model = model(pp_data, TSLM(abundance ~ mintemp))
report(linear_model)
```

```r
linear_model_aug = augment(linear_model)
autoplot(linear_model_aug, abundance) + autolayer(linear_model_aug, .fitted, color = "orange")
```

* This looks reasonable
* But let's look at the residuals

```r
gg_tsresiduals(linear_model)
```

* There is still a lot of autocorrelation
* And that's a problem because regression assumes data points are independent
* The autocorrelation tells us that they aren't
* So any statistical comparisons will be invalid

### ARIMA + Exogenous variables

* We can solve this by combining the two approaches
* In an ARIMA model we can specify external covariates like in a linear model

```r
arima_x_mod <- model(pp_data, ARIMA(abundance ~ mintemp))
report(arima_x_mod)
```

| `y_t = c + b_1 * y_t-1 + b_1 * mintemp + e_t`

```r
arima_mod_aug <- augment(arima_mod)
autoplot(arima_mod_aug, abundance, color = "black") + autolayer(arima_mod_aug, .fitted)
gg_tsresiduals(arima_mod)
gg_tsdisplay(pp_data, abundance)
```