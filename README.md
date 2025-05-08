# `crew_census`

🛑 **_archived_** 🛑


> Historical census tracts and data DeGAUSS container built for CREW.

## Versions

| release tag | date    | notes                                                     |
|-------------|---------|-----------------------------------------------------------|
| 0.1         | 2/24/18 | initial release                                           |
| 0.2         | 9/26/18 | update for inflation fixes and new ARiC deprivation index |
| 0.3         | 12/19/18| fix errors in ARiC data calculations                      |

## Using

DeGAUSS arguments specific to this container:

- `file_name`: name of a CSV file in the current working directory with columns named `lat` and `lon`
- `year`: year to be used for overlay onto census tracts and merging with CREW supplied data; must be one of `1990`, `2000`, or `2010`

Example call:

`docker run --rm=TRUE -v $PWD:/tmp degauss/crew_census:0.3 geocoded_csv_file.csv 2000`

In the above example call, replace `geocoded_csv_file.csv` with the name of your geocoded csv file and `2000` with the decentennial census year to be used for the tract overlay and merging of census data.

Some progress messages will be printed and when complete, the program will save the output as the same name as the input file name, but with `crew_census` and the year appended, e.g. `geocoded_csv_file_crew_census_2000.csv`

## DeGAUSS Details

For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS](https://github.com/cole-brokamp/DeGAUSS) README.

This software is part of DeGAUSS and uses its same [license](https://github.com/cole-brokamp/DeGAUSS/blob/master/LICENSE.txt).

## Methodology

- Census tract files from [NHGIS](https://www.nhgis.org/documentation/gis-data) are used to overlay geocodes to tracts depending on the year suppplied
    - 1980, 1990, and 2000 tracts are based on NHGIS "conflating" the census boundary files with 2008 TIGER/Line files
    - 2010 tracts are based on the NHGIS supplied 2010 TIGER/Line files
- CREW data was merged to shapefiles and used to create integrated RDS files (using `make_crew_geo_data.R`)
- Numbers on "raw" data:

| data           | shapefile     | year | missing `totalpop`?                            |
|----------------|---------------|------|----------------------------------------------|
| [46,728 × 58]  | [46,197 × 16] | 1980 | 3,126                                        |
| [61,258 × 75]  | [60,947 × 17] | 1990 | 1 (`NANA030398`)                             |
| [66,304 × 152] | [65,669 × 16] | 2000 | 3 (`NANA005221`, `NANA002011`, `NANA002014`) |
| [74,001 × 148] | [73,669 × 16] | 2010 | 0                                            |

## Identifiers

Remove any of the following identifier columns that are considered PHI:

- `lat`, `lon`
- `Geo_QName_1990`, `Geo_FIPS_1990`, `Geo_TRACT6_1990`
-  `Geo_QName_2000`, `Geo_FIPS_2000`, `Geo_TRACT6_2000`
-  `Geo_QName_2010`, `Geo_FIPS_2010`, `Geo_TRACT6_2010`
