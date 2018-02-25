#!/usr/bin/Rscript

setwd('/tmp')

suppressPackageStartupMessages(library(argparser))
p <- arg_parser('return census tracts for geocoded CSV file and merge to CREW census data')
p <- add_argument(p,'file_name',help='name of geocoded csv file')
p <- add_argument(p,'year',help='select year for census tracts and data (must be 1980, 1990, 2000, or 2010)')
args <- parse_args(p)

suppressPackageStartupMessages(library(sf))
suppressPackageStartupMessages(library(tidyverse))

selected_year <- args$year
# selected_year <- '1990' # for testing

if (! selected_year %in% c('1990', '2000', '2010')){
    message('\nWARNING: year argument is invalid or missing')
    message('\ncontinuing with year set to 2010')
    message('\nplease see the documentation for details')
    selected_year <- '2010'
}

message('\nloading and projecting input file...')
d <- read.csv(args$file_name,stringsAsFactors=FALSE)
# d <- read.csv('addr.csv',stringsAsFactors=FALSE)

d_cc <- complete.cases(d[ ,c('lat','lon')])

if (! all(d_cc)) {
    n_rows_missing <- nrow(d) - nrow(d_cc)
	message('WARNING: input files contains', n_rows_missing, 'rows with missing coordinates, these rows will be omitted from output.')
        d <- d[d_cc, ]
}

# store coords as separate numeric columns because
# trans and back trans lead to rounding errors, making them unsuitable for merging
d$old_lat <- d$lat
d$old_lon <- d$lon

d %<>%
    st_as_sf(coords=c('lon', 'lat'), crs=4326) %>%
    st_transform(5072)

message('\nloading CREW tract data...')

shp.tracts <- readRDS(paste0('/app_source/crew_census_', selected_year, '.rds'))

message('\nfinding census tract for each point...')

d_out <- sf::st_join(d, shp.tracts, left = FALSE)

# transform to dataframe
# remove transformed coords
# add back "old" coords
out.file <- d_out %>%
    st_set_geometry(NULL) %>%
    rename(lon = old_lon,
           lat = old_lat)

out.file.name <- paste0(gsub('.csv','',args$file_name,fixed=TRUE),'_crew_census_', selected_year, '.csv')

write_csv(out.file, out.file.name)

message('\nFINISHED! output written to ',out.file.name)
