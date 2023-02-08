# out of range points ignored

    Code
      get_nlcd_data(get_nlcd_cell_numbers_points(d))
    Message <simpleMessage>
      1 rows were missing nlcd_cell and will be removed
    Output
      # A tibble: 5 x 10
           id   lat   lon  nlcd_cell year  impervious landcove~1 landc~2 green road_~3
        <dbl> <dbl> <dbl>      <dbl> <chr>      <dbl> <chr>      <chr>   <lgl> <chr>  
      1     1  18.2 -66.6         NA <NA>          NA <NA>       <NA>    NA    <NA>   
      2     2  39   -85   7955002182 2001           0 cultivated pastur~ TRUE  non-im~
      3     2  39   -85   7955002182 2006           0 cultivated pastur~ TRUE  non-im~
      4     2  39   -85   7955002182 2011           0 cultivated pastur~ TRUE  non-im~
      5     2  39   -85   7955002182 2016           0 cultivated pastur~ TRUE  non-im~
      # ... with abbreviated variable names 1: landcover_class, 2: landcover,
      #   3: road_type

---

    Code
      get_nlcd_data_point_buffer(d, 400)
    Message <simpleMessage>
      polygon is outside of contiguous U.S. all NLCD values will be missing
    Output
      # A tibble: 8 x 19
           id   lat   lon year  imperv~1 green prima~2 prima~3 secon~4 secon~5 terti~6
        <dbl> <dbl> <dbl> <chr>    <dbl> <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
      1     1  18.2 -66.6 2001        NA    NA      NA      NA      NA      NA      NA
      2     1  18.2 -66.6 2006        NA    NA      NA      NA      NA      NA      NA
      3     1  18.2 -66.6 2011        NA    NA      NA      NA      NA      NA      NA
      4     1  18.2 -66.6 2016        NA    NA      NA      NA      NA      NA      NA
      5     2  39   -85   2001         0   100       0       0       0       0       0
      6     2  39   -85   2006         0   100       0       0       0       0       0
      7     2  39   -85   2011         0   100       0       0       0       0       0
      8     2  39   -85   2016         0   100       0       0       0       0       0
      # ... with 8 more variables: tertiary_rural <dbl>, thinned_urban <dbl>,
      #   thinned_rural <dbl>, nonroad_urban <dbl>, nonroad_rural <dbl>,
      #   energyprod_urban <dbl>, energyprod_rural <dbl>, nonimpervious <dbl>, and
      #   abbreviated variable names 1: impervious, 2: primary_urban,
      #   3: primary_rural, 4: secondary_urban, 5: secondary_rural, 6: tertiary_urban

