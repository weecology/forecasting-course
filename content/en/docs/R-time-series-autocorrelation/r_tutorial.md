---
title: "R Tutorial"
weight: 3
description:
---
## Time Series Autocorrelation in R
### Video Tutorial

1. Watch Introduction to exploring autocorrelation
<iframe width="560" height="315" src="https://www.youtube.com/embed/iSfRh8nxAgI" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

2. Watch Generating randomt time series in R
<iframe width="560" height="315" src="https://www.youtube.com/embed/iO3yXnnSksM" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

3. Import portal_timeseries.csv in R using read.csv. 
Convert the NDVI data column into a time series object using ts(). Name that time series object: NDVI.ts
Convert the rodent column into a time series object using ts(). Name that time series object: rats.ts 
Convert the rain column into a time series object using ts(). Name that time series object: rain.ts
(Why am I telling you what to name these things? So that when I type code in the video, it is easier for you to follow along. That's all!)

4. Watch Exploring autocorrelation through lag plots
<iframe width="560" height="315" src="https://www.youtube.com/embed/V-4W8Wl-H9E" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

5. Generate a lag plot for rats.ts using lag.plot() 

6. Watch Using acf() in R to explore autocorrelation
<iframe width="560" height="315" src="https://www.youtube.com/embed/deV2SlJ2Dnw" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

7. Generate an acf plot for rain.ts using acf()
Generate an acf plot for rats.ts using acf()

8. Watch Autoregressive vs. moving average processes
<iframe width="560" height="315" src="https://www.youtube.com/embed/KXsYYhdkjgs" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

9. Watch Using pacf() to diagnose time lags for autoregressive models
<iframe width="560" height="315" src="https://www.youtube.com/embed/4W9uI4pjc8U" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

10. Using tsdisplay() examine the acf and pacf for NDVI.ts
Using tsdisplay() examine the acf and pacf for rain.ts

11. Watch Exploring lagged correlations between different time series
<iframe width="560" height="315" src="https://www.youtube.com/embed/dKDgihvtZGk" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

12. Plot the lag plot comparing NDVI.ts and rats.ts
Generate the ccf plot comparing NDVI.ts and rats.ts

13. Submit your r code (either as a file or cut and paste text) through the assignment for this module in the course canvas site.

---

Last week we talked about the different time scales as one type of signal that was embedded in a timeseries. This week we're going to talk about a different issue with time series. 

Let's start by thinking about an extreme case of a time series. 

DRAW ON BOARD NORMAL DISTRIBUTION CENTERED AT ZERO 

Say I have a normal distribution centered on zero and at each time step I randomly draw a value from the distribution. If I plotted this time series, what do you think it would look like? 

HAVE THEM WALK YOU THROUGH DRAWING THE TIME SERIES.

(the point you want them to get from this is that the choice of the value at time t is not dependent on its value at t-1)

So let's look at a random time series where the value at one time step has no dependence on the previous time step. This gives us a signal that we typically
call white noise.

We'll make a white noise time series by doing just what we said. We'll pull
273 values randomly from a normal distribution, which R already has a function for generating. We'll just use the default values of a mean of zero and sd=1

```{r}
set.seed(20)
whitenoise <- ts(rnorm(273, mean=0.18))           
plot(whitenoise, main="White noise")
abline(h=0.18)
```
How biological does this look to you?

Now, let's look at the NDVI timeseries from portal that we were working with last week. So, just like last week, we'll load the data, turn the column with NDVI data into a ts object. And let's plot it to compare to the white noise.

```{r}
data = read.csv('portal_timeseries.csv')
NDVI.ts = ts(data$NDVI, start = c(1992, 3), end = c(2014, 11), frequency = 12)
plot(NDVI.ts, xlab = "Year", ylab="greenness", main="NDVI")
abline(h=0.18)
```

clearly the biological time series and the white noise series look different.

What did we learn about the NDVI time series last week? 

(Strong Seasonal signal)

What does a strong seasonal signal tell you about the dependence of the value at time t relative to t-1

(not independent)

that's clearly one major difference, related to that is that the value at one
time step is not necessarily indpendent from previous time steps. We can
explore that dependence by looking at lag plots. How much does one time step 
tell you about the next?

Lag plots are simply the correlation between values at time t and some time step in the past. The difference btween time t and a value in the past is the lag. 

So here, let's plot all the lags up to 12 months.

```{r}
lag.plot(NDVI.ts, lags=12, do.lines=FALSE)
```

The lag.plot is showing you the autocorrelation within a time series. WHich
is great as a data viz step, but hard to interpret more precisely than to see
how the time series is related to itself and when things look more strongly related

To quantify these relationships we could calculate a correlation coefficient at each one of these lags. an autocorrelation function or ACF or correlogram conducts those correlationns  and plots them for us in a way that makes the autocorrelation structure of the time series easier to understand

```{r}
acf(NDVI.ts)
```


A time series should always give you a correlation coefficient of 1 at a zero time lag, depending on the package you use, you may or may not get the 0 lag coefficient. So just make sure you check before you get excited about having a strong signal

In this case, the x axis is the proportion of the annual frequency 
for the NDVI time series, but sometimes this is displayed in the actual units of the timeseries

For our NDVI time series, the strongest correlation is at a lag of 1 month, and then the autocorrelation in the time series drop off substantially. We get little blips every 12 months which is the seasonality coming through and perhaps a weak signal of a negative relationship at 6 month lags. 

the blue lines plotted are the 95% confidence interval for the autocrrelation of a time series (+- 1.96/(sqrt(T))). If more than 5% of spikes are outside this bound, your time series is probably not white noise. 

Let's see what white noise looks like in one of these graphs
```{r}
lag.plot(whitenoise, lag = 12, do.lines = FALSE)

```

```{r}
acf(whitenoise)
```

Basically no relationships but we do get a few spikes in the ACF peaking above our confidence interval, which is just what you expect from multiple comparisons.

If there's a pattern to your spikes, that is usually another good sign that you have autocorrelation structure in your time series

**HAVE STUDENTS LOAD data, create a TS object AND PLOT PPT AND RODENT. Tell
them to do PPT first then rodents, their reaction to the rodent plot
will be a signal for when they've finished the exercise**

```{r}
PPT.ts = ts(data$rain, start=c(1992,3), end = c(2014,11), frequency=12)
lag.plot(PPT.ts, lags=12, do.lines=FALSE)
```
```{r}
acf(PPT.ts)
```

```{r}
rats.ts = ts(data$rodents, start=c(1992,3), end = c(2014,11), frequency=12)
lag.plot(rats.ts, lags=12, do.lines=FALSE)
```

```{r}
acf(rats.ts)
```

Autocorrelation can echo through a time series. 

MAKE TIME SERIES GRAPH ON BOARD

If Y_t and Y_t-1 are strongly correlated and Y_t-1 and Y_t-2 are strongly correlated then presumably Y_t and Y_t-2 are correlated even if there is no causal factor involved. We can examine this by using a partial acf. The partial acf examines the correlations at a specific lag value, controlling for the lags at all shorter lags. 

```{r}
acf(NDVI.ts)

```

```{r}
pacf(NDVI.ts) # note pacf starts at lag1 not 0 so this can confuse people
```


FOrecast package has a nice feature that let's you look at the time series, the acf, and pacf at the same time

```{r}
library(forecast)
tsdisplay(NDVI.ts)
```

HAVE STUDENT DO THIS FOR RODENTS AND RAIN

```{r}
tsdisplay(rats.ts)
```
```{r}
tsdisplay(PPT.ts)
```

The rodents show a classic signal of an autoregressive model. WHat is an autoregressive model? Something where the value at time t depends on the values at previous time steps. 

A classic autoregressive model is a random walk:

```{r}
set.seed(1)
x = w = rnorm(1000) # I will be drawing both x and the change from x from the  #same normal distribution
for (t in 2:1000) x[t] = x[t-1]+w[t]
tsdisplay(x)
```


you can use these plots to get a better understanding of your time series. What dynamics are occurring? What questions might be worth asking or what is surprising to you that doesn't seem to be coming through? If you are doing time
series modelling you can also use these graphs to help inform what structure
of a time series models makes the most sense given your data. I think Ethan
will be talking more about that next week.

Understanding your autocorrrelation structure is also important statistically
Regression approaches with autocorreated data will give underestimates of the variance inflated test statsitics, and narrow CIs. 

Finally, sometimes you want to understand how two time series are correlated
across different lags. You can use the cross-correlation function to dig into that

```{r}
ccf.plantsrain = ccf(PPT.ts, NDVI.ts)
```
These do both forwards and backwards lags. The first series listed is the one that gets lagged. In this case, we have reason to believe that PPT from the past influences NDVI in the future. 
```{r}
library(astsa)
lag2.plot(PPT.ts, NDVI.ts, 12)
```
lag2.plot provides the crosscorrelation value and the loess fit (which can be non-linear).

```{r}

ccf.plantrat = ccf(NDVI.ts, rats.ts)
lag2.plot(NDVI.ts, rats.ts, 12)
```



Some take home messages for autocorrelation: 
1. Autocorrelation is useful in that information about the past and future states of the system are encoded in the timeseries. This is information that can potentially be leveraged for forecasting.
2. Autocorrelation is a statistical pain in the butt. Statistical approaches
Assume iid: independent and identically distributed errors. i.e. that your
data is a random draw from an underlying distribution. But autocorrelation
means that your data is not a random draw. Each draw is influenced by the
previous draw. This means that if you put a time series through a regression your confidence intervals will be smaller than they should be. Parameter estimates are generally ok. Need to deal with that autocorrelation for statsitical tests many modern statsitical approaches in R have a method for dealing or specifying autocorrelated errors - sometimes referred to as covariance in the errors.

