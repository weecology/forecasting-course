---
title: "Instructor Notes"
weight: 4
type: book
summary: " "
show_date: false
editable: true
---

* Why is it important to forecasting at large scales using dynamic models?
* What new tools/data have the potential to make this possible?

* Let's talk through the model formulation

* Qualitatively, what is the spatial component of the model doing?
  * Places m knots at the best locations across space
  * Fits separate percent cover estimates for each knot
  * Smooths (or krigs) between knots based on distance (exponential decay)

* What are the four sets of simulations (computation experiments) performed in the paper?
  1.  compare simulated equilibrium cover to observed (start at low cover and simulate with samples from observed climate)
  2. compare observed and simulated cover for each year and location
  3. forecast future equilibrium populate states (start at low cover and
     simulate with samples from end state GCM forecast climate)
  4. temporally explicit forecasts starting at t + 1 (initialize each pixel with last observed value & forecast with yearly GCM predictions)

* How does the model perform at predicting observed patterns?
* What changes does the model predict in the future?
* What are the sources of uncertainty shown in Figure 6 and how might they be
  reduced?

* How do the results of this study differ from species-distribution modeling
  based approaches and what does this tell us?

* Does the model use spatially explicit environmental factors?
  * No
  * Would require downscaling
  * How could this influence the outcome?

* How do the methods & predicted results differ from Homer et al. 2015 and what
  does this tell us about ecological forecasting?
