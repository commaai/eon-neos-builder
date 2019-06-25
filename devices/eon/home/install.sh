#!/usr/bin/env bash
set -e

while true; do
    ping -c 1 8.8.8.8 && break
    sleep 1
done

mount -o remount,rw /system

# Execute all apt postinstall scripts
chmod +x /usr/var/lib/dpkg/info/*.postinst
find /usr/var/lib/dpkg/info -type f  -executable -exec sh -c 'exec "$1"' _ {} \;
chmod +x /usr/var/lib/dpkg/info/*.prerm

# Fix arm-none-eabi-gcc
# TODO: build from scratch
pushd /usr/local/bin
patchelf --add-needed /usr/lib/libandroid-support.so arm-none-eabi*
popd

pushd /usr/local/libexec/gcc/arm-none-eabi/4.7.1
patchelf --add-needed /usr/lib/libandroid-support.so cc1
patchelf --add-needed /usr/lib/libandroid-support.so collect2
patchelf --add-needed /usr/lib/libandroid-support.so lto1
patchelf --add-needed /usr/lib/libandroid-support.so lto-wrapper
popd


mkdir /tmp/build
cd /tmp/build


# -------- Capnp stuff
# Version 0.7.0 doesnt work with pycapnp for some reason. TODO: Figure out why
# VERSION=0.7.0
VERSION=0.6.1

wget --tries=inf https://capnproto.org/capnproto-c++-${VERSION}.tar.gz
tar xvf capnproto-c++-${VERSION}.tar.gz

pushd capnproto-c++-${VERSION}

# Patch for 0.7.0
# sed -i '399s/#if __APPLE__ || __CYGWIN__/#if __APPLE__ || __CYGWIN__ || 1/' src/kj/filesystem-disk-unix.c++

# Patch for 0.6.1
patch -p1 < ~/capnp.patch
CXXFLAGS="-fPIC -O2" ./configure --prefix=/usr
make -j4 install
popd

git clone https://github.com/commaai/c-capnproto.git
pushd c-capnproto
git submodule update --init --recursive
CFLAGS="-fPIC -O2" autoreconf -f -i -s
CFLAGS="-fPIC -O2" ./configure --prefix=/usr
gcc -fPIC -O2 -c lib/capn-malloc.c
gcc -fPIC -O2 -c lib/capn-stream.c
gcc -fPIC -O2 -c lib/capn.c
ar rcs libcapn.a capn-malloc.o capn-stream.o capn.o
cp libcapn.a /usr/lib

make -j4 install
popd


# ----- libzmq
VERSION="4.2.0"
wget --tries=inf https://github.com/zeromq/libzmq/releases/download/v$VERSION/zeromq-$VERSION.tar.gz
tar xvf zeromq-$VERSION.tar.gz
pushd zeromq-$VERSION
CFLAGS="-fPIC -O2 -DCZMQ_HAVE_ANDROID=1" CXXFLAGS="-fPIC -O2 -DCZMQ_HAVE_ANDROID=1" ./configure --prefix=/usr --enable-drafts=no
make -j4
make install
popd

VERSION="4.0.2"
wget --tries=inf https://github.com/zeromq/czmq/releases/download/v$VERSION/czmq-$VERSION.tar.gz
tar xvf czmq-$VERSION.tar.gz
pushd czmq-$VERSION
CFLAGS="-fPIC -O2 -DCZMQ_HAVE_ANDROID=1" LDFLAGS="-llog" ./configure --prefix=/usr --enable-drafts=no --with-liblz4=no
make -j4
make install
popd

# ---- Eigen
wget --tries=inf http://bitbucket.org/eigen/eigen/get/3.3.7.tar.bz2
mkdir eigen
tar xjf 3.3.7.tar.bz2
pushd eigen-eigen-323c052e1731
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make install
popd

# --- Libusb
wget --tries=inf https://github.com/libusb/libusb/releases/download/v1.0.22/libusb-1.0.22.tar.bz2
tar xjf libusb-1.0.22.tar.bz2
pushd libusb-1.0.22
./configure --prefix=/usr --disable-udev
make -j4
make install
popd

# ------- tcpdump
VERSION="4.9.2"
wget --tries=inf https://www.tcpdump.org/release/tcpdump-$VERSION.tar.gz
tar xvf tcpdump-$VERSION.tar.gz
pushd tcpdump-$VERSION
./configure --prefix=/usr
make -j4
make install
popd

# ------- Openvpn
VERSION="2.4.7"
wget --tries=inf -O openvpn-v$VERSION.tar.gz https://github.com/OpenVPN/openvpn/archive/v$VERSION.tar.gz
tar xvf openvpn-v${VERSION}.tar.gz
pushd openvpn-$VERSION
autoreconf -i -v -f
LDFLAGS="-L/usr/lib64 -llog" ./configure --disable-plugin-auth-pam --prefix=/usr
make -j4
make install
popd

# ----- DFU util 0.8
wget --tries=inf http://dfu-util.sourceforge.net/releases/dfu-util-0.8.tar.gz
tar xvf dfu-util-0.8.tar.gz
pushd dfu-util-0.8
./configure --prefix=/usr
make -j4
make install
popd

# ----- Nload
wget --tries=inf -O nload-v0.7.4.tar.gz https://github.com/rolandriegel/nload/archive/v0.7.4.tar.gz
tar xvf nload-v0.7.4.tar.gz
pushd nload-0.7.4
bash run_autotools
./configure --prefix=/usr
make -j4
make install
popd


# Cleanup
cd $HOME
rm -rf /tmp/build

# Python stuff
pip2 install pipenv

# Default python2
rm /usr/bin/python
ln -s /usr/bin/python2 /usr/bin/python
cp /usr/bin/pip2 /usr/bin/pip

pipenv install --deploy --system
