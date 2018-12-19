#!/system/bin/sh

if [ ! -f /EON ]; then
  # wait for usb to be enumerated...
  sleep 10

  # make device USB connections work
  # (NEOS kernel is OTG-mode on bootup otherwise to force it to detect the board)
  echo 1 > /sys/module/dwc3_msm/parameters/otg_switch
fi
