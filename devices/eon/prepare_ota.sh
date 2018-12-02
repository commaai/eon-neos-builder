#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

TOOLS="$DIR/../../tools"
KEYS="$DIR/../../keys"

OTA="$DIR/ota"
NEOSUPDATE="$DIR/neosupdate"
RECOVERY_IMAGE="$DIR/out/recovery.img"
NEOS_UPDATE_URL=${NEOS_UPDATE_URL:-https://commadist.azureedge.net/neosupdate}
NEOS_STAGING_UPDATE_URL=${NEOS_STAGING_UPDATE_URL:-https://commadist.blob.core.windows.net/neosupdate-staging}
NEOS_LOCAL_UPDATE_URL=${NEOS_LOCAL_UPDATE_URL:-http://192.168.5.1:8000/neosupdate}

mkdir -p $NEOSUPDATE

echo "copying files"
RECOVERY_HASH=$(sha256sum $RECOVERY_IMAGE | cut -c 1-64)
RECOVERY_LEN=$(wc -c $RECOVERY_IMAGE | awk '{print $1}')
cp -v $RECOVERY_IMAGE $NEOSUPDATE/recovery-$RECOVERY_HASH.img

echo "zipping ota"
(cd $OTA && zip -r $NEOSUPDATE/ota.zip *)

echo "signing ota"
java -jar $TOOLS/signapk.jar -w $KEYS/testkey.x509.pem $KEYS/testkey.pk8 $NEOSUPDATE/ota.zip $NEOSUPDATE/ota-signed.zip
rm -f $NEOSUPDATE/ota.zip
OTA_HASH=$(sha256sum $NEOSUPDATE/ota-signed.zip | cut -c 1-64)
mv $NEOSUPDATE/ota-signed.zip $NEOSUPDATE/ota-signed-$OTA_HASH.zip
rm -f $NEOSUPDATE/ota-signed-latest.zip
ln -s ota-signed-$OTA_HASH.zip $NEOSUPDATE/ota-signed-latest.zip

tee $NEOSUPDATE/update.json > /dev/null <<EOM
{
  "ota_url": "$NEOS_UPDATE_URL/ota-signed-$OTA_HASH.zip",
  "ota_hash": "$OTA_HASH",
  "recovery_url": "$NEOS_UPDATE_URL/recovery-$RECOVERY_HASH.img",
  "recovery_len": $RECOVERY_LEN,
  "recovery_hash": "$RECOVERY_HASH"
}
EOM

tee $NEOSUPDATE/update.staging.json > /dev/null <<EOM
{
  "ota_url": "$NEOS_STAGING_UPDATE_URL/ota-signed-$OTA_HASH.zip",
  "ota_hash": "$OTA_HASH",
  "recovery_url": "$NEOS_STAGING_UPDATE_URL/recovery-$RECOVERY_HASH.img",
  "recovery_len": $RECOVERY_LEN,
  "recovery_hash": "$RECOVERY_HASH"
}
EOM

tee $NEOSUPDATE/update.local.json > /dev/null <<EOM
{
  "ota_url": "$NEOS_LOCAL_UPDATE_URL/ota-signed-$OTA_HASH.zip",
  "ota_hash": "$OTA_HASH",
  "recovery_url": "$NEOS_LOCAL_UPDATE_URL/recovery-$RECOVERY_HASH.img",
  "recovery_len": $RECOVERY_LEN,
  "recovery_hash": "$RECOVERY_HASH"
}
EOM

