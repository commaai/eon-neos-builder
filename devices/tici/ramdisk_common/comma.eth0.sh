#!/system/bin/sh
DHCP=$(getprop persist.neos.dhcp)
IP=$(getprop persist.neos.ip)

if [ "$DHCP" = "1" ]; then
    /system/bin/ifconfig eth0 0.0.0.0 0.0.0.0
    /system/bin/dhcpcd -ABKLG eth0
elif [ ! -z $IP ]; then
    /system/bin/ifconfig eth0 $IP netmask 255.255.255.0
else
    /system/bin/ifconfig eth0 192.168.5.11 netmask 255.255.255.0
fi
