test_that("out of range points ignored", {
  d <- tibble::tibble(id = c(1, 2),
                      lat = c(18.2084835, 39),
                      lon = c(-66.5858779, -85))

  expect_snapshot(
    get_nlcd_data(get_nlcd_cell_numbers_points(d))
  )

  expect_snapshot(
    get_nlcd_data_point_buffer(d, 400)
  )

  on.exit(fs::dir_delete("s3_downloads"))
})
