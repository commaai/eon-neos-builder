NEOS Builder
======

This is the tool to build the operating system for your [EON](https://shop.comma.ai/products/eon-dashcam-devkit) or [Comma Two](https://comma.ai/shop/products/comma-two-devkit) dashcam development kit.

What is NEOS?
------

* A kernel built outside the Android build system
* A minified version of Android
* Userspace from termux

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

Usage
------

### Prerequisites

* An Ubuntu 16.04 build environment with at least 80GB of free disk space
* Install git and [git-lfs](https://github.com/git-lfs/git-lfs/wiki/Installation) to fetch build tools during `git clone`

### Building and Installing

See the device-specific instructions in `devices/eon/README.md`

