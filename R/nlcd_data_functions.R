#' get NLCD cell numbers for given lat and lon
#'
#' @param point_data data.frame with columns 'lat' and 'lon'
#'
#' @return a data.frame identical to the input data.frame but with appended NLCD cell numbers
#'
#' @examples
#' if (FALSE) {
#' point_data <- data.frame(
#'   id = c('1a', '2b', '3c'),
#'   lat = c(39.19674, 39.19674, 39.28765),
#'   lon = c(-84.582601, -84.582601, -84.510173)
#' )
#'
#' get_nlcd_cell_numbers_points(point_data)
#' }
#' @export
get_nlcd_cell_numbers_points <- function(point_data) {
  if (!"lat" %in% colnames(point_data)) {
    stop("input dataframe must have a column called 'lat'")
  }

  if (!"lon" %in% colnames(point_data)) {
    stop("input dataframe must have a column called 'lon'")
  }

  point_data$.row <- seq_len(nrow(point_data))

  d <-
    point_data %>%
    dplyr::select(.row, lat, lon) %>%
    stats::na.omit() %>%
    tidyr::nest(.rows = c(.row)) %>%
    sf::st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
    sf::st_transform(crs = raster::crs(r_nlcd_empty())) # reproject points into NLCD projection for overlay

  d <- d %>%
    dplyr::mutate(nlcd_cell = raster::cellFromXY(r_nlcd_empty(), sf::as_Spatial(d)))

  d_out <- d %>%
    tidyr::unnest(.rows) %>%
    sf::st_drop_geometry() %>%
    dplyr::left_join(point_data, ., by = ".row") %>%
    dplyr::select(-.row)

  return(d_out)
}

read_nlcd_fst_join <- function(d,
                               product = c("nlcd", "impervious", "imperviousdescriptor"),
                               year = c(2001, 2006, 2011, 2016)) {
  nlcd_cell_number <- unique(d$nlcd_cell)
  nlcd_chunk <- nlcd_cell_number %/% 1e+07
  nlcd_row <- nlcd_cell_number %% 1e+07
  nlcd_file <- glue::glue("./nlcd_fst/nlcd_chunk_{nlcd_chunk}.fst")
  nlcd_columns <- unlist(purrr::map(year, ~ glue::glue("{product}_{.}")))
  if (!file.exists(nlcd_file)) download_nlcd_chunk(nlcd_chunk)
  out <- fst::read_fst(
    path = nlcd_file,
    from = nlcd_row,
    to = nlcd_row,
    columns = nlcd_columns
  )
  out <- tibble::as_tibble(out)
  out <- dplyr::bind_cols(d, out)
  out
}


#' get NLCD data for NLCD cells
#'
#' @param d data.frame with column 'nlcd_cell'
#' @param product a character string of desired nlcd variables; a subset of c("nlcd", "impervious", "imperviousdescriptor")
#' @param year a numeric vector of desired nlcd years; a subset of c(2001, 2006, 2011, 2016)
#'
#' @return a data.frame identical to the input data.frame but with appended NLCD values (and in long format)
#'
#' @examples
#' if (FALSE) {
#' d <- data.frame(
#'   id = c('1a', '2b', '3c'),
#'   nlcd_cell = c(7814606790, 7814606790, 7756256174)
#' )
#'
#' get_nlcd_data(d, product = c("nlcd", "impervious"), year = c(2011, 2016))
#' }
#' @export
get_nlcd_data <- function(d,
                          product = c("nlcd", "impervious", "imperviousdescriptor"),
                          year = c(2001, 2006, 2011, 2016)) {

  if (!"nlcd_cell" %in% colnames(d)) {
    stop("input dataframe must have a column called 'nlcd_cell'")
  }

  message(nrow(d %>% dplyr::filter(is.na(nlcd_cell))), ' rows were missing nlcd_cell and will be removed')
  d <- d %>% dplyr::filter(!is.na(nlcd_cell))

  d <- split(d, d$nlcd_cell)

  out <- purrr::map_dfr(d, ~ read_nlcd_fst_join(.x, product, year))

  out <-
    out %>%
    dplyr::select(-nlcd_cell) %>%
    tidyr::pivot_longer(cols = tidyselect::starts_with(product),
                        names_to = c("product", "year"), names_sep = "_") %>%
    tidyr::pivot_wider(names_from = product, values_from = value) %>%
    dplyr::left_join(nlcd_legend, by = c("nlcd" = "value")) %>%
    dplyr::select(-nlcd) %>%
    dplyr::left_join(imperviousness_legend, by = c("imperviousdescriptor" = "value")) %>%
    dplyr::select(-imperviousdescriptor)

  return(out)
}

download_nlcd_chunk <- function(nlcd_chunk_number) {
  dir.create("./nlcd_fst/", showWarnings = FALSE)
  nlcd_file <- glue::glue("./nlcd_fst/nlcd_chunk_{nlcd_chunk_number}.fst")
  if (file.exists(nlcd_file)) {
    message(glue::glue("{nlcd_file} already exists"))
    invisible(return(NULL))
  }
  message(glue::glue("downloading s3://geomarker/nlcd/nlcd_chunk_{nlcd_chunk_number}.fst to {nlcd_file}"))
  utils::download.file(
    url = glue::glue(
      "https://geomarker.s3.us-east-2.amazonaws.com/",
      "nlcd/nlcd_fst/", "nlcd_chunk_{nlcd_chunk_number}.fst"
    ),
    destfile = nlcd_file
  )
}

#' download all chunks needed for nlcd multiple cell numbers ahead of time
#'
#' @param nlcd_cell_numbers vector of nlcd cell numbers
#'
#' @return downloaded fst files in nlcd_fst folder in working directory
#'
#' @examples
#' if (FALSE) {
#' nlcd_cell_numbers <- c(7814606790, 7814606790, 7756256174)
#'
#' download_nlcd_chunks(nlcd_cell_numbers)
#' }
#' @export
download_nlcd_chunks <- function(nlcd_cell_numbers) {
  nlcd_chunks_needed <- unique(nlcd_cell_numbers %/% 1e+07)
  message("downloading ", length(nlcd_chunks_needed), " total chunk files to ./nlcd_fst/")
  purrr::walk(nlcd_chunks_needed, download_nlcd_chunk)
}
