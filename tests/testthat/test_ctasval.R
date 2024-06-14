library(testthat)
library(dplyr)
library(tidyr)
library(purrr)

# Sample data from the pharmaversesdtm package
data("lb", package = "pharmaversesdtm")
data("dm", package = "pharmaversesdtm")

test_that("prep_sdtm_lb works correctly", {
  result <- prep_sdtm_lb(lb, dm)

  expect_true("timepoint_rank" %in% names(result))
  expect_true("timepoint_1_name" %in% names(result))
  expect_true("result" %in% names(result))
  expect_true("parameter_id" %in% names(result))
  expect_true("subject_id" %in% names(result))
  expect_true("site" %in% names(result))
})

test_that("anomaly_average works correctly", {
  df_prep <- prep_sdtm_lb(lb, dm, scramble = TRUE)
  anomaly_degree <- 0.5
  result <- anomaly_average(df_prep, anomaly_degree)

  expect_true("method" %in% names(result))
  expect_equal(result$method[1], "average")
})

test_that("anomaly_sd works correctly", {
  df_prep <- prep_sdtm_lb(lb, dm, scramble = TRUE)
  anomaly_degree <- 0.5
  result <- anomaly_sd(df_prep, anomaly_degree)

  expect_true("method" %in% names(result))
  expect_equal(result$method[1], "sd")
})

test_that("anomaly_autocorr works correctly", {
  df_prep <- prep_sdtm_lb(lb, dm, scramble = TRUE)
  anomaly_degree <- 0.5
  result <- anomaly_autocorr(df_prep, anomaly_degree)

  expect_true("method" %in% names(result))
  expect_equal(result$method[1], "autocorr")
})

test_that("anomaly_lof works correctly", {
  df_prep <- prep_sdtm_lb(lb, dm, scramble = TRUE)
  anomaly_degree <- 0.5
  result <- anomaly_lof(df_prep, anomaly_degree)

  expect_true("method" %in% names(result))
  expect_equal(result$method[1], "lof")
})

test_that("ctasval works correctly", {
  df_prep <- prep_sdtm_lb(lb, dm, scramble = TRUE)

  df_filt <- df_prep %>%
    filter(parameter_id == "Alkaline Phosphatase")

  ctas <- ctasval(
    df = df_filt,
    fun_anomaly = c(anomaly_average, anomaly_sd),
    feats = c("average", "sd"),
    parallel = FALSE,
    iter = 1
  )

  expect_true("result" %in% names(ctas))
  expect_true("anomaly" %in% names(ctas))
  expect_true("score" %in% colnames(ctas$anomaly))
})
