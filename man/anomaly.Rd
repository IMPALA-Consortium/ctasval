% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/anomaly.R
\name{anomaly_average}
\alias{anomaly_average}
\alias{anomaly_sd}
\alias{anomaly_autocorr}
\alias{anomaly_lof}
\alias{anomaly_range}
\alias{anomaly_unique_value_count_relative}
\title{Create site with anomalous patients}
\usage{
anomaly_average(df, anomaly_degree, site = "sample_site")

anomaly_sd(df, anomaly_degree, site = "sample_site")

anomaly_autocorr(df, anomaly_degree, site = "sample_site")

anomaly_lof(df, anomaly_degree, site = "sample_site", verbose = FALSE)

anomaly_range(df, anomaly_degree, site = "sample_site")

anomaly_unique_value_count_relative(df, anomaly_degree, site = "sample_site")
}
\arguments{
\item{df}{Data frame containing the study data.}

\item{anomaly_degree}{Degree of anomaly to add.}

\item{site}{prefix for new sites, Default is "sample_site".}

\item{verbose}{logical, Default: FALSE}
}
\value{
A data frame with added anomalies.
}
\description{
Average
}
\examples{
set.seed(1)
library(ggplot2)

df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)

df_filt <- df_prep \%>\%
  filter(parameter_id == "Alkaline Phosphatase")

df_anomaly <- anomaly_average(df_filt, anomaly_degree = 2, site = "anomolous")

ggplot(df_filt, aes(x = timepoint_rank, y = result, group = subject_id)) +
geom_line(color = "black") +
geom_line(data = df_anomaly, color = "tomato") +
coord_cartesian(xlim = c(0, max(df_anomaly$timepoint_rank)))

set.seed(1)
library(ggplot2)

df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)

df_filt <- df_prep \%>\%
  filter(parameter_id == "Alkaline Phosphatase")

df_anomaly <- anomaly_sd(df_filt, anomaly_degree = 2, site = "anomolous")

ggplot(df_filt, aes(x = timepoint_rank, y = result, group = subject_id)) +
geom_line(color = "black") +
geom_line(data = df_anomaly, color = "tomato") +
coord_cartesian(xlim = c(0, max(df_anomaly$timepoint_rank)))

set.seed(1)
library(ggplot2)

df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)

df_filt <- df_prep \%>\%
  filter(parameter_id == "Alkaline Phosphatase")

df_anomaly <- anomaly_autocorr(df_filt, anomaly_degree = 2, site = "anomolous")

ggplot(df_filt, aes(x = timepoint_rank, y = result, group = subject_id)) +
geom_line(color = "black") +
geom_line(data = df_anomaly, color = "tomato") +
coord_cartesian(xlim = c(0, max(df_anomaly$timepoint_rank)))

set.seed(1)
library(ggplot2)

df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)

df_filt <- df_prep \%>\%
  filter(parameter_id == "Alkaline Phosphatase")

df_anomaly <- anomaly_lof(df_filt, anomaly_degree = 2, site = "anomolous", verbose = TRUE)

ggplot(df_filt, aes(x = timepoint_rank, y = result, group = subject_id)) +
geom_line(color = "black") +
geom_line(data = df_anomaly, color = "tomato") +
coord_cartesian(xlim = c(0, max(df_anomaly$timepoint_rank)))


set.seed(7)
library(ggplot2)

df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)

df_filt <- df_prep \%>\%
  filter(parameter_id == "Alkaline Phosphatase")

df_anomaly <- anomaly_range(df_filt, anomaly_degree = 2, site = "anomolous")

ggplot(df_filt, aes(x = timepoint_rank, y = result, group = subject_id)) +
geom_line(color = "black") +
geom_line(data = df_anomaly, color = "tomato") +
coord_cartesian(xlim = c(0, max(df_anomaly$timepoint_rank)))

set.seed(1)
library(ggplot2)

df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)

df_filt <- df_prep \%>\%
  filter(parameter_id == "Alkaline Phosphatase")

df_anomaly <- anomaly_unique_value_count_relative(df_filt, anomaly_degree = 2, site = "anomolous")

ggplot(df_filt, aes(x = timepoint_rank, y = result, group = subject_id)) +
geom_line(color = "black") +
geom_line(data = df_anomaly, color = "tomato") +
coord_cartesian(xlim = c(0, max(df_anomaly$timepoint_rank)))

}
\seealso{
\link{rsurprise}
}
