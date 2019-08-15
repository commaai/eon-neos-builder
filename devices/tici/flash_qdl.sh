#!/bin/bash
if [ ! -d qdl ]; then
  git clone https://git.linaro.org/landing-teams/working/qualcomm/qdl.git
  cd qdl
  make
  cd ..
fi
cd ufs
../qdl/qdl prog_firehose_ddr.elf rawprogram.xml patch.xml

