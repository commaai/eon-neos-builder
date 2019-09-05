#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
if [ -z "$PHONE" ]; then
    PHONE=192.168.5.11
fi
chmod 600 "$DIR/id_rsa"
sshphone="ssh -i $DIR/id_rsa -p 8022 -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no"

# Copy finished /usr from phone to put in image
sudo rm -rf out/
mkdir -p out/data/data/com.termux/files/usr

# Run as root so we can keep user id and permissions
sudo rsync -Pac -e "$sshphone" $PHONE:/usr/ out/data/data/com.termux/files/usr
