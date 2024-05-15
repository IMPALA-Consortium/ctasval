
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
  filter(parameter_id %in% c("Alkaline Phosphatase", "Alanine Aminotransferase"))

plan(multisession, workers = 6)

ctas <- ctasval(
  df = df_filt,
  fun_anomaly = c(anomaly_average, anomaly_sd),
  feats = c("average", "sd"),
  parallel = TRUE,
  iter = 100,
  n_sites = 3,
  anomaly_degree = c(0, 0.5, 1, 2, 10, 50),
  thresh = 1
)

plan(sequential)

ctas
#> $result
#> # A tibble: 28 × 9
#>    anomaly_degree feats   parameter_id      TN    FN    FP    TP     tpr     fpr
#>             <dbl> <chr>   <chr>          <int> <int> <int> <int>   <dbl>   <dbl>
#>  1            0   sd      Alanine Amino…  1597   299     3     1 0.00333 1.87e-3
#>  2            0   sd      Alkaline Phos…  1567   298    33     2 0.00667 2.06e-2
#>  3            0   average Alanine Amino…  1598   297     2     3 0.01    1.25e-3
#>  4            0   average Alkaline Phos…  1563   298    37     2 0.00667 2.31e-2
#>  5            0.5 sd      Alanine Amino…  1599   295     1     5 0.0167  6.25e-4
#>  6            0.5 sd      Alkaline Phos…  1580   268    20    32 0.107   1.25e-2
#>  7            0.5 average Alanine Amino…  1600   299     0     1 0.00333 0      
#>  8            0.5 average Alkaline Phos…  1576   282    24    18 0.06    1.5 e-2
#>  9            1   sd      Alanine Amino…  1600   282     0    18 0.06    0      
#> 10            1   sd      Alkaline Phos…  1577   248    23    52 0.173   1.44e-2
#> # ℹ 18 more rows
#> 
#> $anomaly
#> # A tibble: 954,674 × 38
#>     iter anomaly_degree fun_anomaly feats STUDYID      DOMAIN subject_id   LBSEQ
#>    <int>          <dbl> <list>      <chr> <chr>        <chr>  <chr>        <dbl>
#>  1     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…     2
#>  2     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…    39
#>  3     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…    74
#>  4     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…   104
#>  5     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…   134
#>  6     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…   164
#>  7     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…   199
#>  8     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…   231
#>  9     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…   262
#> 10     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…   299
#> # ℹ 954,664 more rows
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

| anomaly_degree | feats   | parameter_id             |   TN |  FN |  FP |  TP |   tpr |   fpr |
|---------------:|:--------|:-------------------------|-----:|----:|----:|----:|------:|------:|
|            0.0 | sd      | Alanine Aminotransferase | 1597 | 299 |   3 |   1 | 0.003 | 0.002 |
|            0.0 | sd      | Alkaline Phosphatase     | 1567 | 298 |  33 |   2 | 0.007 | 0.021 |
|            0.0 | average | Alanine Aminotransferase | 1598 | 297 |   2 |   3 | 0.010 | 0.001 |
|            0.0 | average | Alkaline Phosphatase     | 1563 | 298 |  37 |   2 | 0.007 | 0.023 |
|            0.5 | sd      | Alanine Aminotransferase | 1599 | 295 |   1 |   5 | 0.017 | 0.001 |
|            0.5 | sd      | Alkaline Phosphatase     | 1580 | 268 |  20 |  32 | 0.107 | 0.013 |
|            0.5 | average | Alanine Aminotransferase | 1600 | 299 |   0 |   1 | 0.003 | 0.000 |
|            0.5 | average | Alkaline Phosphatase     | 1576 | 282 |  24 |  18 | 0.060 | 0.015 |
|            1.0 | sd      | Alanine Aminotransferase | 1600 | 282 |   0 |  18 | 0.060 | 0.000 |
|            1.0 | sd      | Alkaline Phosphatase     | 1577 | 248 |  23 |  52 | 0.173 | 0.014 |
|            1.0 | average | Alanine Aminotransferase | 1597 | 300 |   3 |   0 | 0.000 | 0.002 |
|            1.0 | average | Alkaline Phosphatase     | 1576 | 280 |  24 |  20 | 0.067 | 0.015 |
|            2.0 | sd      | Alanine Aminotransferase | 1600 | 268 |   0 |  32 | 0.107 | 0.000 |
|            2.0 | sd      | Alkaline Phosphatase     | 1584 | 253 |  16 |  47 | 0.157 | 0.010 |
|            2.0 | average | Alanine Aminotransferase | 1600 | 287 |   0 |  13 | 0.043 | 0.000 |
|            2.0 | average | Alkaline Phosphatase     | 1581 | 266 |  19 |  34 | 0.113 | 0.012 |
|            5.0 | sd      | Alanine Aminotransferase | 1600 | 260 |   0 |  40 | 0.133 | 0.000 |
|            5.0 | sd      | Alkaline Phosphatase     | 1582 | 254 |  18 |  46 | 0.153 | 0.011 |
|            5.0 | average | Alanine Aminotransferase | 1600 | 262 |   0 |  38 | 0.127 | 0.000 |
|            5.0 | average | Alkaline Phosphatase     | 1583 | 262 |  17 |  38 | 0.127 | 0.011 |
|           10.0 | sd      | Alanine Aminotransferase | 1600 | 265 |   0 |  35 | 0.117 | 0.000 |
|           10.0 | sd      | Alkaline Phosphatase     | 1582 | 245 |  18 |  55 | 0.183 | 0.011 |
|           10.0 | average | Alanine Aminotransferase | 1600 | 252 |   0 |  48 | 0.160 | 0.000 |
|           10.0 | average | Alkaline Phosphatase     | 1576 | 243 |  24 |  57 | 0.190 | 0.015 |
|           50.0 | sd      | Alanine Aminotransferase | 1600 | 274 |   0 |  26 | 0.087 | 0.000 |
|           50.0 | sd      | Alkaline Phosphatase     | 1580 | 247 |  20 |  53 | 0.177 | 0.013 |
|           50.0 | average | Alanine Aminotransferase | 1600 | 254 |   0 |  46 | 0.153 | 0.000 |
|           50.0 | average | Alkaline Phosphatase     | 1582 | 234 |  18 |  66 | 0.220 | 0.011 |

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

| iter | anomaly_degree | feats   | parameter_id             | site         | subject_id               | timepoint_rank |    result | score |
|-----:|---------------:|:--------|:-------------------------|:-------------|:-------------------------|---------------:|----------:|------:|
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1033 |            1.0 | 1099.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1033 |            4.0 | 1118.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1033 |            5.0 | 1097.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1180 |            1.0 | 1241.5000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1180 |            4.0 | 1241.5000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1180 |            5.0 | 1232.5000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1180 |            7.0 | 1231.5000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1188 |            1.0 | 1171.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1188 |            4.0 | 1179.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1188 |            5.0 | 1173.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-701-1188 |            7.0 | 1169.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |            1.0 |  402.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |            4.0 |  402.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |            5.0 |  401.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |            7.0 |  402.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |            8.0 |  402.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |            9.0 |  408.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |           10.0 |  404.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |           11.0 |  405.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |           12.0 |  402.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-704-1164 |           13.0 |  401.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1348 |            1.2 |  598.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1348 |            4.0 |  595.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1348 |            5.0 |  592.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1348 |            7.0 |  588.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1348 |            8.0 |  594.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1348 |           10.0 |  595.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1348 |           11.0 |  597.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1348 |           12.0 |  597.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1348 |           13.0 |  596.3333 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1339 |            1.0 | 1225.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1339 |            4.0 | 1227.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1339 |            5.0 | 1226.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1339 |            7.0 | 1231.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1339 |            8.0 | 1227.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1339 |            9.0 | 1225.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1339 |           10.0 | 1227.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1339 |           11.0 | 1218.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1339 |           12.0 | 1217.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1339 |           13.0 | 1217.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1070 |            1.0 |  586.5714 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1070 |            4.0 |  589.5714 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1070 |            5.0 |  591.5714 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1070 |            7.0 |  592.5714 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1070 |            8.0 |  590.5714 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1070 |            9.0 |  589.5714 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1070 |           10.0 |  590.5714 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1354 |            1.0 | 1669.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1354 |            4.0 | 1667.0000 |     0 |
|    1 |             50 | average | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1354 |            5.0 | 1665.0000 |     0 |
