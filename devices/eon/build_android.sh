#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/../..
TOOLS=$ROOT/tools

cd $DIR

# install build tools
if [[ -z "${SKIP_DEPS}" ]]; then
  source $DIR/install_deps.sh
fi

if [[ -z "${LIMIT_CORES}" ]]; then
  JOBS=$(nproc --all)
else
  JOBS=8
fi

# build mindroid
mkdir -p $DIR/mindroid/system
cd $DIR/mindroid/system
$TOOLS/repo init -u https://github.com/commaai/android.git -b mindroid
$TOOLS/repo sync -c -j$JOBS

export PATH=$PWD/bin:$PATH
(source build/envsetup.sh && breakfast oneplus3 && make -j$JOBS)
F