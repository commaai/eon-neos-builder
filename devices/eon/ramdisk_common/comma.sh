#!/usr/bin/bash

# useful for not pissing off vim
mount -o remount,rw /

# run once (if zygote is restarted we might get here multiple times)
if mkdir /runonce; then
  echo "running once"
else
  exit 0
fi


# fix the messed up routes in android for eth0
# TODO: investigate this
ip rule add prio 100 from all lookup main

# disable the button lights
echo 0 > /sys/class/leds/button-backlight/max_brightness

# constrain everything but us to one cpu
echo 0 > /dev/cpuset/background/cpus
echo 0 > /dev/cpuset/system-background/cpus
echo 0 > /dev/cpuset/foreground/boost/cpus
echo 0 > /dev/cpuset/foreground/cpus

# setup CPU set for all android tasks
mkdir /dev/cpuset/android
echo 0 > /dev/cpuset/android/cpus
echo 0 > /dev/cpuset/android/mems

# migrate all tasks
while read i; do echo $i > /dev/cpuset/android/tasks; done < /dev/cpuset/tasks 2>/dev/null

# we get all the cores
mkdir /dev/cpuset/app
echo 0-3 > /dev/cpuset/app/cpus
echo 0 > /dev/cpuset/app/mems

echo $$ > /dev/cpuset/app/tasks
# (our parent, tmux, also gets all the cores)
echo $PPID > /dev/cpuset/app/tasks

if ! iptables -t mangle -w -C PREROUTING -i wlan0 -j TTL  --ttl-set 65 > /dev/null 2>&1; then
  iptables -t mangle -w -A PREROUTING -i wlan0 -j TTL --ttl-set 65
fi

if [ ! -f /persist/comma/id_rsa.pub ]; then
  mkdir -p /persist/comma

  openssl genrsa -out /persist/comma/id_rsa.tmp 2048 &&
    openssl rsa -in /persist/comma/id_rsa.tmp -pubout -out /persist/comma/id_rsa.tmp.pub &&
    sync &&
    mv /persist/comma/id_rsa.tmp /persist/comma/id_rsa &&
    mv /persist/comma/id_rsa.tmp.pub /persist/comma/id_rsa.pub &&
    chmod 755 /persist/comma/ &&
    chmod 744 /persist/comma/id_rsa &&
    sync
fi

rm -f /data/params/d/AthenadPid

while true; do
  if [ -f /data/data/com.termux/files/continue.sh ]; then
    exec /data/data/com.termux/files/continue.sh
  fi

  rm -f /data/data/ai.comma.plus.neossetup/installer
  am start -n ai.comma.plus.neossetup/.MainActivity
  while [ ! -f /data/data/ai.comma.plus.neossetup/installer ]; do
    echo "waiting for installer"
    sleep 1
  done

  chmod +x /data/data/ai.comma.plus.neossetup/installer
  /data/data/ai.comma.plus.neossetup/installer

  if [ $? -ne 0 ]; then
    echo "Installer failed"
    rm -f /data/data/com.termux/files/continue.sh
  fi
done
