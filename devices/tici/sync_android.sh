#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/../..
TOOLS=$ROOT/tools

cd $DIR

mkdir -p $DIR/android
cd $DIR/android
$TOOLS/repo init -u git@github.com:commaai/android.git -b tici-8
$TOOLS/repo sync -c -j$(nproc --all) --force-sync

