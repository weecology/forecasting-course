---
title: "R Tutorial"
weight: 3
type: book
summary: " "
show_date: false
editable: true
---

* Load the packages

```r
library(readr)
library(tsibble)
library(fable)
library(dplyr)
library(feasts)
```

* Then load the data

```r
raw_data = read_csv("content/data/portal_timeseries.csv", col_types = cols(date = col_date(format = "%m/%d/%Y")))
portal_data <- raw_data |>
  mutate(month = yearmonth(date)) |>
  as_tsibble(index = month)
portal_data
```

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

* So if `theta_1` > 0 then if the observation has greater than the mean at the previous time step it is like to be greater than the mean at the current time step
* Positive MA components say that if the previous observation was an outlier then the next observation is expected to be an outlier in the same direction
* This makes sense for NDVI
* Greenness isn't really driven by greenness in the same way a populations abundance is
* But if it's greener than normal this month it's probably a good year so it's likely to be greener than normal next month

* Both AR and MA structures can be present in time-series
* We can combine them in an ARMA model

> `y_t = c + b_1 * y_t-1 + theta_1 * error_t-1 + error_t`

### Accounting for trends

* An assumption when fitting models of this form is that the time-series is "stationary"
* Basically - there is no general trend in the data
* This is handled using "differencing" which is similar to what we did when decomposing time-series
* To take out the trend before model fitting the data is differenced
* Typically by subtracting the previous value

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
* So this model is a 3rd order MA model, with no differencing, and no autoregressive terms

> `y_t = c + theta_1 * e_t-1 + theta_2 * e_t-2 + theta_3 * e_t-3 + e_t`

* This is also shown in the `Coefficients` table by the `ma1`, `ma2`, and `ma3` terms
* So, if NDVI was above average over the last 3 months we expect it to be above average now
* This lines up with our idea that MA might be better for NDVI since it indicates a good year

* But what is the `sar1` coefficient?
* That's our season signal
* A seasonal autoregressive term of order 1
* The seasonal component is also shown in PDQ notation in the second set of parentheses
* We model season components with lags of the length of a full seasonal cycle
* In this case a full cycle is 1 year
* So the SAR1 part of the model as

> `y_t = c + b_12 * y_t-12`

* The value in the current month is related to the value observed 1 year ago
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

* Seasonal autocorrelation is now gone

> You do:
> * Fit an ARIMA model to the `rain` data
> * Plot your data with the model fit on top
> * Plot the residuals

## External co-variates

### TSLM

* Most ecological models include exogenous covariates
* We'll look at this with some data on the abundance of the desert pocket mouse

```r
pp_data = read_csv("content/data/pp_abundance_timeseries.csv") |>
  as_tsibble(index = newmoonnumber)
gg_tsdisplay(pp_data, abundance)
```

* Traditionally we do this with some sort of regression analysis
* Try to predict abundances with minimum temperature
* Because this species hibernates when it gets cold

| `y_t = c + b_1 * mintemp_t + e_t`

* We can do this in a time-series context with the `TSLM()` function

```r
tslm_model = pp_data |>
  model(TSLM(abundance ~ mintemp))
report(tslm_model)
```

* Visualize the model

```r
tslm_model_aug = augment(tslm_model)
autoplot(tslm_model_aug, abundance) + autolayer(tslm_model_aug, .fitted, color = "orange")
```

* TSLM also lets us add season and trend components
* It's possible we have a decrease over time so let's add a trend

```r
tslm_model = tslm_model = pp_data |>
  model(TSLM(abundance ~ mintemp + trend()))
```

* This adds time itself as a predictor

| `y_t = c + b_1 * mintemp_t + b_2 * t + e_t`

```r
tslm_model_aug = augment(tslm_model)
autoplot(tslm_model_aug, abundance) + autolayer(tslm_model_aug, .fitted, color = "orange")
```

* Looks pretty good
* But let's look at the residuals

```r
gg_tsresiduals(tslm_model)
```

* There is still a lot of autocorrelation
* And that's a problem because regression assumes data points are independent
* The autocorrelation tells us that they aren't
* So any statistical inferences would be questionable

### ARIMA + Exogenous variables

* We can solve this by combining the two approaches
* In an ARIMA model we can specify external covariates like in a linear model

```r
arimax_model <- model(pp_data, ARIMA(abundance ~ mintemp))
report(arimax_model)
```

* When we do this we see an AR1 term, an MA1 term, and a mintemp term
* We can generally think of this model as being something like

| `y_t = c + b_1 * mintemp + b_1 * y_t-1 + theta_1 * e_t-1 + e_t`

* This is called an ARMAX model, with the X standing for eXogenous predictors
* Fable actually fits a linear regression with ARIMA errors

| `y_t = c + b_1 * mintemp + n_t`
| `n_t = b_2 * n_t-1 + theta_1 * e_t-1 + e_t`

* But all that most of us need to know is that the model includes both time-series structure and external covariates

```r
arimax_model_aug <- augment(arimax_model)
autoplot(arimax_model_aug, abundance) + autolayer(arimax_model_aug, .fitted, color = "orange")
gg_tsresiduals(arimax_model)
```

* This gives us nice look predictions and good error structure
* But did you notice anything weird?
* Negative abundances don't make sense
* Why do we have them?
* We'll come back to how to fix this in a couple of weeks
