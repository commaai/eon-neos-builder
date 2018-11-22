#!/bin/bash -e
mkdir -p eon-neos

echo "copying files"
RECOVERY_HASH=$(sha256sum build/recoverynew.img | cut -c 1-64)
RECOVERY_LEN=$(wc -c build/recoverynew.img | awk '{print $1}')
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

NEOS_UPDATE_URL=${NEOS_UPDATE_URL:-https://commadist.azureedge.net/neosupdate}
tee eon-neos/update.json > /dev/null <<EOF
{
  "ota_url": "$NEOS_UPDATE_URL/ota-signed-$OTA_HASH.zip",
  "ota_hash": "$OTA_HASH",
  "recovery_url": "$NEOS_UPDATE_URL/recovery-$RECOVERY_HASH.img",
  "recovery_len": $RECOVERY_LEN,
  "recovery_hash": "$RECOVERY_HASH"
}
EOF 
