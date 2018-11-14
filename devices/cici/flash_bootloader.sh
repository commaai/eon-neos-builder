#!/bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd $DIR/bootloader/qdl
make -j$(nproc --all)

cd ../microsom
sudo ../qdl/qdl prog_ufs_firehose_8996_ddr.elf rawprogram.xml patch.xml
