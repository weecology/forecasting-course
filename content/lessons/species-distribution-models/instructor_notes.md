---
title: "Instructor Notes"
weight: 4
type: book
summary: " "
show_date: false
editable: true
---

## Concepts

> How (generally) do species distribution models work?

* Model relationship between species occurence and environment and use to predict species presence at unsampled places and times

> What is the distinction between environmental & geographic space?

* Environmental space shows how locations are related to one another in terms of similarity in environmental conditions
  
> What is the distinction between using SDMs for explanation vs. interpolation vs. extrapolation

* Explanation: understanding why a species occurs in some areas and not others
* Interpolation: understanding where is species should occur within a region at points that haven't been surveyed
* Extrapolation: understanding where/when is species should occur outside of the bounds of current sampling

## Predictors

> How do we select predictors for SDMs (or other ecological models)?

* Ideally: the variables that directly drive species distributions
* Practically: what data is available

> What should we do if we don't have measurements of our preferred variables?

* Try to find proxies that are likely to be well correlated with preferred variables

## Modeling approaches

> What are some of the major categories of modeling approaches for SDMs and what
  are their characteristics?

* Statistical
* Machine learning
* Process based

> How do differences in these approaches relate to their use of explanation vs. prediction?

* Machine learning mostly useful for prediction due to difficulty of interpretation
* Process based best for explanation because they parameters of direct biological meaning

> How are presence only data dealt with when building models?

* Pseudo absences

## Challenges

> Why do you think SDMs are so popular in attempts to forecast ecological change?

> What are the challenges for making SDM based forecasts?

> How might we determine how well these forecasts perform?

* Hindcasting

## Key Processes

> Should SDMs model the influence of other species and do they currently do this?

* Yes if possible
* JSDM

> What about other key biological processes like density dependence and dispersal?

* Biological process are good, if you can successfully measure/model them

## Uncertainty

> How is uncertainty addressed in SDMs and are there areas for improvement?

* Probabilistic forecasts
* But often not evaluated
* Often converted into presence/absence maps

## Future

> What should be the next big steps in species distribution modeling?

* JSDMS
* More process
* Active evalution