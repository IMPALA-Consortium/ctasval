# Prepare SDTM LB Data

This function prepares the LB (Laboratory) data for SDTM (Study Data
Tabulation Model) by merging it with the DM (Demographics) data.

## Usage

``` r
prep_sdtm_lb(lb, dm, scramble = TRUE)
```

## Arguments

- lb:

  Data frame containing the LB data.

- dm:

  Data frame containing the DM data.

- scramble:

  Logical indicating whether to scramble the SITEID in the DM data.
  Default is TRUE.

## Value

A data frame with the prepared SDTM LB data.
