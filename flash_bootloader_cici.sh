#!/bin/bash
cd bootloader/qdl
make
cd ../prebuilt
../qdl/qdl prog_ufs_firehose_8996_ddr.elf rawprogram.xml patch.xml

