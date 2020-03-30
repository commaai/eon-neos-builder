#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
NEOSUPDATE="$DIR/neosupdate"

OTA_HASH=$(cat $NEOSUPDATE/update.json | jq -r .ota_hash)
RECOVERY_HASH=$(cat $NEOSUPDATE/update.json | jq -r .recovery_hash)

DATA_ACCOUNT="commadist"
DATA_CONTAINER="neosupdate"

SAS_EXPIRY=$(date -u '+%Y-%m-%dT%H:%M:%SZ' -d '+1 hour')
DATA_SAS_TOKEN=$(az storage container generate-sas --as-user --auth-mode login --account-name $DATA_ACCOUNT --name $DATA_CONTAINER --https-only --permissions w --expiry $SAS_EXPIRY --output tsv)

azcopy cp $NEOSUPDATE/recovery-$RECOVERY_HASH.img "https://$DATA_ACCOUNT.blob.core.windows.net/$DATA_CONTAINER/recovery-$RECOVERY_HASH.img?$DATA_SAS_TOKEN"
azcopy cp $NEOSUPDATE/ota-signed-$OTA_HASH.zip "https://$DATA_ACCOUNT.blob.core.windows.net/$DATA_CONTAINER/ota-signed-$OTA_HASH.zip?$DATA_SAS_TOKEN"
