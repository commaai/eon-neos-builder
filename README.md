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
./build_oneplus.sh
```

#### Build for LeEco LePro 3
```
./build_leeco.sh
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

### Make OTA update
```
./prepare_ota.sh
```

TODO
------

* Make the OTA support both OnePlus and LeEco

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

