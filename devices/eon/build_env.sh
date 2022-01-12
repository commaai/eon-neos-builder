#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
export PATH="$DIR/bin:$PATH"

# sets /VERSION for the build
export NEOS_BUILD_VERSION="19"

# NEOS_BASE_FOR_USR sets the OTA image used for normal NEOS builds, where the
# Termux /system base binaries are copied from the production shipping OTA
# image instead of rebuilding from scratch. Ignored if CLEAN_USR set.
export NEOS_BASE_FOR_USR="https://raw.githubusercontent.com/commaai/eon-neos/0b090d11af27c227de81fc07a0bd02f313ea5421/update.json"
