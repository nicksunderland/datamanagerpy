import validators
import os
import re
import requests
import zipfile
from datetime import datetime
import functools
import pathlib
import shutil
from tqdm.auto import tqdm
import cache
import pkg_utils

class DataFile(object):
  # constructor
  def __init__(self, name: str, source: str, overwrite: bool = False):
    # member variables (they are actually functions, the self._ will be the variables)
    
    if not cache.in_cache(name) or overwrite:
      cache.delete_cache(name)
      self.name = name
      self.source = source
      self.dir_path = name
      self._data_paths = self.parse_source(source)
      self.created = datetime.now()
      self.update_cache()
      print(self)
    else:
      existing = cache.cache_get(name)
      self._name = existing["name"]
      self._source = existing["source"]
      self._dir_path = existing["dir_path"]
      self._data_paths = existing["data_paths"]
      self._created = existing["created"]
      print("Loading from cache...")
      print(self)

  @property
  def name(self):
    return self._name    
  
  @name.setter
  def name(self, value):
    if(not isinstance(value, str)):
      raise ValueError("Exception: name must be a string")
    if(cache.in_cache(value)):
      raise DataFileExistsException("Exception: DataFile name already exists")
    self._name = value
    
  @property
  def source(self):
    return self._source

  @source.setter
  def source(self, value):
    if(not validators.url(value)):
      raise ValueError("Exception: source must be a valid URL (remember the https://)")
    self._source = value
  
  @property
  def dir_path(self):
    return self._dir_path
  
  @dir_path.setter
  def dir_path(self, value):
    dl_path = pkg_utils.get_config("download_dir_path")
    self._dir_path = os.path.join(dl_path, value)

  @property
  def data_paths(self):
    return self._data_paths
  
  def get(self, file_name: str):
    return self._data_paths[file_name]
  
  @property
  def created(self):
    return self._created
  
  @created.setter
  def created(self, value):
    self._created = value
    
  def __str__(self):
    paths = "\n            ".join([f'{n}: {p}' for n, p in self.data_paths.items()])
    return(
      f'DataFile object \n'
      f'---------------\n'
      f'Name:       {self.name}\n'
      f'Source:     {self.source}\n'
      f'Created:    {self.created}\n'
      f'Dir path:   {self.dir_path}\n'
      f'Data files: {paths}\n'
    )
  
  def update_cache(self):
    # New cache entry
    new_entry = {
      "name": self.name, 
      "source": self.source,
      "dir_path": self.dir_path,
      "data_paths": self.data_paths,
      "created": str(self.created)
    }
    # Get the cache, append and write out
    cache_alt = cache.cache()
    cache_alt.append(new_entry)
    cache.write_cache(cache_alt)

  def parse_source(self, source: str) -> dict:
    # source is a url
    if validators.url(source):
      data_dict = self.download(source)
      return data_dict
    else:
      print("source was not a url, not downloaded")

  def download(self, url: str) -> dict:
    try:
      # Get the file name from the source url
      file_name = os.path.basename(url)
      # Define the path to the downloads directory
      file_out = os.path.join(self.dir_path, file_name)
      file_out = pathlib.Path(file_out).expanduser().resolve()
      file_out.parent.mkdir(parents=True, exist_ok=False)
      # Set up the url request
      r = requests.get(url, stream=True, allow_redirects=True)
      r.raw.read = functools.partial(r.raw.read, decode_content=True)  # Decompress if needed
      # download from the url to the file 
      with tqdm.wrapattr(r.raw, "read", position=0, leave=True) as r_raw:
        with file_out.open("wb") as f:
          shutil.copyfileobj(r_raw, f)
      # extract zipped files
      if zipfile.is_zipfile(file_out):
        with zipfile.ZipFile(file_out,"r") as z:
          z.extractall(self.dir_path)
        #delete the zip file
        os.remove(file_out)
      # flatten the directory
      pkg_utils.flatten(self.dir_path)
      # return the paths as a dot accessible dictionary
      file_dict = {f: os.path.join(self.dir_path, f) 
                      for f in os.listdir(self.dir_path) 
                      if os.path.isfile(os.path.join(self.dir_path, f))}
      return file_dict

    except FileExistsError as e:
      print("The directory for this download already exists; delete or rename")
      print(e)

  @staticmethod
  def delete(name: str):
    cache.delete_cache(name)


class DataFileExistsException(Exception):
    "Raised when the DataFile name given exists in the cache"
    pass
