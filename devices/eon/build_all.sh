#!/bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

$DIR/build_boot.sh
$DIR/build_recovery.sh
$DIR/build_system.h
