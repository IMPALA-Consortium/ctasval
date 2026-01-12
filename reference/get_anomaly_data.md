# Generate Anomaly Data

This function generates anomaly data by applying a specified anomaly
function to the data frame.

## Usage

``` r
get_anomaly_data(
  df,
  n_sites,
  fun_anomaly,
  anomaly_degree,
  site_prefix = "site"
)
```

## Arguments

- df:

  Data frame containing the study data.

- n_sites:

  Number of sites to generate.

- fun_anomaly:

  Function to apply to generate anomalies.

- anomaly_degree:

  Degree of anomaly to add.

- site_prefix:

  Prefix for the site names. Default is "site".

## Value

A data frame with the generated anomaly data.

## See also

[`get_anomaly_scores`](https://impala-consortium.github.io/ctasval/reference/get_anomaly_scores.md)
