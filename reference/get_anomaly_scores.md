# Get Anomaly Scores

This function calculates the scores for anomalies in the data frame.

## Usage

``` r
get_anomaly_scores(
  df,
  n_sites,
  fun_anomaly,
  anomaly_degree,
  feats,
  thresh = NULL,
  default_minimum_timepoints_per_series = 3,
  default_minimum_subjects_per_series = 3,
  default_max_share_missing_timepoints_per_series = 0.5,
  default_generate_change_from_baseline = FALSE,
  autogenerate_timeseries = TRUE,
  site_scoring_method,
  padjust_method = "BY"
)
```

## Arguments

- df:

  Data frame containing the study data.

- n_sites:

  Number of sites to generate.

- fun_anomaly:

  Function to apply to generate anomalies.

- anomaly_degree:

  Degree of anomaly to add.

- feats:

  Features to calculate for the timeseries.

- thresh:

  Threshold for classification. Default is NULL.

- default_minimum_timepoints_per_series:

  Minimum timepoints per series. Default is 3.

- default_minimum_subjects_per_series:

  Minimum subjects per series. Default is 3.

- default_max_share_missing_timepoints_per_series:

  Maximum share of missing timepoints per series. Default is 0.5.

- default_generate_change_from_baseline:

  Logical indicating whether to generate change from baseline. Default
  is FALSE.

- autogenerate_timeseries:

  Logical indicating whether to auto-generate timeseries. Default is
  TRUE.

- site_scoring_method:

  How to score sites ("ks" = Kolmogorov-Smirnov, "mixedeffects" = mixed
  effects modelling, "avg_feat_value" = Average site feature value.

- padjust_method:

  parameter passed to
  [`p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) method
  parameter, Default: "BY"

## Value

A data frame with the anomaly scores.

## See also

[`ctasval`](https://impala-consortium.github.io/ctasval/reference/ctasval.md)
