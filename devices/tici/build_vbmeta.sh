#!/bin/bash -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
ROOT=$DIR/../..
TOOLS=$ROOT/tools/

android/out/host/linux-x86/bin/avbtool make_vbmeta_image --output $OUT/vbmeta.img \
  --algorithm SHA256_RSA4096 --key android/external/avb/test/data/testkey_rsa4096.pem \
  --include_descriptors_from_image $OUT/boot.img \
  --include_descriptors_from_image $OUT/dtbo.img \
  --include_descriptors_from_image $OUT/vendor.img \
  --generate_dm_verity_cmdline_from_hashtree $OUT/system.img\

# Print output message
GREEN="\033[0;32m"
NO_COLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
echo -e "${GREEN}Output: ${BOLD}$OUT/vbmeta.img${NORMAL}${NO_COLOR}"

