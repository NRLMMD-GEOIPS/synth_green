#!/bin/env python

# # # Distribution Statement A. Approved for public release. Distribution unlimited.
# # #
# # # Author:
# # # Naval Research Laboratory, Marine Meteorology Division
# # #
# # # This program is free software: you can redistribute it and/or modify it under
# # # the terms of the NRLMMD License included with this program. This program is
# # # distributed WITHOUT ANY WARRANTY; without even the implied warranty of
# # # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the included license
# # # for more details. If you did not receive the license, for more information see:
# # # https://github.com/U-S-NRL-Marine-Meteorology-Division/

"""Build dependencies."""

from subprocess import run
from os.path import dirname
from pathlib import Path


def run_untar(setup_kwargs):
    """Build dependencies."""
    retval = run(["tar", "-xzvf", Path(dirname(__file__), "dat.tgz")])
    if retval.returncode != 0:
        exit(retval.returncode)
    return setup_kwargs


def run_make(setup_kwargs):
    """Build dependencies."""
    retval = run(["make", "-C", dirname(__file__)])
    if retval.returncode != 0:
        exit(retval.returncode)
    return setup_kwargs


if __name__ == "__main__":
    run_make({})
    run_untar({})
