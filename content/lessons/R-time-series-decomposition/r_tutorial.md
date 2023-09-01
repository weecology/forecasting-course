---
title: "R Tutorial"
weight: 3
type: book
summary: " "
show_date: false
editable: true
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

## Inherent scales within a time series


Talk about scales within the data often our data has some frequency of collection within a year interested in either focusing on that scale, or removing the effects of other scales. For example - seasonally adjusted housing sales or unemployment.

## What is time series decomposition
A time series approach for trying to pull out the signals at different scales. Breaks down a time series into the trend, seasonal, and "irregular" fluctuations. Looks at a graph of atmospheric CO2 (https://www.climate.gov/news-features/understanding-climate/climate-change-atmospheric-carbon-dioxide). Two scales of variation should pop out at you! What do you think they are?

These scales of dynamics are not always as apparent to the unaided eye as the CO2 dynamics are. To isolate the dynamics at these different scales and think about them, we can use an approach called time series decomposition. The output from time series decomposition can be used for analyses - for example, seasonally-adjusted data is data that has gone through some form of time series decomposition to pull out the seasonal signal. Even if you don't need seasonally adjusted data, time series decomposition can be a good data vizualization approach for better understanding your time series and whats going on and what you might need to think about.

There are a variety of time series decomposition approaches, but they all boil down to 3 basic steps.
1) we fit something to the observed data to extract the trend.
2) we fit a seasonal model to the remaining data to pull out the season
3) whatever is left over it the irregular fluctuations (residuals)

## Decomposing a time series

### Working with data as a ts object. 
Let's read in our data:
```{r}
data = read.csv('portal_timeseries.csv', stringsAsFactors = FALSE)
head(data)
```
This is a data file that we will be using for the next few weeks. This data is from my field site in Arizona. At my field site, called the Portal Project, we monitor rodents, plants, and weather. I've given you data here for each of these components: rodent abundance, precipitation amount in mm, and the plant data I've given you is actually NDVI, which is a measure of greenness that comes from satellites. This data is given in a format where each data point is associated with a specific month. Our data is not collected exactly a month apart, but this approach requires regularly collected data, so I've fudged things to make this data fit the constraints of this approach. You'll see that I have a date column that is not in the international date format. The first column is just a row index that I forgot to suppress when I made this file.

## Converting data to a format better suited for timeseries analyses
As we talked about on Thursday, dates and times have their own rules for how they operate and to simplify working with time series data, many packages require the data to be loaded into special formats that help the computer recognize and work with the data correctly. We're going to be working with the fpp3 package which was written by forecasters to help teach and conduct forecasting. fpp3 is a metapackage, which is a package that bundles multiple packages together. Ethan may have you work with the individual packages more directly, but we're going to start by letting fpp3 make things easy for us as we learn. Fpp3 uses a special format called a tsibble. A tsibble is essentially a nicely formatted dataframe that is designed specifically for time series data. 

```{r}
library(fpp3)
```
Our first step is to take the date in our datafile and turn it into a date. We're going to use the function mutate which is a dplyr command to take an existing column and transform it into something new. In this case, we're going to take our badly formatted dates and convert them into year-month information. You may wonder why year month and not into a date? Many of the time series analyses require regularly collected data - monthly, daily, quarterly, annually. Our data is collected roughly monthly, so we're dropping the day information and turning it into a monthly time series.
```{r}
data = dplyr::mutate(data, month=tsibble::yearmonth(date))
class(data$month)
```
So we're dealing with a different type of date object - the yearmonth, which is not a date object but works in a similar way but with months and years. Let's see how this looks in our dataframe.

```{r}
head(data)
```
We've got a row index column that I forgot to supress when I made this file. We have three value columns - NDVI, rain, and rodents. We have our original date column, which is being stored as character data, and our yearmonth column. 
I imagine you're wondering why we dropped the day information. Many time series analyses require regularly sampled data. It can be hourly, daily, monthly, yearly, even quarterly, but there needs to be a regular spacing to the timing. Many time series approaches also struggle with gaps in the data - so missed months. The data you're working with is a processed version of our data where we have filled gaps by estimating the missing values and forced the data into a monthly structure. Later in the semester we'll learn an approach that can deal with irregular data but it is a lot more complicated, so we're going to start by working with the foundational analyses that require this regularity.

We're now doing to turn our datafile into a special type of data storage device called a tsibble. A tibble is essentially a dataframe. A tsibble is a time series tibble designed specifically to hold time series data and can hold multiple time series in the same object. We're going to give it our data and tell it where the time information is.

```{r}
data_ts = tsibble::as_tsibble(data, index=month)
head(data_ts)
```
Nothing has changed in how the data looks, except it is now identified as a tsibble.

We can work with our tsibble like we would work with a dataframe using the commands in the dplyr package. We can drop columns we no longer want

```{r}
data_ts = select(data_ts, c(-date, -X))
```

We can create subsets of our data, so if we only want the data after 2000.

```{r}
ts_2000 = filter(data_ts, month > yearmonth("1999 Dec"))
```

And we can plot our data

So, for example, we can plot this time series object without specifying the x or y axis because R knows this is a time series. We're going to use autoplot which is a function in R that automatically generates different types of plots based on the data object passed to it. We're going to give it our tsibble and the NDVI data and it will understand that this is a time series where the date information is being stored in the column we gave it when we created the tsibble.

```{r}
autoplot(data_ts, NDVI)

```
So here is the plot. As you can see we have a highly variable NDVI signal over time. We see some strong peaks and troughs, we see some regions with lower peaks and higher peaks that span multiple years. And there is a considerable amount of just variation over the time series.

In every time series, there will be these multiple level of information - the variation happening from time step to time step, the variation happening over a sub-annual time scale (if you have sub-annual data), and the pattern that emerges over multiple years - increases over time or long-term cycles. 

We can think about this with the following equation. 
Observed value = Trend + Seasonal Signal + Residual Variation

The goal of time series is to extract these different time scales of patterns so we can better understand the dynamics occuring in our data.
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
To do this, we're going load yet another package slider, which calculates the moving average values, and create a new column in our tsibble so that these moving averages are still associated with our time variable. In slider, we tell the function how many time steps before and after each time point we want to include in our moving average. If I want a ma=13 how many months before and after should I tell it?

* 6 and 6 *

```{r}
library(slider)
data_ts = data_ts |> mutate('ma_13' = slide_dbl(NDVI, mean, .before = 6, .after=6, .complete=TRUE))

```
.complete is an argument that tells slider to only calculate the moving average for a time point if it has data for the full window before and after the time point. 

This will become a little clearer when we look at our tsibble

```{r}
head(data_ts)
```
These values at the beginning of the time series are missing because slider cannot make a complete window. 6 months before the very first time point there is no data. If you scroll down to the bottom of the datafile, you'll see the same thing. 

Now let's look at what this smoothed time series looks like, plotted over top of our observed monthly data
```{r}
autoplot(data_ts,NDVI) + autolayer(data_ts, ma_13, color="blue", lwd=1)
```
What the moving average does is smooths over the short-term variation in the time series, allowing the long-term patterns to emerge. This is the first step in class decomposition methods.  Larger window sizes will smooth the data further, but at the expense of fewer and fewer time points as the ends of the time series get truncated. 

The next step in time series decomposition is to remove the trend from the observed data to see what is left over. Let's look at our plot again and think about what impact this might have on our NDVI. The trend is picking up the decline in 

Monthly Data - Moving Average Value for each month = Remaining_info (includes seasonal and other signals)

```{r}
data_ts = data_ts |> mutate("detrend" = NDVI - ma_13)
autoplot(data_ts, detrend, color="blue") + autolayer(data_ts, NDVI)
```
So we've pulled out the trend. We can see that our y-axis has been reset 


Our next step in time series decomposition is to extract the seasonal signal. 

The most basic way to extract a seasonal signal is to calculate the long-term average for each month. So take the January values for every year and generate an overall January  average and so on. Those average monthly values constitute our seasonal signal. To remove the seasonal signal from our data, to get the residual variation If we then correct out the monthly values like we did for the trend values, we have the signal in our data that cannot be explained by a long-term trend in the data or seasonal signals.

Detrended monthly data - monthly long-term average = residual variation

Instead of doing this by hand, in the interest of time, we're going to jump to a function that will do a decomposition for us

```{r}
add_decomp = data_ts |> model(classical_decomposition(NDVI, type = 'additive')) |> components()
add_decomp
```
we see the missing values at the beginning of the trend, the seasonal values, and the left over residual variation.
```{r}
autoplot(add_decomp)

```
We see the original time series at the top. Followed by our trend, our seasonal signal, and the random or residual variation. The y-axis scale changes with each graph. Ignore the bars they are not essential to understanding time series and only this group does it.

The trend shows us what we saw before, more or less. The one difference is that they've done something complicated to get a ma-12 which involves doing a moving average on top of a moving average. The function autodetects that we have monthly data and does it. I poked around in the function and did not see a way to change the moving average order, but in other packages you can specific things more. 

At the bottom is all the variation i nthe data that could not be epxlained by the other time scales. 

Notice anything odd about the seasonal signal?

*It's extremely regular**

Different approaches make different assumptions about the stability of the seasonal signal. Because the seasonal signal is calculated as the average value for each month, this approach assumes that there is no change in the pattern of seasonality.

## STL Decomposition ##

If we want more flexibility in our seasonal signal, we have to use a more complicated approach. STL decomposition (Season Trend decomposition using Loess) is a slightly different approach for extracting the components from the time series. The residuals from these regressions contain the seasonal and residual variation. To extract the seasonal signal, the STL still calculates the average value for each month, but instead of using all years, it uses a sliding window of years to calculate the January average.

**Illustrate on Board**

And again, the residual or random variation is everything that is left over.
```{r}
stl_output = data_ts |> model(STL(NDVI ~ trend(window=21) + season(window = 13), robust = TRUE)) |> components()
```
Window sizes must be odd. For trend, window size is the number of consecutive months of data used to fit the regression. For season this is the number of consecutive  years of a month's data to be used for the seasonal signal. Robust = True invokes procedures that keep STL from being overly influenced by extreme points when conducting the trend and seasonal analyses. We're using 21 and 13 here because these are actually the default values of the function. We'll change those in a minute. 

```{r}

autoplot(stl_output)
```
Our trend looks different in part because of the approach but also because 21 months is much larger than the window size we were using with classic decomposition. The big difference though, is in our seasonal signal, where we now see a shift in our seasonal signal over time where our insead of 2 peaks per year, we seem to be moving more towards 1 very large peak in our plan productivity at the site. 

Let's force the stl to be more similar to our classic decomposition:

```{r}
data_ts |> model(STL(NDVI ~ trend(window=13) + season(window = "periodic"), robust = TRUE)) |> components() |> autoplot()
```
A little more movement in the trend data and our regular seasonal signal has returned. 

How do you choose reasonable window sizes? Frankly, it's an art not a science. Time series decomposition is taking the inherent variation in the data and trying to pars eout what seems to be related to long-term annual and seasonal patterns versus random fluctuations. As such, you generally want there to be no clear long-term signals in your remainder and a long-term signal sneaking through is often a sign that you have windows that are two large (therefore not picking up shorter-term long-term fluctuations). So for example, imagine a system where every 12 months the system flips from a productive to an unproductive one. In a productive year, every month is above average and during an unproductive year, every month is below average. A 21 month window is going to average over that to some extent, because it will combine good years and bad years. STL's flexible seasonal approach also won't pick that up, because it will be averaging 13 years of january, february, etc. So that variability will end up in the residuals as a signal. So, looking at your remainder graph and examining it for signal is the best approach to figuring out if your window sizes make sense.

For our STL, I think you could argue that the seasonal signal is leaking through to the residuals. Those strong peaks that are occurring with some regularity could be because the seasonal signal is not changing quickly enough to absorb the speed of the dynamics. 

```{r}
data_ts |> model(STL(NDVI ~ trend(window=21) + season(window = 7), robust = TRUE)) |> components() |> autoplot()
```

And now we seem something that is a little more balanced in the remained. We have both troughs and peaks. The regularity and magnitude of the peaks have been reduced. Having some knowledge of your system and data will be useful in making these types of decisions. 

