# this uses rlang magic to pull all the coefficients out tidily
pull_wavelet_coefs <- function(dwt_object, type = "W", level = 3) {

  each_level <- function(dwt_object, level, type) {
    args <- list(dwt_object, type)
    slot_call <- rlang::call2(.fn = `@`, !!!args)
    slot_obj <- eval(slot_call)
    x <- slot_obj[[level]] %>% as.numeric()
    names(x) <- paste0(type, level, "_", 1:length(x))
    return(x)
  }

  # check that the levels actually exist
  args <- list(dwt_object, type)
  slot_call <- rlang::call2(.fn = `@`, !!!args)
  slot_obj <- eval(slot_call)
  if (length(slot_obj) < level) {
    level <- length(slot_obj)
    rlang::warn("The DWT object doesn't have that many levels, defaulting to lowest.")
  }

  # this is slow and circle-of-R-hell-y - need to improve

  x <- numeric()
  for (k in 1:level) {
    x1 <- each_level(dwt_object, k, type)
    x <- c(x, x1)
  }
  return(x)
}


# This then extracts the coefficients from a vector (as a time series)
extract_dwt_vector <- function(x, filter, coefs = "all",  level = 3, align) {
  dwt_out <- wavelets::dwt(x, filter = filter)
  if (align & filter != "haar") {
    dwt_out <- wavelets::align(dwt_out)
  }
  dwt_vars <- switch(coefs,
              all = c(pull_wavelet_coefs(dwt_out, type = "W", level = level),
                      pull_wavelet_coefs(dwt_out, type = "V", level = level)
                      ),
              wavelet = pull_wavelet_coefs(dwt_out, type = "W", level = level),
              scaling =  pull_wavelet_coefs(dwt_out, type = "V", level = level)
              )
  return(dwt_vars)
}
# the second tries to efficiently repeat the process over a dataframe
#' @export
map_dwt_over_df <- function(df, filter, coefs  = "all", level = 3, align = FALSE) {
  if(filter == "haar" & align) rlang::warn("Haar filter doesn't require alignment.")
  purrr::map_dfr(1:nrow(df), ~ extract_dwt_vector(df[.x,] %>% as.numeric(), filter = filter, coefs = coefs, level = level, align = align) %>% {.[names(.) != ""]})
}
