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

test_that("anomaly_autocorr2 works correctly", {
  df_prep <- prep_sdtm_lb(lb, dm, scramble = TRUE)
  anomaly_degree <- 0.5
  result <- anomaly_autocorr2(df_prep, anomaly_degree)

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

test_that("anomaly_range works correctly", {
  df_prep <- prep_sdtm_lb(lb, dm, scramble = TRUE)
  anomaly_degree <- 0.5
  result <- anomaly_range(df_prep, anomaly_degree)

  expect_true("method" %in% names(result))
  expect_equal(result$method[1], "range")
})

test_that("anomaly_unique_value_count works correctly", {
  df_prep <- prep_sdtm_lb(lb, dm, scramble = TRUE)
  anomaly_degree <- 0.5
  result <- anomaly_unique_value_count_relative(df_prep, anomaly_degree)

  expect_true("method" %in% names(result))
  expect_equal(result$method[1], "unique_value_count_relative")
})

test_that("ctasval works correctly for ks scoring", {
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
  expect_true("is_signal" %in% colnames(ctas$anomaly))

  check_3P <- ctas$result %>%
    mutate(
      P = TP + FN,
      check = P == 3
    ) %>%
    pull(check) %>%
    all()

  expect_true(check_3P)

})

test_that("ctasval works correctly for mixedeffects scoring", {
  df_prep <- prep_sdtm_lb(lb, dm, scramble = TRUE)

  df_filt <- df_prep %>%
    filter(parameter_id == "Alkaline Phosphatase")

  ctas <- ctasval(
    df = df_filt,
    fun_anomaly = c(anomaly_average, anomaly_sd),
    feats = c("average", "sd"),
    parallel = FALSE,
    iter = 1,
    site_scoring_method = "mixedeffects"
  )

  expect_true("result" %in% names(ctas))
  expect_true("anomaly" %in% names(ctas))
  expect_true("score" %in% colnames(ctas$anomaly))
  expect_true("is_signal" %in% colnames(ctas$anomaly))

  check_3P <- ctas$result %>%
    mutate(
      P = TP + FN,
      check =  P == 3
    ) %>%
    pull(check) %>%
    all()

  expect_true(check_3P)
})

test_that("ctasval works correctly for avg_feat_value scoring", {
  df_prep <- prep_sdtm_lb(lb, dm, scramble = TRUE)

  df_filt <- df_prep %>%
    filter(parameter_id == "Alkaline Phosphatase")

  ctas <- ctasval(
    df = df_filt,
    fun_anomaly = c(anomaly_average, anomaly_sd),
    feats = c("average", "sd"),
    parallel = FALSE,
    iter = 1,
    site_scoring_method = "avg_feat_value"
  )
  expect_true("result" %in% names(ctas))
  expect_true("anomaly" %in% names(ctas))
  expect_true("score" %in% colnames(ctas$anomaly))
  expect_true("is_signal" %in% colnames(ctas$anomaly))

  check_3P <- ctas$result %>%
    mutate(
      P = TP + FN,
      check = P == 3
    ) %>%
    pull(check) %>%
    all()

  expect_true(check_3P)

})

test_that("NA rate comparable across scoring methods", {
  df_prep <- prep_sdtm_lb(lb, dm, scramble = TRUE)

  df_filt <- df_prep %>%
    filter(parameter_id == "Alkaline Phosphatase")

  ctas_ks <- ctasval(
    df = df_filt,
    fun_anomaly = c(anomaly_average),
    feats = c("average"),
    parallel = FALSE,
    anomaly_degree = 10,
    iter = 20,
    site_scoring_method = "ks"
  )

  ctas_mixedeffects <- ctasval(
    df = df_filt,
    fun_anomaly = c(anomaly_average),
    feats = c("average"),
    parallel = FALSE,
    anomaly_degree = 10,
    iter = 20,
    site_scoring_method = "mixedeffects"
  )

  ctas_avg_feat_value <- ctasval(
    df = df_filt,
    fun_anomaly = c(anomaly_average),
    feats = c("average"),
    parallel = FALSE,
    anomaly_degree = 10,
    iter = 20,
    site_scoring_method = "avg_feat_value"
  )


  na_rate_avg_feat_value <- ctas_avg_feat_value$anomaly %>%
    distinct(iter, site, anomaly_degree, feats, is_signal) %>%
    summarise(ratio = sum(is.na(is_signal)) / nrow(.)) %>%
    pull(ratio)

  na_rate_mixedeffects <- ctas_mixedeffects$anomaly %>%
    distinct(site, anomaly_degree, feats, is_signal) %>%
    summarise(ratio = sum(is.na(is_signal)) / nrow(.)) %>%
    pull(ratio)

  na_rate_ks <- ctas_ks$anomaly %>%
    distinct(site, anomaly_degree, feats, is_signal)%>%
    summarise(ratio = sum(is.na(is_signal)) / nrow(.)) %>%
    pull(ratio)

  tolerance <- 0.25

  expect_true(all(c(na_rate_mixedeffects, na_rate_ks, na_rate_avg_feat_value) > 0))

  expect_true(between(na_rate_mixedeffects, na_rate_avg_feat_value - tolerance, na_rate_avg_feat_value + tolerance))
  expect_true(between(na_rate_ks, na_rate_avg_feat_value - tolerance, na_rate_avg_feat_value + tolerance))
  expect_true(between(na_rate_mixedeffects, na_rate_ks - tolerance, na_rate_ks + tolerance))

})

test_that("ctas timeseries and sites must be identical across scoring methds", {

  df_prep <- prep_sdtm_lb(lb, dm, scramble = FALSE)

  df_filt <- df_prep %>%
    filter(parameter_id == "Alkaline Phosphatase")

  df_ana <- get_anomaly_data(
    df = df_filt,
    n_sites = 3,
    fun_anomaly = anomaly_average,
    anomaly_degree = 10,
    site_prefix = "sample_site"
  )

  df <- df_ana

  parameters <- df %>%
    distinct(
      .data$parameter_id,
      .data$parameter_name,
      .data$parameter_category_1
    ) %>%
    mutate(
      parameter_category_2 = "no",
      parameter_category_3 = "no",
      time_point_count_min = NA,
      subject_count_min = NA,
      max_share_missing = NA,
      generate_change_from_baseline = NA,
      timeseries_features_to_calculate = NA,
      use_only_custom_timeseries = FALSE # should have datatype check
    )

  subjects <- df %>%
    distinct(.data$subject_id, .data$site) %>%
    mutate(
      country = "no",
      region = "no"
    )

  data <- df %>%
    select(c(
      "subject_id",
      "parameter_id",
      "timepoint_1_name",
      "timepoint_2_name",
      "timepoint_rank",
      "result",
      "baseline"
    ))

  ls_ctas_avg <- process_a_study(
    data = data,
    subjects = subjects,
    parameters = parameters,
    custom_timeseries = ctas::ctas_data$custom_timeseries,
    custom_reference_groups = ctas::ctas_data$custom_reference_groups,
    default_timeseries_features_to_calculate = "average",
    default_minimum_timepoints_per_series = 3,
    default_minimum_subjects_per_series = 3,
    default_max_share_missing_timepoints_per_series = 0.5,
    default_generate_change_from_baseline = FALSE,
    autogenerate_timeseries = TRUE,
    site_scoring_method = "avg_feat_value"
  )

  ls_ctas_mix <- process_a_study(
    data = data,
    subjects = subjects,
    parameters = parameters,
    custom_timeseries = ctas::ctas_data$custom_timeseries,
    custom_reference_groups = ctas::ctas_data$custom_reference_groups,
    default_timeseries_features_to_calculate = "average",
    default_minimum_timepoints_per_series = 3,
    default_minimum_subjects_per_series = 3,
    default_max_share_missing_timepoints_per_series = 0.5,
    default_generate_change_from_baseline = FALSE,
    autogenerate_timeseries = TRUE,
    site_scoring_method = "mixedeffects"
  )

  ls_ctas_ks <- process_a_study(
    data = data,
    subjects = subjects,
    parameters = parameters,
    custom_timeseries = ctas::ctas_data$custom_timeseries,
    custom_reference_groups = ctas::ctas_data$custom_reference_groups,
    default_timeseries_features_to_calculate = "average",
    default_minimum_timepoints_per_series = 3,
    default_minimum_subjects_per_series = 3,
    default_max_share_missing_timepoints_per_series = 0.5,
    default_generate_change_from_baseline = FALSE,
    autogenerate_timeseries = TRUE,
    site_scoring_method = "ks"
  )

  expect_equal(ls_ctas_avg$time_series$site, ls_ctas_mix$time_series$site)
  expect_equal(ls_ctas_avg$time_series$site, ls_ctas_ks$time_series$site)
  expect_equal(ls_ctas_mix$time_series$site, ls_ctas_ks$time_series$site)

  sites_avg <- sort(unique(ls_ctas_avg$site_scores$entity))
  sites_mix <- sort(unique(ls_ctas_mix$site_scores$entity))
  sites_ks <- sort(unique(ls_ctas_ks$site_scores$site))

  expect_equal(sites_avg, sites_mix)
  expect_equal(sites_avg, sites_ks)
  expect_equal(sites_mix, sites_ks)

})
