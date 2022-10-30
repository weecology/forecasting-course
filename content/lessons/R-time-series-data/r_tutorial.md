---
title: "R Tutorial"
weight: 3
summary: " "
---
## Handling Dates and Times in R
### Video Tutorial

1. Watch Introduction to dates and times
<iframe width="560" height="315" src="https://www.youtube.com/embed/mZ3qiSGcWKw" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

2. Watch Importing dates
<iframe width="560" height="315" src="https://www.youtube.com/embed/gcCmQRiweXo" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

3. Watch Issues with character dates
<iframe width="560" height="315" src="https://www.youtube.com/embed/2p1grj-f_iA" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

3. Watch Formatting dates
<iframe width="560" height="315" src="https://www.youtube.com/embed/NmVIPNk85yI" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

4. On your own, create some new dates in R and use as.Date() and the date formatting codes to read in different date formats.

5. Watch Importing Dates with Times
<iframe width="560" height="315" src="https://www.youtube.com/embed/yAAgJm9zgqQ" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

6. On your own, format the datatime$datetime column using posixlt()

7. Watch Using Lubridate
<iframe width="560" height="315" src="https://www.youtube.com/embed/8XR14F7CdmE" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


### Written notes (may vary slightly from video in details, but main content is the same)

If you are working with data, what are the different ways you could write today's date?

**September 7th 2017, 9-7-2017, 9-7-17, Sept 7 2017 7-9-2017, 9/7/2017**

What are some issues you see with this? How do you think a computer would see these different styles for dates? As the same thing? Or as different things? How would it know what is a day or month or year?

We're going to explore today what the challenge is for communicating dates and times to computers and learn to use some tools that will make it easier for us to tell the computer what we want in a way that lets both it and us interpret date-times accurately.

First, we need to load a package. We'll do some plotting today, so we'll load up the ggplot library

```{r}
library(ggplot2)
```

We're going to use some data today from the NEON project that we have talked about a little in the context of data that could be useful for forecasting. Let's get that loaded up and make sure everything is working for everyone.

```{r}
daily = read.csv("NEON_Harvardforest_date_2001_2006.csv", stringsAsFactors = FALSE)
```

This is a subset of a weather data file from the Harvard Forest NEON site. Let's look at the data and see what we got:

```{r}
head(daily)
```

We have 3 columns. A row index column. a date column, and an airtemperature column. The data I gave you is daily air temperature from 2001 through 2006.

Out of curiosity does anyone have a date that looks different

**will happen if open and save in Excel. Dates in excel are nightmarish. It
likes its own date formats. ISO international not a default, but you can force excel to behave**

Let's see what the computer thinks this date is.

```{r}
class(daily$date)
```

The computer thinks this is just character data. These could be names of species, sites, whatever, it will treat dates just like any other character data that we would give it.

```{r}
head(daily$date)
```

Each date is just an arbitrary label in the computer and because of that it does not know about any relationships that exist between these. 

Why might that be a problem?

*sorting*

Let's sort this and see what happens:

```{r}
daily = daily[order(daily$date),]
head(daily)
```

That didn't actually cause us any problems. That's one of the advantages of this date format, called the ISO international date format. Because of the order the information is presented, the computer will sort first on year, then month, then day, just like we would want.

Would this happen if the date format was 1-15-2016? How would it sort the data?

**all the januarys together, then all the january 15ths togethers, then order
the january 15ths by year**

What does itlook like if we plot this data?

```{r}
qplot(x=date, y=airt,
      data=daily, main="Daily Air Temp")
```

Anything look odd or annoying? 

*x axis*

What if I told you I took our an entire YEAR of data? I removed 2005 from your
data file. Anything wrong now?

Why isn't the gap showing up?

** the computer doesn't know anything is missing**

The computer doesn't magically know that dates are special. It doesn't understand that they come in a specific order. It doesn't understand their relationship to each other. To understand dates, the computer needs to store date information differently and we need to tell it to do that. It stores it in what we call a date object, which we can do by using as.Date. as.Date stores the information in such a way that it knows what humans want the dates to do but in a way that the computer understand it. You do not need lubridate to use as.Date.

Let's use it and see how it changes how it stores this info

```{r}
daily$asdate.date = as.Date(daily$date)
head(daily$asdate.date)


```
It looks the same. It still looks like the computer is storing the information as character data but if we see what type of data the computer thinks this is now:

```{r}
class(daily$asdate.date)
```

Now let's plot this:

```{r}
qplot(x=asdate.date, y=airt, 
      data=daily,
      main="Daily Air Temperature")

```

Now we see our missing year. It now knows that December 31 of 2004 is 1 year
away from January 1 2006 and that it should space those data points accordingly. 

And what happened to the x-axis?

The other nice thing about the ISO international data format is that many of the data functions are setup to import it by default. This is why we didn't have to tell asDate what the year was and what the month was. But what if our date is set up differently?

```{r}
test_date = "07-28-1977"
# output = as.Date(test_date)
# output
```

as.Date can ready other formats, we just have to tell it what we're giving it.

%d = day of month
%m = numeric month
%b = abbreviated month name
%B = full month name
%y = two digit year
%Y = 4 digit year

```{r}
output = as.Date(test_date, format = "%m-%d-%Y")
output
```

Can also reformat how the date displays. What if I needed my date to display as Full month Day 2 digit year? What would my format look like?

```{r}
new.asdate.format = format(daily$asdate.date, format="%B %d %y")
head(new.asdate.format)
```

Because R now knows that the dates are and their relationship between each other, you can do things like ask R to tell you the difference between two 
adjacent values in your date column.

```{r}
diff.dates = diff(daily$asdate.date)
head(diff.dates)
```

This is something I've done when I need to know if samples are more than some period of time apart to find gaps in my data collection.

You can also filter your data based on dates and have it behave as you think it should.

```{r}
Subsetted = subset(daily, asdate.date > "2001-12-31")
head(Subsetted)

```

If you have automated data, like from a sensor or weather station, you may also have a time associated with your date. Let's look at the higher frequency data from the NEON site.

```{r}
quarterhour = read.csv("hf001-10-15min-m.csv", stringsAsFactors = FALSE)
head(quarterhour)
```

Let's see what as.Date does with this format.

#### Class Activity

go ahead and run the as.Date function on that column like we did for the other dataset. How did it store the time information?

```{r}
asDate_datetime = as.Date(quarterhour$datetime)
class(asDate_datetime)

```
```{r}
head(asDate_datetime)
```
It didn't. as.Date is only for dates. as.Date has pretty basic functionality. If we have more complicated things we need to do with dates, there are other functions or libraries that we need to use.

For date and time, there are different functions we can use: posixlt or posixct

Posixct = more computationally efficient, but stores the data as number of seconds since January 1 1970. Cannot extract specific date info quickly from that.

Posixlt = slower but stores the info in an easily accessible way. January = month 0. Year from 1900.

Let's play with these and see how they work:

```{r}
ct.timeDate <- as.POSIXct("2015-10-19 10:15")
class(ct.timeDate)
```

This is a different type of object from what as.Date stores dates as.

Let's see what posix ct looks like:

```{r}
ct.timeDate

```

This looks pretty similar to what we gave it, because we gave it a format that it is expecting. The one difference is the addition of the timezone.

To see how posix converted your date time, let's pull out the underlying info:

```{r}
unclass(ct.timeDate)
```

So this is the number of seconds since January 1 1970.

Let's do the same thing with posixlt
```{r}
lt.timeDate <- as.POSIXlt("2015-10-19 10:15")
lt.timeDate
```

```{r}
unclass(lt.timeDate)
```

So we can see that it's storing the information fundamentally differently. In this format, we can easily pull out specific pieces if we need to:

```{r}
lt.timeDate$mon
```

Except we need to remember its rules: is month 9 september?

*No, it starts with January = 0*

#### CLASS ACTIVITY - convert the datetime in NEON to POSIXct and look at it.

```{r}
ct.datetime = as.POSIXct(quarterhour$datetime)
head(ct.datetime)

```

What went wrong?
Still no time.

Like as.Date, the posix functions are expecting data in a specific format. If its not in that format, you need to tell it how to read the data. The NEON date time is almost what posix is looking for, with one exception:

```{r}
head(quarterhour)
```

The T separating the date from the time. So we need to tell it about it:

```{r}
ct.datetime = as.POSIXct(quarterhour$datetime, format = "%Y-%m-%dT%H:%M")
head(ct.datetime)
```

Now we're good.

#### Class Activity

Why don't you all try to convert to posixlt.



#### Lubridate

We have done everything in base R. You can do a lot of this in a single package which plays nicely with the tidyverse in R (if that's your thing). Lubridate has a variety of built in functions that makes a lot of what we've done today more intuitive.Lubridate is a package that makes working with dates..less terrible. 


```{r}
library(lubridate)

```


```{r}
lub = lubridate::ymd(daily$date)
head(lub)
```
```{r}
lub_time = lubridate::ymd_hm(quarterhour$datetime)
head(lub_time)
```
```{r}
date = "July 4th 2019"
new_date = mdy(date)
new_date
```

```{r}
now = today()
now
```

```{r}
today() + days(5)
```

