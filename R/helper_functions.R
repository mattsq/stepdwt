

# two helper functions - the first extracts the coefficients from a vector
extract_dwt_vector <- function(x, filter, coefs = "all") {
  dwt_out <- wavelets::dwt(x, filter = filter)
  dwt_vars <- switch(coefs,
              all = unlist(c(dwt_out@W,dwt_out@V[[dwt_out@level]])),
              wavelet = unlist(dwt_out@W),
              scaling =  unlist(dwt_out@V[[dwt_out@level]])
              )
  return(dwt_vars)
}
# the second tries to efficiently repeat the process over a dataframe
map_dwt_over_df <- function(df, filter, coefs  = "all") {
  purrr::map_dfr(1:nrow(df), ~ extract_dwt_vector(df[.x,] %>% as.numeric(), filter = filter, coefs = coefs) %>% {.[names(.) != ""]})
}
