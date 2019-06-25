#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
if [ -z "$PHONE" ]; then
    PHONE=192.168.5.11
fi

chmod 600 "$DIR/build_usr/id_rsa"
sshphone="ssh -i $DIR/build_usr/id_rsa -p 8022 -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no"

# connect to internet through computer
$sshphone $PHONE "route add default gw 192.168.5.1 && ndc network create 100 && ndc network interface add 100 eth0 && ndc resolver setnetdns 100 localdomain 8.8.8.8 8.8.4.4 && ndc network default set 100"

NOW=$(date)
$sshphone $PHONE "date -s '$NOW'"
