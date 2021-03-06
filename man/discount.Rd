% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{discount}
\alias{discount}
\title{Discount a Quantity Over Time}
\usage{
discount(x, r, first = FALSE, period = 1)
}
\arguments{
\item{x}{numeric. A quantity to discount.}

\item{r}{discount rate.}

\item{first}{logical. Should discouting start at the
first value ?}

\item{period}{Number of cycle per unit of discount rate.}
}
\value{
A numeric vector of the same length as \code{x}.
}
\description{
Discount a Quantity Over Time
}
\examples{

discount(rep(10, 5), .02)
discount(rep(10, 5), .02, first = FALSE)

}
\keyword{internal}
