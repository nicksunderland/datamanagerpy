library(reticulate)
use_virtualenv("/Users/nicholassunderland/git/thesis/datamanager/my_env")
dmpy <- import("datamanagerpy")

dmpy$pkg_utils$set_config("download_dir_path", "/Users/nicholassunderland/git/thesis/datamanager/downloads")

dmpy$data_file$DataFile$delete("hermes")

data_file = dmpy$data_file$DataFile(
  name="hermes",
  source="https://personal.broadinstitute.org/ryank/HERMES_Jan2019_HeartFailure_summary_data.txt.zip")

df = data_file$get("HERMES_Jan2019_HeartFailure_summary_data.txt")

