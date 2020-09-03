
<!-- README.md is generated from README.Rmd. Please edit that file -->

# stepdwt

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/stepdwt)](https://CRAN.R-project.org/package=stepdwt)
<!-- badges: end -->

The goal of stepdwt is to add a recipes:: preprocessing step that
converts a dataframe of numeric columns, where each row is a
time-series, into their discrete wavelet transformation coefficents. Is
this a good idea? Maybe not\! This is purely experimental for me at this
point.

## Installation

stepdwt isn’t on CRAN, although I guess one day it could be.

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
# install.packages("wavelets")
devtools::install_github("mattsq/stepdwt")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(tidymodels)
#> -- Attaching packages ---------------------------------------------------------------------------------------------------------------------- tidymodels 0.1.1 --
#> v broom     0.7.0      v recipes   0.1.13
#> v dials     0.0.8      v rsample   0.0.7 
#> v dplyr     1.0.2      v tibble    3.0.3 
#> v ggplot2   3.3.2      v tidyr     1.1.2 
#> v infer     0.5.3      v tune      0.1.1 
#> v modeldata 0.0.2      v workflows 0.1.3 
#> v parsnip   0.1.3      v yardstick 0.0.7 
#> v purrr     0.3.4
#> -- Conflicts ------------------------------------------------------------------------------------------------------------------------- tidymodels_conflicts() --
#> x purrr::discard() masks scales::discard()
#> x dplyr::filter()  masks stats::filter()
#> x dplyr::lag()     masks stats::lag()
#> x recipes::step()  masks stats::step()
library(wavelets)
library(stepdwt)

create_data <- function(n, ts_length, arima_terms = list(ar = .2)) {

  # create an arbitrary set of ar = .2 time series, for testing.

  l <- map(1:n, ~ {
    set.seed(.x)
    return(tibble(id = .x, idx = 1:ts_length, ts = arima.sim(model = arima_terms, n = ts_length)))
  })

  # bind them together and pivot them so each row is a series, each column is a position
  l_df <- bind_rows(l)
  df <- pivot_wider(l_df, id_cols = c(id), names_from = c(idx), values_from = c(ts), names_prefix = "ts_")
  return(df)

}

df <- create_data(n = 100, ts_length = 100)
head(df)
#> # A tibble: 6 x 101
#>      id    ts_1    ts_2    ts_3   ts_4    ts_5   ts_6   ts_7   ts_8    ts_9
#>   <int>   <dbl>   <dbl>   <dbl>  <dbl>   <dbl>  <dbl>  <dbl>  <dbl>   <dbl>
#> 1     1 -0.697   0.348   0.808   0.737 -0.158   1.48   0.686 -0.484 -2.31  
#> 2     2  0.0839  0.725  -0.0948  1.97   0.254   0.469  1.08  -0.178 -1.08  
#> 3     3  0.0245  0.0903  1.13   -0.992  1.07   -0.531 -1.24  -0.964  0.0599
#> 4     4  1.05   -1.07   -0.428   1.81   2.14    0.994  0.215  0.426  0.0401
#> 5     5 -0.266  -0.525  -0.740  -0.434  0.0513  1.24  -0.554 -1.19  -0.396 
#> 6     6  0.448  -1.22    0.495   0.144 -1.02    1.52  -0.874  0.478 -0.273 
#> # ... with 91 more variables: ts_10 <dbl>, ts_11 <dbl>, ts_12 <dbl>,
#> #   ts_13 <dbl>, ts_14 <dbl>, ts_15 <dbl>, ts_16 <dbl>, ts_17 <dbl>,
#> #   ts_18 <dbl>, ts_19 <dbl>, ts_20 <dbl>, ts_21 <dbl>, ts_22 <dbl>,
#> #   ts_23 <dbl>, ts_24 <dbl>, ts_25 <dbl>, ts_26 <dbl>, ts_27 <dbl>,
#> #   ts_28 <dbl>, ts_29 <dbl>, ts_30 <dbl>, ts_31 <dbl>, ts_32 <dbl>,
#> #   ts_33 <dbl>, ts_34 <dbl>, ts_35 <dbl>, ts_36 <dbl>, ts_37 <dbl>,
#> #   ts_38 <dbl>, ts_39 <dbl>, ts_40 <dbl>, ts_41 <dbl>, ts_42 <dbl>,
#> #   ts_43 <dbl>, ts_44 <dbl>, ts_45 <dbl>, ts_46 <dbl>, ts_47 <dbl>,
#> #   ts_48 <dbl>, ts_49 <dbl>, ts_50 <dbl>, ts_51 <dbl>, ts_52 <dbl>,
#> #   ts_53 <dbl>, ts_54 <dbl>, ts_55 <dbl>, ts_56 <dbl>, ts_57 <dbl>,
#> #   ts_58 <dbl>, ts_59 <dbl>, ts_60 <dbl>, ts_61 <dbl>, ts_62 <dbl>,
#> #   ts_63 <dbl>, ts_64 <dbl>, ts_65 <dbl>, ts_66 <dbl>, ts_67 <dbl>,
#> #   ts_68 <dbl>, ts_69 <dbl>, ts_70 <dbl>, ts_71 <dbl>, ts_72 <dbl>,
#> #   ts_73 <dbl>, ts_74 <dbl>, ts_75 <dbl>, ts_76 <dbl>, ts_77 <dbl>,
#> #   ts_78 <dbl>, ts_79 <dbl>, ts_80 <dbl>, ts_81 <dbl>, ts_82 <dbl>,
#> #   ts_83 <dbl>, ts_84 <dbl>, ts_85 <dbl>, ts_86 <dbl>, ts_87 <dbl>,
#> #   ts_88 <dbl>, ts_89 <dbl>, ts_90 <dbl>, ts_91 <dbl>, ts_92 <dbl>,
#> #   ts_93 <dbl>, ts_94 <dbl>, ts_95 <dbl>, ts_96 <dbl>, ts_97 <dbl>,
#> #   ts_98 <dbl>, ts_99 <dbl>, ts_100 <dbl>
```

Then we preprocess it using a recipe, and get back DWT coefficients\!

``` r
recipe_check <- recipe(id ~ ., data = df) %>%
   step_dwt(ends_with("1"), ends_with("2"))

training_data <- recipe_check %>%
  prep() %>%
  juice()

head(training_data)
#> # A tibble: 6 x 99
#>      ts_3   ts_4    ts_5   ts_6   ts_7   ts_8    ts_9   ts_10  ts_13   ts_14
#>     <dbl>  <dbl>   <dbl>  <dbl>  <dbl>  <dbl>   <dbl>   <dbl>  <dbl>   <dbl>
#> 1  0.808   0.737 -0.158   1.48   0.686 -0.484 -2.31    0.663   0.944  1.01  
#> 2 -0.0948  1.97   0.254   0.469  1.08  -0.178 -1.08    1.57    0.132  1.04  
#> 3  1.13   -0.992  1.07   -0.531 -1.24  -0.964  0.0599  0.164  -0.850  1.05  
#> 4 -0.428   1.81   2.14    0.994  0.215  0.426  0.0401  0.0424  0.196 -0.0612
#> 5 -0.740  -0.434  0.0513  1.24  -0.554 -1.19  -0.396  -1.15   -2.32  -0.223 
#> 6  0.495   0.144 -1.02    1.52  -0.874  0.478 -0.273  -0.654  -0.756 -0.440 
#> # ... with 89 more variables: ts_15 <dbl>, ts_16 <dbl>, ts_17 <dbl>,
#> #   ts_18 <dbl>, ts_19 <dbl>, ts_20 <dbl>, ts_23 <dbl>, ts_24 <dbl>,
#> #   ts_25 <dbl>, ts_26 <dbl>, ts_27 <dbl>, ts_28 <dbl>, ts_29 <dbl>,
#> #   ts_30 <dbl>, ts_33 <dbl>, ts_34 <dbl>, ts_35 <dbl>, ts_36 <dbl>,
#> #   ts_37 <dbl>, ts_38 <dbl>, ts_39 <dbl>, ts_40 <dbl>, ts_43 <dbl>,
#> #   ts_44 <dbl>, ts_45 <dbl>, ts_46 <dbl>, ts_47 <dbl>, ts_48 <dbl>,
#> #   ts_49 <dbl>, ts_50 <dbl>, ts_53 <dbl>, ts_54 <dbl>, ts_55 <dbl>,
#> #   ts_56 <dbl>, ts_57 <dbl>, ts_58 <dbl>, ts_59 <dbl>, ts_60 <dbl>,
#> #   ts_63 <dbl>, ts_64 <dbl>, ts_65 <dbl>, ts_66 <dbl>, ts_67 <dbl>,
#> #   ts_68 <dbl>, ts_69 <dbl>, ts_70 <dbl>, ts_73 <dbl>, ts_74 <dbl>,
#> #   ts_75 <dbl>, ts_76 <dbl>, ts_77 <dbl>, ts_78 <dbl>, ts_79 <dbl>,
#> #   ts_80 <dbl>, ts_83 <dbl>, ts_84 <dbl>, ts_85 <dbl>, ts_86 <dbl>,
#> #   ts_87 <dbl>, ts_88 <dbl>, ts_89 <dbl>, ts_90 <dbl>, ts_93 <dbl>,
#> #   ts_94 <dbl>, ts_95 <dbl>, ts_96 <dbl>, ts_97 <dbl>, ts_98 <dbl>,
#> #   ts_99 <dbl>, ts_100 <dbl>, id <int>, W11 <dbl>, W12 <dbl>, W13 <dbl>,
#> #   W14 <dbl>, W15 <dbl>, W16 <dbl>, W17 <dbl>, W18 <dbl>, W19 <dbl>,
#> #   W110 <dbl>, W21 <dbl>, W22 <dbl>, W23 <dbl>, W24 <dbl>, W25 <dbl>,
#> #   W31 <dbl>, W32 <dbl>, W4 <dbl>
```

You can then use this to fit a model. Here we do a very silly example,
just for the purposes of illustration:

    #> i Bootstrap1: recipe
    #> v Bootstrap1: recipe
    #> i Bootstrap1: model
    #> v Bootstrap1: model
    #> i Bootstrap1: model (predictions)
    #> i Bootstrap2: recipe
    #> v Bootstrap2: recipe
    #> i Bootstrap2: model
    #> v Bootstrap2: model
    #> i Bootstrap2: model (predictions)
    #> i Bootstrap3: recipe
    #> v Bootstrap3: recipe
    #> i Bootstrap3: model
    #> v Bootstrap3: model
    #> i Bootstrap3: model (predictions)
    #> i Bootstrap4: recipe
    #> v Bootstrap4: recipe
    #> i Bootstrap4: model
    #> v Bootstrap4: model
    #> i Bootstrap4: model (predictions)
    #> i Bootstrap5: recipe
    #> v Bootstrap5: recipe
    #> i Bootstrap5: model
    #> v Bootstrap5: model
    #> i Bootstrap5: model (predictions)
    #> # A tibble: 2 x 5
    #>   .metric .estimator    mean     n std_err
    #>   <chr>   <chr>        <dbl> <int>   <dbl>
    #> 1 rmse    standard   28.0        5  0.520 
    #> 2 rsq     standard    0.0746     5  0.0133
