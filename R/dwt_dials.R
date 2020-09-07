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

#' @rdname dwt_filter
#' @export
values_dwt_filter <- c(
  "haar",
  paste0("d", seq(2,20, by = 2)),
  paste0("la", seq(8,20, by = 2)),
  paste0("bl", c(14,18,20)),
  paste0("c", seq(6,30, by = 6))
)
