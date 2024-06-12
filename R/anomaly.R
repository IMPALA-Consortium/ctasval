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
