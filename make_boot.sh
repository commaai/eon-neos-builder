#!/bin/bash
set -e

TARGET="$1"
if [ -z "$TARGET" ]; then
  echo "usage: $0 [oneplus|leeco]"
  exit 1
fi

mkdir -p build
pushd build
  mkdir -p boot
  pushd boot
    abootimg -x ../../android/system/out/target/product/oneplus3/boot.img

    # extract ramdisk
    sudo rm -rf ramdisk
    mkdir -p ramdisk

    pushd ramdisk
      gunzip -c ../initrd.img | sudo cpio -i

      echo "running populate ramdisk"
      sudo "$FIRMWARE_DIR"/populate_ramdisk.sh oneplus

      # repack ramdisk
      rm -f ../initrd_new.img.gz
      sudo find . | sudo cpio -o -H newc -O ../initrd_new.img
      gzip ../initrd_new.img
    popd

    # copy new kernel
    KERNEL=../../android_kernel_"$TARGET"_msm8996/arch/arm64/boot/Image.gz-dtb
    if [ -f $KERNEL ]; then
      echo "using external kernel with hash"
      sha1sum $KERNEL
      cp $KERNEL zImage
    fi

    # recreate bootimg
    abootimg --create ../bootnew.img.nonsecure -f "$FIRMWARE_DIR"/bootimg.cfg -k zImage -r initrd_new.img.gz
  popd

  sudo rm -rf boot

  # sign bootimg (stage 1)
  java -Xmx512M -jar ../tools/BootSignature.jar /boot bootnew.img.nonsecure "$FIRMWARE_DIR"/keys/verity.pk8 "$FIRMWARE_DIR"/keys/verity.x509.pem bootnew.img.nonsecure

  # sign bootimg (stage 2), unclear if this is needed
  openssl dgst -sha256 -binary bootnew.img.nonsecure > bootnew.img.sha256
  openssl rsautl -sign -in bootnew.img.sha256 -inkey "$FIRMWARE_DIR"/keys/qcom.key -out bootnew.img.sig
  dd if=/dev/zero of=bootnew.img.sig.padded bs=4096 count=1
  dd if=bootnew.img.sig of=bootnew.img.sig.padded conv=notrunc
  cat bootnew.img.nonsecure bootnew.img.sig.padded > bootnew.img
popd

