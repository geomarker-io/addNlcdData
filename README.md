
<!-- README.md is generated from README.Rmd. Please edit that file -->

# addNlcdData

<!-- badges: start -->

[![R build
status](https://github.com/geomarker-io/addNlcdData/workflows/R-CMD-check/badge.svg)](https://github.com/geomarker-io/addNlcdData/actions)
<!-- badges: end -->

The goal of addNlcdData is to add varaibles from the [National Landcover
Database](https://www.mrlc.gov/) to your data based on nlcd\_cell (an
identifier for a 30 x 30 m NLCD grid cell) and year (2001, 2006, 2011,
or 2016).

## Installation

Install the development version from GitHub with:

    # install.packages("remotes")
    remotes::install_github("geomarker-io/addNlcdData")

### NLCD data details

  - Variables returned for point data include:
    
      - `impervious`: percent impervious
      - `landcover_class`: landcover classfication category (broad)
      - `landcover`: landcover classification (detailed)
      - `green`: TRUE/FALSE if landcover classification in any category
        except water, ice/snow, developed medium intensity, developed
        high intensity, rock/sand/clay
      - `road_type`: impervious descriptor category (or
        “non-impervious”)

  - Variables returned for polygon data include:
    
      - `impervious`: average percent impervious of all nlcd cells
        overlapping the polygon
      - `green`: percent of `green = TRUE` nlcd cells overlapping
        polygon
      - `primary_urban`, `primary_rural`, `secondary_urban`,
        `secondary_rural`, `tertiary_urban`, `tertiary_rural`,
        `thinned_urban`, `thinned_rural` `nonroad_urban`,
        `nonroad_rural`, `energyprod_urban`, `energyprod_rural`: percent
        of nlcd cells overlapping polygon classified as the
        corresponding impervious descriptor category
      - `nonimpervious`: percent of ncld cells overlapping polygon not
        classified as any of the impervious descriptior categories

  - Note that the NLCD categories correspond exactly to fraction
    imperviousness
    
    | nlcd category    | fraction impervious |
    | ---------------- | ------------------- |
    | developed open   | \< 20%              |
    | developed low    | 20 - 49%            |
    | developed medium | 50 - 79%            |
    | developed high   | 80 - 100%           |
    | any other        | 0%                  |
    

### NLCD grid chunk files

The NLCD product values are stored in fst files as “chunks” of the total
data and are names like `nlcd_chunk_{chunk_number}.fst`. Chunk files
will be automatically downloaded to the `./nlcd_fst/` folder in the
working directory; the number of chunk files needed depends on the
geographic extent of the input spatial data; their sizes vary, but each
file is 28.5 MB in size on average (all 1,685 files take about 48 GB on
disk). These files were created using code available at
<https://github.com/geomarker-io/nlcd_raster_to_fst>.

## Examples

Point Data

``` r
library(addNlcdData)

point_data <- tibble::tribble(
  ~id, ~lon, ~lat,
  51981, -84.69127387, 39.24710734,
  77553, -84.47798287, 39.12005904,
  52284, -84.47123583,  39.2631309,
  96308, -84.41741798, 39.18541228,
  78054, -84.41395064, 39.18322447
)

point_data <- get_nlcd_cell_numbers_points(point_data)
#> Warning: replacing previous import 'vctrs::data_frame' by
#> 'tibble::data_frame' when loading 'dplyr'

get_nlcd_data(point_data, product = c("nlcd", "impervious", "imperviousdescriptor"), year = 2016)
#> # A tibble: 5 x 10
#>      id   lon   lat nlcd_cell year  impervious landcover_class landcover
#>   <dbl> <dbl> <dbl>     <dbl> <chr>      <dbl> <chr>           <chr>    
#> 1 51981 -84.7  39.2    7.79e9 2016           0 forest          deciduou…
#> 2 77553 -84.5  39.1    7.85e9 2016          65 developed       develope…
#> 3 52284 -84.5  39.3    7.77e9 2016          36 developed       develope…
#> 4 96308 -84.4  39.2    7.81e9 2016           8 developed       develope…
#> 5 78054 -84.4  39.2    7.81e9 2016          28 developed       develope…
#> # … with 2 more variables: green <lgl>, road_type <chr>
```

Polygon Data

``` r
library(sf)
#> Linking to GEOS 3.7.2, GDAL 2.4.2, PROJ 5.2.0
library(tigris)
#> To enable 
#> caching of data, set `options(tigris_use_cache = TRUE)` in your R script or .Rprofile.
#> 
#> Attaching package: 'tigris'
#> The following object is masked from 'package:graphics':
#> 
#>     plot
options(tigris_class = 'sf')

polygon_data <- tigris::tracts(state = 'oh', county = 'hamilton') %>% 
  dplyr::slice(1:3) %>% 
  dplyr::select(GEOID)

get_nlcd_data_polygons(polygon_data)
#> Simple feature collection with 12 features and 17 fields
#> geometry type:  MULTIPOLYGON
#> dimension:      XY
#> bbox:           xmin: -84.44668 ymin: 39.14784 xmax: -84.37301 ymax: 39.1935
#> epsg (SRID):    4269
#> proj4string:    +proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs
#> First 10 features:
#>         GEOID year impervious green primary_urban primary_rural
#> 1 39061005500 2001         35    69             0             0
#> 2 39061005500 2006         37    67             0             0
#> 3 39061005500 2011         37    67             0             0
#> 4 39061005500 2016         38    66             0             0
#> 5 39061005600 2001         29    84             0             0
#>   secondary_urban secondary_rural tertiary_urban tertiary_rural
#> 1              11               0             18              0
#> 2              11               0             19              0
#> 3              11               0             19              0
#> 4              11               0             19              0
#> 5               7               0             34              0
#>   thinned_urban thinned_rural nonroad_urban nonroad_rural energyprod_urban
#> 1             0             0            59             0                0
#> 2             0             0            61             0                0
#> 3             0             0            61             0                0
#> 4             0             0            61             0                0
#> 5             0             0            54             0                0
#>   energyprod_rural nonimpervious                       geometry
#> 1                0            11 MULTIPOLYGON (((-84.42279 3...
#> 2                0             8 MULTIPOLYGON (((-84.42279 3...
#> 3                0             8 MULTIPOLYGON (((-84.42279 3...
#> 4                0             8 MULTIPOLYGON (((-84.42279 3...
#> 5                0             5 MULTIPOLYGON (((-84.40451 3...
#>  [ reached 'max' / getOption("max.print") -- omitted 5 rows ]
```

Points with buffers

``` r
get_nlcd_data_point_buffer(point_data, buffer_m = 400)
#> # A tibble: 20 x 20
#>       id   lon   lat nlcd_cell year  impervious green primary_urban
#>    <dbl> <dbl> <dbl>     <dbl> <chr>      <dbl> <dbl>         <dbl>
#>  1 51981 -84.7  39.2    7.79e9 2001           0   100             0
#>  2 51981 -84.7  39.2    7.79e9 2006           0   100             0
#>  3 51981 -84.7  39.2    7.79e9 2011           0   100             0
#>  4 51981 -84.7  39.2    7.79e9 2016           0   100             0
#>  5 77553 -84.5  39.1    7.85e9 2001          12    50             0
#>  6 77553 -84.5  39.1    7.85e9 2006          12    50             0
#>  7 77553 -84.5  39.1    7.85e9 2011          12    50             0
#>  8 77553 -84.5  39.1    7.85e9 2016          12    50             0
#>  9 52284 -84.5  39.3    7.77e9 2001          38    66             0
#> 10 52284 -84.5  39.3    7.77e9 2006          38    66             0
#> 11 52284 -84.5  39.3    7.77e9 2011          38    66             0
#> 12 52284 -84.5  39.3    7.77e9 2016          38    66             0
#> 13 96308 -84.4  39.2    7.81e9 2001          23    90             0
#> 14 96308 -84.4  39.2    7.81e9 2006          24    89             0
#> 15 96308 -84.4  39.2    7.81e9 2011          24    89             0
#> 16 96308 -84.4  39.2    7.81e9 2016          24    89             0
#> 17 78054 -84.4  39.2    7.81e9 2001          21    91             0
#> 18 78054 -84.4  39.2    7.81e9 2006          21    91             0
#> 19 78054 -84.4  39.2    7.81e9 2011          21    91             0
#> 20 78054 -84.4  39.2    7.81e9 2016          21    90             0
#> # … with 12 more variables: primary_rural <dbl>, secondary_urban <dbl>,
#> #   secondary_rural <dbl>, tertiary_urban <dbl>, tertiary_rural <dbl>,
#> #   thinned_urban <dbl>, thinned_rural <dbl>, nonroad_urban <dbl>,
#> #   nonroad_rural <dbl>, energyprod_urban <dbl>, energyprod_rural <dbl>,
#> #   nonimpervious <dbl>
```
