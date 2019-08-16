#!/bin/bash -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
ROOT=$DIR/../..
TOOLS=$ROOT/tools
IMG_TYPE=boot

cd "$DIR"

#BOOT_RAMDISK="android/out/target/product/sdm845/ramdisk.img"
#[ ! -f $BOOT_RAMDISK ] && ./build_android.sh

if [ ! -d android_kernel_comma_sdm845 ]; then
  git clone git@github.com:commaai/android_kernel_comma_sdm845.git --branch msm --depth 1
fi

#export CROSS_COMPILE=$TOOLS/aarch64-linux-gnu-gcc/bin/aarch64-linux-gnu-
export CROSS_COMPILE=../android/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export ARCH=arm64

$TOOLS/extract_toolchains.sh
mkdir -p $OUT

# Compile kernel
cd android_kernel_comma_sdm845
git pull
# the DTC from the Android tree supports "-@"
# TODO: move it into the kernel for true standalone build
DTC="../android/out/host/linux-x86/bin/dtc"
UFDT="../android/out/host/linux-x86/bin/ufdt_apply_overlay_host"
make DTC_EXT=$DTC DTC_OVERLAY_TEST_EXT=$UFDT CONFIG_BUILD_ARM64_DT_OVERLAY=y sdm845_defconfig
make DTC_EXT=$DTC DTC_OVERLAY_TEST_EXT=$UFDT CONFIG_BUILD_ARM64_DT_OVERLAY=y -j$(nproc --all)
cd ..

# Assemble an unsigned boot.img

# boot.img
android/out/host/linux-x86/bin/mkbootimg \
  --kernel android_kernel_comma_sdm845/arch/arm64/boot/Image.gz-dtb \
  --cmdline "console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0xA84000 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.selinux=permissive video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 service_locator.enable=1 swiotlb=2048 androidboot.configfs=true androidboot.usbcontroller=a600000.dwc3 buildvariant=userdebug" \
  --base 0x80000000 \
  --kernel_offset 0x8000 \
  --tags_offset 0x100 \
  --pagesize 4096 \
  --os_version 8.1 --os_patch_level 2018-06-20 \
  --output $OUT/boot.img

# the key to making keymaster happy is *not* signing, but adding the hash. thundercomm specific
android/out/host/linux-x86/bin/avbtool add_hash_footer --image $OUT/boot.img \
  --partition_name boot --partition_size 0x04000000

# dtbo
android/out/host/linux-x86/bin/mkdtimg create $OUT/dtbo.img --page_size=4096 $(find -L android_kernel_comma_sdm845/arch/arm64/boot/dts -name "*.dtbo")

android/out/host/linux-x86/bin/avbtool add_hash_footer --image $OUT/dtbo.img \
  --partition_name dtbo --partition_size 0x0800000

