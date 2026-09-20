# Build the monthly Lake Barco (BARC) limnology time series used by the
# "Time series modeling in R 3" assignment.
#
# Source: the aquatics target file from the NEON Ecological Forecasting
# Challenge, run by the Ecological Forecasting Initiative Research Coordination
# Network. https://projects.ecoforecast.org/neon4cast-docs/
#
# The Challenge targets repackage two NEON data products for lake sites:
#   DP1.20264.001  Temperature at specific depth in surface water  -> temperature
#   DP1.20288.001  Water quality                                   -> oxygen, chla
#
# Thomas RQ, Boettiger C, Carey CC, et al. (2023) The NEON Ecological
# Forecasting Challenge. Front Ecol Environ 21(3): 112-113. doi:10.1002/fee.2616
#
# Run from the repository root:  Rscript data/make_barco_timeseries.R

library(readr)
library(dplyr)
library(tidyr)
library(tsibble)
library(zoo)

targets_url <- paste0(
  "https://sdsc.osn.xsede.org/bio230014-bucket01/challenges/targets/",
  "project_id=neon4cast/duration=P1D/aquatics-targets.csv.gz"
)

# The window is fixed so that everyone works with the same 92 months. It starts
# in Nov 2018, the first month with all three sensors reporting, and ends in
# Jun 2026. Extend `end_month` to pick up newer data.
start_month <- yearmonth("2018 Nov")
end_month <- yearmonth("2026 Jun")

barco <- read_csv(targets_url, show_col_types = FALSE) |>
  filter(site_id == "BARC", variable %in% c("temperature", "oxygen", "chla")) |>
  mutate(month = yearmonth(datetime)) |>
  group_by(month, variable) |>
  summarize(value = mean(observation, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(names_from = variable, values_from = value) |>
  filter(month >= start_month, month <= end_month) |>
  as_tsibble(index = month) |>
  # A handful of months have no data at all because the sonde was out of the
  # water. Interpolate them so that the series is gap free: fable's AR() errors
  # out on missing values, and the assignment asks students to fit one.
  fill_gaps() |>
  mutate(across(c(temperature, oxygen, chla), \(x) round(na.approx(x), 3)))

stopifnot(
  nrow(barco) == 92,
  !any(is.na(barco))
)

barco |>
  as_tibble() |>
  mutate(date = as.Date(month)) |>
  select(date, temperature, oxygen, chla) |>
  write_csv("data/barco_oxygen_timeseries.csv")
