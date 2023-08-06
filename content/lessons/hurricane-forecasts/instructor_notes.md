---
title: "Instructor Notes"
weight: 4
type: book
summary: " "
show_date: false
editable: true
---

#### Instructor notes

Finding a good and - most improtantly - accessible reading to introduce ecology students to hurricane forecasting has proven difficult. This is currently accoplished through a series of websites. We used to assign the article "The quiet revolution of numerical weather prediction" (https://www.nature.com/articles/nature14956) but it was generally too laden with climatology jargon for the standard ecology student. It might, however, be good background reading for instructors to have for leading the discussion

#### Discussion Questions

> What are the different types of forecast models used to forecast hurricanes? Pros and cons?
* dynamical (numerical weather prediction): supercomputers to solve mathmatical equations based on fundamental physical principles that govern the atmosphere
  * Cons: Data hungry. Computationally intensive. Can be slow to run models. Sensitive to data uncertainty
  * Pros: Able to predict novel responses. More accurate than other methods.
* Statistical: uses past correlations between hurricane specific information and behavior of  hurricanes as a guide to ppredict likely future behaviors
  * Pros: Quick to run, doesn't require intensive data collection or computational resources
  * Cons: Doesn't capture the processes actually driving hurricane formation thus can make bad predictions when underlying conditions different from the past (or seem similar to the past but caused by different processes). Limited to what has been seen before.
* Statistical-dynamical models: a combination of statsitical relationships and dynamic (process-based) models
  * Pros: Faster than pure dynamical models. Reduces data requirements.
  * Cons: Statistical pieces are simplifications of more complex processes and interactions, thus may not be capturing reality correctly.

> Let's spend a little more time discussing how numerical weather prediction works. How does numerical weather prediction create its forecasts? What kind of processes and equations are the models based on?
* fundamental laws of physics, laws of viscous fluid dynamics (navier-stokes), laws of thermodynamics, ideal gas law to predict heat transfer, changes in pressure, temperature. Not a single equation for the globe, but for "cells" or regions that are then linked together.
    > Follow-up question: What does the need for supercomputers for numeric weather forecasting tell you?
    * intensive. Lots of data, lots of calculations for lots of spatial locations.

> Where are the sources of uncertainty in this approach? 
  * Data: don’t have measurements for all locations, measurement error. Inprecise initial conditions to start the model
  * Model: Some equations have to be approximated for the computer to conduct calculations
  
> What does this uncertainty mean for our forecasts?
* initial condition differences can generate different outcomes
* Errors in the forecasted tracks

> The page on dynamical models lists four different global dynamical models that are used in US hurricane forecasting. Given your readings of “How Hurricane Forecast Models Work” what doyou think some of the differences are among these models?
* differences in the scales they operate at, differences in the approximations they use

> What is an ensemble model and why is it useful? What do you think is an important piece of information that you would want from an ensemble forecast?
* An “average” forecast either from the same model or different models. Can weight equally or based on the past performance
* because different models will have different weaknesses, combining models often gives a more robust forecast
* Still want to know the uncertainty of the ensemble model.
    * Turns out this is something being debated. The NHC communicates uncertainty through their cone of uncertainty, which is simply the distance that 2/3 of hurricanes fell from the official forecast X hours out. This band of uncertainty is fixed for a given season and does not change from hurricane to hurricane. (information from NOAA website).
    * Instructor note: this is often not what students assume the cone of uncertainty is conveying and can be used a a good discussion item for discussing how we convey uncertainty to the public and what we - as scientists - assume uncertainty means in a model prediction.
    
> Do you think numerical weather prediction is a good model for ecological forecasting? What issues would we have in applying this approach? Can we overcome them?
  * Instructor note: push the students to think about applying something like this to their systems. What types of 'fundamental equations' would they need? What type of data? How intensively collected? How close are we to being able to do this in ecology?
  
•
