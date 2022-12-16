
<!-- README.md is generated from README.Rmd. Please edit that file -->

# addNlcdData

<!-- badges: start -->

[![R build
status](https://github.com/geomarker-io/addNlcdData/workflows/R-CMD-check/badge.svg)](https://github.com/geomarker-io/addNlcdData/actions)
<!-- badges: end -->

The goal of addNlcdData is to add varaibles from the [National Landcover
Database](https://www.mrlc.gov/) to your data based on nlcd_cell (an
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
    except water, ice/snow, developed medium intensity, developed high
    intensity, rock/sand/clay (based on
    [published](https://doi.org/10.1016/j.ufug.2016.10.013) definitions)
  - `road_type`: impervious descriptor category (or “non-impervious”)

- Variables returned for polygon data include:

  - `impervious`: average percent impervious of all nlcd cells
    overlapping the polygon
  - `green`: percent of `green = TRUE` nlcd cells overlapping polygon
  - `primary_urban`, `primary_rural`, `secondary_urban`,
    `secondary_rural`, `tertiary_urban`, `tertiary_rural`,
    `thinned_urban`, `thinned_rural` `nonroad_urban`, `nonroad_rural`,
    `energyprod_urban`, `energyprod_rural`: percent of nlcd cells
    overlapping polygon classified as the corresponding impervious
    descriptor category
  - `nonimpervious`: percent of ncld cells overlapping polygon not
    classified as any of the impervious descriptior categories

- Note that the NLCD categories correspond exactly to fraction
  imperviousness

  | nlcd category    | fraction impervious |
  |------------------|---------------------|
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

get_nlcd_data(point_data, product = c("nlcd", "impervious", "imperviousdescriptor"), year = 2016)
#> # A tibble: 5 × 10
#>      id   lon   lat  nlcd_cell year  impervious landcove…¹ landc…² green road_…³
#>   <dbl> <dbl> <dbl>      <dbl> <chr>      <dbl> <chr>      <chr>   <lgl> <chr>  
#> 1 51981 -84.7  39.2 7790589150 2016           0 forest     decidu… TRUE  non-im…
#> 2 77553 -84.5  39.1 7854743431 2016          65 developed  develo… FALSE nonroa…
#> 3 52284 -84.5  39.3 7768829115 2016          36 developed  develo… TRUE  nonroa…
#> 4 96308 -84.4  39.2 7812350603 2016           8 developed  develo… TRUE  tertia…
#> 5 78054 -84.4  39.2 7813317754 2016          28 developed  develo… TRUE  nonroa…
#> # … with abbreviated variable names ¹​landcover_class, ²​landcover, ³​road_type
```

Polygon Data

``` r
library(sf)
library(tigris)
options(tigris_class = 'sf')
```

``` r
polygon_data <- tigris::tracts(state = 'oh', county = 'hamilton') %>% 
  dplyr::slice(1:3) %>% 
  dplyr::select(GEOID)
#> Retrieving data for the year 2021
#>   |                                                                              |                                                                      |   0%  |                                                                              |                                                                      |   1%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |==                                                                    |   4%  |                                                                              |===                                                                   |   4%  |                                                                              |===                                                                   |   5%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  17%  |                                                                              |============                                                          |  18%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |==============                                                        |  21%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  39%  |                                                                              |============================                                          |  40%  |                                                                              |============================                                          |  41%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |===============================                                       |  44%  |                                                                              |=================================                                     |  47%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |==========================================                            |  61%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  77%  |                                                                              |======================================================                |  78%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |==========================================================            |  84%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |===============================================================       |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |=================================================================     |  94%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================|  99%  |                                                                              |======================================================================| 100%
```

``` r
get_nlcd_data_polygons(polygon_data)
```

    #> Simple feature collection with 12 features and 17 fields
    #> Geometry type: MULTIPOLYGON
    #> Dimension:     XY
    #> Bounding box:  xmin: -84.66381 ymin: 39.16639 xmax: -84.57982 ymax: 39.2207
    #> Geodetic CRS:  NAD83
    #> First 10 features:
    #>          GEOID year impervious green primary_urban primary_rural
    #> 1  39061020764 2001         35    75             0             0
    #> 2  39061020764 2006         35    75             0             0
    #> 3  39061020764 2011         35    75             0             0
    #> 4  39061020764 2016         35    75             0             0
    #> 5  39061020763 2001         32    82             0             0
    #> 6  39061020763 2006         32    82             0             0
    #> 7  39061020763 2011         32    82             0             0
    #> 8  39061020763 2016         32    82             0             0
    #> 9  39061020604 2001         20    84             3             0
    #> 10 39061020604 2006         22    82             3             0
    #>    secondary_urban secondary_rural tertiary_urban tertiary_rural thinned_urban
    #> 1               10               0             23              0             0
    #> 2               10               0             23              0             0
    #> 3               10               0             23              0             0
    #> 4               10               0             23              0             0
    #> 5               10               0             23              0             0
    #> 6               10               0             23              0             0
    #> 7               10               0             23              0             0
    #> 8               10               0             23              0             0
    #> 9                8               0             18              0             0
    #> 10               8               0             19              0             0
    #>    thinned_rural nonroad_urban nonroad_rural energyprod_urban energyprod_rural
    #> 1              0            64             0                0                0
    #> 2              0            64             0                0                0
    #> 3              0            64             0                0                0
    #> 4              0            64             0                0                0
    #> 5              0            64             0                0                0
    #> 6              0            64             0                0                0
    #> 7              0            64             0                0                0
    #> 8              0            64             0                0                0
    #> 9              0            40             0                0                0
    #> 10             0            40             0                0                0
    #>    nonimpervious                       geometry
    #> 1              3 MULTIPOLYGON (((-84.60153 3...
    #> 2              3 MULTIPOLYGON (((-84.60153 3...
    #> 3              3 MULTIPOLYGON (((-84.60153 3...
    #> 4              3 MULTIPOLYGON (((-84.60153 3...
    #> 5              4 MULTIPOLYGON (((-84.60085 3...
    #> 6              4 MULTIPOLYGON (((-84.60085 3...
    #> 7              4 MULTIPOLYGON (((-84.60085 3...
    #> 8              4 MULTIPOLYGON (((-84.60085 3...
    #> 9             31 MULTIPOLYGON (((-84.66314 3...
    #> 10            30 MULTIPOLYGON (((-84.66314 3...

Points with buffers

``` r
get_nlcd_data_point_buffer(point_data, buffer_m = 400)
```

    #> # A tibble: 20 × 20
    #>       id   lon   lat nlcd_…¹ year  imper…² green prima…³ prima…⁴ secon…⁵ secon…⁶
    #>    <dbl> <dbl> <dbl>   <dbl> <chr>   <dbl> <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
    #>  1 51981 -84.7  39.2  7.79e9 2001        0   100       0       0       0       0
    #>  2 51981 -84.7  39.2  7.79e9 2006        0   100       0       0       0       0
    #>  3 51981 -84.7  39.2  7.79e9 2011        0   100       0       0       0       0
    #>  4 51981 -84.7  39.2  7.79e9 2016        0   100       0       0       0       0
    #>  5 77553 -84.5  39.1  7.85e9 2001       12    50       0       0      12       0
    #>  6 77553 -84.5  39.1  7.85e9 2006       12    50       0       0      12       0
    #>  7 77553 -84.5  39.1  7.85e9 2011       12    50       0       0      12       0
    #>  8 77553 -84.5  39.1  7.85e9 2016       12    50       0       0      12       0
    #>  9 52284 -84.5  39.3  7.77e9 2001       38    66       0       0       6       0
    #> 10 52284 -84.5  39.3  7.77e9 2006       38    66       0       0       6       0
    #> 11 52284 -84.5  39.3  7.77e9 2011       38    66       0       0       6       0
    #> 12 52284 -84.5  39.3  7.77e9 2016       38    66       0       0       6       0
    #> 13 96308 -84.4  39.2  7.81e9 2001       23    90       0       0       9       0
    #> 14 96308 -84.4  39.2  7.81e9 2006       23    89       0       0       9       0
    #> 15 96308 -84.4  39.2  7.81e9 2011       23    89       0       0       9       0
    #> 16 96308 -84.4  39.2  7.81e9 2016       24    89       0       0       9       0
    #> 17 78054 -84.4  39.2  7.81e9 2001       21    91       0       0       6       0
    #> 18 78054 -84.4  39.2  7.81e9 2006       21    91       0       0       6       0
    #> 19 78054 -84.4  39.2  7.81e9 2011       21    91       0       0       6       0
    #> 20 78054 -84.4  39.2  7.81e9 2016       21    90       0       0       6       0
    #> # … with 9 more variables: tertiary_urban <dbl>, tertiary_rural <dbl>,
    #> #   thinned_urban <dbl>, thinned_rural <dbl>, nonroad_urban <dbl>,
    #> #   nonroad_rural <dbl>, energyprod_urban <dbl>, energyprod_rural <dbl>,
    #> #   nonimpervious <dbl>, and abbreviated variable names ¹​nlcd_cell,
    #> #   ²​impervious, ³​primary_urban, ⁴​primary_rural, ⁵​secondary_urban,
    #> #   ⁶​secondary_rural
