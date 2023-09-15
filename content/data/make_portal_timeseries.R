library(portalr)
library(dplyr)
library(portalcasting)
library(forecast)
library(tsibble)
library(readr)

weather = as_tibble(weather("newmoon"), fill = TRUE)
rodents = as_tibble(abundance(time = "newmoon",
                              shape = "flat",
                              na_drop = FALSE,
                              zero_drop = FALSE))

rodents = as_tibble(summarize_rodent_data(
  path = get_default_data_path(),
  clean = TRUE,
  type = "Rodents",
  plots = "Longterm",
  unknowns = FALSE,
  shape = "crosstab",
  time = "newmoon",
  output = "abundance",
  na_drop = FALSE,
  zero_drop = FALSE,
  min_traps = 1,
  min_plots = 1,
  effort = TRUE,
  download_if_missing = TRUE,
  quiet = FALSE
))

pp = rodents |>
  select(newmoonnumber, abundance = PP) |>
  inner_join(weather, join_by(newmoonnumber)) |>
  mutate(abundance = round_na.interp(abundance),
         mintemp = na.interp(mintemp),
         precip = na.interp(precipitation)) |>
  filter(newmoonnumber >= 403, newmoonnumber <= 526) |>
  as_tsibble(index = newmoonnumber) |>
  select(newmoonnumber, abundance, date, mintemp, precipitation, cool_precip, warm_precip, precip)

write_csv(pp, "pp_abundance_timeseries.csv")
