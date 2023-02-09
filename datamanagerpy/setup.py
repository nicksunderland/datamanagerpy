import os
from setuptools import setup

# Utility function to read the README file.
# Used for the long_description.  It's nice, because now 1) we have a top level
# README file and 2) it's easier to type in the README file than to put a raw
# string in below ...
def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

setup(
    name = "datamanagerpy",
    version = "0.0.1",
    author = "Nicholas Sunderland",
    author_email = "nicholas.sunderland@gmail.com",
    description = ("A package to manage data downloads"),
    license = "MIT",
    keywords = "data management downloads",
    #url = "http://packages.python.org/an_example_pypi_project",
    packages=['datamanagerpy', 'tests'],
    package_dir={'datamanagerpy': 'datamanagerpy'},
    package_data={'datamanagerpy': ['settings/*.json']},
    long_description=read('README.md'),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
)
