#' @title saveRDS/readRDS
#' @description Serialization interface to read/write R objects to S3
#' @author Steven Akins <skawesome@gmail.com>
#' 
#' @param x For \code{s3saveRDS}, a single R object to be saved via \code{\link[base]{saveRDS}} and uploaded to S3. \code{x} is analogous to the \code{object} argument in \code{saveRDS}.
#' @template bucket
#' @template object
#' @param ... Additional arguments passed to \code{\link{s3HTTP}}.
#'
#' @return For \code{s3saveRDS}, a logical. For \code{s3readRDS}, an R object.
#' @examples
#' \dontrun{
#' # create bucket
#' b <- put_bucket("myexamplebucket")
#'
#' # save a single object to s3
#' s3saveRDS(x = mtcars, bucket = "myexamplebucket", object = "mtcars.rds")
#'
#' # restore it under a different name
#' mtcars2 <- s3readRDS(object = "mtcars.rds", bucket = "myexamplebucket")
#' identical(mtcars, mtcars2)
#' 
#' # cleanup
#' delete_object(object = "mtcars.rds", bucket = "myexamplebucket")
#' delete_bucket("myexamplebucket")
#' }
#' @seealso \code{\link{s3save}},\code{\link{s3load}}
#' @export
s3saveRDS <- function(x, bucket, object, ...) {
    body <- memCompress(from = serialize(x, connection = NULL), type = 'gzip')
    r <- put_object(file = body, bucket = bucket, object = object, ...)
    if (inherits(r, "aws-error")) {
        return(r)
    } else {
        return(invisible(r))
    }
}

#' @rdname s3saveRDS
#' @export
s3readRDS <- function(bucket, object, ...) {
    r <- get_object(bucket = bucket, object = object, ...)
    if (typeof(r) == 'raw') {
        return(unserialize(memDecompress(from = as.vector(r), type = 'gzip')))
    } else {
        return(r)
    }
}