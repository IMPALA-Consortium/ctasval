# Prepare SDTM VS Data

This function prepares the VS (Vital Sign) data for SDTM (Study Data
Tabulation Model) by merging it with the DM (Demographics) data.

## Usage

``` r
prep_sdtm_vs(vs, dm, scramble = TRUE)
```

## Arguments

- vs:

  Data frame containing the VS data.

- dm:

  Data frame containing the DM data.

- scramble:

  Logical indicating whether to scramble the SITEID in the DM data.
  Default is TRUE.

## Value

A data frame with the prepared SDTM LB data.
