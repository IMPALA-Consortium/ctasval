# CTAS Validation

This function performs CTAS validation by generating anomalies,
calculating scores, and summarizing performance metrics.

## Usage

``` r
ctasval(
  df,
  fun_anomaly,
  feats,
  anomaly_degree = c(0, 0.5, 1, 5, 10, 50),
  thresh = 1,
  iter = 100,
  n_sites = 3,
  parallel = FALSE,
  progress = TRUE,
  default_minimum_timepoints_per_series = 3,
  default_minimum_subjects_per_series = 3,
  default_max_share_missing_timepoints_per_series = 0.5,
  default_generate_change_from_baseline = FALSE,
  autogenerate_timeseries = TRUE,
  site_scoring_method = "ks",
  padjust_method = "BY"
)
```

## Arguments

- df:

  Data frame containing the study data.

- fun_anomaly:

  List of functions to apply to generate anomalies.

- feats:

  List of features to calculate for the timeseries.

- anomaly_degree:

  Vector of anomaly degrees to add. Default is c(0, 0.5, 1, 5, 10, 50).

- thresh:

  Threshold for classification. Default is 1.0.

- iter:

  Number of iterations to run. Default is 100.

- n_sites:

  Number of sites to generate. Default is 3.

- parallel:

  Logical indicating whether to run in parallel. Default is FALSE.

- progress:

  Logical indicating whether to show progress. Default is TRUE.

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

  site_scoring_method How to score sites ("ks" = Kolmogorov-Smirnov,
  "mixedeffects" = mixed effects modelling, "avg_feat_value" = Average
  site feature value. Default:ks

- padjust_method:

  parameter passed to
  [`p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) method
  parameter, Default: "BY"

## Value

A list containing the performance metrics and anomaly data.

## Examples

``` r
df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)

df_filt <- df_prep %>%
  filter(parameter_id == "Alkaline Phosphatase")

ctas <- ctasval(
  df = df_filt,
  fun_anomaly = c(anomaly_average, anomaly_sd),
  feats = c("average", "sd"),
  parallel = FALSE,
  iter = 1
)

ctas
#> $result
#> # A tibble: 12 × 9
#>    anomaly_degree feats   parameter_id          TN    FN    FP    TP   tpr   fpr
#>             <dbl> <chr>   <chr>              <int> <int> <int> <int> <dbl> <dbl>
#>  1            0   average Alkaline Phosphat…    17     3     0     0 0         0
#>  2            0   sd      Alkaline Phosphat…    17     3     0     0 0         0
#>  3            0.5 average Alkaline Phosphat…    17     3     0     0 0         0
#>  4            0.5 sd      Alkaline Phosphat…    17     3     0     0 0         0
#>  5            1   average Alkaline Phosphat…    17     3     0     0 0         0
#>  6            1   sd      Alkaline Phosphat…    17     3     0     0 0         0
#>  7            5   average Alkaline Phosphat…    17     3     0     0 0         0
#>  8            5   sd      Alkaline Phosphat…    17     3     0     0 0         0
#>  9           10   average Alkaline Phosphat…    17     2     0     1 0.333     0
#> 10           10   sd      Alkaline Phosphat…    17     3     0     0 0         0
#> 11           50   average Alkaline Phosphat…    17     3     0     0 0         0
#> 12           50   sd      Alkaline Phosphat…    17     2     0     1 0.333     0
#> 
#> $anomaly
#> # A tibble: 3,358 × 39
#>     iter anomaly_degree fun_anomaly feats   STUDYID      DOMAIN subject_id LBSEQ
#>    <int>          <dbl> <list>      <chr>   <chr>        <chr>  <chr>      <dbl>
#>  1     1              0 <fn>        average CDISCPILOT01 LB     sample_si…     2
#>  2     1              0 <fn>        average CDISCPILOT01 LB     sample_si…    39
#>  3     1              0 <fn>        average CDISCPILOT01 LB     sample_si…    74
#>  4     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   104
#>  5     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   134
#>  6     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   164
#>  7     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   199
#>  8     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   229
#>  9     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   259
#> 10     1              0 <fn>        average CDISCPILOT01 LB     sample_si…     2
#> # ℹ 3,348 more rows
#> # ℹ 31 more variables: LBTESTCD <chr>, LBTEST <chr>, LBCAT <chr>,
#> #   LBORRES <chr>, LBORRESU <chr>, LBORNRLO <chr>, LBORNRHI <chr>,
#> #   LBSTRESC <chr>, LBSTRESN <dbl>, LBSTRESU <chr>, LBSTNRLO <dbl>,
#> #   LBSTNRHI <dbl>, LBNRIND <chr>, LBBLFL <chr>, VISITNUM <dbl>, VISIT <chr>,
#> #   VISITDY <dbl>, LBDTC <chr>, LBDY <dbl>, timepoint_rank <dbl>,
#> #   timepoint_1_name <chr>, result <dbl>, parameter_id <chr>, …
#> 
#> attr(,"class")
#> [1] "ctasval_aggregated"
```
