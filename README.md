
<!-- README.md is generated from README.Rmd. Please edit that file -->

# addNlcdData

<!-- badges: start -->

[![R build
status](https://github.com/geomarker-io/addNlcdData/workflows/R-CMD-check/badge.svg)](https://github.com/geomarker-io/addNlcdData/actions)
<!-- badges: end -->

The goal of addNlcdData is to add NLCD weather varaibles to your data
based on nlcd\_cell (an identifier for a 30 x 30 m NLCD grid cell) and
year (2001, 2006, 2011, or 2016).

## Installation

Install the development version from GitHub with:

    # install.packages("remotes")
    remotes::install_github("geomarker-io/addNlcdData")

### NLCD grid chunk files

The NLCD product values are stored in fst files as “chunks” of the total
data and are names like `nlcd_chunk_{chunk_number}.fst`. Chunk files
will be automatically downloaded to the `./nlcd_fst/` folder in the
working directory; the number of chunk files needed depends on the
geographic extent of the input spatial data; their sizes vary, but each
file is 28.5 MB in size on average (all 1,685 files take about 48 GB on
disk).

## Example

``` r
library(addNlcdData)
library(magrittr)

d <- tibble::tribble(
  ~id, ~lon, ~lat,
  51981, -84.69127387, 39.24710734,
  77553, -84.47798287, 39.12005904,
  52284, -84.47123583,  39.2631309,
  96308, -84.41741798, 39.18541228,
  78054, -84.41395064, 39.18322447
)

d <- get_nlcd_cell_numbers_points(d)
#> Warning: replacing previous import 'vctrs::data_frame' by
#> 'tibble::data_frame' when loading 'dplyr'

get_nlcd_data(d, product = c("nlcd", "impervious", "imperviousdescriptor"), year = 2016)
#> 0 rows were missing nlcd_cell and will be removed
#> # A tibble: 5 x 9
#>      id   lon   lat year  impervious landcover_class landcover green
#>   <dbl> <dbl> <dbl> <chr>      <dbl> <chr>           <chr>     <lgl>
#> 1 52284 -84.5  39.3 2016          22 developed       develope… TRUE 
#> 2 51981 -84.7  39.2 2016           0 forest          deciduou… TRUE 
#> 3 96308 -84.4  39.2 2016          10 developed       develope… TRUE 
#> 4 78054 -84.4  39.2 2016          40 developed       develope… TRUE 
#> 5 77553 -84.5  39.1 2016          51 developed       develope… FALSE
#> # … with 1 more variable: road_type <chr>
```
