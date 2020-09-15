#!/bin/bash

# NEOS_VERSION sets the /VERSION for the new build. This value MUST be updated
# for any change put into test/staging or production.

export NEOS_BUILD_VERSION="15"

# NEOS_BASE_FOR_USR sets the OTA image used for normal NEOS builds, where the
# Termux /system base binaries are copied from the production shipping OTA
# image instead of rebuilding from scratch. Ignored if CLEAN_USR=1.

export NEOS_BASE_FOR_USR="https://raw.githubusercontent.com/commaai/eon-neos/d22cfd2123e13fded340e6290eea8204c73ce9a2/update.json"


# NEOS_BASE_FOR_DASHCAM is used by build_dashcam_images.sh to set the base OTA
# image on which to build a dashcam-cached system image. These images are used
# in the Comma manufacturing process and also for PC desktop flashing. Before
# and after NEOS versions must match.

# TODO: this url can't be used for NEOS 14 because it's missing the focaltech touchscreen fix in the kernel
# export NEOS_BASE_FOR_DASHCAM="https://raw.githubusercontent.com/commaai/openpilot/dashcam-staging/installer/updater/update.json"
export NEOS_BASE_FOR_DASHCAM="$NEOS_BASE_FOR_USR"
