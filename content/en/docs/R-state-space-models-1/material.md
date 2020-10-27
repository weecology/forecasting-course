---
title: "Material"
weight: 1
description: Software installation requirements
---

## Software Installation

* [Install JAGS](https://sourceforge.net/projects/mcmc-jags/files/)
* Install the `rjags` R package: `install.packages('rjags')`
* Install the `ecoforecastR` package
  * Not available on CRAN so first install RTools by downloading and running https://cran.r-project.org/bin/windows/Rtools/rtools40-x86_64.exe
  * Then install `devtools`: `install.packages("devtools")
  * The use `devtools` to install `ecoforecastR`:
  * `devtools::install_github('EcoForecast/ecoforecastR')`