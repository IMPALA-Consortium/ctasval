# Get CTAS

This function processes a study using the CTAS (Clinical Trial Anomaly
Spotter) by providing various parameters and features.

## Usage

``` r
get_ctas(
  df,
  feats,
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

- feats:

  Features to calculate for the timeseries.

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

- padjust_method:

  parameter passed to
  [`p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) method
  parameter, Default: "BY"

## Value

A data frame with the CTAS results.

## See also

[`get_anomaly_scores`](https://impala-consortium.github.io/ctasval/reference/get_anomaly_scores.md)
