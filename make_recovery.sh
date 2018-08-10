#!/bin/bash

TARGET="$1"
if [ -z "$TARGET" ]; then
  echo "usage: $0 [oneplus|leeco]"
  exit 1
fi

FIRMWARE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$FIRMWARE_DIR"

mkdir -p build
pushd build

  mkdir -p recovery
  pushd recovery
    abootimg -x "$FIRMWARE_DIR"/mindroid/system/out/target/product/oneplus3/recovery.img

    # copy new kernel
    KERNEL="$FIRMWARE_DIR"/android_kernel_"$TARGET"_msm8996/out/arch/arm64/boot/Image.gz-dtb
    if [ -f $KERNEL ]; then
      echo "using external kernel with hash"
      sha1sum $KERNEL
      cp $KERNEL zImage
    fi

    # recreate bootimg
    abootimg --create ../recoverynew.img.nonsecure -f "$FIRMWARE_DIR"/bootimg.cfg -k zImage -r initrd.img
  popd

  # sign bootimg (stage 1)
  java -Xmx512M -jar ../tools/BootSignature.jar /boot recoverynew.img.nonsecure "$FIRMWARE_DIR"/keys/verity.pk8 "$FIRMWARE_DIR"/keys/verity.x509.pem recoverynew.img.nonsecure

  # sign bootimg (stage 2), unclear if this is needed
  openssl dgst -sha256 -binary recoverynew.img.nonsecure > recoverynew.img.sha256
  openssl rsautl -sign -in recoverynew.img.sha256 -inkey "$FIRMWARE_DIR"/keys/qcom.key -out recoverynew.img.sig
  dd if=/dev/zero of=recoverynew.img.sig.padded bs=4096 count=1
  dd if=recoverynew.img.sig of=recoverynew.img.sig.padded conv=notrunc
  cat recoverynew.img.nonsecure recoverynew.img.sig.padded > recoverynew_$TARGET.img
popd

