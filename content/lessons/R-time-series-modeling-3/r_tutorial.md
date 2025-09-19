---
title: "R Tutorial"
weight: 3
type: book
summary: " "
show_date: false
editable: true
---

## External co-variates

### TSLM

* Most ecological models include exogenous covariates
* We'll look at this with some data on the abundance of the desert pocket mouse
* Load the packages

```r
library(tsibble)
library(fable)
library(feasts)
```

* Load the data

```r
pp_data = read.csv("pp_abundance_timeseries.csv") |>
  as_tsibble(index = newmoonnumber)
pp_data
```

* Look at our response time-series

```r
gg_tsdisplay(pp_data, abundance)
```

* Traditionally we model relationships between variables with some sort of regression analysis
* Try to predict abundances with minimum temperature
* Because this species hibernates when it gets cold

{{< math >}}
$$y_t = c + \beta_1 x_t + \epsilon_t$$
{{< /math >}}


* We can do this in a time-series context with the `TSLM()` function

```r
tslm_model = model(pp_data, TSLM(abundance ~ mintemp))
report(tslm_model)
```

* Visualize the model

```r
tslm_model_aug = augment(tslm_model)
autoplot(tslm_model_aug, abundance) + autolayer(tslm_model_aug, .fitted, color = "orange")
```

* It has the seasonal ups and downs but not differences in high years vs low years
* Let's try adding another predictor
* We'll add precipitation when it is cool
* The driver of vegetation and therefore food when PP's are most active
* We do this by adding more variables to our formula using the `+` sign

> Update code by adding cool_precip

```r
tslm_model = model(pp_data, TSLM(abundance ~ mintemp + cool_precip))
report(tslm_model)
```

* Cool precip is significant, but weakly so

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
* This ramp suggests that there might be a trend
* It's possible we have a decrease over time

* We can try to model the trend explicitly to remove the autocorrelation
* We can do this by adding a fitted trend to our model using `trend()`

```r
tslm_model = tslm_model = model(pp_data, TSLM(abundance ~ mintemp + cool_precip + trend()))
```

* This adds time itself as a predictor

{{< math >}}
$$y_t = c + \beta_1 x_{1,t} + \beta_2 x_{2,t} + \beta_3 t +  \epsilon_t$$
{{< /math >}}

* Basically it says that there's a trend that we can't explain
* But we include it in the model
* If this removes all of the autocorrelation then we're in good shape

```r
report(tslm_model)
```

* Trend is significant
* Also changes the `cool_precip` coefficient & makes it more clearly significant

```r
tslm_model_aug = augment(tslm_model)
autoplot(tslm_model_aug, abundance) + autolayer(tslm_model_aug, .fitted, color = "orange")
```

* Better matching of ups and downs

```r
gg_tsresiduals(tslm_model)
```

* It gets the longer-term autocorrelation
* But the short lag AR is still there 

> You do:
> * Make a TSLM model but try some different combinations of predictors
> * Plot your data with the model fit on top
> * Plot the residuals


### Dynamic regression models

* We can solve the autocorrelation issue in our time-seris linear model by combining it with ARIMA
* In an ARIMA model we can specify external covariates like in a linear model

```r
arima_exog_model <- model(pp_data, ARIMA(abundance ~ mintemp))
report(arima_exog_model)
```

* When we do this we see an AR1 term, an MA1 term, and a mintemp term
* There is also a difference term
* Model has automatically incorporated the trend we fit with TSLM
* We can generally think of this model as being something like

{{< math >}}
$$y_t = c + \beta_1 x_{1,t} + \beta_2 y_{t-1} + \theta_1 \epsilon_{t-1} + \epsilon_t$$
{{< /math >}}

* This is called an ARMAX model, with the X standing for eXogenous predictors
* Fable actually fits a linear regression with ARIMA errors

{{< math >}}
$$y_t = c + \beta_1 x_{1,t} + \eta_t$$
$$\eta_t = \beta_2 \eta_{t-1} + \theta_1 \epsilon_{t-1} + \epsilon_t$$
{{< /math >}}

* The model includes time-series structure & external covariates
* With interpretable coefficients

```r
arima_exog_model_aug <- augment(arima_exog_model)
autoplot(arima_exog_model_aug, abundance) + autolayer(arima_exog_model_aug, .fitted, color = "orange")
gg_tsresiduals(arima_exog_model)
```

* This gives us nice look predictions and good error structure

> You do:
> * Make a ARIMA model with both mintemp and cool_precip
> * Plot your data with the model fit on top
> * Plot the residuals

* Look at the report, is this model better than the model with just mintemp?
* What does that tell us?

* But did you notice anything else weird?
* Negative abundances don't make sense
* Why do we have them?
* We'll come back to how to fix this in a couple of weeks
