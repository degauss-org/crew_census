#!/usr/bin/Rscript

setwd('/tmp')

suppressPackageStartupMessages(library(argparser))
p <- arg_parser('return census tracts for geocoded CSV file')
p <- add_argument(p,'file_name',help='name of geocoded csv file')
p <- add_argument(p,'year',help='select year for census tracts and data (must be 1980, 1990, 2000, or 2010)')
args <- parse_args(p)

suppressPackageStartupMessages(library(tigris))
suppressPackageStartupMessages(library(rgdal))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(purrr))

# create memoised version of functions using local persistent cache
suppressPackageStartupMessages(library(memoise)) # note: requires gh version of this package

selected_year <- args$year

if (! selected_year %in% c('1980', '1990', '2000', '2010')){
    message('/nWARNING: year argument is invalid or not detected')
    message('/nplease see the documentation for details')
    message('/nproceeding with year set to 2010')
    selected_year <- '2010'
}

lc <- cache_filesystem('/tmp/degauss_cache')
counties <- memoise(tigris::counties,cache=lc)
tracts  <- memoise(tigris::tracts,cache=lc)
over <- memoise(sp::over,cache=lc)

message('\n(down)loading all county 2008 TIGER/Line shapefiles...\n')
shp.counties <- counties(year = '2008') %>%
  spTransform(CRS('+init=epsg:5072'))

message('\nloading and projecting input file...\n')
d <- read.csv(args$file_name,stringsAsFactors=FALSE)
# d <- read.csv('addr.csv',stringsAsFactors=FALSE)

d_cc <- complete.cases(d[ ,c('lat','lon')])

if (! all(d_cc)) {
	message('WARNING: input files contains missing coordinates, these rows will be omitted from output.')
        d <- d[d_cc, ]
}

coordinates(d) <- c('lon','lat')
proj4string(d) <- CRS('+init=epsg:4326')
d <- spTransform(d,CRS('+init=epsg:5072'))


message('\nfinding necessary counties...\n')
d$county <- over(d,shp.counties)$GEOID


### TODO change GEOID variable name depending on year
### 2010: GEOID
### 2000: paste0(STATEFP00, COUNTYFP00)
### 1990: paste0(COUNTYFP, STATEFP)

counties_needed <- unique(d$county)
counties_needed  <- na.omit(counties_needed)

message(paste('\n(down)loading 2008 TIGER/Line tract shapefiles for counties',paste(counties_needed,collapse=', ')))

shps.tracts <- map(counties_needed,function(x) {
  message('\n',x,'\n')
  tracts(state=substr(x,1,2),county=substr(x,3,5),year=2008) %>%
    spTransform(CRS('+init=epsg:5072'))
  }) %>%
  set_names(counties_needed)

d_c_tract <- complete.cases(as.data.frame(d[ ,'county']))

if (! all(d_c_tract)) {
  message('WARNING: some coordinates were not able to be assigned to a county, these rows will be omitted from output.')
  d <- d[d_c_tract, ]
}

message('\nfinding census tract for each point...')
d$tract <- NA
for (x in counties_needed) {
  message('\n',x,'...')
  d[d$county == x,'tract'] <- over(d[d$county == x, ],shps.tracts[[x]])$GEOID
}

out.file <- d %>% spTransform(CRS('+init=epsg:4326')) %>% as.data.frame

message('\nloading and merging to CREW census data based on ', selected_year)

crew_data <- read.csv(paste0('./CREW_Tract_', selected_year, '.csv'), stringsAsFactors = FALSE)

out.file <- merge.data.frame(out.file, crew_data, all.x = TRUE, all.y = FALSE, by.x='tract', by.y='Geo_FIPS')

out.file.name <- paste0(gsub('.csv','',args$file_name,fixed=TRUE),'_crew_census_', selected_year, '.csv')
write.csv(out.file,out.file.name,row.names=F)

message('\nFINISHED! output written to ',out.file.name)
