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
library(tsibble) # convert time-series data in a tsibble
library(fable) # main package for modeling and forecasting with time-series data
library(feasts) # time-series data visualization
library(dplyr) # data manipulation
```

* Then load the data

```r
data = read.csv("portal_timeseries.csv")
data_ts <- data |>
  mutate(month = yearmonth(date)) |>
  as_tsibble(index = month)
data_ts
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
arima_model = model(data_ts, ARIMA(NDVI))
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

* Looks good
* Check the residuals

```r
gg_tsresiduals(arima_model)
```

* Seasonal autocorrelation is now gone

> You do:
> * Fit an ARIMA model to the `rain` data
> * Plot your data with the model fit on top
> * Plot the residuals

* What do you think about this result?
