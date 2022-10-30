---
title: "Instructor Notes"
weight: 4
summary: " "
---

<script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

> What is parametric modeling and what are its limitations for modeling and forecasting?

* Model with specific mathematical form
* Don't know the true mathematical form, which can lead to incorrect fits/conclusions

> What are some example of non-linear dynamics in ecology?

* Species interactions influencing responses to environmental factors

> What is Empirical Dynamic Modeling and how is it different from parametric modeling?

* Equation free approach
* Model arbitrarily complex *F*
* Can capture the complexity of a multiple species/state system in a single
  species/state time-series
* Does this based on Taken's Theorem
    * Resconstruct a shadow of the real system from single time-series
    * Instead of relying on:

$$x_i(t+1) = F_i\left(x_1(t), x_2(t), \dots, x_d(t)\right)$$

* The system dynamics can be represented as a function of a single variable and its lags

$$x_i(t+1) = G_i\left(x_i(t), x_i(t-1), \dots, x_i(t-(E-1))\right)$$

* $E$ is the embedding dimension which defines how far back in time we go

> Describe what is happening with the Lorenz attractor (from the video)?

* Simple model of complex population dynamics
* Shows the abundances of three species at large number of points in time
* Individual population time series can be shown as the time-series for a single axis

> How does EDM address some of the limits of parametric modeling for forecasting ecological systems?

* Doesn't specificy a specific equation
* Determines what should happen next based on what happen next in the past when the system was in a similar configuration

> What are some potential the downsides of this approach? 

* Assumes the system is behaving like it used to
* Difficult to interpret

> Why is the Fraser River Sockeye Salmon fishery useful for comparing the EDM approach to parametric modeling approaches.

* Well studied system
* Established parametric approaches
* Long time-series with key co-variates

> What is parametric approach that the EDM is compared to?

* Ricker population growth

> How are forecasts from the Ricker model and EDM model compared?

* Ability to predict held out data from the end of the time-series

> How are environmental factors incorporated into EDM?

> How do the different modeling approaches compare in this system?

* EDM forecasts perform better in general
* Improvement is modest when just using population time-series
* Improvement is larger when incorporating environmental drivers

> Can EDM help infer the causal links among variables?

* In this case it suggests that the environmental drivers that are thought to be important to population dynamics do matter even though they were missed by the parametric approach
* By avoiding the limitations of specifying a parametric model this approach may provide better causal inference in some cases