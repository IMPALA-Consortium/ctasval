
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
devtools::install_github("IMPALA-Consortium/ctasval")
```

## Example

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


df_prep <- prep_sdtm_lb(pharmaversesdtm::lb, pharmaversesdtm::dm, scramble = TRUE)
#> Joining with `by = join_by(USUBJID)`

df_filt <- df_prep %>%
  filter(parameter_id %in% c("Alkaline Phosphatase", "Alanine Aminotransferase"))

plan(multisession, workers = 6)

ctas <- ctasval(
  df = df_filt,
  fun_anomaly = c(anomaly_average, anomaly_sd),
  feats = c("average", "sd"),
  parallel = TRUE,
  iter = 100
)
#> Warning: There were 6 warnings in `mutate()`.
#> The first warning was:
#> ℹ In argument: `ctas = simaerep::purrr_bar(...)`.
#> Caused by warning:
#> ! UNRELIABLE VALUE: Future ('<none>') unexpectedly generated random numbers without specifying argument 'seed'. There is a risk that those random numbers are not statistically sound and the overall results might be invalid. To fix this, specify 'seed=TRUE'. This ensures that proper, parallel-safe random numbers are produced via the L'Ecuyer-CMRG method. To disable this check, use 'seed=NULL', or set option 'future.rng.onMisuse' to "ignore".
#> ℹ Run `dplyr::last_dplyr_warnings()` to see the 5 remaining warnings.

plan(sequential)

ctas
#> $result
#> # A tibble: 28 × 9
#>    anomaly_degree feats   parameter_id      TN    FN    FP    TP     tpr     fpr
#>             <dbl> <chr>   <chr>          <int> <int> <int> <int>   <dbl>   <dbl>
#>  1            0   sd      Alkaline Phos…  1700   298     0     2 0.00667 0      
#>  2            0   sd      Alanine Amino…  1700   300     0     0 0       0      
#>  3            0   average Alkaline Phos…  1700   299     0     1 0.00333 0      
#>  4            0   average Alanine Amino…  1699   300     1     0 0       5.88e-4
#>  5            0.5 sd      Alkaline Phos…  1700   266     0    34 0.113   0      
#>  6            0.5 sd      Alanine Amino…  1700   297     0     3 0.01    0      
#>  7            0.5 average Alkaline Phos…  1700   284     0    16 0.0533  0      
#>  8            0.5 average Alanine Amino…  1696   296     4     4 0.0133  2.35e-3
#>  9            1   sd      Alkaline Phos…  1700   267     0    33 0.11    0      
#> 10            1   sd      Alanine Amino…  1700   290     0    10 0.0333  0      
#> # ℹ 18 more rows
#> 
#> $anomaly
#> # A tibble: 890,197 × 39
#>     iter anomaly_degree fun_anomaly feats STUDYID      DOMAIN subject_id   LBSEQ
#>    <int>          <dbl> <list>      <chr> <chr>        <chr>  <chr>        <dbl>
#>  1     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…     2
#>  2     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…    39
#>  3     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…    75
#>  4     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…   110
#>  5     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…   140
#>  6     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…   170
#>  7     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…   200
#>  8     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…     2
#>  9     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…    34
#> 10     1              0 <fn>        sd    CDISCPILOT01 LB     sample_site…    69
#> # ℹ 890,187 more rows
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
