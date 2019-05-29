NEOS Builder
======

This is the tool to build the operating system for your [EON Dashcam Development Kit](https://shop.comma.ai/products/eon-dashcam-devkit)

What is it?
------

* A kernel built outside the Android build system
* A minified version of Android
* Userspace from termux

### Prerequisite

* [Install git-lfs](https://github.com/git-lfs/git-lfs/wiki/Installation)
  * for large files such as toolchain.

Usage
------

### Building

```bash
cd devices/eon
./build_ramdisks.sh
./build_all.sh
```

Images are written to the `out` directory.

### Flashing Devices

Boot device to fastboot. With an EON Gold, hold Power+Volume Down. With an EON, hold Power+Volume Up.

```bash
cd devices/eon
./flash.sh
```

### Make OTA update

```bash
cd devices/eon
./prepare_ota.sh
```

Supported Devices
------
* [OnePlus 3T](https://www.oneplus.com/3t)
* [LeEco LePro 3](https://www.cnet.com/products/leeco-lepro-3/review/)

What works
-----
- [X] **Compute**
  - [X] GPU
  - [X] OpenCL
  - [X] DSP
- [X] **Sensors**
  - [X] GPS
  - [X] IMU
  - [X] Camera with visiond
  - [X] Audio
  - [X] Touchscreen
- [X] **Connectivity**
  - [X] Ethernet
  - [X] Radio
  - [X] Wi-FI
  - [X] Bluetooth
  - [X] Tethering

