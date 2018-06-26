NEOS Builder
======

This is the tool to build the operating system for your [EON Dashcam Development Kit](https://shop.comma.ai/products/eon-dashcam-devkit)

What is it?
------

* A kernel built outside the Android build system
* A minified version of Android
* Userspace from termux

Usage
------

### Building
#### Build for OnePlus 3T
```
./build_android.sh
./build_kernel_oneplus.sh
./make_boot.sh oneplus
./make_recovery.sh oneplus
./make_system.sh
```

#### Build for LeEco LePro 3
```
./build_android.sh
./build_kernel_leeco.sh
./make_boot.sh leeco
./make_recovery.sh leeco
./make_system.sh
```

#### Build All
```
./build_all.sh
```

### Flashing Devices
#### Flash OnePlus 3T
```
./flash_oneplus.sh
```
#### Flash LeEco LePro 3
```
./flash_leeco.sh
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

