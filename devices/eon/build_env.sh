#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
export PATH="$DIR/bin:$PATH"

# sets /VERSION for the build
export NEOS_BUILD_VERSION="17"

# NEOS_BASE_FOR_USR sets the OTA image used for normal NEOS builds, where the
# Termux /system base binaries are copied from the production shipping OTA
# image instead of rebuilding from scratch. Ignored if CLEAN_USR set.
export NEOS_BASE_FOR_USR="https://raw.githubusercontent.com/commaai/eon-neos/0b090d11af27c227de81fc07a0bd02f313ea5421/update.json"

# NEOS_BASE_FOR_DASHCAM is used by build_dashcam_images.sh to set the base OTA
# image on which to build a dashcam-cached system image. These images are used
# in the Comma manufacturing process and also for PC desktop flashing. Before
# and after NEOS versions must match.

export NEOS_BASE_FOR_DASHCAM="https://raw.githubusercontent.com/commaai/openpilot/dashcam-staging/installer/updater/update.json"
