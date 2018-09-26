library(tidyverse)
library(sf)

## import shps and merge in data for each year
# crew_tract_data.zip from https://colebrokamp-dropbox.s3.amazonaws.com/crew_tract_data.zip
# tract_shps.zip from https://colebrokamp-dropbox.s3.amazonaws.com/nhgis_crew_tract_shps.zip

# d_1980 <- read_csv('crew_tract_data/CREW_Tract_1980.csv')
d_1990 <- read_csv('crew_tract_data/CREW_Tract_1990.csv')
d_2000 <- read.csv('crew_tract_data/crew_tract_2000.csv', stringsAsFactors = FALSE) %>%
  as_tibble() %>%
  mutate(Geo_FIPS_2000 = as.character(Geo_FIPS_2000)) %>%
  mutate(Geo_FIPS_2000 = stringr::str_pad(Geo_FIPS_2000, 11, pad = '0'))
d_2010 <- read.csv('crew_tract_data/crew_tract_2010.csv', stringsAsFactors = FALSE) %>%
  as_tibble() %>%
  mutate(Geo_FIPS_2010 = as.character(Geo_FIPS_2010)) %>%
  mutate(Geo_FIPS_2010 = stringr::str_pad(Geo_FIPS_2010, 11, pad = '0'))

# s_1980 <- read_sf('crew_tract_shps/US_tract_1980_conflated.shp')
s_1990 <- read_sf('crew_tract_shps/us_tract_1990_conflated.shp')
s_2000 <- read_sf('crew_tract_shps/US_tract_2000_conflated.shp')
    # quickfix: for 3 tracts with missing state/county
    # "5221" should have (state/county) 36059 (NY)
    # "2011" should have 36103 (NY)
    # "2014" should have 36103 (NY)
s_2000[is.na(s_2000$STATE) & s_2000$TRACT == 5221, 'COUNTY'] <- '059'
s_2000[is.na(s_2000$STATE) & s_2000$TRACT == 2011, 'COUNTY'] <- '103'
s_2000[is.na(s_2000$STATE) & s_2000$TRACT == 2014, 'COUNTY'] <- '103'
s_2000[is.na(s_2000$STATE), 'STATE'] <- '36'

s_2010 <- read_sf('crew_tract_shps/us_tract_2010.shp')

# s_1980 %<>%
#     as_tibble() %>%
#     mutate(TRACT = as.character(TRACT)) %>%
#     mutate(TRACT = stringr::str_pad(TRACT, 6, pad = '0')) %>%
#     transmute(tract_fips = paste0(substr(NHGISST, 1, 2), COUNTY, TRACT)) %>%
#     left_join(d_1980, by = c('tract_fips' = 'Geo_FIPS_1980')) %>%
#     st_transform(5072)

s_1990 %<>%
    as_tibble() %>%
    mutate(TRACT = as.character(TRACT)) %>%
    mutate(TRACT = stringr::str_pad(TRACT, 6, pad = '0')) %>%
    transmute(tract_fips = paste0(STATE, COUNTY, TRACT)) %>%
    left_join(d_1990, by = c('tract_fips' = 'Geo_FIPS_1990')) %>%
    st_transform(5072)

s_2000 %<>%
    as_tibble() %>%
    mutate(TRACT = as.character(TRACT)) %>%
    mutate(TRACT = stringr::str_pad(TRACT, 6, pad = '0')) %>%
    transmute(tract_fips = paste0(STATE, COUNTY, TRACT)) %>%
    left_join(d_2000, by = c('tract_fips' = 'Geo_FIPS_2000')) %>%
  st_transform(5072)

s_2010 %<>%
    as_tibble() %>%
    mutate(TRACT = as.character(TRACTCE10)) %>%
    mutate(TRACT = stringr::str_pad(TRACT, 6, pad = '0')) %>%
    transmute(tract_fips = paste0(STATEFP10, COUNTYFP10, TRACT)) %>%
    left_join(d_2010, by = c('tract_fips' = 'Geo_FIPS_2010')) %>%
    st_transform(5072)

# s_1980 %>%
#     filter(nchar(tract_fips) < 11)
# summary(s_1980$totpop_1980)

saveRDS(s_1990, 'crew_census_1990.rds')
saveRDS(s_2000, 'crew_census_2000.rds')
saveRDS(s_2010, 'crew_census_2010.rds')
