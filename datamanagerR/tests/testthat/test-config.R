test_that(
  desc = "set_download_dirpath() works",
  code = {
    # The path to the config file
    config_fp <- system.file("config.json", package="datamanager")
    # read the current config settings to a list
    config <- jsonlite::read_json(config_fp)
    # the download directory path
    current_path <- config$download_path
    # create and set to some test folder
    test_dl_path <- file.path(system.file("..", package="datamanager"), testthat::test_path())
    # set
    set_download_dirpath(test_dl_path, verbose=FALSE)
    # read the path back from the config file
    config_alt <- jsonlite::read_json(config_fp)
    # check this is correct
    expect_equal(test_dl_path, config_alt$download_path)
    # change the path back to what it was
    jsonlite::write_json(config, config_fp, auto_unbox=TRUE, pretty=TRUE)
  }
)

test_that(
  desc = "get_download_dirpath() works",
  code = {
    # path to the local config file
    config_fp <- system.file("config.json", package="datamanager")
    # read the current config settings to a list
    config <- jsonlite::read_json(config_fp)
    # the download path
    dl_path <- config$download_path
    # test that this is the same as the get_download_dirpath() function
    expect_equal(dl_path, get_download_dirpath())
  }
)
