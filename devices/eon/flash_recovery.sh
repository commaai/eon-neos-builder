#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out

fastboot oem 4F500301 1>/dev/null 2>&1
fastboot flash boot $OUT/recovery.img
