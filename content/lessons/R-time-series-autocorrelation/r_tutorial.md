---
title: "R Tutorial"
weight: 3
type: book
summary: " "
show_date: false
editable: true
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
library(fpp3)
set.seed(1)
whitenoise = tsibble(sample=1:273, wn = rnorm(273, mean=0.18), index=sample)           
autoplot(whitenoise, wn) + geom_hline(yintercept=.18)
```
How biological does this look to you?

Now, let's look at the NDVI timeseries from portal that we were working with last week. So, just like last week, we'll load the data, turn the column with NDVI data into a tsibble object. And let's plot it to compare to the white noise.

```{r}
data = read.csv('portal_timeseries.csv')
data = mutate(data, month = yearmonth(date))
data_ts = as_tsibble(data, index=month)
autoplot(data_ts, NDVI) + geom_hline(yintercept=.18)

```

clearly the biological time series and the white noise series look different.

What did we learn about the NDVI time series last week? 

(Strong Seasonal signal)

What does a strong seasonal signal tell you about the dependence of the value at time t relative to t-1

(not independent)

that's clearly one major difference, related to that is that the value at one
time step is not necessarily independent from previous time steps. We can
explore that dependence by looking at lag plots. How much does one time step 
tell you about the next?

Lag plots are simply the correlation between values at time t and some time step in the past, where the lag is the amount of time between the two time points. 

```{r}
gg_lag(data_ts, NDVI, geom= "point") + labs(x= "lagged NDVI")
```
The lag.plot is showing you correlation within a time series, called autocorrelation. So in our top left panel, we have each data point plotted against the value one month prior, where the current or time t data point is on the y and the value one month ago is on the x. These plots go up to a 9 month lag. In lag one we see some correlation between this month and the previous month, and that signal breaks down over time. The different colors are the different months, which helps visualize if there are specific months that are outliers from the overall relationship.

We can quantify these relationships by calculating a correlation coefficient at each one of these lags. An autocorrelation function or ACF or correlogram conducts those correlations.

```{r}
ACF_results = ACF(data_ts, NDVI, lag_max=12)
ACF_results
```

As our lag plots suggested, our strongest correlation is at 1 month and the signal decays over time. ACF results are most often presented as graphs, so lets look at a typical ACF plot:

```{r}
autoplot(ACF_results)
```
A time series should always give you a correlation coefficient of 1 at a zero time lag, depending on the package you use, you may or may not get the 0 lag coefficient. So just make sure you check before you get excited about having a strong signal. This package does not give you lag zero

Our x-axis is tthe lag value in months.And again ,we see the strongest correlation is at a lag of 1 month, and then the autocorrelation in the time series drop off substantially. We get little blips every 12 months which is the seasonality coming through and perhaps a weak signal of a negative relationship around 4-8 month lags. 

the blue lines plotted are the 95% confidence interval for the autocrrelation of a time series (+- 1.96/(sqrt(T))), where T is the length of the time series. If more than 5% of spikes are outside this bound, your time series is probably not white noise. 

Let's see what white noise looks like in one of these graphs

```{r}
gg_lag(whitenoise, wn, geom= "point") + labs(x= "lagged value")

```
No relationship between the points, which is what we would expect sicne we deliberately pulled them without any dependence of one time point on the next. Let's look at the acf plot for this data

```{r}
ACF(whitenoise, wn, lag_max=12) |> autoplot()
```

No correlations go above the blue lines. You can sometimes get a spike edging above the blue lines even with white noise. Sometimes randomess can result in correlations but they should not be very strong. 

If there's a pattern to your spikes, that is usually another good sign that you have autocorrelation structure in your time series

**HAVE STUDENTS LOAD do the lag plot and ACF for precip and rodents. Tell them to do PPT first then rodents, their reaction to the rodent plot
will be a signal for when they've finished the exercise**

```{r}
gg_lag(data_ts, rain, geom= "point") + labs(x= "lagged value")
```
```{r}
ACF(data_ts, rain, lag_max=12) |> autoplot()
```
```{r}
ACF(data_ts, rodents, lag_max=12) |> autoplot()
```
```{r}
gg_lag(data_ts, rodents, geom= "point") + labs(x= "lagged value")
```
The slow decay in the ACF graph can indicate you have a trend in your data because if your time series is increasing over time, this month will be higher and next month will be higher and the lonth after that will be higher, which will generate correlations between your time points, not because the months are correlated but because of the trend. In time series analysis language your time series is non-stationary and many time series analyses would want you to detrend you data. So, let's look at the decomposition for our rodent data

```{r}
stl_rodents = data_ts |> model(STL(rodents ~ trend(window=21) + season(window = 13), robust = TRUE)) |> components() 
autoplot(stl_rodents)
```
We have long-term wiggles, but not really a strong trend. Another possibility is the echo of time periods past.

MAKE TIME SERIES GRAPH ON BOARD

If Y_t and Y_t-1 are strongly correlated and Y_t-1 and Y_t-2 are strongly correlated then presumably Y_t and Y_t-2 are correlated even if there is no causal factor involved. We can examine this by using a partial acf. The partial acf examines the correlations at a specific lag value, controlling for the lags at all shorter lags. 

We're going to use one of the functions in fpp3 that will give us both the ACF and the PACF graphs for the rodents.

```{r}
gg_tsdisplay(data_ts, rodents, plot_type=c("partial"))
```
HAVE STUDENT DO THIS FOR NDVI AND RAIN

```{r}
gg_tsdisplay(data_ts, NDVI, plot_type="partial")
```
```{r}
gg_tsdisplay(data_ts, rain, plot_type="partial")
```
So, unlike the NDVI, we have a really strong 1 month lag correlation  but very little seasonal autocorrelation in the data. 
The rodents show a classic signal of an autoregressive model. An autoregressive model is when the value at time t depends on the values at previous time steps. 

A classic autoregressive model is a random walk. To make a random walk we'll draw a series of random numbers from a normal distribution with mean=0 and standard deviation=1. We will save the same draw of numbers as x and w (ie. x and w are identical lists of random numbers). A random walk is where the value at time t is dependent on the value at time t-1. We'll make that time series by taking the value of w in a row and adding the value of x from the previous row. This creates the AR1 signal where there is a strong 1 time step autocorrelation in the time series.

```{r}
set.seed(1)
x = w = rnorm(1000)
for (t in 2:1000) x[t] = x[t-1]+w[t]
randomwalk = tsibble(sample=1:1000, rwalk = x, index=sample)
gg_tsdisplay(randomwalk, plot_type="partial")

```

you can use these plots to get a better understanding of your time series. What dynamics are occurring? What questions might be worth asking or what is surprising to you that doesn't seem to be coming through? If you are doing time
series modelling you can also use these graphs to help inform what structure
of a time series models makes the most sense given your data. I think Ethan
will be talking more about that next week.

Understanding your autocorrelation structure is also important statistically
Regression approaches with autocorrelated data will give underestimates of the variance inflated test statistics, and narrow CIs. 

Finally, sometimes you want to understand how two time series are correlated
across different lags. You can use the cross-correlation function to dig into that

```{r}
ccf.plantsrain = ccf(data_ts$rain, data_ts$NDVI)
```
These do both forwards and backwards lags. The first series listed is the one that gets lagged. In this case, we have reason to believe that PPT from the past influences NDVI in the future. 

Some take home messages for autocorrelation: 
1. Autocorrelation is useful in that information about the past and future states of the system are encoded in the timeseries. This is information that can potentially be leveraged for forecasting.
2. Autocorrelation is a statistical pain in the butt. Statistical approaches
Assume iid: independent and identically distributed errors. i.e. that your
data is a random draw from an underlying distribution. But autocorrelation
means that your data is not a random draw. Each draw is influenced by the
previous draw. This means that if you put a time series through a regression your confidence intervals will be smaller than they should be. Parameter estimates are generally ok. Need to deal with that autocorrelation for statistical tests many modern statistical approaches in R have a method for dealing or specifying autocorrelated errors - sometimes referred to as covariance in the errors.

