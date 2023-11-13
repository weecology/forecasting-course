library(dplyr)
library(mvgam)
# Also requires collapse to be installed

data("portal_data")

portal_data %>%
  
  # mvgam requires a 'time' variable be present in the data to index
  # the temporal observations. This is especially important when tracking 
  # multiple time series. In the Portal data, the 'moon' variable indexes the
  # lunar monthly timestep of the trapping sessions
  dplyr::mutate(time = moon - (min(moon)) + 1) %>%
  
  # We can also provide a more informative name for the outcome variable, which 
  # is counts of the 'PP' species (Chaetodipus penicillatus) across all control
  # plots
  dplyr::mutate(count = PP) %>%
  
  # The other requirement for mvgam is a 'series' variable, which needs to be a
  # factor variable to index which time series each row in the data belongs to.
  # Again, this is more useful when you have multiple time series in the data
  dplyr::mutate(series = as.factor('PP')) %>%
  dplyr::mutate(ndvi_lag12 = dplyr::lag(ndvi, 12)) %>%
  
  # Select the variables of interest to keep in the model_data
  dplyr::select(series, year, time, count, mintemp, ndvi, ndvi_lag12) -> model_data

head(model_data)
model_data %>%
  dplyr::filter(!is.na(ndvi_lag12)) %>%
  dplyr::mutate(time = time - min(time) + 1) -> model_data_trimmed
model_data_trimmed %>% 
  dplyr::filter(time <= 160) -> data_train 
model_data_trimmed %>% 
  dplyr::filter(time > 160) -> data_test


ss_rw_gaussian <- mvgam(count ~ 1,
               family = gaussian(),
               data = data_train,
               newdata = data_test,
               trend_model = "RW")

ss_rw <- mvgam(count ~ 1,
               family = poisson(),
               data = data_train,
               newdata = data_test,
               trend_model = "RW")

mcmc_plot(ss_rw, variable = 'trend_params', regex = TRUE, type = 'trace')

ss_ar1 <- mvgam(count ~ 1,
               family = poisson(),
               data = data_train,
               newdata = data_test,
               trend_model = "AR1")

model3b <- mvgam(count ~ 
                  s(ndvi_lag12, k = 9) +
                  mintemp,
                family = poisson(),
                data = data_train,
                newdata = data_test,
                trend_model = 'RW')

summary(model3)

plot_predictions(model3, condition = "time", points = 1)
plot(ss_rw, type = "trend", newdata = data_test)

hindcasts <- predict(model3,
               probs = c(0.05, 0.2, 0.8, 0.95),
               robust = TRUE)
plot(ss_ar1, type = 'forecast', newdata = data_test)

compare_mvgams(ss_rw, ss_ar1, fc_horizon = 10)