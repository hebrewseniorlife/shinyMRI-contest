lazyr <- function(inputs, FUN) {
  obj = new.env(parent = globalenv())
  
  len = length(inputs)
  obj$FUN = FUN
  obj$inputs = inputs
  obj$checks = vector(mode = "logical", length = len)
  obj$returns = rep(NA, len)
  obj$length = len
  
  class(obj) = "lzr_obj"
  return(obj)
}

print.lzr_obj <- function(obj) {
  print(list("inputs" = obj$inputs, "returns" = obj$returns))
}

`[.lzr_obj` <- function(obj, idx, ...) {
  if (any(idx > obj$length)) stop("Out of bounds")
  if (is.na(obj$checks[idx]) | !obj$checks[idx]) {
    obj$returns[idx] = obj$FUN(obj$inputs[idx], ...)
    obj$checks[idx] = T
  }
  return(obj$returns[idx])
}

# Cache invalidation
`[<-.lzr_obj` <- function(obj, idx, value) {
  obj$inputs[idx] <- value
  obj$checks[idx] <- F
  invisible(obj)
}

