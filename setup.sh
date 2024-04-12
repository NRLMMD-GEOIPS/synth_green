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

#!/bin/bash

if [[ -z "$GEOIPS_PACKAGES_DIR" ]]; then
    echo "Must define GEOIPS_PACKAGES_DIR environment variable prior to setting up geoips packages"
    exit 1
fi

if [[ "$1" == "install" ]]; then

    tar -xzvf $GEOIPS_PACKAGES_DIR/synth_green/dat.tgz
    pip install -e $GEOIPS_PACKAGES_DIR/synth_green

else
    echo "UNRECOGNIZED COMMAND $1"
    exit 1
fi

