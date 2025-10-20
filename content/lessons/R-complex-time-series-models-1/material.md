---
title: "Data & Software"
weight: 1
type: book
summary: Software installation requirements
show_date: false
editable: true
---

## Data & Software

### Data

Download the [Desert Pocket Mouse data](/data/pp_abundance_timeseries.csv)

### Software Installation

**Windows users: If you don't already have RTools installed then you'll need to install it from https://cran.r-project.org/bin/windows/Rtools/**

**Mac users: If you don't already have Xcode installed then you'll need to install it from the mac app store.**

1\. Install dependencies:

```r
install.packages(c("brms", "collapse", "dplyr", "gratia",
  "ggplot2", "marginaleffects", "tidybayes", "zoo",
  "viridis", "remotes"))
```

2\. Install cmdstanr:

```r
install.packages(
  "cmdstanr",
  repos = c("https://mc-stan.org/r-packages/", getOption("repos"))
)
```

3\.Install mvgam:

```r
remotes::install_github('nicholasjclark/mvgam', force = TRUE)
```

4\. Install cmdstan:

On Windows:

```r
library(cmdstanr)
check_cmdstan_toolchain(fix = TRUE)
install_cmdstan()
```

On macOS & Linux:

```r
library(cmdstanr)
check_cmdstan_toolchain()
install_cmdstan()
```

5\. Test to make sure the installation worked

```r
cmdstan_version()
```

If this returns a version number like "2.33.1" then you're all set.
