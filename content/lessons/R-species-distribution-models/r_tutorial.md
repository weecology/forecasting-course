---
title: "R Tutorial"
weight: 3
type: book
summary: " "
show_date: false
editable: true
---

## Video Tutorial

<iframe width="560" height="315" src="https://www.youtube.com/embed/0VObf2rMrI8" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Text Tutorial

* Species Distribution Models attempt to model where species are expect to occur
* Can be based on lots of things, but often just environmental variables
* This demo will build a simple version version using a linear model and two predictors

## Load some packages

* `dismo` is the major package for SDM in R
* We'll also load `ggplot2` for plotting and `dplyr` for data manipulation

```r
library(dismo)
library(ggplot2)
library(dplyr)
library(terra)
```

## Data

* We need two kinds of data for SDMs
* Locations for where a species occurs
    * And ideally where it is absent
    * When no absences make fake absences called "background" or "pseudo absences"
* Spatial data on predictor variables
    * Most commonly temp & precip based
    * But that is mostly convenience based, not biology based
    * To use the SDM for forecasting we need both current and future values
    * So we need forecasts for our predictor variables to make forecasts for species distributions
* For location data we'll use the Breeding Bird Survey of North America data on the Hooded Warbler
* For environmental data we'll use minimum temperature and annual precipitation
* Fore forecasts of environmental data we'll use CMIP5 50 year forecasts (CMIP = coupled model intercomparison project)
* Download data from [https://course.naturecast.org/data/sdm_data.zip](https://course.naturecast.org/data/sdm_data.zip) and unzip it into your working directory

* The hooded warbler data is in a csv file
* Load it using `read.csv()`

```r
hooded_warb_data = read.csv("hooded_warb_locations.csv")
head(hooded_warb_data)
```

* We can see that this file has information on locations as latitude & longitude plus whether or not the species is present at that location

* The environmental data is stored in raster stacks in `.grd` files
* Load those using the `rast()`, which is part of the `terra` package

```r
env_data_current = rast("env_current.grd")
env_data_forecast = rast("env_forecast.grd")
plot(env_data_current$tmin)
plot(env_data_current$precip)
```

## Determine environment where species is (and isn't)

* Now we need to combine the data to get information environment where a species occur and where it doesn't
* Combine the two data types
* To start we'll extract the environmental data at the locations that have been sampled
* To do this we get just the position data for the locations by selecting the `lon` and `lat` columns
* And then use the `extract()` function from the raster package
* It takes a raster that we want to extract data from as the first argument and the point locations to extract as the second argument

```r
hooded_warb_locations = select(hooded_warb_data, lon, lat)
hooded_warb_env = extract(env_data_current, hooded_warb_locations)
```

* Then we need to attached these extracted environmental values back to our presence absence data using `cbind()`

```r
hooded_warb_data = cbind(hooded_warb_data, hooded_warb_env)
```

* Now we can look at where the species occurs in 2D environmental space

```r
ggplot(hooded_warb_data, aes(x = tmin, y = precip, color = present)) +
  geom_point()
```

* We want our SDM to find regions of climate space where the species is likely to occur
* Visually we can see that this species is associated with high temps and precips


## Modeling species distribution

* Many different ways to model the probability of species presence
* Look at one of the simplest - Generalized linear modeling
* Specifically we'll build a multivariate logistic regression
* Do this using the `glm()` function
* First argument is the model, where we want the `present` column to depend on `tmin` and `precip`
* Second argument is the link function, which gives us our logistic regression
* Third argument is the data

```r
logistic_regr_model <- glm(present ~ tmin + precip,
                           family = binomial(link = "logit"),
                           data = hooded_warb_data)
summary(logistic_regr_model)
```

## Evaluate the model performance

* To evaluate model performance for binary classification problems, like our presence vs absence model, we often use Receiver Operating Characteristic or ROC curves
* These are plots of false positives (cases where we predict a species is present but it isn't) on the x axis
* Against true positives (cases where we predict a species is present and it is present) on the y axis
* We use different thresholds on the predicted probability to say whether a species is predicted to be present or absent
* So we might say that if the probability is at least 10% we'll call that present
* That will give us a pair of values for true and false positives
* Then do the same thing for 20%, 30%, 40%, and so on which gives us a curve
* The 1:1 line on this graph is what we would get if we randomly assigned each point to be present or absent
* So we definitely want a model that is above that line

* Let's make our own ROC curve
* Split the data in into presences and absences

```r
presence_data = filter(hooded_warb_data, present == 1)
absence_data = filter(hooded_warb_data, present == 0)
```

* The run the `evaluate()` function from `dismo`
* It takes 3 arguments: presence data, absence data, and the model

```r
evaluation <- evaluate(presence_data, absence_data, logistic_regr_model)
```

* We can then plot the ROC curve

```r
plot(evaluation, 'ROC')
```

* Looks good, but it is important to know that this is biased when using absences from large scales


## Plot the model predictions

* To make predictions and forecasts from this model we use the overloaded `predict` function from the `raster` package
* Arguments
    * Raster of environmental conditions
    * Model
    * `type = "response"` to get probabilities

```r
predictions <- predict(env_data_current, logistic_regr_model, type = "response")
present <- select(filter(hooded_warb_data, present == 1), lon, lat)
plot(predictions, ext = extent(-140, -50, 25, 60))
points(present, pch='+', cex = 0.5)
```

* This shows us the probability that each species will be present across spatial locations
* Sometimes we we want to identify the locations where we expext the species to occur instead
* To do this we can only show predictions that are greater than some threshold
* So, we could say that if our model says there is a 50% chance of a species being present that it is present

```r
plot(predictions > 0.5, ext = extent(-140, -50, 25, 60))
points(present, pch='+', cex = 0.5)
```

* This 50% threshold is one of the values from our ROC curve
* Can also choose a different threshold
* E.g., > 25% probability of occuring
* Different thresholds often have better characterisics depending on what we value
* We might want to make sure that all locations that a species could possibly occur are included
* Or we might want to make sure our model predicts approximately the right number of presencences
* Can choose this automatically using `threshold()`
* First argument is our `evaluation` object
* Second argument allows us to specific what is important to us
* We'll use `'prevalence'` which predicts approximately the right number of presencences 

```r
tr <- threshold(evaluation, stat = 'prevalence')
plot(predictions > tr, ext = extent(-140, -50, 25, 60))
points(present, pch='+', cex = 0.5)
```
## Make forecasts

* To make predictions for the future we use the exact same approach, but using forecasts for future environmental conditions
* We'll use the CMIP5 predictions for 50 years from now that we loaded at the beginning of the lesson

```r
forecasts <- predict(env_data_forecast, logistic_regr_model, type = "response")
plot(forecasts, ext = extent(-140, -50, 25, 60))
plot(forecasts > tr, ext = extent(-140, -50, 25, 60))
```

* If we want to see the changes that are expected to occur we can plot the difference between the current predictions and the future forecasts

```r
plot(forecasts - predictions, ext = extent(-140, -50, 25, 60))
```

