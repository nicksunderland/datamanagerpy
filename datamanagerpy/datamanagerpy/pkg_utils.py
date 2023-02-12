import os
import json
import shutil
import importlib_resources

def get_config(value) -> str:
  # The path to the config file
  config_file_path = importlib_resources.files('datamanagerpy').joinpath('settings/config.json')
  # Read it
  with open(config_file_path, 'r') as f:
    config = json.load(f)
  # Return the value
  return config[value]

def set_config(key, value) -> str:
  # The path to the config file
  config_file_path = importlib_resources.files('datamanagerpy').joinpath('settings/config.json')
  # Read it
  with open(config_file_path, 'r') as f:
    config = json.load(f)
  # Set the value
  config[key] = value
  # write out
  with open(config_file_path, 'w') as json_file: 
    json.dump(config, json_file, indent="\t")




def flatten(directory):
    for dirpath, _, filenames in os.walk(directory, topdown=False):
        for filename in filenames:
            i = 0
            source = os.path.join(dirpath, filename)
            target = os.path.join(directory, filename)

            while os.path.exists(target):
                i += 1
                file_parts = os.path.splitext(os.path.basename(filename))

                target = os.path.join(
                    directory,
                    file_parts[0] + "_" + str(i) + file_parts[1],
                )
            shutil.move(source, target)
            
        if dirpath != directory:
            os.rmdir(dirpath)
            
