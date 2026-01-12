# sample values from a randomly selected non-normal distribution

sample values from a randomly selected non-normal distribution

## Usage

``` r
rsurprise(n, verbose = FALSE)
```

## Arguments

- n:

  integer, number of values

- verbose:

  logical, Default: FALSE

## Examples

``` r
set.seed(1)
rsurprise(5, verbose = TRUE)
#> Selected distribution: rbinom 
#> Parameters: size = 68; prob = 0.5729 
#> [1] 34 42 34 32 37
rsurprise(5, verbose = TRUE)
#> Selected distribution: rbeta 
#> Parameters: shape1 = 0.4028; shape2 = 1.1093 
#> [1] 5.397180e-01 2.708550e-01 2.370827e-06 5.344772e-01 6.524672e-01

```
