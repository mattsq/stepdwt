#' DWT Filter Methods
#'
#' @param values A character string of possible values. See `values_prune_method`
#'  in examples below.
#'
#' @details
#' This parameter is used in `stepdwt::step_dwt`.
#' @examples
#' values_dwt_filter
#' dwt_filter()
#' @importFrom dials new_qual_param
#' @export
#'
dwt_filter <- function(values = values_dwt_filter) {
  dials::new_qual_param(
    type     = c("character"),
    values   = values,
    default  = "haar",
    label    = c(dwt_filter = "DWT Filter"),
    finalize = NULL
  )
}
#' DWT Coefficient Methods
#'
#' @param values A character string of possible values. See `values_prune_method`
#'  in examples below.
#'
#' @details
#' This parameter is used in `stepdwt::step_dwt`.
#' @examples
#' values_dwt_coefs
#' dwt_coefs()
#' @importFrom dials new_qual_param
#' @export
#'
dwt_coefs <- function(values = values_dwt_coefs) {
  dials::new_qual_param(
    type     = c("character"),
    values   = values,
    default  = "all",
    label    = c(dwt_coefs = "DWT Coefficients"),
    finalize = NULL
  )
}

#' @rdname dwt_filter
#' @export
values_dwt_filter <- c(
  "haar",
  paste0("d", seq(2,20, by = 2)),
  paste0("la", seq(8,20, by = 2)),
  paste0("bl", c(14,18,20)),
  paste0("c", seq(6,30, by = 6))
)
#' @rdname dwt_coefs
#' @export
values_dwt_coefs <- c(
  "all", "wavelet", "scaling"
)

#' @export
tunable.step_dwt <- function(x, ...) {
  tibble::tibble(
    name = c("dwt_filter", "dwt_coefs"),
    call_info = list(
      list(pkg = "stepdwt", fun = "dwt_filter"),
      list(pkg = "stepdwt", fun = "dwt_coefs")),
    source = "recipe",
    component = "step_dwt",
    component_id = x$id
  )
}
