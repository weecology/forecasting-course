---
title: "R Tutorial"
weight: 3
summary: " "
---
## Time Series Decomposition in R
### Video Tutorial

1. Watch Introduction to time series decomposition
<iframe width="560" height="315" src="https://www.youtube.com/embed/D45ddUVcEfY" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

2. Watch Loading data for time series decomposition in R
<iframe width="560" height="315" src="https://www.youtube.com/embed/qVDAxVx6D_Q" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

3. Convert date column into a date format, using as.Date()

4. Watch Importing data into a time series object in R
<iframe width="560" height="315" src="https://www.youtube.com/embed/OXrn7hI08TI" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

5. Convert the rodent column into a time series object using ts()

6. Watch Identifying the Long-term Signal in a Time Series
<iframe width="560" height="315" src="https://www.youtube.com/embed/2wcUuTqrj60" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

7. Watch Conducting a moving average in R
<iframe width="560" height="315" src="https://www.youtube.com/embed/16ClJ5piZW4" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

8. Do a moving average with the rodent time series object using ma()

9. Watch time series decomposition: removing the long-term signal
<iframe width="560" height="315" src="https://www.youtube.com/embed/oxMZ_cVUTP0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

10. Watch multiplicative vs. additive time series decomposition in R
<iframe width="560" height="315" src="https://www.youtube.com/embed/iG9pOaQmvJs" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

11. Pull the trend out of the rodent time series object, using either the additive or multiplicative approach

12. Watch Using decompose() to do a time series decomposition in R
<iframe width="560" height="315" src="https://www.youtube.com/embed/nYAQMnAguQ8" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

13. Apply decompose() to the rodent time series object


14. Watch Using Season Trend Decomposition using Loess (stl) in R
<iframe width="560" height="315" src="https://www.youtube.com/embed/Y8OHQjcYEjU" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

15. Use stl() on the rodent time series object

16. Watch Time Series Decomposition Wrap up
<iframe width="560" height="315" src="https://www.youtube.com/embed/v3dkh4YnX5w" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

17. Submit your r code (either as a file or cut and paste text) through the assignment for this module in the course canvas site
---

### Written version of the lesson. It will vary from the videos, but the core info is the same.
### You may find it helpful to watch the videos without "in R" in their title as these are more informative videos with visuals that are not  present in the written document.
---
title: "Decomposition"
author: "Morgan Ernest"
date: "September 20, 2018"
output: html_document
---
## Inherent scales within a time series


Talk about scales within the data often our data has some frequency of collection within a year interested in either focusing on that scale, or removing the effects of other scales. For example - seasonally adjusted housing sales or unemployment.

## What is time series decomposition
A time series approach for trying to pull out the signals at different scales. Breaks down a time series into the trend, seasonal, and "irregular" fluctuations. Looks at a graph of atmospheric CO2 (https://www.climate.gov/news-features/understanding-climate/climate-change-atmospheric-carbon-dioxide). Two scales of variation should pop out at you! What do you think they are?

These scales of dynamics are not always as apparent to the unaided eye as the CO2 dynamics are. To isolate the dynamics at these different scales and think about them, we can use an approach called time series decomposition. The output from time series decomposition can be used for analyses - for example, seasonally-adjusted data is data that has gone through some form of time series decomposition to pull out the seasonal signal. Even if you don't need seasonally adjusted data, time series decomposition can be a good data vizualization approach for better understanding your time series and whats going on and what you might need to think about.

There are a variety of time series decomposition approaches, but they all boil down to 3 basic steps.
1) we fit something to the observed data to extract the trend.
2) we fit a seasonal model to the remaining data to pull out the season
3) whatever is left over it the irregular fluctuations (residuals)

## Time Series Objects

To do a time series decomp using existing packages, we need our data to be a time series object. This is a data format, like a dataframe is a format, that has a special structure and R knows to work with it in a special way.

Some packages will require you to put your data into a time series object specific to that package. For today, we will use the standard ts object in the base package. It's limitation is is that it can only take regularly spaced data (i.e. monthly, daily, quarterly, annual). There are other methods that can take irregular data and import that into a time series object. Packages that can handle irregular data include zoo and xts.

## Decomposing a time series

### Working with data as a ts object. 
Let's read in our data:
```{r}
data = read.csv('portal_timeseries.csv', stringsAsFactors = FALSE)
head(data)
```
This is a data file that we will be using for the next few weeks. This data is from my field site in Arizona. At my field site, called the Portal Project, we monitor rodents, plants, and weather. I've given you data here for each of these components: rodent abundance, precipitation amount in mm, and the plant data I've given you is actually NDVI, which is a measure of greenness that comes from satellites. This data is given in a format where each data point is associated with a specific month. Our data is not collected exactly a month apart, but this approach requires regularly collected data, so I've fudged things to make this data fit the constraints of this approach. You'll see that I have a date column that is not in the international date format. The first column is just a row index that I forgot to supress when I made this file.


Before we turn this data into a time series object to work with, we need to make sure that the data is already in chronological order. ts does not use the date info when the object is made. 

So, let's make sure the data is ordered and review what we know about dates. Do I need to turn the date column into a date format before sorting? Why?

**Yes because in this format, it will group things by month, no int chronological order**

How do we do this?

```{r}
data$date = as.Date(data$date, format="%m/%d/%Y")
class(data$date)
```

Now, we'll sort this by date then today 

```{r}
data = data[order(data$date),]
```

I just want to focus on the NDVI data,so we'll pull that data out and turn it into a ts object. When we turn data into a timeseries object, we do not give it a date column, we tell the computer when the start and stop dates are and how frequently the data is collected. So, let's get the info and then create a time series object with the NDVI data.
```{r}
min(data$date)

```

```{r}
max(data$date)
```
```{r}
NDVI.ts = ts(data$NDVI, start = c(1992, 3), end = c(2014, 11), frequency = 12)
head(NDVI.ts)
```

We're used to data being stored as a column for date and a column with data, but in a time series object there is no date column to call. But R is storing that date info and knows how to work with something in this format. 
```{r}
# NDVI.ts
```

So, for example, we can plot this time series object without specifying the x or y axis because it knows this is a time series. 

```{r}
plot(NDVI.ts, xlab = "Year", ylab="greenness")
```

You cannot slice and dice a ts object without losing the date info, unless you
use a special tool
```{r}
data.2000 = window(NDVI.ts, start=c(1999,1),end=c(2000,12))
data.2000
```

### Extracting a trend

So what we're going to do know is work through what time series decomposition is doing. 

**Draw a multi-year time series on the board running with a section demarking months**

The first step in time series decomposition is removing any long-term trends or cycles in the data. A moving average is a classic way of extracting the 'cross year' pattern in the data. What a moving average is doing is smoothing over the high frequency, or shorter-term fluctuations in the data so that the large-scale movements in the data become more apparent.

When conducting a moving average, we need to tell the computer the size of the window we're averaging over. This is called the order. So a MA-5 was a window 5 time units wide. Which means for May, we are averaging values from march-july. 

One issue with moving averages is that we lose data on the front and back because as the name implies it is averaging over a window of values - if there is no march or july, it won't calculate a moving average value for any window missing that data.

What happens if the window is an even number?

**Unbalanced average.**

These are typically odd so that the window is balanced. But can do an even order MA by doing 2 x m-MA

So, let's do a moving average on this data. To do this, we're going to be using the package forecast which has a lot of handy and simple time series analysis functions in it.
```{r}
library(forecast)
MA_m13 = ma(NDVI.ts, order=13, centre = TRUE)
```

I used an order of 13 to get a roughly annual average (it's an average of the 6 months before and after the focal month)

```{r}
plot(NDVI.ts)
lines(MA_m13, col="blue", lwd = 3)
```
```{r}
#if get even question
MA_m12 = ma(NDVI.ts, order=12, centre = FALSE)
MA_2x12 = ma(MA_m12, order=2,centre=FALSE)
plot(NDVI.ts)
lines(MA_2x12, col="green", lwd = 3)
```
Classic Decomposition uses a Moving Average to obtain a trend, then detrend the observed data.

Monthly Data - Moving Average Value for each month = Remaining_info (includes seasonal and other signals)

two basic ways to remove a seasonal signal - additive or multiplicative. 
Additive: Observed = Trend + Seasonal + Irregular (fluctuations in the time series stable with trend)

Multiplicative Observed = Trend*Seasonal*Irregular (fluctuations in the time series increase with trend)


```{r}
Seasonal_residual_add = NDVI.ts - MA_m13
plot(Seasonal_residual_add)
```

```{r}
Seasonal_residual_multi = NDVI.ts/MA_m13
plot(Seasonal_residual_multi)
```

So, we've pulled out the trend. What does this plot represent? What's still left in here?

*Seasonal signal and the "random" signal. The next step is to disentangle those two signals.*

We walked through pullig out the trend signal because I wanted you to have a basic understanding of what's going on with decomposition approaches. But we don't have to disentangle allthese signals by hand. There are packages that do this. 

So let's take our NDVI data and run it through one of these standard decomposition packages.


```{r}
fit_add = decompose(NDVI.ts, type = 'additive')
plot(fit_add)
```

The decompose function oes all of this for us and we can then plot the results. We get the raw data on top, the trend from the moving average next, the seasonal signal, and then the movement in the data that cannot be explained from these other processes.

You cansee the loss of data that occurs at the edges of the time series. 

We clearly have g fluctuations from year to year in NDVI, but there's no pattern of increasing NDVI through time. We also have a clear seasonal signal. Tthe large peak  iis our summer growing season, and thhe smaller peak is our winter growiing season. 

Notice anything odd about the seasonal signal?

*It's extremely regular**

Different approaches make different assumptions about the stability of the seasonal signal. This approach assumes that there is no change in the pattern of seasonality - except an effect of trend magnitude in the multiplicative model. 

At the other end of the spectrum is STL decomposition (Season Trend decomposition using Loess). This is a slightly different approach for extracting the components from the time series. Instead of a moving average, it uses locally weighted regressions over the window. It does this iteratively as it also calculates the seasonal fits, so your trend for the same window size can be different depending on your season window.

Advantages: Seasonal component can change through time, user can control the trend averaging, can control sensitivity to outliers. 

Drawbacks: only additive. Can make it give you a multiplicative requires logs and back transformations.

t.window controls the trend window. NUmber of consecutive observations to use when estimating trend
s.window controls the season window. NUmber of years to use to estimate seasonal
robust uses approach which is less sensitive to outliers.

How to choose windows sizes for seasonal vs. trend. An art. 
But there are some rules to the art. First, the trend window must be
larger than the season window - odd orders
(1.5* number of observations in a seasonal cycle)/(1-1.5*seasonal smooth order^-1) for monthly data, the number of observations in a seasonal cycle is 12, so it should be 23. the stl function will automatically calculate that if we leave t.window unspecified


```{r}
fit_stl = stl(NDVI.ts, s.window=19, robust=TRUE)
fit_stl$win
```

l.window is the span or lags for the loess window.


```{r}
plot(fit_stl)
```

```{r}
fit_stl_periodic = stl(NDVI.ts, s.window='periodic', robust=TRUE)
plot(fit_stl_periodic)
```

```{r}
fit_stl_5yr = stl(NDVI.ts, t.window = 61, s.window=13, robust=TRUE)
plot(fit_stl_5yr)
```

```{r}
library(stlplus)
season_window = 7
min_twindow = as.integer(1.5*12/(1-1.5*season_window^-1))
```

```{r}
s_7 = stlplus(NDVI.ts, s.window = season_window, t.window = min_twindow)
plot_seasonal(s_7)
```
wiggles are bad and means that the s.window is not large enough. You want to capture the trend in the seasonal signal, not the year to year variation in the seasonal signal.

```{r}
season_window = 19
min_twindow = (1.5*12)/(1-1.5*season_window^-1)
s_19 = stlplus(NDVI.ts, s.window = season_window, t.window = min_twindow)
plot_seasonal(s_19)
```

```{r}
stl_s19 = stl(NDVI.ts, s.window=19, robust=TRUE)
plot(stl_s19)
```

