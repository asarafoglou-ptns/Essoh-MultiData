% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Functions for RSA and CCA.R
\name{RSA}
\alias{RSA}
\title{Representational Similarity Analysis (RSA)}
\usage{
RSA(X, Y)
}
\arguments{
\item{X}{matrix or dataframe, a set of explanatory variables.}

\item{Y}{matrix or dataframe, a set of response variables.}
}
\value{
numeric, the correlation between the pairwise distance matrices of X and Y.
}
\description{
This function performs Representational Similarity Analysis (RSA) by calculating the correlation
between the pairwise distance matrices of two sets of variables.
}
\examples{
# Example with random data
set.seed(1)
X <- matrix(rnorm(100*3), 100, 3)
Y <- matrix(rnorm(100*2), 100, 2)
rsa_correlation <- RSA(X, Y)
}
