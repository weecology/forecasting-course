---
title: "Instructor Notes"
weight: 4
type: book
summary: " "
show_date: false
editable: true
---


## Logistic Growth

* Is everyone comfortable with the basic logistic growth example?
  * *If not, give a brief introduction or clarify questions*
* This is an autoregressive model in that the abundance at the current time is
  influenced by the abundance at the previous timestep, but in a more
  complicated way than the ARIMA model.

## Adding sources of uncertainty

* So far we've talked about uncertainty as a single thing: epilson ~ N(0, sigma)
* What are the different sources of uncertainty? ***list on board and discuss what each is as students name them***
  * observation error
  * parameter uncertainty
  * initial condition uncertainty
  * process variability
  * model uncertainty
  * driver and scenario uncertainty
  * numerical approximation error
* What is the distinction between uncertainties & sources of variation?
  * uncertainties: describe ignorance about a process; should decrease
    asymptotically with sample size
  * sources of variability: variation in the process that are not captured by a
    model
* Which of items on the board are uncertainties vs. sources of variation? ***mark on board***
    * What does the author mean when they say "if observation error was the only
      source of uncertainty then this forecast would have zero uncertainty"?
* How does this related to measurement error?
* Can uncertainty in initial conditions be reduced with more data?
* What is the difference between the additive process error and observation
  error?
* What information do covariance matrices provide?

## Thinking probabilistically

* How do the boxes in the the graphical model of logistic growth relate to the
  sources of error?

## Predictability

* How does disturbance make forecasting difficult?
  * What could be done to ameliorate the influence of disturbance on forecasts?

* Which components of uncertainty (e.g., in eq. 2.1) have the potential to grow
  through time?
  * What implications does this have for our ability to forecast?
* What aspects of external drivers make systems easy vs. difficult to forecast?
* Are there implications of the need for different experimental designs for
  forecasting vs. hypothesis testing for how we should do science?
  
* What is the difference between parameter uncertainty and parameter variability?
* What are the implications for forecasting?
* How can we tell them apart?

* What kinds of uncertainty/variability do you think are most important in
  ecological systems?
* If a forecast model doesn't include all of these sources of variance can it be
  a valid forecast?
