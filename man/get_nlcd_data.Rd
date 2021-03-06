% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nlcd_data_functions.R
\name{get_nlcd_data}
\alias{get_nlcd_data}
\title{get NLCD data for NLCD cells}
\usage{
get_nlcd_data(raw_data, product = c("nlcd", "impervious",
  "imperviousdescriptor"), year = c(2001, 2006, 2011, 2016))
}
\arguments{
\item{raw_data}{data.frame with column 'nlcd_cell'}

\item{product}{a character string of desired nlcd variables; a subset of c("nlcd", "impervious", "imperviousdescriptor")}

\item{year}{a numeric vector of desired nlcd years; a subset of c(2001, 2006, 2011, 2016)}
}
\value{
a data.frame identical to the input data.frame but with appended NLCD values (and in long format)
}
\description{
get NLCD data for NLCD cells
}
\examples{
if (FALSE) {
d <- data.frame(
  id = c('1a', '2b', '3c'),
  nlcd_cell = c(7814606790, 7814606790, 7756256174)
)

get_nlcd_data(d, product = c("nlcd", "impervious"), year = c(2011, 2016))
}
}
