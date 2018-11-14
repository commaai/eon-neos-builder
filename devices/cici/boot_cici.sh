#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
OUT=$DIR/out

fastboot boot $OUT/boot.img
