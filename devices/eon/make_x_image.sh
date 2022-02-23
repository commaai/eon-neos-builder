#!/bin/bash -e

IMG_TYPE=$1
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
ROOT=$DIR/../..
TOOLS=$ROOT/tools

cd $DIR

export CROSS_COMPILE=$TOOLS/aarch64-linux-gnu-gcc/bin/aarch64-linux-gnu-
export ARCH=arm64

$TOOLS/extract_toolchains.sh
mkdir -p $OUT

if [ ! -d android_kernel_comma_msm8996 ]; then
  git clone https://github.com/commaai/android_kernel_comma_msm8996.git
fi

# Compile kernel
cd android_kernel_comma_msm8996
git fetch --all
#git checkout adb
git checkout d024641fc34e9fcff6f3c7a9102a08e873866701
make comma_defconfig
make -j$(nproc --all)
cd ..

# Assemble an unsigned boot.img
# for a bootloader-to-shell serial console, add these options to the kernel cmdline:
#   "earlycon=msm_hsl_uart,0x75b0000 console=ttyHSL0,115200n8 androidboot.console=ttyHSL0"
# serial UART is on the USB-C SBU1/SBU2 pins, TTL level 1.8V, 115200, 8n1, no flow control
# TX/RX will flip with USB orientation, be sure to connect ground or output will be noisy
# won't work through comma two uno daughterboard, attempting might damage your TTL device
$TOOLS/mkbootimg \
  --kernel android_kernel_comma_msm8996/out/arch/arm64/boot/Image.gz-dtb \
  --cmdline "cma=32M@0-0xffffffff androidboot.hardware=qcom androidboot.selinux=permissive" \
  --base 0x80000000 \
  --kernel_offset 0x8000 \
  --ramdisk_offset 0x2000000 \
  --tags_offset 0x100 \
  --pagesize 4096 \
  --ramdisk ramdisk-$IMG_TYPE.gz \
  --output unf-$IMG_TYPE.img

# Sign the boot.img
java -Xmx512M -jar $ROOT/tools/BootSignature.jar /$IMG_TYPE unf-$IMG_TYPE.img $ROOT/keys/verity.pk8 $ROOT/keys/verity.x509.pem unf-$IMG_TYPE.img
openssl dgst -sha256 -binary unf-$IMG_TYPE.img > unf-$IMG_TYPE.img.sha256
openssl rsautl -sign -in unf-$IMG_TYPE.img.sha256 -inkey $ROOT/keys/qcom.key -out unf-$IMG_TYPE.img.sig
dd if=/dev/zero of=unf-$IMG_TYPE.img.sig.padded bs=4096 count=1
dd if=unf-$IMG_TYPE.img.sig of=unf-$IMG_TYPE.img.sig.padded conv=notrunc
cat unf-$IMG_TYPE.img unf-$IMG_TYPE.img.sig.padded > $OUT/$IMG_TYPE.img

# Clean up
rm unf-$IMG_TYPE*

# Print output message
GREEN="\033[0;32m"
NO_COLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
echo -e "${GREEN}Output: ${BOLD}$OUT/$IMG_TYPE.img${NORMAL}${NO_COLOR}"
