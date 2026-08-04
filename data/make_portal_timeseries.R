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

write_csv(pp, "data/pp_abundance_timeseries.csv")

# In cases with two surveys in a month (blue moon) average them
# In one case we have zero samples one month and two samples the following month
# Drop the average value for the second month, move the first value up a month,
# and use the remaining value for the second month

pp_2014_feb <- pp |>
  as_tibble() |>
  filter(date == "2014-03-01") |>
  mutate(month = yearmonth("2014 Feb")) |>
  select(month, abundance, mintemp, precip = precipitation, cool_precip, warm_precip)

pp_2014_mar <- pp |>
  as_tibble() |>
  filter(date == "2014-03-30") |>
  mutate(month = yearmonth("2014 Mar")) |>
  select(month, abundance, mintemp, precip = precipitation, cool_precip, warm_precip)

pp_data_month <- pp |>
  as_tibble() |>
  mutate(month = yearmonth(date)) |>
  group_by(month) |>
  summarize(abundance = round(mean(abundance)),
    mintemp = mean(mintemp),
    precip = mean(precipitation),
    cool_precip = mean(cool_precip),
    warm_precip = mean(warm_precip)) |>
  filter(month != yearmonth("2014 Mar"))

pp_data_clean <- pp_data_month |>
  rbind(pp_2014_feb) |>
  rbind(pp_2014_mar) |>
  arrange(month)

write_csv(pp_data_clean, "content/data/pp_abundance_by_month.csv")


# Get the next two years of climate data for forecasting
# There just happen to be no month vs newmoon issues during this period
pp_future_climate <- weather |>
  filter(newmoonnumber >= 527, newmoonnumber < 527 + 24) |>
  mutate(month = yearmonth(date)) |>
  select(month, mintemp, precipitation, cool_precip, warm_precip, date)

write_csv(pp_future_climate, "content/data/pp_future_climate.csv")
