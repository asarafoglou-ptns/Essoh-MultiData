% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Functions for RSA and CCA.R
\name{adjust_RSA}
\alias{adjust_RSA}
\title{Adjusted Representational Similarity Analysis (RSA)}
\usage{
adjust_RSA(X, Y, num_permutations = 1000, observed)
}
\arguments{
\item{X}{matrix or dataframe, a set of explanatory variables.}

\item{Y}{matrix or dataframe, a set of response variables.}

\item{num_permutations}{numeric, the number of permutations to perform. Default is 1000.}

\item{observed}{numeric, the observed distance correlation.}
}
\value{
numeric, the adjusted RSA value.
}
\description{
This function calculates an adjusted RSA value by comparing the observed distance correlation
to the mean of the null distribution generated by permuting the response variables.
}
\examples{
# Example with random data
set.seed(1)
X <- matrix(rnorm(100*3), 100, 3)
Y <- matrix(rnorm(100*2), 100, 2)
observed <- 0.5  # Placeholder for observed distance correlation
adjusted_RSA <- adjust_RSA(X, Y, num_permutations = 500, observed = observed)
}
