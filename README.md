
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

df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)

df_filt <- df_prep %>%
  filter(parameter_id %in% c("Alkaline Phosphatase", "Alanine Aminotransferase")) %>%
  filter(! grepl("UNSCH", VISIT) & !VISIT %in% c("AMBUL ECG REMOVAL", "RETRIEVAL"))

plan(multisession, workers = 6)

ctas <- ctasval(
  df = df_filt,
  fun_anomaly = c(anomaly_average, anomaly_sd, anomaly_autocorr, anomaly_lof, anomaly_range, anomaly_unique_value_count_relative),
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
#> ! There were 13 warnings in `mutate()`.
#> The first warning was:
#> ℹ In argument: `ts_features = list(...)`.
#> ℹ In row 2.
#> Caused by warning in `cor()`:
#> ! the standard deviation is zero
#> ℹ Run `dplyr::last_dplyr_warnings()` to see the 12 remaining warnings.
#> ℹ Run `dplyr::last_dplyr_warnings()` to see the 799 remaining warnings.

plan(sequential)

ctas
#> $result
#> # A tibble: 96 × 9
#>    anomaly_degree feats    parameter_id       TN    FN    FP    TP     tpr   fpr
#>             <dbl> <chr>    <chr>           <int> <int> <int> <int>   <dbl> <dbl>
#>  1              0 average  Alanine Aminot…  1600   299     0     1 0.00333     0
#>  2              0 average  Alkaline Phosp…  1600   300     0     0 0           0
#>  3              0 sd       Alanine Aminot…  1600   300     0     0 0           0
#>  4              0 sd       Alkaline Phosp…  1600   299     0     1 0.00333     0
#>  5              0 autocorr Alanine Aminot…  1600   299     0     1 0.00333     0
#>  6              0 autocorr Alkaline Phosp…  1600   300     0     0 0           0
#>  7              0 lof      Alanine Aminot…  1600   300     0     0 0           0
#>  8              0 lof      Alkaline Phosp…  1600   299     0     1 0.00333     0
#>  9              0 range    Alanine Aminot…  1600   300     0     0 0           0
#> 10              0 range    Alkaline Phosp…  1600   300     0     0 0           0
#> # ℹ 86 more rows
#> 
#> $anomaly
#> # A tibble: 3,188,246 × 39
#>     iter anomaly_degree fun_anomaly feats   STUDYID      DOMAIN subject_id LBSEQ
#>    <int>          <dbl> <list>      <chr>   <chr>        <chr>  <chr>      <dbl>
#>  1     1              0 <fn>        average CDISCPILOT01 LB     sample_si…     2
#>  2     1              0 <fn>        average CDISCPILOT01 LB     sample_si…    39
#>  3     1              0 <fn>        average CDISCPILOT01 LB     sample_si…    74
#>  4     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   104
#>  5     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   134
#>  6     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   164
#>  7     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   199
#>  8     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   231
#>  9     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   262
#> 10     1              0 <fn>        average CDISCPILOT01 LB     sample_si…   299
#> # ℹ 3,188,236 more rows
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
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              1 |  1329.591059 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              4 |  1435.230742 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              5 |   233.794413 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              7 | -1163.719886 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              8 | -1472.524558 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              1 |  -426.189638 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              4 |  1036.256627 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              5 |  1549.925469 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              7 |   649.874541 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              8 |  -836.312880 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |              9 | -1548.484747 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |             10 |  -824.712320 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |             11 |   665.410160 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |             12 |  1552.870956 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1317 |             13 |  1026.823311 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1341 |              1 |  -390.409416 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1341 |              4 | -1482.376594 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1341 |              5 | -1142.662637 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1444 |              1 |   252.433754 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1444 |              4 |  1439.912228 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1444 |              5 |  1320.091157 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1444 |              7 |     9.214086 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1096 |              1 | -1305.988280 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1096 |              5 | -1400.438299 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              1 |  -163.137851 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              4 |  1226.684787 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              5 |  1527.555509 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              7 |   445.935765 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              8 | -1008.609775 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |              9 | -1517.859254 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |             10 |  -602.288633 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |             11 |   877.847056 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1258 |             12 |  1576.362722 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1009 |              1 |   848.046284 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1009 |              4 |  -627.894508 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1025 |              1 | -1525.695564 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1025 |              4 |  -979.310643 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1025 |              5 |   483.594061 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              1 |  1508.111314 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              4 |  1167.513747 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              5 |  -241.054807 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              7 | -1420.482311 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              8 | -1288.489162 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |              9 |    40.570748 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |             10 |  1334.282240 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |             11 |  1414.535351 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |             12 |   199.465139 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |             13 | -1190.556635 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1199 |              1 | -1473.469757 | 5.351146 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1199 |              4 |  -393.648835 | 5.351146 |
