#!/bin/bash -e

PYTHON_MAJOR=`python -c "import platform; major, minor, patch = platform.python_version_tuple(); print(major)"`
if [ "$PYTHON_MAJOR" != "2" ]; then
  echo "Parts of the NEOS build still require \"python\" to be legacy Python 2!"
  echo "You may have pyenv shims in your PATH pointing to Python 3."
  exit
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

cd $DIR

./build_ramdisks.sh
./build_boot.sh
./build_recovery.sh
./build_system.sh
