
#' Discrete Wavelet Transformation
#'
#' `step_dwt` creates a *specification* of a recipe step
#'  that will convert numeric data into an arbitrary number
#'  of wavelets as computed by `wavelets::dwt()`
#'
#' @param ... One or more selector functions to choose which
#'  variables will be used to compute the components. See
#'  [selections()] for more details. For the `tidy`
#'  method, these are not currently used.
#' @param role For model terms created by this step, what analysis
#'  role should they be assigned?. By default, the function assumes
#'  that the new principal component columns created by the original
#'  variables will be used as predictors in a model.
#' @param options A list of options to the default method for
#'  [wavelets::dwt()]. Argument defaults are set to
#'  `filter = 'haar'`. No others should be passed.
#' @param prefix A character string that will be the prefix to the
#'  resulting new variables.
#' @param ref_dist placeholder
#' @return An updated version of `recipe` with the new step
#'  added to the sequence of existing steps (if any). For the
#'  `tidy` method, a tibble with columns `terms` (the
#'  selectors or variables selected), `value` (the
#'  loading), and `component`.
#' @keywords datagen
#' @concept preprocessing
#' @concept dwt
#' @concept projection_methods
#' @importFrom recipes add_step step terms_select ellipse_check check_name
#' @importFrom recipes rand_id bake prep
#' @importFrom tibble as_tibble tibble
#' @importFrom purrr map_dfr
#' @importFrom wavelets dwt
#' @importFrom rlang call2
#' @export
#' @details
#' Some boilerplate about what DWT actually is to go here!
#'
#' @references Add reference
#'
#' @examples
#' \dontrun{
#' rec <- recipe( ~ ., data = USArrests)
#' dwt_trans <- rec %>%
#'   step_center(all_numeric()) %>%
#'   step_scale(all_numeric()) %>%
#'   step_dwt(all_numeric())
#' dwt_estimates <- prep(dwt_trans, training = USArrests)
#' dwt_data <- bake(dwt_estimates, USArrests)
#'}

step_dwt <- function(
  recipe,
  ...,
  role = NA,
  trained = FALSE,
  ref_dist = NULL,
  filter = "haar",
  coefs = "all",
  coef_level = 3,
  align = FALSE,
  options = list(),
  prefix = "DWT_",
  skip = FALSE,
  id = recipes::rand_id("dwt")
) {

  ## The variable selectors are not immediately evaluated by using
  ##  the `quos()` function in `rlang`. `ellipse_check()` captures
  ##  the values and also checks to make sure that they are not empty.
  terms <- recipes::ellipse_check(...)

  recipes::add_step(
    recipe,
    step_dwt_new(
      terms = terms,
      trained = trained,
      role = role,
      ref_dist = ref_dist,
      filter = filter,
      coefs = coefs,
      coef_level = coef_level,
      align = align,
      options = options,
      prefix = prefix,
      skip = skip,
      id = id
    )
  )
}

step_dwt_new <-
  function(terms, role, trained, ref_dist, filter, coefs, coef_level, align, options, prefix, skip, id) {
    recipes::step(
      subclass = "dwt",
      terms = terms,
      role = role,
      trained = trained,
      ref_dist = ref_dist,
      filter = filter,
      coefs = coefs,
      coef_level = coef_level,
      align = align,
      options = options,
      prefix = prefix,
      skip = skip,
      id = id
    )
  }

#' @export
prep.step_dwt <- function(x, training, info = NULL, ...) {
  col_names <- recipes::terms_select(terms = x$terms, info = info)
  ## We actually only need the training set here
  ## Since there's nothing about the trained data that's useful
  ## you could probably even just return the variable names?
  ref_dist <- training[,col_names]

  ## Use the constructor function to return the updated object.
  ## Note that `trained` is now set to TRUE

  step_dwt_new(
    terms = x$terms,
    trained = TRUE,
    role = x$role,
    ref_dist = ref_dist,
    filter = x$filter,
    coefs = x$coefs,
    coef_level = x$coef_level,
    align = x$align,
    options = x$options,
    prefix = x$prefix,
    skip = x$skip,
    id = x$id
  )
}
#' @export
bake.step_dwt <- function(object, new_data, ...) {
  ## I use expr(), mod_call_args and eval to evaluate map_dwt
  ## this probably is a little aroundabout?
  vars <- names(object$ref_dist)
  args <- list(df = object$df,
               filter = object$filter,
               coefs = object$coefs,
               level = object$level,
               align = object$align
               )

  dwt_call <- rlang::call2(map_dwt_over_df, !!!args)
  new_data_cols <- eval(dwt_call)

  comps <- recipes::check_name(new_data_cols, new_data, object)
  new_data <- dplyr::bind_cols(new_data, tibble::as_tibble(new_data_cols))
  ## get rid of the original columns
  ## -vars will not do this!
  new_data <-
    new_data[, !(colnames(new_data) %in% vars), drop = FALSE]

  ## Always convert to tibbles on the way out
  tibble::as_tibble(new_data)
}

#' @export
print.step_dwt <- function (x, width = max(20, options()$width - 31), ...)
{
  cat("Discrete Wavelet Transformation for ", sep = "")
  printer(names(x$models), x$terms, x$trained, width = width)
  invisible(x)
}



