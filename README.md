
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ctasval

<!-- badges: start -->

[![R-CMD-check](https://github.com/IMPALA-Consortium/ctasval/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/IMPALA-Consortium/ctasval/actions/workflows/R-CMD-check.yaml)

<!-- badges: end -->

The goal of ctasval is to provide structured code to validate {ctas}
performance on study data.

## Installation

You can install the development version of ctasval from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("IMPALA-Consortium/ctas")
devtools::install_github("IMPALA-Consortium/ctasval")
```

## ctasval

`ctasval` adds three anomalous sites to the data set for each iteration
and tries to detect them using {ctas}. It samples from the study site
pool to first determine the number of patients and then samples a
sufficient number of patients from the study patient pool.

``` r

library(pharmaversesdtm)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(future)
library(ctasval)
library(ggplot2)
library(tidyr)



set.seed(1)

df_prep <- prep_sdtm(
  lb = pharmaversesdtm::lb,
  vs = pharmaversesdtm::vs,
  dm = pharmaversesdtm::dm,
  scramble = TRUE
)

df_filt <- df_prep %>%
  filter(parameter_id %in% c("Pulse Rate", "Alanine Aminotransferase")) %>%
  filter(! grepl("UNSCH", timepoint_1_name) & !timepoint_1_name %in% c("AMBUL ECG REMOVAL", "RETRIEVAL"))

plan(multisession, workers = 6)

ctas <- ctasval(
  df = df_filt,
  fun_anomaly = c(
    anomaly_average,
    anomaly_sd,
    anomaly_autocorr,
    anomaly_lof,
    anomaly_range,
    anomaly_unique_value_count_relative
  ),
  feats = c("average", "sd", "autocorr", "lof", "range", "unique_value_count_relative"),
  parallel = TRUE,
  iter = 100,
  n_sites = 3,
  anomaly_degree = c(0, 0.1, 0.25, 0.5, 1, 2, 5, 100),
  thresh = 1
)
#> Warning: There were 800 warnings in `mutate()`.
#> The first warning was:
#> ℹ In argument: `ctas = simaerep::purrr_bar(...)`.
#> Caused by warning:
#> ! There were 11 warnings in `mutate()`.
#> The first warning was:
#> ℹ In argument: `ts_features = list(...)`.
#> ℹ In row 2.
#> Caused by warning in `cor()`:
#> ! the standard deviation is zero
#> ℹ Run `dplyr::last_dplyr_warnings()` to see the 10 remaining warnings.
#> ℹ Run `dplyr::last_dplyr_warnings()` to see the 799 remaining warnings.

plan(sequential)

ctas
#> $result
#> # A tibble: 96 × 9
#>    anomaly_degree feats    parameter_id       TN    FN    FP    TP     tpr   fpr
#>             <dbl> <chr>    <chr>           <int> <int> <int> <int>   <dbl> <dbl>
#>  1              0 average  Alanine Aminot…  1600   298     0     2 0.00667     0
#>  2              0 average  Pulse Rate       1600   300     0     0 0           0
#>  3              0 sd       Alanine Aminot…  1600   299     0     1 0.00333     0
#>  4              0 sd       Pulse Rate       1600   300     0     0 0           0
#>  5              0 autocorr Alanine Aminot…  1600   299     0     1 0.00333     0
#>  6              0 autocorr Pulse Rate       1600   299     0     1 0.00333     0
#>  7              0 lof      Alanine Aminot…  1600   298     0     2 0.00667     0
#>  8              0 lof      Pulse Rate       1600   300     0     0 0           0
#>  9              0 range    Alanine Aminot…  1600   300     0     0 0           0
#> 10              0 range    Pulse Rate       1600   299     0     1 0.00333     0
#> # ℹ 86 more rows
#> 
#> $anomaly
#> # A tibble: 8,332,852 × 18
#>     iter anomaly_degree fun_anomaly feats   subject_id    site  timepoint_1_name
#>    <int>          <dbl> <list>      <chr>   <chr>         <chr> <chr>           
#>  1     1              0 <fn>        average sample_site1… samp… SCREENING 1     
#>  2     1              0 <fn>        average sample_site1… samp… WEEK 2          
#>  3     1              0 <fn>        average sample_site1… samp… WEEK 4          
#>  4     1              0 <fn>        average sample_site1… samp… WEEK 6          
#>  5     1              0 <fn>        average sample_site1… samp… WEEK 8          
#>  6     1              0 <fn>        average sample_site1… samp… WEEK 12         
#>  7     1              0 <fn>        average sample_site1… samp… WEEK 16         
#>  8     1              0 <fn>        average sample_site1… samp… WEEK 20         
#>  9     1              0 <fn>        average sample_site1… samp… WEEK 24         
#> 10     1              0 <fn>        average sample_site1… samp… WEEK 26         
#> # ℹ 8,332,842 more rows
#> # ℹ 11 more variables: timepoint_2_name <chr>, timepoint_rank <dbl>,
#> #   parameter_id <chr>, parameter_name <chr>, parameter_category_1 <chr>,
#> #   baseline <lgl>, result <dbl>, method <chr>, score <dbl>, is_signal <dbl>,
#> #   add_outlier <lgl>
#> 
#> attr(,"class")
#> [1] "ctasval_aggregated"
```

### Performance Metrics

``` r
ctas$result %>%
  tidyr::pivot_longer(c(tpr, fpr), values_to = "metric", names_to = "metric_type") %>%
  ggplot(aes(log(anomaly_degree),  metric)) +
  geom_line(aes(linetype = metric_type)) +
  geom_point() +
  facet_grid(parameter_id ~ feats) +
  theme(legend.position = "bottom")
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

### Anamolous Sites

Anomalous Sites and their scores can be reviewed.

``` r
ctas$anomaly %>%
  select(
    iter,
    anomaly_degree,
    feats,
    parameter_id,
    site,
    subject_id,
    timepoint_rank,
    result,
    score
  ) %>%
  arrange(iter, desc(anomaly_degree), parameter_id, feats, site, subject_id, timepoint_rank) %>%
  head(50) %>%
  knitr::kable()
```

| iter | anomaly_degree | feats    | parameter_id             | site         | subject_id               | timepoint_rank |       result |    score |
|-----:|---------------:|:---------|:-------------------------|:-------------|:-------------------------|---------------:|-------------:|---------:|
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              1 |  1174.880193 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              4 |  1272.855514 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              5 |   204.525485 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              7 | -1040.569773 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              8 | -1317.614817 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              9 |  -378.137526 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |             10 |   921.272222 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |             11 |  1381.781886 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |             12 |   581.001007 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |             13 |  -739.755565 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1341 |              1 | -1327.512747 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1341 |              4 |  -728.435898 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1341 |              5 |   609.152487 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              1 |  1415.512560 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              4 |   939.990915 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              5 |  -360.897622 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              7 | -1308.041525 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              8 | -1015.512593 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              9 |   228.658818 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |             10 |  1291.909670 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |             11 |  1178.208404 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |             12 |     6.736278 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1025 |              1 | -1153.460639 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1025 |              4 | -1231.702652 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1025 |              5 |  -161.376833 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              1 |  1063.544801 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              4 |  1332.084017 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              5 |   381.347099 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              7 |  -912.482211 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              8 | -1361.943816 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              9 |  -546.804790 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |             10 |   773.016178 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |             11 |  1395.404196 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |             12 |   740.057985 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |             13 |  -587.258357 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1199 |              1 | -1362.135701 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1199 |              4 |  -876.639019 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1007 |              1 |   428.626465 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1007 |              4 |  1353.363871 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1007 |              5 |  1053.373892 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1045 |              1 |  -204.775882 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1045 |              4 | -1259.864724 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1045 |              5 | -1137.445795 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1045 |              7 |    31.526483 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1045 |              8 |  1187.949225 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1045 |              9 |  1258.451487 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1137 |              1 |   184.213813 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1137 |              4 | -1047.437050 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1137 |              5 | -1310.449399 | 4.535962 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1137 |              7 |  -349.527264 | 4.535962 |
