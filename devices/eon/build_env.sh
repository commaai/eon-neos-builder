#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
export PATH="$DIR/bin:$PATH"

# sets /VERSION for the build
export NEOS_BUILD_VERSION="19.1"

# NEOS_BASE_FOR_USR sets the OTA image used for normal NEOS builds, where the
# Termux /system base binaries are copied from the production shipping OTA
# image instead of rebuilding from scratch. Ignored if CLEAN_USR set.
export NEOS_BASE_FOR_USR="https://raw.githubusercontent.com/commaai/openpilot/6a9514570cfeb2bf9b15929b2a6d3748ff2eb9a6/selfdrive/hardware/eon/neos.json"
