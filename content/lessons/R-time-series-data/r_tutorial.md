---
title: "R Tutorial"
weight: 3
type: book
summary: " "
show_date: false
editable: true
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

If you are working with data, what are the different ways you could write today's date? If it always the same order of information (month, day, year). Are those pieces of information always given in the same way (always numerical?).

[write down the different ways you can think of recording a date[

What are some issues you see with these formats? How do you think a computer would see these different styles for dates? As the same thing? Or as different things? How would it know what is a day or month or year?

We're going to explore today what the challenge is for communicating dates and times to computers and learn to use some tools that will make it easier for us to tell the computer what we want in a way that lets both it and us interpret date-times accurately.

First, we need to load two packages. We'll use the ggplot library for plotting and the lubirdate package which has some nice features for working with dates and times.

```{r}
library(ggplot2)
```

We're going to use some data from a weather station from one of the sites that make up the National Ecological Observatory Network . Let's get that loaded up and make sure everything is working for everyone.
```{r}
daily = read.csv("NEON_Harvardforest_date_2001_2006.csv", stringsAsFactors = FALSE)
```
This is a subset of a weather data file from the Harvard Forest NEON site. Let's look at the data and see what we got:

```{r}
head(daily)
```

We have 3 columns. A row index column. a date column, and an airtemperature column. The data I gave you is daily air temperature from 2001 through 2006.

Out of curiosity does anyone have a date that looks different?

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

What would happen if the date format was 1-15-2016? How would it sort the data?

*all the januarys together, then all the january 15ths togethers, then order
the january 15ths by year*

Let's try dates in one of the formats we brainstormed at the beginning that we commonly use in the United States: Month Day Year 

```{r}
US_dates = c("01-16-2015", "12-16-2015", "07-16-2014", "01-16-2023")
sort(US_dates)
```
Is that chronological order? 

How was the date formatted in the NEON data? How would those date formats sort? 

The format used in the NEON data is called the ISO international date format and the order the information is presented avoids this problem, the computer will sort first on year, then month, then day, just like we would want.

So, let's look at the data we have from NEON. We're going to use the ggplot function to create a graph of the data. We give it our data, tell it what the x and y axis is and that we want to plot the data as points.

```{r}
ggplot(daily, aes(x=date, y=airt)) + geom_point()
```


Anything look odd or annoying? 

*x axis*

What if I told you I took out an entire YEAR of data? I removed 2005 from your data file. Anything wrong now?

Why isn't the gap showing up?

** the computer doesn't know anything is missing**

The computer doesn't magically know that dates are special. It doesn't understand that they come in a specific order. It doesn't understand their relationship to each other. To understand dates, the computer needs to store date information differently and we need to tell it to do that. It stores it in what we call a date object, which we can do by using as.Date. as.Date stores the information in such a way that it knows what humans want the dates to do but in a way that the computer understand it. We're going to start by using as.Date which is not part of the lubridate package. It's a little clunkier but will help illustrate some concepts.

Let's see how as.Date changes how our dates.

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

Now we see our missing year. It now knows that December 31 of 2004 is 1 year away from January 1 2006 and that it should space those data points accordingly. 

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
 Because R now knows that the dates are and their relationship between each other, you can do things like ask R to tell you the difference between two adjacent values in your date column.

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
It didn't. as.Date is only for dates. as.Date has pretty basic functionality. This is where we're going to hop over the lubridate. Lubridate is a handy package that is deisnged to make working with dates and times and their wide variety of possible formats easier. 

You can do everything we just did with as.Date in lubridate, but it works slightly differently. Instead of using one function and then telling it what order the information is in, there are different functions that assume different orders of information. 

```{r}
output = lubridate::mdy("3-15-2001")
output
class(output)

```
Or

```{r}
lubri_date = lubridate::dmy("16-1-1980")
lubri_date
```
If we have time as well as date information, we simply add that information in the order that it is presented.

```{r}
timeDate <- lubridate::ymd_hm("2015-10-19 10:15")
class(timeDate)
```

This is a different type of object from what as.Date stores dates as.

Let's see what this posixct object looks like:

```{r}
timeDate

```

This looks pretty similar to what we gave it, because we gave it a format that it is expecting. The one difference is the addition of the timezone.

To see how posix deals with your date time, let's pull out the underlying info:

```{r}
unclass(timeDate)
```

So this is the number of seconds since January 1 1970. The computer doesn't understand dates the way we do, so it stores that information in a way that it can work with in the way we want dates worked with and these different functions (as.Date and ymd_hm) then have ways of converting that into what we expect to see. Here's what we have is we look under the hood at the 

```{r}
unclass(lubri_date)
```
This is the number of days since 1/1/1970.

#### CLASS ACTIVITY - convert the datetime in NEON to POSIX format using lubridate. Looks at the datafile and see what order the date time is given then use the appropriate lubridate function.

```{r}
neon_datetime = as.POSIXct(quarterhour$datetime)
head(neon_datetime)

```
And now you have the power to convert whatever datetimes into a format your computer can work with and recognize as a date.

#### Fun with Lubridate - if time

LUbridate just generally makes working with dates less terrible. It is capable of autodetecting lots of different date formats and extracting the relevant information:


```{r}
nightmare_date = dmy("4th of July 1999")
two_digit_year = dmy("4-7-99")
nightmare_date
two_digit_year
```
You can extract parts of a date:

```{r}
year(nightmare_date)
```
You can have the computer tell you what today is
```{r}
today = now()
today
```
And have it tell you what day of the week a date is/was

```{r}
wday(today)
```
For those of you - like my family - that have debated what day of the week is the start of a week - lubridate says its Sunday.

And you can do math with dates:
```{r}
today + days(10)


```
[End of Tutorial]


```

