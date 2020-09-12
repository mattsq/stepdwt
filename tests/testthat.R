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
#   stepdwt::step_dwt(all_predictors(), coefs = "all", coef_level = 1, filter = "la8", align = TRUE) %>%
#   prep()
#
# test_recipe %>% bake(., new_data = df)
#
# df_check <- bind_rows(df, map_dfr(1:n, ~ generate_ts(.x, ts_length, ar = .9)), .id = "df") %>%
#   mutate(df = factor(df))
#
# df_check <- select(df_check, -id)
#
# test_recipe_2_df <- recipe(df ~ ., data = df_check) %>%
#   step_dwt(all_predictors(), coef_level = 1) %>%
#   prep() %>% bake(new_data = df_check)
#
# model_test <- rand_forest(mode = "classification") %>%
#   set_engine("ranger")
#
# fit(model_test, df ~ ., data = test_recipe_2_df)
#
# ## Something still isn't quite right here - for some reason, used in a workflow like this
# ## all the predictors disappear?
#
# wf <- workflow() %>%
#   add_recipe(test_recipe_2) %>%
#   add_model(model_test)
#
# bs <- bootstraps(df_check)
#
# fit_resamples(wf, resamples = bs, control = control_resamples(verbose = TRUE))

