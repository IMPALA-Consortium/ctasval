
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
  filter(! grepl("UNSCH", VISIT))

plan(multisession, workers = 6)

ctas <- ctasval(
  df = df_filt,
  fun_anomaly = c(anomaly_average, anomaly_sd, anomaly_autocorr, anomaly_lof, anomaly_range),
  feats = c("average", "sd", "autocorr", "lof", "range"),
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
#> # A tibble: 80 × 9
#>    anomaly_degree feats    parameter_id       TN    FN    FP    TP     tpr   fpr
#>             <dbl> <chr>    <chr>           <int> <int> <int> <int>   <dbl> <dbl>
#>  1              0 average  Alanine Aminot…  1600   299     0     1 0.00333     0
#>  2              0 average  Alkaline Phosp…  1600   300     0     0 0           0
#>  3              0 sd       Alanine Aminot…  1600   299     0     1 0.00333     0
#>  4              0 sd       Alkaline Phosp…  1600   300     0     0 0           0
#>  5              0 autocorr Alanine Aminot…  1600   299     0     1 0.00333     0
#>  6              0 autocorr Alkaline Phosp…  1600   300     0     0 0           0
#>  7              0 lof      Alanine Aminot…  1600   299     0     1 0.00333     0
#>  8              0 lof      Alkaline Phosp…  1600   300     0     0 0           0
#>  9              0 range    Alanine Aminot…  1600   300     0     0 0           0
#> 10              0 range    Alkaline Phosp…  1600   299     0     1 0.00333     0
#> # ℹ 70 more rows
#> 
#> $anomaly
#> # A tibble: 2,672,132 × 39
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
#> # ℹ 2,672,122 more rows
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

| iter | anomaly_degree | feats    | parameter_id             | site         | subject_id               | timepoint_rank |        result |     score |
|-----:|---------------:|:---------|:-------------------------|:-------------|:-------------------------|---------------:|--------------:|----------:|
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1281 |              1 |  1069.6635991 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1281 |              4 |  1158.7549537 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1281 |              5 |   188.0414647 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1281 |              7 |  -939.4431305 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1281 |              8 | -1191.0140900 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1281 |              9 |  -341.5394432 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-705-1281 |             10 |   836.2195511 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1178 |              1 |  1249.1948912 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1178 |              4 |   526.0213724 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1178 |              5 |  -668.4992118 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1178 |              7 | -1240.5331682 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1178 |              8 |  -662.1551153 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-708-1178 |              9 |   544.1186462 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1088 |              1 |  1257.7619553 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1088 |              4 |   827.8156540 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1088 |              5 |  -341.1877973 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1088 |              7 | -1190.1168534 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1088 |              8 |  -928.1476369 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1088 |              9 |   204.0277721 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1088 |             10 |  1165.3313145 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1088 |             11 |  1062.6225283 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1088 |             12 |    -0.1043698 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-709-1088 |             13 | -1051.6219616 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1249 |              1 | -1122.0892178 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1249 |              4 |  -153.0412865 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1249 |              5 |   969.6642379 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1249 |              7 |  1212.8170738 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1249 |              8 |   349.8636253 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1249 |              9 |  -821.5588729 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1249 |             10 | -1232.5305830 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1249 |             11 |  -497.8835914 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1249 |             12 |   700.7898365 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site1 | sample_site1-01-710-1249 |             13 |  1263.4348790 |  1.209217 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1047 |              1 |  1624.3964979 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1047 |              4 |  1747.5570455 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1047 |              5 |   288.7320309 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1133 |              1 | -1418.1639736 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1133 |              5 | -1805.0604670 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1133 |              7 |  -517.0853884 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1133 |              8 |  1267.0865425 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1133 |              9 |  1900.0152759 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1133 |             10 |   799.7890532 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1133 |             11 | -1016.9686057 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1133 |             12 | -1886.2615062 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1133 |             13 | -1004.7851598 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1146 |              1 |   815.1157503 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1146 |              4 |  1900.3939295 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1146 |              5 |  1254.3302295 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1146 |              7 |  -535.2485727 | 16.897054 |
|    1 |            100 | autocorr | Alanine Aminotransferase | sample_site2 | sample_site2-01-701-1153 |              1 | -1817.7701655 | 16.897054 |
