library(devtools)
library(reticulate)
load_all()
source_python(system.file("python", "DataFile.py", package="datamanager"))



data_file <- DataFile("myfile", "www.google.com")
data_file$name









#setting up directory path for downloads
get_download_dirpath()
set_download_dirpath(system.file("extdata", package="datamanager"))

#looking at the file cache
file_cache()

#create a file manually
dir_path = "/Users/nicholassunderland/Downloads/testing"
dir.create(dir_path)
path = "/Users/nicholassunderland/Downloads/testing/testing.txt"
fileConn<-file(path)
writeLines(c("Hello","World"), fileConn)
close(fileConn)
f <- create_data_file(name="testing",
                      source="made up",
                      dir_path=dir_path,
                      data_paths=setNames(as.list(path), basename(path)),
                      overwrite=TRUE)

#has it added to the cache
file_cache()

#get the file
f_obj <- get_data_file(name="testing")
f_obj

# check the file is in the cache
in_file_cache("testing")

# check a random name is NOT in the cache
in_file_cache("notfound")

# delete the file
delete_data_file(name="testing")

# check it no longer exists
in_file_cache("testing")

# some download stuff e.g. the HERMES summary statistics
hermes_url <- "https://personal.broadinstitute.org/ryank/HERMES_Jan2019_HeartFailure_summary_data.txt.zip"

f <- get_web_file(hermes_url, "hermes_summary_stats", FALSE)
f$data_paths$HERMES_Jan2019_HeartFailure_summary_data.txt


