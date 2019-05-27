#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out

scp $OUT/boot.img phone:/tmp/boot.img
ssh phone "dd if=/tmp/boot.img of=/dev/block/platform/soc/624000.ufshc/by-name/boot bs=16M && reboot"

