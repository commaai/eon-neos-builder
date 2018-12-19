#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

cd $DIR

./build_boot.sh
./build_recovery.sh
./build_system.sh
