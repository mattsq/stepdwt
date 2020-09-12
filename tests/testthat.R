library(testthat)
library(stepdwt)

test_check("stepdwt")

## Tests to be added later, when I get better at adding tests
# library(tidymodels); library(stepdwt);
# n <- 100
# ts_length <- 50
# generate_ts <- function(seed, ts_length, ar = .2){
#   set.seed(seed)
#   df <- tibble::tibble(
#     id = seed,
#     idx = paste0("I", 1:ts_length),
#     val = arima.sim(list(ar = ar), n = ts_length)
#   ) %>%
#     tidyr::pivot_wider(names_from = idx, values_from = val)
#   return(df)
# }
#
# df <- map_dfr(1:n, ~ generate_ts(.x, ts_length))
#
# test_recipe <- recipes::recipe(id ~ ., data = df) %>%
#   stepdwt::step_dwt(all_predictors(), coefs = "all", coef_level = 2) %>%
#   prep()
#
# test_recipe %>% bake(., new_data = df)
#
# wavelets::dwt(df[10,2:ncol(df)] %>% unlist()) %>%
#   pull_wavelet_coefs(level = 3, type = "V")
#
# df %>% map_dwt_over_df(filter = "d4", align = TRUE, level = 3)
#
#
