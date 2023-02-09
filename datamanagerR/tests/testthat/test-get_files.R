test_that(
  desc = "in_file_cache() works",
  code = {
    # create a fake data_file S3 object and write to cache
    d <- data_file(name="test_name",
                   source="test_source",
                   dir_path="some/file/path",
                   data_paths=list("textfile.txt"="some/file/path/textfile.txt",
                                   "csvfile.csv"="some/file/path/csvfile.csv"),
                   created_on=Sys.time())
    # write to the cache; assign to d to silence the output
    update_file_cache(d, overwrite=TRUE)
    # check if in the cache
    expect_true(in_file_cache(d$name))
    # check that random name is not in the cache
    expect_false(in_file_cache("1% no one should be able to name a data_file this..."))
    # delete the fake data_file
    delete_data_file("test_name")
  }
)

test_that(
  desc = "file_cache() works",
  code = {
    cache <- file_cache()
    # should be a list
    expect_type(cache, "list")
    # a list of s3 "data_file" objects
    for(entry in cache) {
      expect_s3_class(entry, "data_file", exact=TRUE)
    }
  }
)

test_that(
  desc = "write_file_cache() works",
  code = {
    # get the current cache
    current <- file_cache()
    # Some files to add to the cache
    new_files <- list(
      data_file(name="test1",
                source="www.test.com",
                dir_path="User/test",
                data_paths=list("User/test/test.txt"),
                created_on="2023-02-03 18:29:42 GMT"),
      data_file(name="test2",
                source="www.test.com",
                dir_path="User/test",
                data_paths=list("User/test/test.txt"),
                created_on="2023-02-03 18:29:42 GMT")
      )
    # write the cache
    write_file_cache(append(current, new_files))
    # get altered cache
    alt_cache <- file_cache()
    # check new files are in there
    expect_true(all(new_files %in% alt_cache))
    # revert the cache to original
    write_file_cache(current)
  }
)

test_that(
  desc = "get_data_file() works",
  code = {
    # get the current cache
    current <- file_cache()
    # Some file to add to the cache
    new_file <- data_file(name="test1",
                          source="www.test.com",
                          dir_path="User/test",
                          data_paths=list("User/test/test.txt"),
                          created_on="2023-02-03 18:29:42 GMT")
    # write the cache
    write_file_cache(append(current, list(new_file)))
    # get the new test1 file
    file <- get_data_file("test1")
    # test that we got the file
    expect_true(all.equal(file, new_file, check.attributes=TRUE))
    # revert the cache to original
    write_file_cache(current)
  }
)

test_that(
  desc = "delete_data_file() works",
  code = {
    # get the current cache
    current <- file_cache()
    # Some file to add to the cache
    new_file <- data_file(name="test1",
                          source="www.test.com",
                          dir_path="User/test",
                          data_paths=list("User/test/test.txt"),
                          created_on="2023-02-03 18:29:42 GMT")
    # write the cache
    write_file_cache(append(current, list(new_file)))
    # make sure it added the file
    expect_true(in_file_cache("test1"))
    # try to delete it
    delete_data_file("test1")
    # make sure it has gone
    expect_false(in_file_cache("test1"))
  }
)

test_that(
  desc = "update_file_cache() works",
  code = {
    # Some file to add to the cache
    new_file <- data_file(name="test1",
                          source="www.test.com",
                          dir_path="User/test",
                          data_paths=list("User/test/test.txt"),
                          created_on="2023-02-03 18:29:42 GMT")
    # update cache with the new file
    update_file_cache(new_file)
    # check file now in cache
    expect_true(in_file_cache("test1"))
    # now delete the file
    delete_data_file("test1")
  }
)

test_that(
  desc = "data_file() works",
  code = {
    file <- data_file(name="test1",
                      source="www.test.com",
                      dir_path="User/test",
                      data_paths=list("User/test/test.txt"),
                      created_on="2023-02-03 18:29:42 GMT")
    # check it is a data_file s3 object
    expect_s3_class(file, "data_file", exact=TRUE)
    # manually create the data_file s3 object
    manual_file <- structure(list(name="test1",
                                  source="www.test.com",
                                  dir_path="User/test",
                                  data_paths=list("User/test/test.txt"),
                                  created_on="2023-02-03 18:29:42 GMT"),
                             class="data_file")
    expect_true(all.equal(file, manual_file, check.attributes=TRUE))
  }
)

# test_that(
#   desc = "create_data_file() works",
#   code = {
#     # the directory
#     dir = file.path(system.file("..", package="datamanager"), testthat::test_path("testdata"))
#     # a text file
#     text_file = file.path(dir, "test.txt")
#     # try to create a test file
#     create_data_file(name="test1",
#                      source="www.test.com",
#                      dir_path=dir,
#                      data_paths=list(text_file))
#     # check it now lives in the cache
#     current <- file_cache()
#     # make sure it added the file
#     expect_true(in_file_cache("test1"))
#     #  delete it
#     delete_data_file("test1", remove_all_files=FALSE)
#     # make sure it has gone
#     expect_false(in_file_cache("test1"))
#   }
# )

# test_that(
#   desc = "get_web_file() works",
#   code = {
#     # try to download a test file
#     web_file <- get_web_file(url  = "https://data.bris.ac.uk/datasets/pnoat8cxo0u52p6ynfaekeigi/pnoat8cxo0u52p6ynfaekeigi.zip",
#                              name = "test",
#                              verbose = FALSE)
#
#     # expected data_file
#     file <- data_file(name="test",
#                       source="https://data.bris.ac.uk/datasets/pnoat8cxo0u52p6ynfaekeigi/pnoat8cxo0u52p6ynfaekeigi.zip",
#                       dir_path=file.path(get_download_dirpath(), "test"),
#                       data_paths=list(
#                         `MRC IEU UK Biobank GWAS pipeline version 2.pdf` =  file.path(get_download_dirpath(), "test", "MRC IEU UK Biobank GWAS pipeline version 2.pdf"),
#                         pnoat8cxo0u52p6ynfaekeigi = file.path(get_download_dirpath(), "test", "pnoat8cxo0u52p6ynfaekeigi"),
#                         readme.txt = file.path(get_download_dirpath(), "test", "readme.txt")),
#                       created_on="2023-02-03 18:29:42 GMT")
#     # set the created on equal, as these won't match
#     file$created_on <- web_file$created_on
#     # test if the same
#     all.equal(web_file, file)
#     #  delete it
#     delete_data_file("test")
#     # make sure it has gone
#     expect_false(in_file_cache("test"))
#   }
# )
