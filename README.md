
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
library(stringr)


set.seed(1)

df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)

df_filt <- df_prep %>%
  filter(parameter_id %in% c("Alkaline Phosphatase", "Alanine Aminotransferase")) %>%
  filter(! grepl("UNSCH", VISIT))

plan(multisession, workers = 6)

ctas <- ctasval(
  df = df_filt,
  fun_anomaly = c(anomaly_average, anomaly_sd, anomaly_autocorr),
  feats = c("average", "sd", "autocorr"),
  parallel = TRUE,
  iter = 100,
  n_sites = 3,
  anomaly_degree = c(0, 0.1, 0.25, 0.5, 1, 2, 5),
  thresh = 1
)
#> Warning: There were 700 warnings in `mutate()`.
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
#> ℹ Run `dplyr::last_dplyr_warnings()` to see the 699 remaining warnings.

plan(sequential)

ctas
#> $result
#> # A tibble: 42 × 9
#>    anomaly_degree feats    parameter_id     TN    FN    FP    TP     tpr     fpr
#>             <dbl> <chr>    <chr>         <int> <int> <int> <int>   <dbl>   <dbl>
#>  1            0   average  Alanine Amin…  1600   300     0     0 0       0      
#>  2            0   average  Alkaline Pho…  1600   300     0     0 0       0      
#>  3            0   sd       Alanine Amin…  1600   299     0     1 0.00333 0      
#>  4            0   sd       Alkaline Pho…  1600   299     0     1 0.00333 0      
#>  5            0   autocorr Alanine Amin…  1599   300     1     0 0       6.25e-4
#>  6            0   autocorr Alkaline Pho…  1600   300     0     0 0       0      
#>  7            0.1 average  Alanine Amin…  1600   299     0     1 0.00333 0      
#>  8            0.1 average  Alkaline Pho…  1600   298     0     2 0.00667 0      
#>  9            0.1 sd       Alanine Amin…  1600   289     0    11 0.0367  0      
#> 10            0.1 sd       Alkaline Pho…  1543   121    57   179 0.597   3.56e-2
#> # ℹ 32 more rows
#> 
#> $anomaly
#> # A tibble: 1,408,058 × 38
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
#> # ℹ 1,408,048 more rows
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
|           0.00 | sd       | Alanine Aminotransferase | 1600 | 299 |   0 |   1 | 0.003 | 0.000 |
|           0.00 | sd       | Alkaline Phosphatase     | 1600 | 299 |   0 |   1 | 0.003 | 0.000 |
|           0.00 | autocorr | Alanine Aminotransferase | 1599 | 300 |   1 |   0 | 0.000 | 0.001 |
|           0.00 | autocorr | Alkaline Phosphatase     | 1600 | 300 |   0 |   0 | 0.000 | 0.000 |
|           0.10 | average  | Alanine Aminotransferase | 1600 | 299 |   0 |   1 | 0.003 | 0.000 |
|           0.10 | average  | Alkaline Phosphatase     | 1600 | 298 |   0 |   2 | 0.007 | 0.000 |
|           0.10 | sd       | Alanine Aminotransferase | 1600 | 289 |   0 |  11 | 0.037 | 0.000 |
|           0.10 | sd       | Alkaline Phosphatase     | 1543 | 121 |  57 | 179 | 0.597 | 0.036 |
|           0.10 | autocorr | Alanine Aminotransferase | 1595 | 298 |   5 |   2 | 0.007 | 0.003 |
|           0.10 | autocorr | Alkaline Phosphatase     | 1600 | 264 |   0 |  36 | 0.120 | 0.000 |
|           0.25 | average  | Alanine Aminotransferase | 1600 | 241 |   0 |  59 | 0.197 | 0.000 |
|           0.25 | average  | Alkaline Phosphatase     | 1599 | 200 |   1 | 100 | 0.333 | 0.001 |
|           0.25 | sd       | Alanine Aminotransferase | 1526 | 120 |  74 | 180 | 0.600 | 0.046 |
|           0.25 | sd       | Alkaline Phosphatase     | 1382 |  25 | 218 | 275 | 0.917 | 0.136 |
|           0.25 | autocorr | Alanine Aminotransferase | 1579 | 209 |  21 |  91 | 0.303 | 0.013 |
|           0.25 | autocorr | Alkaline Phosphatase     | 1600 | 106 |   0 | 194 | 0.647 | 0.000 |
|           0.50 | average  | Alanine Aminotransferase | 1561 | 111 |  39 | 189 | 0.630 | 0.024 |
|           0.50 | average  | Alkaline Phosphatase     | 1583 |  69 |  17 | 231 | 0.770 | 0.011 |
|           0.50 | sd       | Alanine Aminotransferase | 1429 |  28 | 171 | 272 | 0.907 | 0.107 |
|           0.50 | sd       | Alkaline Phosphatase     | 1376 |   7 | 224 | 293 | 0.977 | 0.140 |
|           0.50 | autocorr | Alanine Aminotransferase | 1422 |  83 | 178 | 217 | 0.723 | 0.111 |
|           0.50 | autocorr | Alkaline Phosphatase     | 1600 |  57 |   0 | 243 | 0.810 | 0.000 |
|           1.00 | average  | Alanine Aminotransferase | 1460 |  37 | 140 | 263 | 0.877 | 0.088 |
|           1.00 | average  | Alkaline Phosphatase     | 1515 |  29 |  85 | 271 | 0.903 | 0.053 |
|           1.00 | sd       | Alanine Aminotransferase | 1411 |  12 | 189 | 288 | 0.960 | 0.118 |
|           1.00 | sd       | Alkaline Phosphatase     | 1373 |   3 | 227 | 297 | 0.990 | 0.142 |
|           1.00 | autocorr | Alanine Aminotransferase | 1386 |  56 | 214 | 244 | 0.813 | 0.134 |
|           1.00 | autocorr | Alkaline Phosphatase     | 1600 |  42 |   0 | 258 | 0.860 | 0.000 |
|           2.00 | average  | Alanine Aminotransferase | 1436 |   8 | 164 | 292 | 0.973 | 0.102 |
|           2.00 | average  | Alkaline Phosphatase     | 1473 |   8 | 127 | 292 | 0.973 | 0.079 |
|           2.00 | sd       | Alanine Aminotransferase | 1417 |  11 | 183 | 289 | 0.963 | 0.114 |
|           2.00 | sd       | Alkaline Phosphatase     | 1388 |  10 | 212 | 290 | 0.967 | 0.132 |
|           2.00 | autocorr | Alanine Aminotransferase | 1369 |  46 | 231 | 254 | 0.847 | 0.144 |
|           2.00 | autocorr | Alkaline Phosphatase     | 1598 |  35 |   2 | 265 | 0.883 | 0.001 |
|           5.00 | average  | Alanine Aminotransferase | 1410 |   5 | 190 | 295 | 0.983 | 0.119 |
|           5.00 | average  | Alkaline Phosphatase     | 1437 |   1 | 163 | 299 | 0.997 | 0.102 |
|           5.00 | sd       | Alanine Aminotransferase | 1389 |   1 | 211 | 299 | 0.997 | 0.132 |
|           5.00 | sd       | Alkaline Phosphatase     | 1367 |   6 | 233 | 294 | 0.980 | 0.146 |
|           5.00 | autocorr | Alanine Aminotransferase | 1358 |  29 | 242 | 271 | 0.903 | 0.151 |
|           5.00 | autocorr | Alkaline Phosphatase     | 1600 |  36 |   0 | 264 | 0.880 | 0.000 |

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

| iter | anomaly_degree | feats    | parameter_id             | site         | subject_id               | timepoint_rank |      result |    score |
|-----:|---------------:|:---------|:-------------------------|:-------------|:-------------------------|---------------:|------------:|---------:|
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1111 |              1 |  98.7633251 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1111 |              4 | 100.8701985 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1115 |              1 |  30.7059890 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1115 |              4 | -53.1400482 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1115 |              5 | -73.3384393 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1115 |              7 |  -7.1576675 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1115 |              8 |  75.1529478 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1146 |              1 | 104.0786157 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1146 |              4 |  51.1058151 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1146 |              5 | -32.9819008 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1146 |              7 | -77.0358829 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1188 |              1 | -27.3112896 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1188 |              4 |  66.8304806 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1188 |              5 | 112.1910814 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1188 |              7 |  77.5498133 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              1 |  -6.9218832 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              4 | -67.5611198 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              5 | -53.6164620 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              7 |  28.4944591 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1211 |              8 | 103.1986367 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1363 |              1 |  84.3297669 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1363 |              4 |  10.2030567 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1363 |              5 | -67.1909474 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1363 |              7 | -69.5353459 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1363 |              8 |  -0.9165234 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1363 |              9 |  81.6582958 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1363 |             10 | 100.1089944 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1363 |             11 |  38.3914807 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1363 |             12 | -51.7514479 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1363 |             13 | -77.9591709 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1444 |              1 | -17.3782424 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1444 |              4 |  67.6486744 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1444 |              5 | 107.0288289 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1444 |              7 |  70.6368933 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1086 |              1 | -18.5521823 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1086 |              4 | -60.2965593 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1086 |              5 | -40.9420915 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1086 |              7 |  39.6840680 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1086 |              8 | 102.7770184 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1086 |              9 |  79.0875783 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1086 |             10 |  10.7181281 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1279 |              1 | -71.5206350 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1379 |              1 | -65.8903068 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1379 |              4 |   6.5938241 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1379 |              5 |  83.6126004 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1379 |              7 |  87.1941053 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1379 |              8 |  17.1261242 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1379 |              9 | -59.1711642 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1379 |             10 | -79.8728032 | 12.03571 |
|    1 |              5 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-703-1379 |             11 |   0.3766170 | 12.03571 |
