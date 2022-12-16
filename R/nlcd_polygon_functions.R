get_nlcd_percentages <- function(query_poly) {
  nlcd_cells <- exactextractr::exact_extract(r_nlcd_empty(), query_poly, include_cell = T)[[1]]

  query_poly <- tibble::tibble(
    .row = seq_len(length(nlcd_cells$cell)),
    nlcd_cell = nlcd_cells$cell,
    coverage_fraction = nlcd_cells$coverage_fraction
  )

  nlcd_data <- get_nlcd_data(query_poly)

  road_type_percentage <- function(road_type_vector, road_type) {
    fraction_roads <- sum(road_type_vector == road_type) / length(road_type_vector)
    round(fraction_roads * 100, 0)
  }

  nlcd_data %>%
    dplyr::group_by(year) %>%
    dplyr::summarize(
      impervious = round(mean(impervious), 0),
      green = round(100 * sum(green) / length(green), 0),
      primary_urban = road_type_percentage(road_type, "primary_urban"),
      primary_rural = road_type_percentage(road_type, "primary_rural"),
      secondary_urban = road_type_percentage(road_type, "secondary_urban"),
      secondary_rural = road_type_percentage(road_type, "secondary_rural"),
      tertiary_urban = road_type_percentage(road_type, "tertiary_urban"),
      tertiary_rural = road_type_percentage(road_type, "tertiary_rural"),
      thinned_urban = road_type_percentage(road_type, "thinned_urban"),
      thinned_rural = road_type_percentage(road_type, "thinned_rural"),
      nonroad_urban = road_type_percentage(road_type, "nonroad_urban"),
      nonroad_rural = road_type_percentage(road_type, "nonroad_rural"),
      energyprod_urban = road_type_percentage(road_type, "energyprod_urban"),
      energyprod_rural = road_type_percentage(road_type, "energyprod_rural"),
      nonimpervious = road_type_percentage(road_type, "non-impervious")
    )
}

#' get NLCD data for polygons
#'
#' @param polygon_data an sf data.frame containing polygons for which data from nlcd cells will be averaged
#'
#' @return a data.frame identical to the input data.frame but with appended percentage NLCD values (and in long format)
#'         all available products and years will be returned.
#'
#' @export
get_nlcd_data_polygons <- function(polygon_data) {
  if (!"sf" %in% class(polygon_data)) {
    stop("input object must be of class 'sf'")
  }

  polygon_data$.row <- seq_len(nrow(polygon_data))

  d <-
    polygon_data %>%
    dplyr::select(.row) %>%
    stats::na.omit() %>%
    sf::st_transform(crs = raster::crs(r_nlcd_empty())) # reproject points into NLCD projection for overlay

  d_out <- purrr::map(1:nrow(d), ~ get_nlcd_percentages(d[.x, ]))

  d_out <- purrr::map2(d_out, 1:length(d_out), ~ dplyr::mutate(.x, .row = .y))

  d_out <-
    dplyr::bind_rows(d_out) %>%
    dplyr::left_join(polygon_data, ., by = ".row") %>%
    dplyr::select(-.row)

  return(d_out)
}

#' get NLCD data for specified buffer radius around point data
#'
#' @param point_data data.frame with columns 'lat' and 'lon'
#' @param buffer_m desired buffer radius in meters
#'
#' @return a data.frame identical to the input data.frame but with appended percentage NLCD values (and in long format)
#'         all available products and years will be returned.
#'
#' @examples
#' if (FALSE) {
#'   point_data <- data.frame(
#'     id = c("1a", "2b", "3c"),
#'     lat = c(39.19674, 39.19674, 39.28765),
#'     lon = c(-84.582601, -84.582601, -84.510173)
#'   )
#'
#'   get_nlcd_data_polygons(point_data, buffer_m = 400)
#' }
#' @export
get_nlcd_data_point_buffer <- function(point_data, buffer_m) {
  point_data$.row <- seq_len(nrow(point_data))

  d <-
    point_data %>%
    dplyr::select(.row, lat, lon) %>%
    stats::na.omit() %>%
    tidyr::nest(.rows = c(.row)) %>%
    sf::st_as_sf(coords = c("lon", "lat"), crs = 4326)

  # project to 5072 for buffering in meters
  d <- d %>%
    sf::st_transform(5072) %>%
    sf::st_buffer(dist = buffer_m)

  d <- get_nlcd_data_polygons(d)

  d_out <-
    d %>%
    sf::st_drop_geometry() %>%
    tidyr::unnest(cols = c(.rows))

  d_out <-
    dplyr::left_join(point_data, d_out, by = ".row") %>%
    dplyr::select(-.row)

  return(d_out)
}
