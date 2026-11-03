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

| ⚠️ **Warning** |
| -------------- |
| This package is an early release and should be expected to change in the future. We don’t expect the functionality to change in significant ways. We intend to improve the installation process, consolidate packages and, potentially, convert Fortran routines to Python to avoid complexity in installation. |

synth_green GeoIPS Plugin
=========================

The synth_green package is a GeoIPS-compatible plugin, intended to be used within the GeoIPS ecosystem.
Please see the
[GeoIPS Documentation](https://github.com/NRLMMD-GEOIPS/geoips#readme)
for more information on the GeoIPS plugin architecture and base infrastructure.

Package Overview
-----------------

The synth_green package includes fortran code with Python wrappers for reading
in and using various ancillary datasets within GeoIPS.  This includes
elevation, rayleigh scattering look up tables, climatology, etc.


System Requirements
---------------------

* geoips >= 1.12.0
* Test data repos contained in $GEOIPS_TESTDATA_DIR for tests to pass.

IF REQUIRED: Install base geoips package
------------------------------------------------------------
SKIP IF YOU HAVE ALREADY INSTALLED BASE GEOIPS ENVIRONMENT

If GeoIPS Base is not yet installed, follow the
[installation instructions](https://github.com/NRLMMD-GEOIPS/geoips#installation)
within the geoips source repo documentation:

Install synth_green package
----------------------------
```bash
    # Assuming you followed the fully supported installation,
    # using $GEOIPS_PACKAGES_DIR and $GEOIPS_CONFIG_FILE:
    source $GEOIPS_CONFIG_FILE
    git clone https://github.com/NRLMMD-GEOIPS/fortran_utils $GEOIPS_PACKAGES_DIR/fortran_utils
    git clone https://github.com/NRLMMD-GEOIPS/synth_green $GEOIPS_PACKAGES_DIR/synth_green

    # NOTE: currently, fortran dependencies must be installed separately, initially
    # including in pyproject.toml resulted in incorrect installation paths.
    # More work required to get the pip dependencies working properly for fortran
    # installations via pyproject.toml with the poetry backend.
    pip install -e $GEOIPS_PACKAGES_DIR/fortran_utils
    pip install -e $GEOIPS_PACKAGES_DIR/synth_green
```

Test synth_green installation
-----------------------------
```bash

    # Ensure GeoIPS Python environment is enabled.

    # synth_green package is used for True Color and GeoColor
    # Test those products to test synth_green functionality
```
