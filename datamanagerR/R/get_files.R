#' get_web_file()
#'
#' Download a web based file into this packages downloads directory (inst/extdata), or elsewhere is
#' this has been set with set_download_dirpath()
#'
#' @param url url to file to download
#' @param name name for the file being downloaded, e.g. 'my_interesting_data"
#' @param overwrite whether or not to overwrite the file
#' @param verbose if FALSE, suppress status messages and the progress bar.
#'
#' @return a data_file object, or if failed a filepath to the data
#'
#' @importFrom httr GET
#' @importFrom utils tail download.file
#' @importFrom checkmate check_path_for_output
#' @importFrom utils tail
#' @importFrom purrr map_lgl
#' @importFrom stats setNames
#' @importFrom TAF rmdir
#'
#' @export
#'
get_web_file <- function(url, name, overwrite=FALSE, verbose=TRUE) {

  ## Parameter checks
  stopifnot(
    "url parameter must be a URL" = !httr::http_error(url),
    "name must be a valid R object name" = name==make.names(name),
    "overwrite parameter must be logical" = is.logical(overwrite)
  )

  ## Get the directory path to download to
  base_dir_path <- get_download_dirpath()

  # Is the name already there
  data_name_exists <- name %in% list.dirs(base_dir_path, full.names=FALSE)

  ## Download the data
  if((data_name_exists & overwrite) | !data_name_exists) {
    tryCatch(
      {
        # create the file path for the download
        dir_path <- file.path(base_dir_path, name)
        # create the directory to download into
        dir.create(dir_path, showWarnings=FALSE)
        ## Create the filename from the url
        web_file_name <- utils::tail(strsplit(url, "/")[[1]],1)
        ## The path to the file
        fp <- file.path(dir_path, web_file_name)
        # download the zip file
        utils::download.file(url=url, destfile=fp, method='curl', quiet=!verbose)
        # unzip into the file_path directory
        utils::unzip(fp, exdir=dirname(fp))
        # remove the zip file
        file.remove(fp)
        # list all the extracted files recursively
        extracted_files <- list.files(dirname(fp), full.names=TRUE, recursive=TRUE, all.files=TRUE)
        # create files names pointing to the the base directory
        flat_directory <- file.path(dir_path, basename(extracted_files))
        # move/rename all the extracted files to the base directory
        file.rename(from=extracted_files, to=flat_directory)
        # delete empty directory folders
        TAF::rmdir(dirname(fp), recursive=TRUE)
        # create the data file object
        f <- create_data_file(name=name,
                              source=url,
                              dir_path=dirname(fp),
                              data_paths=setNames(as.list(list.files(dirname(fp), full.names=TRUE)), list.files(dirname(fp))),
                              overwrite=overwrite)
        return(f)
      },
      error=function(e) {
        stop("TODO: fix this if needed")
#         tryCatch(
#           {
#             httr::GET(url, httr::user_agent("Chrome/102.0.5005.61"), httr::write_disk(fp, overwrite=overwrite))
#             f <- create_data_file(name=name, path=fp, overwrite=overwrite)
#             return(f)
#           },
#           error=function(e) {
#             stop("Tried to download file with 'download.file()' and 'httr::GET()' methods, both failed.")
#             return(NULL)
#           }
#         )
      }
    )
  }else {
    f <- get_data_file(name=name)
    warning(paste0("File already downloaded at:\n",
                   f$dir_path,
                   "\n...if you want to overwrite it change the overwirte parameter to 'TRUE'\n",
                   "Returning file object linked to existing file"))
    return(f)
  }
}

data_file <- function(name, dir_path, data_paths, created_on, source=NA_character_) {

  # Create an S3 data_file object
  dfile <- structure(list("name"=name,
                          "source"=source,
                          "dir_path"=dir_path,
                          "data_paths"=data_paths,
                          "created_on"=created_on),
                     class="data_file")

  return(dfile)
}

create_data_file <- function(name,
                             dir_path,
                             data_paths,
                             source=NA_character_,
                             overwrite=FALSE) {

  stopifnot(
    "dir_path must be a valid file path" = checkmate::test_path_for_output(dir_path, overwrite=TRUE),
    "data_paths must all be valid file paths" = all(file.exists(unlist(data_paths))),
    "name must be a valid R object name" = name==make.names(name),
    "overwrite must be logical" = is.logical(overwrite)
  )

  # Create the data_file S3 object
  dfile <- data_file(name=name, source=source, dir_path=dir_path, data_paths=data_paths, created_on=Sys.time())

  # Update the cache
  dfile <- update_file_cache(dfile, overwrite)

  # Return the data_file
  return(dfile)
}

update_file_cache <- function(data_file, overwrite=FALSE) {
  if(in_file_cache(name=data_file$name) & !overwrite) {
    return(get_data_file(data_file$name))
  }else if(in_file_cache(name=data_file$name) & overwrite) {
    current <- file_cache()
    idxs <- purrr::map_lgl(current, ~ .x$name==data_file$name)
    reduced <- current[ which(!idxs) ]
    updated <- append(reduced, list(data_file))
    write_file_cache(updated)
    return(data_file)
  }else {
    current <- file_cache()
    updated <- append(current, list(data_file))
    write_file_cache(updated)
    return(data_file)
  }
}

write_file_cache <- function(files_list) {
  jsonlite::write_json(files_list,
                       file.path(system.file("file_cache.json", package="datamanager")),
                       force=TRUE,
                       auto_unbox=TRUE,
                       pretty=TRUE)
}

get_data_file <- function(name) {
  current <- file_cache()
  if(in_file_cache(name=name)) {
    file <- current[[ which(purrr::map_lgl(current, ~ .x$name==name)) ]]
    return(file)
  }else {
    stop("data_file name not found in cache")
  }
}

delete_data_file <- function(name, remove_all_files=TRUE) {
  current <- file_cache()
  if(in_file_cache(name)) {
    name_idxs <- purrr::map_lgl(current, ~ .x$name==name)
  }else {
    return(current)
  }
  to_delete <- current[ which(name_idxs)  ]
  if(remove_all_files) {
    unlink(purrr::map_chr(to_delete, ~ .x$dir_path) , recursive=TRUE)
  }
  reduced <- current[ which(!name_idxs) ]
  write_file_cache(reduced)
  return(reduced)
}

file_cache <- function() {
  file_cache <- jsonlite::read_json(system.file("file_cache.json", package="datamanager"))
  s3_lst <- list()
  for(file in file_cache) {
    s3_lst <- append(s3_lst, list(data_file(name=file$name,
                                            source=file$source,
                                            dir_path=file$dir_path,
                                            data_paths=file$data_paths,
                                            created_on=file$created_on)))
  }
  return(s3_lst)
}

in_file_cache <- function(name) {
  current <- file_cache()
  name_in_cache <- purrr::map_lgl(current, ~ .x$name==name)
  return(any(name_in_cache))
}
