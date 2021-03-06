# define legends for raster values (and our green codes)
nlcd_legend <-
  tibble::tribble(
    ~value, ~landcover_class, ~landcover, ~green,
    11, "water", "water", FALSE,
    12, "water", "ice/snow", FALSE,
    21, "developed", "developed open", TRUE,
    22, "developed", "developed low intensity", TRUE,
    23, "developed", "developed medium intensity", FALSE,
    24, "developed", "developed high intensity", FALSE,
    31, "barren", "rock/sand/clay", FALSE,
    41, "forest", "deciduous forest", TRUE,
    42, "forest", "evergreen forest", TRUE,
    43, "forest", "mixed forest", TRUE,
    51, "shrubland", "dwarf scrub", TRUE,
    52, "shrubland", "shrub/scrub", TRUE,
    71, "herbaceous", "grassland", TRUE,
    72, "herbaceous", "sedge", TRUE,
    73, "herbaceous", "lichens", TRUE,
    74, "herbaceous", "moss", TRUE,
    81, "cultivated", "pasture/hay", TRUE,
    82, "cultivated", "cultivated crops", TRUE,
    90, "wetlands", "woody wetlands", TRUE,
    95, "wetlands", "emergent herbaceous wetlands", TRUE
  )

imperviousness_legend <-
  tibble::tribble(
    ~value, ~road_type,
    0, "non-impervious",
    1, "primary_urban",
    2, "primary_nonurban",
    3, "secondary_urban",
    4, "secondary_nonurban",
    5, "tertiary_urban",
    6, "tertiary_nonurban",
    7, "thinned_urban",
    8, "thinned_nonurban",
    9, "nonroad_urban",
    10, "nonroad_nonurban",
    11, "energy_prod_urban",
    12, "energy_prod_nonurban",
  )
