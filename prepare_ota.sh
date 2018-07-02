#!/bin/bash -e
mkdir -p eon-neos

echo "copying files"
RECOVERY_HASH=$(sha256sum build/recoverynew.img | cut -c 1-64)
cp -v build/recoverynew.img eon-neos/recovery-$RECOVERY_HASH.img
rm -f eon-neos/recovery.img
ln -s recovery-$RECOVERY_HASH.img eon-neos/recovery.img

echo "zipping ota"
(cd ota/ && zip -r ../eon-neos/ota.zip *)

echo "signing ota"
java -jar tools/signapk.jar -w keys/testkey.x509.pem keys/testkey.pk8 eon-neos/ota.zip eon-neos/ota-signed.zip
rm -f eon-neos/ota.zip
OTA_HASH=$(sha256sum eon-neos/ota-signed.zip | cut -c 1-64)
mv eon-neos/ota-signed.zip eon-neos/ota-signed-$OTA_HASH.zip
rm -f eon-neos/ota-signed-latest.zip
ln -s ota-signed-$OTA_HASH.zip eon-neos/ota-signed-latest.zip

