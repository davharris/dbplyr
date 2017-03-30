#' Create a "sql src" object
#'
#' Deprecated: please use [src_dbi] instead.
#'
#' @keywords internal
#' @export
#' @param subclass name of subclass. "src_sql" is an abstract base class, so you
#'   must supply this value. `src_` is automatically prepended to the
#'   class name
#' @param con the connection object
#' @param ... fields used by object
src_sql <- function(subclass, con, ...) {
  subclass <- paste0("src_", subclass)
  structure(list(con = con, ...), class = c(subclass, "src_sql", "src"))
}

#' Acquire/release connections from a src object
#'
#' `con_acquire()` gets a connection from a src object; `con_release()`
#' returns a previously acquired connection back to its src object. Intended for
#' internal use.
#'
#' These methods have default implementations for `src_sql` and can be
#' overridden for src objects that are not themselves DB connections, but know
#' how to get them (e.g. a connection pool).
#'
#' @keywords internal
#' @export
#' @param src A src object (most commonly, from `src_sql()`)
#' @param con A connection
#' @return For `con_acquire()`, a connection object; for `con_release()`,
#'   nothing.
con_acquire <- function(src) {
  UseMethod("con_acquire", src)
}

#' @rdname con_acquire
#' @export
con_release <- function(src, con) {
  UseMethod("con_release", src)
}

#' @export
con_acquire.src_sql <- function(src) {
  con <- src$con
  if (is.null(con)) {
    stop("No connection found", call. = FALSE)
  }

  con
}

#' @export
con_release.src_sql <- function(src, con) {
}


#' @export
same_src.src_sql <- function(x, y) {
  if (!inherits(y, "src_sql")) return(FALSE)
  identical(x$obj, y$obj)
}

#' @export
src_tbls.src_sql <- function(x, ...) {
  con <- con_acquire(x)
  on.exit(con_release(x, con), add = TRUE)

  db_list_tables(con)
}

#' @export
format.src_sql <- function(x, ...) {
  paste0(
    "src:  ", db_desc(x$con), "\n",
    wrap("tbls: ", paste0(sort(src_tbls(x)), collapse = ", "))
  )
}
