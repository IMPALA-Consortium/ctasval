#' Create site with anomalous patients
#'
#' Average
#'
#' @param df Data frame containing the study data.
#' @param anomaly_degree Degree of anomaly to add.
#' @param site prefix for new sites, Default is "sample_site".
#' @return A data frame with added anomalies.
#' @export
#' @rdname anomaly
#' @examples
#' set.seed(1)
#' library(ggplot2)
#'
#' df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)
#'
#' df_filt <- df_prep %>%
#'   filter(parameter_id == "Alkaline Phosphatase")
#'
#'df_anomaly <- anomaly_average(df_filt, anomaly_degree = 2, site = "anomolous")
#'
#'ggplot(df_filt, aes(x = timepoint_rank, y = result, group = subject_id)) +
#' geom_line(color = "black") +
#' geom_line(data = df_anomaly, color = "tomato") +
#' coord_cartesian(xlim = c(0, max(df_anomaly$timepoint_rank)))
#'
anomaly_average <- function(df, anomaly_degree, site = "sample_site") {
  sample_data <- sample_site(df, site) %>%
    mutate(
      result = .data$result + mean(.data$result, na.rm = TRUE) * .env$anomaly_degree,
      method = "average",
      .by = c("parameter_id", "subject_id")
    )

  return(sample_data)
}

#' Standard Deviation
#'
#' @rdname anomaly
#' @export
#' @examples
#' set.seed(1)
#' library(ggplot2)
#'
#' df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)
#'
#' df_filt <- df_prep %>%
#'   filter(parameter_id == "Alkaline Phosphatase")
#'
#'df_anomaly <- anomaly_sd(df_filt, anomaly_degree = 2, site = "anomolous")
#'
#'ggplot(df_filt, aes(x = timepoint_rank, y = result, group = subject_id)) +
#' geom_line(color = "black") +
#' geom_line(data = df_anomaly, color = "tomato") +
#' coord_cartesian(xlim = c(0, max(df_anomaly$timepoint_rank)))
#'
anomaly_sd <- function(df, anomaly_degree, site = "sample_site") {
  sample_data <- sample_site(df, site) %>%
    mutate(
      rbin = sample(c(1, -1), replace = TRUE, n())
    ) %>%
    mutate(
      result = .data$result + (mean(.data$result, na.rm = TRUE) * .env$anomaly_degree * .data$rbin),
      method = "sd",
      .by = c("parameter_id", "subject_id")
    ) %>%
    select(-.data$rbin)

  return(sample_data)
}

#' Autocorrelation
#'
#' @rdname anomaly
#' @export
#' @examples
#' set.seed(1)
#' library(ggplot2)
#'
#' df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)
#'
#' df_filt <- df_prep %>%
#'   filter(parameter_id == "Alkaline Phosphatase")
#'
#'df_anomaly <- anomaly_autocorr(df_filt, anomaly_degree = 2, site = "anomolous")
#'
#'ggplot(df_filt, aes(x = timepoint_rank, y = result, group = subject_id)) +
#' geom_line(color = "black") +
#' geom_line(data = df_anomaly, color = "tomato") +
#' coord_cartesian(xlim = c(0, max(df_anomaly$timepoint_rank)))
#'
anomaly_autocorr <- function(df, anomaly_degree, site = "sample_site") {
  sample_data <- sample_site(df, site) %>%
    mutate(
      # sin() calculates a wave with values 0-1 which we normalize by the result mean
      sin_param = sin(seq(1, n())) * mean(.data$result, na.rm = TRUE),
      .by = c("parameter_id")
    ) %>%
    mutate(
      result = .data$result + anomaly_degree * .data$sin_param,
      method = "autocorr"
    ) %>%
    select(-.data$sin_param)

  return(sample_data)
}


#' lof
#'
#' @rdname anomaly
#' @export
#' @param verbose logical, Default: FALSE
#' @seealso [rsurprise]
#' @examples
#' set.seed(1)
#' library(ggplot2)
#'
#' df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)
#'
#' df_filt <- df_prep %>%
#'   filter(parameter_id == "Alkaline Phosphatase")
#'
#'df_anomaly <- anomaly_lof(df_filt, anomaly_degree = 2, site = "anomolous", verbose = TRUE)
#'
#'ggplot(df_filt, aes(x = timepoint_rank, y = result, group = subject_id)) +
#' geom_line(color = "black") +
#' geom_line(data = df_anomaly, color = "tomato") +
#' coord_cartesian(xlim = c(0, max(df_anomaly$timepoint_rank)))
#'
#'
anomaly_lof <- function(df, anomaly_degree, site = "sample_site", verbose = FALSE) {
  sample_data <- sample_site(df, site)

  n_pat <- n_distinct(sample_data$subject_id)
  perc_pat_mod <- 1 - 1 / (anomaly_degree * 5 + 1)
  n_pat_mod <- floor(n_pat * perc_pat_mod)

  sample_data <- sample_data %>%
    mutate(
      surprise = rsurprise(n(), verbose = verbose),
      .by = c("subject_id", "parameter_id")
    ) %>%
    mutate(
      # we sample from a non-normal distribution, by modifying the
      # scale per patient we control the average of the returned values
      # and ensure that the values returned for each patient are different
      # compared to the other patients on site.
      surprise = .data$surprise * mean(.data$result),
      .by = c("parameter_id")
    ) %>%
    mutate(
      result = ifelse(
        dense_rank(.data$subject_id) <= .env$n_pat_mod,
        .data$surprise,
        .data$result
      ),
      method = "lof"
    ) %>%
    select(-.data$surprise)

  return(sample_data)
}


#' Range
#'
#' @rdname anomaly
#' @export
#' @examples
#' set.seed(7)
#' library(ggplot2)
#'
#' df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)
#'
#' df_filt <- df_prep %>%
#'   filter(parameter_id == "Alkaline Phosphatase")
#'
#'df_anomaly <- anomaly_range(df_filt, anomaly_degree = 2, site = "anomolous")
#'
#'ggplot(df_filt, aes(x = timepoint_rank, y = result, group = subject_id)) +
#' geom_line(color = "black") +
#' geom_line(data = df_anomaly, color = "tomato") +
#' coord_cartesian(xlim = c(0, max(df_anomaly$timepoint_rank)))
#'
anomaly_range <- function(df, anomaly_degree, site = "sample_site") {

  sample_data <- sample_site(df, site)

  df_outlier <- sample_data %>%
    group_by(.data$subject_id) %>%
    sample_n(1) %>%
    ungroup() %>%
    select("subject_id", "timepoint_rank") %>%
    mutate(add_outlier = TRUE)


  sample_data <- sample_data %>%
    left_join(
      df_outlier,
      by = c("subject_id", "timepoint_rank")
    ) %>%
    mutate(
      add_outlier = ifelse(is.na(.data$add_outlier), FALSE, .data$add_outlier),
      result = ifelse(
        .data$add_outlier,
        .data$result + mean(.data$result, na.rm = TRUE) * .env$anomaly_degree,
        .data$result),
      method = "range",
      .by = c("parameter_id")
    )

  return(sample_data)
}


#' sample values from a randomly selected non-normal distribution
#' @export
#' @param n integer, number of values
#' @param verbose logical, Default: FALSE
#' @examples
#' set.seed(1)
#' rsurprise(5, verbose = TRUE)
#' rsurprise(5, verbose = TRUE)
#'
#'
rsurprise <- function(n, verbose = FALSE) {
  # List of available distributions (excluding normal distribution)
  distributions <- c("rbinom", "rpois", "runif", "rexp", "rgamma", "rbeta")

  # Randomly select a distribution
  selected_dist <- sample(distributions, 1)

  # Randomly generate parameters based on the selected distribution
  if (selected_dist == "rbinom") {
    size <- sample(1:100, 1)
    prob <- runif(1)
    params <- list(size = size, prob = prob)
  } else if (selected_dist == "rpois") {
    lambda <- runif(1, min = 1, max = 10)
    params <- list(lambda = lambda)
  } else if (selected_dist == "runif") {
    min <- runif(1, min = 0, max = 5)
    max <- runif(1, min = min, max = 10)
    params <- list(min = min, max = max)
  } else if (selected_dist == "rexp") {
    rate <- runif(1, min = 0.1, max = 2)
    params <- list(rate = rate)
  } else if (selected_dist == "rgamma") {
    shape <- runif(1, min = 0.1, max = 10)
    scale <- runif(1, min = 0.1, max = 2)
    params <- list(shape = shape, scale = scale)
  } else if (selected_dist == "rbeta") {
    shape1 <- runif(1, min = 0.1, max = 5)
    shape2 <- runif(1, min = 0.1, max = 5)
    params <- list(shape1 = shape1, shape2 = shape2)
  }

  # Generate data points using the selected distribution and parameters
  data <- do.call(selected_dist, c(list(n = n), params))

  if (verbose) {
    # Print the selected distribution and parameters for information
    cat("Selected distribution:", selected_dist, "\n")
    cat("Parameters:", paste(paste(names(params), "=", sapply(params, round, 4)),
                             collapse = "; "), "\n")
  }

  return(data)
}

