for name in dir():
    if not name.startswith('_'):
        del globals()[name]
import os
import sys
import importlib
for mod in [".".join(["datamanagerpy", n]) for n in ['data_file', 'cache', 'pkg_utils']]:
  if mod in sys.modules:
    importlib.reload(sys.modules[mod])
from datamanagerpy.data_file import *
from datamanagerpy.cache import *
from datamanagerpy.pkg_utils import *

set_config("download_dir_path", "/Users/nicholassunderland/git/thesis/datamanager/downloads")
DataFile.delete("hermes")
data_file = DataFile(
  name="hermes",
  source="https://personal.broadinstitute.org/ryank/HERMES_Jan2019_HeartFailure_summary_data.txt.zip")
df = data_file.get("HERMES_Jan2019_HeartFailure_summary_data.txt")

