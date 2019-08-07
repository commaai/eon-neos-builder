#!/bin/bash -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out

export PATH=android/out/host/linux-x86/bin:$PATH

android/out/host/linux-x86/bin/mkdtimg create $OUT/dtbo.img --page_size=4096 $(find -L android_kernel_comma_sdm845/arch/arm64/boot/dts -name "*.dtbo")

android/out/host/linux-x86/bin/avbtool add_hash_footer --image $OUT/dtbo.img \
  --algorithm SHA256_RSA4096 --key android/external/avb/test/data/testkey_rsa4096.pem \
  --partition_name dtbo --partition_size 8388608
android/out/host/linux-x86/bin/avbtool add_hash_footer --image $OUT/boot.img \
  --algorithm SHA256_RSA4096 --key android/external/avb/test/data/testkey_rsa4096.pem \
  --partition_name boot --partition_size 67108864
echo "added hash footers"

#android/out/host/linux-x86/bin/avbtool erase_footer --image $OUT/system.img
#android/out/host/linux-x86/bin/avbtool add_hashtree_footer --image $OUT/system.img \
#  --algorithm SHA256_RSA4096 --key android/external/avb/test/data/testkey_rsa4096.pem \
#  --partition_name system --partition_size 3221225472
#echo "added hashtree footers"

android/out/host/linux-x86/bin/avbtool make_vbmeta_image --output $OUT/vbmeta.img \
  --algorithm SHA256_RSA4096 --key android/external/avb/test/data/testkey_rsa4096.pem \
  --include_descriptors_from_image $OUT/boot.img \
  --include_descriptors_from_image $OUT/dtbo.img \
  --include_descriptors_from_image $OUT/vendor.img \
  --generate_dm_verity_cmdline_from_hashtree $OUT/system.img
echo "made image"

