#!/system/bin/sh

# init race conditions
if [ "$(getprop persist.neos.ssh)" = "1" ]; then
  export HOME=/data/data/com.termux/files/home
  export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib
  export PATH=/usr/local/bin:/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/sbin:/data/data/com.termux/files/usr/bin/applets:/bin:/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin
  exec /data/data/com.termux/files/usr/bin/sshd -D
fi
