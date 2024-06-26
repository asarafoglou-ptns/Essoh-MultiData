#' @title Simulate Multivariate Data
#' @description
#' This function creates multivariate data with specified means and correlations.
#' @param n numeric, a single number specifying the sample size.
#' @param means numeric, a vector specifying the means for each variable.
#' @param diag_cor numeric, a single number specifying the correlation of each
#' variable with itself
#' @param within_cor numeric, a single number specifying the correlations between
#' variables within each multivariate outcome
#' @param between_cor numeric. a single number specifying the correlations between
#' variables from MV1 and variables from MV2
#' @param column, a single number specifying the column at which to split the 
#' overall data into two separate multivariate datasets.
#' @return A list containing both multivariate outcomes as separate elements 
#' @examples 
#' # Create a list with 2 multivariate outcomes. Each has 2 variables and 100 subjects
#' n <- 100
#'means <- rep(0, 4)
#'diag_cor  <- 1
#'within_cor <- 0.1
#'between_cor <- 0.2
#'column <- 2
#'my_data <- simulate_multivariate_data(n, means, diag_cor, within_cor, between_cor, column)
#' #  Access the split data
#'MV1 <- my_data$MV1
#'MV2 <- my_data$MV2
#' @export
simulate_multivariate_data <- function(n, means, diag_cor, within_cor, between_cor,column) {
  set.seed(1)
  p <- length(means)
  
  # Construct correlation matrix
  cor_matrix <- diag(p)
  cor_matrix[lower.tri(cor_matrix)] <- within_cor
  cor_matrix[upper.tri(cor_matrix)] <- t(cor_matrix)[upper.tri(cor_matrix)]
  cor_matrix[1:column, (column + 1):p] <- between_cor
  cor_matrix[(column + 1):p, 1:column] <- between_cor
  
  
  cor_matrix <- Matrix::nearPD(cor_matrix)$mat  # Ensure positive definite
  
  # Generate correlated data
  multivariate_data <- MASS::mvrnorm(n = n, mu = means, Sigma = cor_matrix, empirical = TRUE)
  
  
  # Split the data
  MV1 <- multivariate_data[, 1:column]
  MV2 <- multivariate_data[, (column + 1):ncol(multivariate_data)]
  
  # Return the split data
  return(list(MV1 = MV1, MV2 = MV2))
}


#' @title Simulate Heterogeneous Data
#' @description
#' The function creates multivariate data consisting of heterogeneous subsets.
#' @param n numeric, a single number specifying the sample size.
#' @param means numeric, a vector specifying the means for each variable.
#' @param cor_values numeric, a vector specifying the unique values in the lower
#' triangle of the correlation matrix, excluding the diagonal
#' @return A matrix containing the multivariate dataset
#' @examples 
#' # Create a matrix with 4 variables and 100 subjects
#'n <- 100
#'means <- rep(0, 4)
#'cor_values <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6)
#'my_data <- simulate_multivariate_data(n, means, cor_values)
#' @export
simulate_heterogeneous_data <- function(n, means, cor_values) {
  set.seed(1)
  p <- length(means)
  
  # Construct correlation matrix
  cor_matrix <- diag(p)
  cor_matrix[lower.tri(cor_matrix)] <- cor_values
  cor_matrix[upper.tri(cor_matrix)] <- t(cor_matrix)[upper.tri(cor_matrix)]
  cor_matrix <- Matrix::nearPD(cor_matrix)$mat  # Ensure positive definite
  
  # Generate correlated data
  simulated_data <- MASS::mvrnorm(n = n, mu = means, Sigma = cor_matrix, empirical = TRUE)
  
  return(simulated_data)
}






#' @title Maximum Canonical Correlation
#' @description
#' This function calculates the maximum canonical correlation between two sets of variables.
#' @param X matrix or dataframe, the first set of variables.
#' @param Y matrix or dataframe, the second set of variables.
#' @return numeric, the maximum canonical correlation.
#' @examples
#' # Create example datasets
#' set.seed(1)
#' X <- matrix(rnorm(100*5), 100, 5)
#' Y <- matrix(rnorm(100*3), 100, 3)
#' 
#' # Calculate the maximum canonical correlation
#' max_CC <- max_cancor(X, Y)
#' print(max_CC)
#' @export
max_cancor <- function(X,Y){
  max_CC <- max(cancor(X,Y)$cor)
  return(max_CC)
}




#' @title Null Distribution for Canonical Correlation Analysis
#' @description
#' This function generates the null distribution of the maximum canonical correlation 
#' by permuting the rows of the response variables and performing Canonical Correlation Analysis (CCA).
#' @param X matrix or dataframe, a set of explanatory variables.
#' @param Y matrix or dataframe, a set of response variables.
#' @param num_permutations numeric, the number of permutations to perform. Default is 1000.
#' @return Vector representing the null distribution of permuted canonical correlations.
#' @examples 
#' # Example with random data
#' set.seed(1)
#' X <- matrix(rnorm(100*3), 100, 3)
#' Y <- matrix(rnorm(100*2), 100, 2)
#' null_dist_CCA(X, Y, num_permutations = 500)
#' @export
null_dist_CCA <- function(X, Y, num_permutations = 1000) {
  null_dist <- numeric(num_permutations)
  for (i in 1:num_permutations) {
    perm_Y <- Y[sample(nrow(Y)), ]
    null_dist[i] <- max(cancor(X, perm_Y)$cor)
  }
  
  
  return(null_dist)
}




#' @title Adjusted Canonical Correlation Analysis
#' @description
#' This function calculates an adjusted canonical correlation by comparing the observed canonical correlation
#' to a null distribution generated by permuting the response variables.
#' @param X matrix or dataframe, a set of explanatory variables.
#' @param Y matrix or dataframe, a set of response variables.
#' @param num_permutations numeric, the number of permutations to perform. Default is 1000.
#' @param raw_CCA numeric, the observed canonical correlation.
#' @return numeric, the adjusted canonical correlation.
#' @examples 
#' # Example with random data
#' set.seed(1)
#' X <- matrix(rnorm(100*3), 100, 3)
#' Y <- matrix(rnorm(100*2), 100, 2)
#' raw_CCA <- max(cancor(X, Y)$cor)
#' adjusted_CCA <- adjust_CCA(X, Y, num_permutations = 500, raw_CCA = raw_CCA)
#' @export
adjust_CCA <- function(X, Y, num_permutations = 1000, raw_CCA) {
  perm_CCA <- numeric(num_permutations)
  for (i in 1:num_permutations) {
    perm_Y <- Y[sample(nrow(Y)), ]
    perm_CCA[i] <- (max(cancor(X, perm_Y)$cor))
  }
  
  mean_CCA <- mean(perm_CCA)
  adjusted_CCA <- raw_CCA - mean_CCA
  return(adjusted_CCA)
}



#' @title Permutation Test for Canonical Correlation Analysis
#' @description
#' This function performs a permutation test to calculate the p-value of the observed canonical correlation
#' by comparing it to a null distribution generated by permuting the response variables.
#' @param X matrix or dataframe, a set of explanatory variables.
#' @param Y matrix or dataframe, a set of response variables.
#' @param num_permutations numeric, the number of permutations to perform. Default is 1000.
#' @param observed numeric, the observed canonical correlation.
#' @return numeric, the p-value representing the significance of the observed canonical correlation.
#' @examples 
#' # Example with random data
#' set.seed(1)
#' X <- matrix(rnorm(100*3), 100, 3)
#' Y <- matrix(rnorm(100*2), 100, 2)
#' observed <- max(cancor(X, Y)$cor)
#' p_value <- Perm_test_CCA(X, Y, num_permutations = 500, observed = observed)
#' @export
Perm_test_CCA <- function(X, Y, num_permutations = 1000, observed) {
  null_dist <- numeric(num_permutations)
  for (i in 1:num_permutations) {
    perm_Y <- Y[sample(nrow(Y)), ]
    null_dist[i] <- max(cancor(X, perm_Y)$cor)
  }
  p <- sum(null_dist >= observed) / num_permutations
  return(p)
}


#' @title Representational Similarity Analysis (RSA)
#' @description
#' This function performs Representational Similarity Analysis (RSA) by calculating the correlation
#' between the pairwise distance matrices of two sets of variables.
#' @param X matrix or dataframe, a set of explanatory variables.
#' @param Y matrix or dataframe, a set of response variables.
#' @return numeric, the correlation between the pairwise distance matrices of X and Y.
#' @examples 
#' # Example with random data
#' set.seed(1)
#' X <- matrix(rnorm(100*3), 100, 3)
#' Y <- matrix(rnorm(100*2), 100, 2)
#' rsa_correlation <- RSA(X, Y)
#' @export
RSA <- function(X,Y){
  MV1_dist <- dist(X)
  MV2_dist <- dist(Y)
  dist_correl <- cor(MV1_dist, MV2_dist)
  return(dist_correl)
}



#' @title Null Distribution for Representational Similarity Analysis (RSA)
#' @description
#' This function generates the null distribution of the absolute value of the distance correlations
#' between two sets of variables by permuting the response variables.
#' @param X matrix or dataframe, a set of explanatory variables.
#' @param Y matrix or dataframe, a set of response variables.
#' @param num_permutations numeric, the number of permutations to perform. Default is 1000.
#' @return Vector representing the null distribution of permuted distance correlations.
#' @examples 
#' # Example with random data
#' set.seed(1)
#' X <- matrix(rnorm(100*3), 100, 3)
#' Y <- matrix(rnorm(100*2), 100, 2)
#' null_dist_RSA(X, Y, num_permutations = 500)
#' @export
null.dist_RSA <- function(X, Y, num_permutations = 1000) {
  null_dist <- numeric(num_permutations)
  for (i in 1:num_permutations){
    perm_Y <- Y[sample(nrow(Y)), ]  # Permute the outcome variables within each iteration
    dist_x <- dist(X)
    dist_y <- dist(perm_Y)
    
    null_dist[i] <- abs(cor(dist_x, dist_y))
  }
  
  return(null_dist)
}

#' @title Adjusted Representational Similarity Analysis (RSA)
#' @description
#' This function calculates an adjusted RSA value by comparing the observed distance correlation
#' to the mean of the null distribution generated by permuting the response variables.
#' @param X matrix or dataframe, a set of explanatory variables.
#' @param Y matrix or dataframe, a set of response variables.
#' @param num_permutations numeric, the number of permutations to perform. Default is 1000.
#' @param observed numeric, the observed distance correlation.
#' @return numeric, the adjusted RSA value.
#' @examples 
#' # Example with random data
#' set.seed(1)
#' X <- matrix(rnorm(100*3), 100, 3)
#' Y <- matrix(rnorm(100*2), 100, 2)
#' observed <- 0.5  # Placeholder for observed distance correlation
#' adjusted_RSA <- adjust_RSA(X, Y, num_permutations = 500, observed = observed)
#' @export
adjust_RSA <- function(X, Y, num_permutations = 1000, observed) {
  null_dist <- numeric(num_permutations)
  for (i in 1:num_permutations){
    perm_Y <- Y[sample(nrow(Y)), ]
    dist_x <- dist(X)
    dist_y <- dist(perm_Y)
    
    null_dist[i] <- abs(cor(dist_x, dist_y))
  }
  mean_cor <- mean(null_dist)
  adjusted_RSA <- observed - mean_cor
  return(adjusted_RSA)
}

#' @title Permutation Test for Representational Similarity Analysis (RSA)
#' @description
#' This function performs a permutation test to calculate the p-value of the observed distance correlation
#' by comparing it to a null distribution generated by permuting the response variables.
#' @param X matrix or dataframe, a set of explanatory variables.
#' @param Y matrix or dataframe, a set of response variables.
#' @param num_permutations numeric, the number of permutations to perform. Default is 1000.
#' @param observed numeric, the observed distance correlation.
#' @return numeric, the p-value representing the significance of the observed distance correlation.
#' @examples 
#' # Example with random data
#' set.seed(1)
#' X <- matrix(rnorm(100*3), 100, 3)
#' Y <- matrix(rnorm(100*2), 100, 2)
#' observed <- 0.5  # Placeholder for observed distance correlation
#' p_value <- Perm_test_RSA(X, Y, num_permutations = 500, observed = observed)
#' @export
Perm_test_RSA <- function(X, Y, num_permutations = 1000, observed) {
  null_dist <- numeric(num_permutations)
  for (i in 1:num_permutations){
    perm_Y <- Y[sample(nrow(Y)), ]  # Permute the outcome variables within each iteration
    dist_x <- dist(X)
    dist_y <- dist(perm_Y)
    
    null_dist[i] <- abs(cor(dist_x, dist_y))
  }
  p <- sum(null_dist >= abs(observed)) / num_permutations
  return(p)
}



