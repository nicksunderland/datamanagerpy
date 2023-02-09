#' set_download_dirpath
#'
#' @param dir_path the directory path to set the download path to
#' @param verbose where to print out
#' @return nothing, sets the package's config file as side effect
#'
#' @importFrom jsonlite read_json write_json
#' @importFrom utils file_test
#' @export
#'
set_download_dirpath <- function(dir_path, verbose=TRUE) {

  # stop if file path given instead of directory path
  stopifnot("dir_path must be a directory path not a file path" = !utils::file_test("-f", dir_path))

  # check if directory exists, create if not
  if(!dir.exists(dir_path)) {
    dir.create(dir_path)
  }

  # path to the local config file
  config_fp <- system.file("config.json", package="datamanager")

  # read the current config settings to a list
  config <- jsonlite::read_json(config_fp)

  # print
  if(verbose)  message(paste0("Download directory changed from:\n", config$download_path, "\n..to.."))

  # adjust the download file path
  config$download_path <- dir_path

  # write out the new config file
  jsonlite::write_json(config, config_fp, auto_unbox=TRUE, pretty=TRUE)

  # print
  config <- jsonlite::read_json(config_fp)
  if(verbose)  message(config$download_path)
}

#' get_download_dirpath
#'
#' @return the download directory path
#'
#' @importFrom jsonlite read_json
#' @export
#'
get_download_dirpath <- function() {

  # path to the local config file
  config_fp <- system.file("config.json", package="datamanager")

  # read the current config settings to a list
  config <- jsonlite::read_json(config_fp)

  # return the download directory path
  return(config$download_path)
}
