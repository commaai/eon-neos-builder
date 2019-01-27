#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
BOARD="$1"

if [ -z "$BOARD" ]; then
  echo "default to inforce"
  BOARD="normsom"
else
  if [ -d "bootloader/$BOARD" ]; then
    echo "flashing $BOARD"
  else
    echo "no $BOARD support"
  fi
fi

cd $DIR

cd bootloader/qdl
make -j$(nproc --all)

cd ../$BOARD
sudo ../qdl/qdl prog_ufs_firehose_8996_ddr.elf rawprogram.xml patch.xml
