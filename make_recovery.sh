#!/bin/bash

mkdir -p build
pushd build
  cp recovery.img recoverynew.img.nonsecure

  # sign bootimg (stage 1)
  java -Xmx512M -jar ../tools/BootSignature.jar /boot recoverynew.img.nonsecure "$FIRMWARE_DIR"/keys/verity.pk8 "$FIRMWARE_DIR"/keys/verity.x509.pem recoverynew.img.nonsecure

  # sign bootimg (stage 2), unclear if this is needed
  openssl dgst -sha256 -binary recoverynew.img.nonsecure > recoverynew.img.sha256
  openssl rsautl -sign -in recoverynew.img.sha256 -inkey "$FIRMWARE_DIR"/keys/qcom.key -out recoverynew.img.sig
  dd if=/dev/zero of=recoverynew.img.sig.padded bs=4096 count=1
  dd if=recoverynew.img.sig of=recoverynew.img.sig.padded conv=notrunc
  cat recoverynew.img.nonsecure recoverynew.img.sig.padded > recoverynew.img

popd
