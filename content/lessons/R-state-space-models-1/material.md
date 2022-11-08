---
title: "Material"
weight: 1
summary: Software installation requirements
show_date: false
editable: true
---

## Software Installation

* [Install JAGS](https://sourceforge.net/projects/mcmc-jags/files/)
* Install the `rjags` R package: `install.packages('rjags')`
* Install the `ecoforecastR` package
  * Since the package is not available on CRAN we need to do a few things before installing it
  * Windows users: Install RTools by downloading and running https://cran.r-project.org/bin/windows/Rtools/rtools40-x86_64.exe
  * Everyone: install `devtools`: `install.packages("devtools")
  * Everyone: The use `devtools` to install `ecoforecastR`:
    * `devtools::install_github('EcoForecast/ecoforecastR')`