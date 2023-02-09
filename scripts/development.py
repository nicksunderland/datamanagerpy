import os
import sys
import importlib
for mod in [".".join(["datamanagerpy", n]) for n in ['data_file', 'cache', 'pkg_utils']]:
  if mod in sys.modules:
    importlib.reload(sys.modules[mod])
from datamanagerpy.data_file import *

#set_config("download_dir_path", "/Users/nicholassunderland/git/thesis/datamanager/downloads")

DataFile.delete("hermes")

data_file = DataFile(
  name="hermes",
  source="https://personal.broadinstitute.org/ryank/HERMES_Jan2019_HeartFailure_summary_data.txt.zip")

data_file.get("HERMES_Jan2019_HeartFailure_summary_data.txt")

