#!/bin/bash -e

sudo sysctl -w net.ipv4.ip_forward=1

PHONE=$(ip route | grep 192.168.5.0/24 | cut -d' ' -f3)
INTERNET=$(ip route | grep 192.168.2.0/23 | cut -d' ' -f3)

FORWARD_NEW="FORWARD -o $INTERNET -i $PHONE -s 192.168.5.0/24 -m conntrack --ctstate NEW -j ACCEPT"
if ! sudo iptables -w -C $FORWARD_NEW > /dev/null 2>&1; then
  sudo iptables -w -A $FORWARD_NEW
fi

FORWARD_EST_REL="FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT"
if ! sudo iptables -w -C $FORWARD_EST_REL > /dev/null 2>&1; then
  sudo iptables -w -A $FORWARD_EST_REL
fi

POSTROUTING_MASQ="POSTROUTING -o $INTERNET -j MASQUERADE"
if ! sudo iptables -t nat -w -C $POSTROUTING_MASQ > /dev/null 2>&1; then
  sudo iptables -t nat -w -A $POSTROUTING_MASQ
fi

ssh phone "date -s '$(date)'"
ssh phone "route add default gw 192.168.5.1 && ndc network create 100 && ndc network interface add 100 eth0 && ndc resolver setnetdns 100 localdomain 8.8.8.8 8.8.4.4 && ndc network default set 100"
