---
title: "R Tutorial"
weight: 3
type: book
summary: " "
show_date: false
editable: true
---

## Objectives

We'll model and forecast abundance data for *Dipodomys ordii*.

```{r, message = FALSE}
# package dependencies
library(ggplot2)
library(portalr)
library(rEDM)
```

## Data

* Download the data

```{r}
rodent_data = abundance()
do_data = data.frame(period = rodent_data$period, abundance = rodent_data$DO)

ggplot(do_data, aes(x = period, y = abundance)) +
  geom_line()
```

## Theory

* Multi-species system
* Population dynamics model would have ~10 state variables (abundance of each species)
* Each at *t* time steps
* If deterministic those 10 values at time *t+1* are fully determined by the values at *t*
* Can write this as:

{{< math >}}
$$\bar{x}(t+1) = F \left(\bar{x}(t)\right)$$
{{< /math >}}

* Could assume some parametric shape (e.g., logistic growth):

{{< math >}}
$$\begin{align*}
x_1(t+1) &= r_1 x_1(t) \left[1 - x_1(t) - \alpha_{1,2} x_2(t)\right]\\
x_2(t+1) &= r_2 x_2(t) \left[1 - x_2(t) - \alpha_{2,1} x_1(t)\right]
\end{align*}$$
{{< /math >}}

with parameters {{< math >}}$r_1, r_2, \alpha_{1,2}, \alpha_{2,1}${{< /math >}}.

* But we might get the form wrong
* And there are typically way more than 2 species even if we're only studying 2

## Empirical Dynamic Modeling

* Model arbitrarily complex *F*
* Can capture the complexity of a multiple species/state system in a single
  species/state time-series
* Does this based on Taken's Theorem
    * Reconstruct a shadow of the real system from single time-series

In other words, instead of relying on:
{{< math >}}
$$x_i(t+1) = F_i\left(x_1(t), x_2(t), \dots, x_d(t)\right)$$
{{< /math >}}

the system dynamics can be represented as a function of a single variable and its lags:
{{< math >}}
$$x_i(t+1) = G_i\left(x_i(t), x_i(t-1), \dots, x_i(t-(E-1))\right)$$
{{< /math >}}

* {{< math >}}$E${{< /math >}} is the embedding dimension which defines how far back in time we go

## Usage

* Need to estimate {{< math >}}$G_i${{< /math >}} from the data
* Typically think of this as fitting an equation, but $G$ is arbitrarily complex
* And since we're focusing on prediction we don't need the equation, we just need to know what is going to happen next
* And we can get this prediction by looking through the existing time-series and finding periods that look like the current period (*draw example*)
* These historical periods should reflect the same dynamics of $G$ and therefore the same state variables in $F$
* Which should mean that what happens next in these periods should match what happens next now.
* Use the simplest, simplex projection
* Weighted nearest-neighbors approximation:

1. Have value of {{< math >}}$x${{< /math >}} and its lags at time {{< math >}}$t${{< /math >}}. Then we want a prediction of {{< math >}}$x(t+1) = G\left(x(t), x(t-1), \dots, x(t - (E-1))\right)${{< /math >}}.
2. We look for {{< math >}}$j = 1..k$ {{< /math >}}nearest neighbors in the observed time series such that
{{< math >}}
$$\begin{multline}
\langle x(t), x(t-1), \dots, x(t - (E-1))\rangle \\ \approx \langle x(n_j), x(n_j-1), \dots, x(n_j - (E-1))\rangle
\end{multline}$$
{{< /math >}}
3. We then suppose that {{< math >}}$x(t+1) \approx x(n_j+1)${{< /math >}}.

* Use a distance function to judge how similar {{< math >}}$\langle x(t), x(t-1), \dots, x(t - (E-1))\rangle${{< /math >}} is to {{< math >}}$\langle x(n_j), x(n_j-1), \dots, x(n_j - (E-1))\rangle${{< /math >}}
* Estimating {{< math >}}$x(t+1)${{< /math >}} as a weighted average of the {{< math >}}$x(n_j+1)${{< /math >}} values with weighting determined by the distances.


## Determining Embedding Dimension

* Need to know {{< math >}}$E${{< /math >}}, how many lags to use for determining if time-series is similar
* Split the data to reserve some for forecasting

```{r}
n <- nrow(do_data)
lib <- c(1, floor(2/3 * n))      # indices for the first 2/3 of the time series
pred <- c(floor(2/3 * n) + 1, n) # indices for the final 1/3 of the time series
```

* Fit 10 different embedding dimensions (1:10) see how well they work

```{r}
simplex(do_data,                     # input data (for data.frames, uses 2nd column)
        lib = lib, pred = lib,   # which portions of the data to train and predict
        E = 1:10)                # embedding dimensions to try
```

* Output shows how well the model "predicted" on the given data
* Focus on measures of fit/error:
    * rho (correlation between observed and predicted values, higher is better)
    * mae (mean absolute error, lower is better)
    * rmse (root mean squared error, lower is better)
* {{< math >}}$E${{< /math >}} of 4 or 5 is optimal
* Use 4 for simpler model
* Use to forecast the remaining 1/3 of the data.

## Forecasts

* Similar code for forecasting for the last 1/3 of the time series
* To store predicted values add `stats_only` argument

```{r}
output <- simplex(do_data,
                  lib = lib, pred = pred,  # predict on last 1/3
                  E = 4, 
                  stats_only = FALSE)      # return predictions, too
```

* Output is a data.frame with a list column for the predictions

```{r}
predictions <- output$model_output[[1]]
str(predictions)
```

* Plot the predictions against the original data

```{r}
ggplot(do_data, aes(x = period, y = abundance)) +
  geom_line() +
  geom_line(data = predictions, mapping = aes(x = period, y = Predictions), color = 'blue')
```

* Also have estimate of the prediction uncertainty in `Pred_Variance`
* Variance of the prediction
* Plot a 95% prediction interval use {{< math >}}$\pm 2 * SD${{< /math >}}

```{r}
ggplot(do_data, aes(x = period, y = abundance)) +
  geom_line() +
  geom_line(data = predictions, mapping = aes(x = period, y = Predictions), color = 'blue') +
  geom_ribbon(data = predictions,
              mapping = aes(x = period,
                            y = Predictions,
                            ymax = Predictions + 2 * sqrt(Pred_Variance),
                            ymin = Predictions - 2 * sqrt(Pred_Variance)),
              fill = 'blue',
              alpha = 0.2)
```


* This is a single time step forecast
* For multi-step forecasts we can take these one step ahead forecasts along with their
  uncertainties and increment forward for multi-step forecasts as you'll see later in the
  week in a different context.
* Or we can train the model to make forecasts the number of steps ahead that we want
* We do this using `tp`

```{r}
output <- simplex(do_data,
          lib = lib, pred = pred,  # predict on last 1/3
          E = 10,                  # predicting 6 steps ahead is different model;
                                   # selecting a different E is recommended, and
                                   # a higher E for a more complex model is sensible
          tp = 6,
          stats_only = FALSE)      # return predictions, too

predictions <- output$model_output[[1]]

ggplot(do_data, aes(x = period, y = abundance)) +
  geom_line() +
  geom_line(data = predictions, mapping = aes(x = period, y = Predictions), color = 'blue')
```

* The model performs less well the longer the "forecast horizon" or distance into the future we ask it to predict, which is a common feature of real world forecasts.