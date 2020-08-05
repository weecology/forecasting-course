library("rdataretriever")
library("raster")
library("rgdal")
library("DBI")
library("dplyr")
library("maptools")


# Hooded Warbler Presence-Absence Data

# bbs_data = fetch("breed-bird-survey")
# counts = bbs_data$breed_bird_survey_counts
# routes = bbs_data$breed_bird_survey_routes
# species = bbs_data$breed_bird_survey_species

if (!file.exists('bbs.sqlite')){
  rdataretriever::get_updates()
  rdataretriever::install('breed-bird-survey', 'sqlite', 'bbs.sqlite')
}

bbs_db = dbConnect(RSQLite::SQLite(), 'bbs.sqlite')
counts = tbl(bbs_db, "breed_bird_survey_counts") %>%
  data.frame()
routes = tbl(bbs_db, "breed_bird_survey_routes") %>%
  data.frame()
species = tbl(bbs_db, "breed_bird_survey_species") %>% 
  data.frame()

hooded_warb_data = filter(counts, aou == 6840) %>% 
  full_join(routes) %>% 
  group_by(statenum, route, latitude, longitude) %>% 
  summarize(present = ifelse(sum(speciestotal, na.rm = TRUE) > 0, 1, 0)) %>% 
  mutate(site = statenum * 1000 + route) %>% 
  ungroup() %>% 
  select(site, everything(), -statenum, -route)

# Environmental data

tmin_now <- getData('worldclim', var = 'tmin', res = 10)
precip_now <- getData('worldclim', var = 'prec', res = 10)
tmin_50yr <- getData('CMIP5', var = 'tmin', res=10, rcp=85, model='AC', year=50)
precip_50yr <- getData('CMIP5', var = 'prec', res=10, rcp=85, model='AC', year=50)
env_rasters <- stack(c(tmin_now, precip_now, tmin_50yr, precip_50yr))

sites_spatial <- SpatialPointsDataFrame(hooded_warb_data[c('longitude', 'latitude')], hooded_warb_data)
env_bbs <- extract(env_rasters, sites_spatial) %>% 
  data.frame() %>% 
  select(tmin_may_current = tmin5, precip_may_current = prec5,
         tmin_may_forecast = ac85tn505, precip_may_forecast = ac85pr505)

data = cbind(hooded_warb_data, env_bbs)
write.csv(data, "lectures/hooded_warbler_sdm_data.csv")

presence_absence_data = hooded_warb_data %>% 
  select(lon = longitude, lat = latitude, present) %>% 
  data.frame()
write.csv(presence_absence_data, "lectures/hooded_warb_locations.csv", row.names = FALSE)

env_data_stacked_current = stack(tmin_now$tmin5, precip_now$prec5)
names(env_data_stacked_current) = c("tmin", "precip")
writeRaster(env_data_stacked_current, "lectures/env_current.grd", format = "raster", overwrite = TRUE)

env_data_stacked_forecast = stack(tmin_50yr$ac85tn505, precip_50yr$ac85pr505)
names(env_data_stacked_forecast) = c("tmin", "precip")
writeRaster(env_data_stacked_forecast, "lectures/env_forecast.grd", format = "raster", overwrite = TRUE)
