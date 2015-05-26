#' RemoteMatrix: A package for remote matrices.
#'
#' @docType package
#' @name RemoteMatrix
#' @importFrom httr GET PUT content
#' @importFrom jsonlite fromJSON
#' @import methods
NULL

#' An S4 class to represent a remote matrix.
#'
#' @slot uri The URI to the remote matrix.
#' @export
setClass('RemoteMatrix', slots = list(uri = 'character'))

#' The constructor for the S4 RemoteMatrix class.
#'
#' @export
setMethod('initialize', signature(.Object = 'RemoteMatrix'), function (.Object, uri) {
    .Object@uri <- uri
    return(.Object)
})

#' The subset operator for the S4 RemoteMatrix class.
#'
#' @export
setMethod('[', signature(x = 'RemoteMatrix'), function (x, i, j, drop) {
    request_params <- c()
    if (!missing(i)) {
        request_params <- c(i = paste(i, collapse = ','), request_params)
    }
    if (!missing(j)) {
        request_params <- c(j = paste(j, collapse = ','), request_params)
    }
    r <- GET(x@uri, query = as.list(request_params))
    response_body <- content(r, as = 'text')
    response_body <- fromJSON(response_body, simplifyMatrix = TRUE)
    return(response_body)
})

#' The replacement operator for the S4 RemoteMatrix class.
#'
#' @export
setReplaceMethod('[', signature(x = 'RemoteMatrix'), function (x, i, j, value) {
    request_body <- c()
    if (!missing(i)) {
        request_params <- c(i = paste(i, collapse = ','), request_params)
    }
    if (!missing(j)) {
        request_params <- c(j = paste(j, collapse = ','), request_params)
    }
    request_params <- c(value = value, request_params)
    PUT(x@uri, query = as.list(request_params))
    return(x)
})

#' The dim method for the S4 RemoteMatrix class.
#'
#' @export
dim.RemoteMatrix <- function (x) {
    r <- GET(paste0(x@uri, '/dim'))
    response_body <- content(r)
    return(c(response_body$rows, response_body$columns))
}
