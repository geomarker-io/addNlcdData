test_that("out of range points ignored", {
  d <- tibble::tibble(id = c(1, 2),
                      lat = c(18.2084835, 39),
                      lon = c(-66.5858779, -85))

  expect_message(
    d_cell <- get_nlcd_data(get_nlcd_cell_numbers_points(d)),
    regexp = "1 rows were missing nlcd_cell and will be removed"
  )

  expect_equal(
    d_cell,
    tibble::tribble(
      ~id,       ~lat,        ~lon, ~nlcd_cell,  ~year, ~impervious, ~landcover_class,    ~landcover, ~green,       ~road_type,
      1, 18.2084835, -66.5858779,         NA,     NA,          NA,               NA,            NA,     NA,               NA,
      2,         39,         -85, 7955002182, "2001",           0,     "cultivated", "pasture/hay",   TRUE, "non-impervious",
      2,         39,         -85, 7955002182, "2006",           0,     "cultivated", "pasture/hay",   TRUE, "non-impervious",
      2,         39,         -85, 7955002182, "2011",           0,     "cultivated", "pasture/hay",   TRUE, "non-impervious",
      2,         39,         -85, 7955002182, "2016",           0,     "cultivated", "pasture/hay",   TRUE, "non-impervious"
    )
  )

  expect_message(
    d_buffer <- get_nlcd_data_point_buffer(d, 400),
    regexp = "polygon is outside of contiguous U.S. all NLCD values will be missing"
  )

  expect_equal(
    d_buffer |> dplyr::group_by(id) |> dplyr::slice(1) |> dplyr::select(id:primary_rural) |> dplyr::ungroup(),
    tibble::tribble(
      ~id,       ~lat,        ~lon,  ~year, ~impervious, ~green, ~primary_urban, ~primary_rural,
      1, 18.2084835, -66.5858779, "2001",          NA,     NA,             NA,             NA,
      2,         39,         -85, "2001",           0,    100,              0,              0
    )
  )

  on.exit(fs::dir_delete("s3_downloads"))
})
