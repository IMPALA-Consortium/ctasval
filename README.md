
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



set.seed(1)

df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)

df_filt <- df_prep %>%
  filter(parameter_id %in% c("Alkaline Phosphatase", "Alanine Aminotransferase")) %>%
  filter(! grepl("UNSCH", VISIT))

plan(multisession, workers = 6)

ctas <- ctasval(
  df = df_filt,
  fun_anomaly = c(anomaly_average, anomaly_sd, anomaly_autocorr, anomaly_lof),
  feats = c("average", "sd", "autocorr", "lof"),
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
#> ! There were 7 warnings in `mutate()`.
#> The first warning was:
#> ℹ In argument: `ts_features = list(...)`.
#> ℹ In row 2.
#> Caused by warning in `cor()`:
#> ! the standard deviation is zero
#> ℹ Run `dplyr::last_dplyr_warnings()` to see the 6 remaining warnings.
#> ℹ Run `dplyr::last_dplyr_warnings()` to see the 799 remaining warnings.

plan(sequential)

ctas
#> $result
#> # A tibble: 64 × 9
#>    anomaly_degree feats    parameter_id       TN    FN    FP    TP     tpr   fpr
#>             <dbl> <chr>    <chr>           <int> <int> <int> <int>   <dbl> <dbl>
#>  1            0   average  Alanine Aminot…  1600   300     0     0 0           0
#>  2            0   average  Alkaline Phosp…  1600   300     0     0 0           0
#>  3            0   sd       Alanine Aminot…  1600   300     0     0 0           0
#>  4            0   sd       Alkaline Phosp…  1600   300     0     0 0           0
#>  5            0   autocorr Alanine Aminot…  1600   300     0     0 0           0
#>  6            0   autocorr Alkaline Phosp…  1600   300     0     0 0           0
#>  7            0   lof      Alanine Aminot…  1600   298     0     2 0.00667     0
#>  8            0   lof      Alkaline Phosp…  1600   300     0     0 0           0
#>  9            0.1 average  Alanine Aminot…  1600   298     0     2 0.00667     0
#> 10            0.1 average  Alkaline Phosp…  1600   294     0     6 0.02        0
#> # ℹ 54 more rows
#> 
#> $anomaly
#> # A tibble: 2,142,209 × 38
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
#> # ℹ 2,142,199 more rows
#> # ℹ 30 more variables: LBTESTCD <chr>, LBTEST <chr>, LBCAT <chr>,
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
  knitr::kable(digits = 3)
```

| anomaly_degree | feats    | parameter_id             |   TN |  FN |  FP |  TP |   tpr |   fpr |
|---------------:|:---------|:-------------------------|-----:|----:|----:|----:|------:|------:|
|           0.00 | average  | Alanine Aminotransferase | 1600 | 300 |   0 |   0 | 0.000 | 0.000 |
|           0.00 | average  | Alkaline Phosphatase     | 1600 | 300 |   0 |   0 | 0.000 | 0.000 |
|           0.00 | sd       | Alanine Aminotransferase | 1600 | 300 |   0 |   0 | 0.000 | 0.000 |
|           0.00 | sd       | Alkaline Phosphatase     | 1600 | 300 |   0 |   0 | 0.000 | 0.000 |
|           0.00 | autocorr | Alanine Aminotransferase | 1600 | 300 |   0 |   0 | 0.000 | 0.000 |
|           0.00 | autocorr | Alkaline Phosphatase     | 1600 | 300 |   0 |   0 | 0.000 | 0.000 |
|           0.00 | lof      | Alanine Aminotransferase | 1600 | 298 |   0 |   2 | 0.007 | 0.000 |
|           0.00 | lof      | Alkaline Phosphatase     | 1600 | 300 |   0 |   0 | 0.000 | 0.000 |
|           0.10 | average  | Alanine Aminotransferase | 1600 | 298 |   0 |   2 | 0.007 | 0.000 |
|           0.10 | average  | Alkaline Phosphatase     | 1600 | 294 |   0 |   6 | 0.020 | 0.000 |
|           0.10 | sd       | Alanine Aminotransferase | 1600 | 295 |   0 |   5 | 0.017 | 0.000 |
|           0.10 | sd       | Alkaline Phosphatase     | 1561 | 134 |  39 | 166 | 0.553 | 0.024 |
|           0.10 | autocorr | Alanine Aminotransferase | 1588 | 298 |  12 |   2 | 0.007 | 0.007 |
|           0.10 | autocorr | Alkaline Phosphatase     | 1600 | 263 |   0 |  37 | 0.123 | 0.000 |
|           0.10 | lof      | Alanine Aminotransferase | 1596 | 296 |   4 |   4 | 0.013 | 0.002 |
|           0.10 | lof      | Alkaline Phosphatase     | 1599 | 290 |   1 |  10 | 0.033 | 0.001 |
|           0.25 | average  | Alanine Aminotransferase | 1600 | 247 |   0 |  53 | 0.177 | 0.000 |
|           0.25 | average  | Alkaline Phosphatase     | 1600 | 211 |   0 |  89 | 0.297 | 0.000 |
|           0.25 | sd       | Alanine Aminotransferase | 1527 | 111 |  73 | 189 | 0.630 | 0.046 |
|           0.25 | sd       | Alkaline Phosphatase     | 1395 |  27 | 205 | 273 | 0.910 | 0.128 |
|           0.25 | autocorr | Alanine Aminotransferase | 1579 | 218 |  21 |  82 | 0.273 | 0.013 |
|           0.25 | autocorr | Alkaline Phosphatase     | 1600 |  93 |   0 | 207 | 0.690 | 0.000 |
|           0.25 | lof      | Alanine Aminotransferase | 1566 | 194 |  34 | 106 | 0.353 | 0.021 |
|           0.25 | lof      | Alkaline Phosphatase     | 1562 | 187 |  38 | 113 | 0.377 | 0.024 |
|           0.50 | average  | Alanine Aminotransferase | 1552 | 114 |  48 | 186 | 0.620 | 0.030 |
|           0.50 | average  | Alkaline Phosphatase     | 1588 |  71 |  12 | 229 | 0.763 | 0.007 |
|           0.50 | sd       | Alanine Aminotransferase | 1417 |  31 | 183 | 269 | 0.897 | 0.114 |
|           0.50 | sd       | Alkaline Phosphatase     | 1367 |   8 | 233 | 292 | 0.973 | 0.146 |
|           0.50 | autocorr | Alanine Aminotransferase | 1434 |  94 | 166 | 206 | 0.687 | 0.104 |
|           0.50 | autocorr | Alkaline Phosphatase     | 1595 |  37 |   5 | 263 | 0.877 | 0.003 |
|           0.50 | lof      | Alanine Aminotransferase | 1509 | 110 |  91 | 190 | 0.633 | 0.057 |
|           0.50 | lof      | Alkaline Phosphatase     | 1491 |  84 | 109 | 216 | 0.720 | 0.068 |
|           1.00 | average  | Alanine Aminotransferase | 1439 |  37 | 161 | 263 | 0.877 | 0.101 |
|           1.00 | average  | Alkaline Phosphatase     | 1516 |  28 |  84 | 272 | 0.907 | 0.052 |
|           1.00 | sd       | Alanine Aminotransferase | 1411 |   9 | 189 | 291 | 0.970 | 0.118 |
|           1.00 | sd       | Alkaline Phosphatase     | 1363 |   8 | 237 | 292 | 0.973 | 0.148 |
|           1.00 | autocorr | Alanine Aminotransferase | 1381 |  53 | 219 | 247 | 0.823 | 0.137 |
|           1.00 | autocorr | Alkaline Phosphatase     | 1597 |  27 |   3 | 273 | 0.910 | 0.002 |
|           1.00 | lof      | Alanine Aminotransferase | 1467 |  67 | 133 | 233 | 0.777 | 0.083 |
|           1.00 | lof      | Alkaline Phosphatase     | 1462 |  53 | 138 | 247 | 0.823 | 0.086 |
|           2.00 | average  | Alanine Aminotransferase | 1428 |  14 | 172 | 286 | 0.953 | 0.108 |
|           2.00 | average  | Alkaline Phosphatase     | 1479 |   4 | 121 | 296 | 0.987 | 0.076 |
|           2.00 | sd       | Alanine Aminotransferase | 1410 |   9 | 190 | 291 | 0.970 | 0.119 |
|           2.00 | sd       | Alkaline Phosphatase     | 1372 |   4 | 228 | 296 | 0.987 | 0.142 |
|           2.00 | autocorr | Alanine Aminotransferase | 1365 |  35 | 235 | 265 | 0.883 | 0.147 |
|           2.00 | autocorr | Alkaline Phosphatase     | 1600 |  44 |   0 | 256 | 0.853 | 0.000 |
|           2.00 | lof      | Alanine Aminotransferase | 1452 |  65 | 148 | 235 | 0.783 | 0.092 |
|           2.00 | lof      | Alkaline Phosphatase     | 1447 |  52 | 153 | 248 | 0.827 | 0.096 |
|           5.00 | average  | Alanine Aminotransferase | 1427 |   5 | 173 | 295 | 0.983 | 0.108 |
|           5.00 | average  | Alkaline Phosphatase     | 1460 |   8 | 140 | 292 | 0.973 | 0.088 |
|           5.00 | sd       | Alanine Aminotransferase | 1405 |  10 | 195 | 290 | 0.967 | 0.122 |
|           5.00 | sd       | Alkaline Phosphatase     | 1387 |   9 | 213 | 291 | 0.970 | 0.133 |
|           5.00 | autocorr | Alanine Aminotransferase | 1375 |  41 | 225 | 259 | 0.863 | 0.141 |
|           5.00 | autocorr | Alkaline Phosphatase     | 1599 |  40 |   1 | 260 | 0.867 | 0.001 |
|           5.00 | lof      | Alanine Aminotransferase | 1436 |  46 | 164 | 254 | 0.847 | 0.102 |
|           5.00 | lof      | Alkaline Phosphatase     | 1420 |  35 | 180 | 265 | 0.883 | 0.112 |
|         100.00 | average  | Alanine Aminotransferase | 1407 |   4 | 193 | 296 | 0.987 | 0.121 |
|         100.00 | average  | Alkaline Phosphatase     | 1443 |   4 | 157 | 296 | 0.987 | 0.098 |
|         100.00 | sd       | Alanine Aminotransferase | 1418 |   8 | 182 | 292 | 0.973 | 0.114 |
|         100.00 | sd       | Alkaline Phosphatase     | 1359 |   5 | 241 | 295 | 0.983 | 0.151 |
|         100.00 | autocorr | Alanine Aminotransferase | 1365 |  29 | 235 | 271 | 0.903 | 0.147 |
|         100.00 | autocorr | Alkaline Phosphatase     | 1600 |  42 |   0 | 258 | 0.860 | 0.000 |
|         100.00 | lof      | Alanine Aminotransferase | 1395 |  52 | 205 | 248 | 0.827 | 0.128 |
|         100.00 | lof      | Alkaline Phosphatase     | 1401 |  37 | 199 | 263 | 0.877 | 0.124 |

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

| iter | anomaly_degree | feats    | parameter_id             | site         | subject_id               | timepoint_rank |        result |    score |
|-----:|---------------:|:---------|:-------------------------|:-------------|:-------------------------|---------------:|--------------:|---------:|
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1097 |              1 |  1520.9164756 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1097 |              4 |  1650.2196838 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1097 |              5 |   269.3840144 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1097 |              7 | -1339.4923539 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1097 |              8 | -1696.9740939 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1097 |              9 |  -485.7165611 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1097 |             10 |  1189.9780735 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1097 |             11 |  1780.4032860 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1097 |             12 |   755.0472773 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1097 |             13 |  -957.9465990 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              1 | -1769.4178592 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              4 |  -940.6259874 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              5 |   765.4415917 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              7 |  1786.6372368 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              8 |  1183.9977767 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1279 |              1 |  -503.8964759 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1295 |              1 | -1707.3972831 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1295 |              4 | -1324.0921577 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1295 |              5 |   289.0457035 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1295 |              7 |  1646.7435811 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1295 |              8 |  1509.3045399 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1295 |              9 |    -0.8299946 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1295 |             10 | -1494.4105052 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1295 |             11 | -1609.5683767 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1135 |              1 |  -220.7025517 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1135 |              4 |  1380.7865077 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1135 |              5 |  1725.4165413 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1135 |              7 |   502.4974949 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1135 |              8 | -1168.8663140 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1135 |              9 | -1753.0307073 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1135 |             10 |  -708.5952174 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1135 |             11 |   999.1909830 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1135 |             12 |  1807.2777416 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1135 |             13 |   961.2301917 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1280 |              1 |  -753.7770327 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1280 |              4 | -1758.7323848 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1280 |              5 | -1138.9263623 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1280 |              7 |   542.0360500 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1280 |              8 |  1738.6857623 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1280 |              9 |  1350.5867339 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1280 |             10 |  -267.6863920 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1280 |             11 | -1618.1395575 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1280 |             12 | -1473.5753730 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1280 |             13 |    46.6587490 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-707-1037 |              1 |  1526.7859633 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-707-1037 |              4 |  1619.7901809 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1286 |              1 |   234.0025440 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1286 |              4 | -1361.9738127 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1286 |              7 | -1691.7249824 | 6.547829 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1286 |              8 |  -457.2404697 | 6.547829 |
