import os 
import json

def cache_path():
  path = os.path.join(os.path.dirname(__file__), "settings/cache.json")
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
      cache = []
  # return
  return cache

def in_cache(name: str) -> bool:
  # Does the name match any in the cache
  return any([x["name"]==name for x in cache()])

def cache_get(name: str) -> dict:
  if in_cache(name):
    c = [x for x in cache() if x["name"]==name]
    return c[0]
  else:
    return None

def delete_cache(name: str):
  try:
    if not in_cache(name):
      return
    # check with user
    answer = input(f'Warning: about to delete all files associated with: {name}.\nContinue? [y/n]: ')
    # delete
    if answer.lower() in ["y","yes"]:
      cache_alt = cache()
      idx = [index for index, entry in enumerate(cache_alt) if entry["name"]==name]
      remove = cache_alt.pop(idx[0])
      # try to delete the data files
      for fp in remove["data_paths"].values():
        os.remove(fp)
      # try to delete the folder
      os.rmdir(remove["dir_path"])
      # write out the new cache
      write_cache(cache_alt)
    elif answer.lower() in ["n","no"]:
      pass
    else:
      print("Incorrect input, try again.")
  
  except IndexError:
    print(f'Exception: DataFile not found in cache.')
  except OSError:
    print(f'Exception: problem deleting data files')
