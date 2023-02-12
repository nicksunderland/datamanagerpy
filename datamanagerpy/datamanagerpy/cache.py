import os 
import json
import shutil
import importlib_resources


def cache_path():
  path = importlib_resources.files('datamanagerpy').joinpath('settings/cache.json')
  return path

def write_cache(cache_in):
  with open(cache_path(), 'w') as json_file: 
    json.dump(cache_in, json_file, indent="\t")

def cache() -> list:
  # Read the cache
  with open(cache_path(), 'r') as f:
    try:
      cache = json.load(f)
    except ValueError:
      cache = {}
  # return
  return cache

def cache_get(name: str) -> dict:
  try:
    return cache()[name]
  except KeyError:
    return None

def delete_cache(name: str):
  try:
    if name not in cache():
      return
    # check with user
    answer = input(f'Warning: about to delete all files associated with: {name}.\nContinue? [y/n]: ')
    # delete
    if answer.lower() in ["y","yes"]:
      # delete from the cache file
      cache_alt = cache()
      remove = cache_alt[name]
      del cache_alt[name]
      # try to delete the data folder and files
      shutil.rmtree(remove["dir_path"], ignore_errors=True)
      # write out the new cache
      write_cache(cache_alt)
    elif answer.lower() in ["n","no"]:
      pass
    else:
      print("Incorrect input, try again.")
  
  except KeyError as e:
    print(f'Exception: DataFile not found in cache.')
    print(e)
  except OSError as e:
    print(f'Exception: problem deleting data files')
    print(e)
