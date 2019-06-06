#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
NEOSUPDATE="$DIR/neosupdate"

OTA_HASH=$(cat $NEOSUPDATE/update.json | jq -r .ota_hash)
RECOVERY_HASH=$(cat $NEOSUPDATE/update.json | jq -r .recovery_hash)

azcopy --source $NEOSUPDATE/ota-signed-$OTA_HASH.zip --destination https://commadist.blob.core.windows.net/neosupdate-staging/ota-signed-$OTA_HASH.zip  --dest-key $(az storage account keys list --account-name commadist --output tsv --query "[0].value")
azcopy --source $NEOSUPDATE/recovery-$RECOVERY_HASH.img --destination https://commadist.blob.core.windows.net/neosupdate-staging/recovery-$RECOVERY_HASH.img  --dest-key $(az storage account keys list --account-name commadist --output tsv --query "[0].value")
