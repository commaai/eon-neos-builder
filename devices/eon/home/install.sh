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

cd /tmp

# ------- Openvpn
VERSION="2.4.7"
wget --tries=inf -O openvpn-$VERSION.tar.gz https://github.com/OpenVPN/openvpn/archive/v$VERSION.tar.gz
tar xvf openvpn-v${VERSION}.tar.gz
pushd openvpn-$VERSION
autoreconf -i -v -f
./configure --disable-plugin-auth-pam --prefix=/usr
make -j4
make install
popd

# -------- Capnp stuff
VERSION=0.6.1
wget --tries=inf https://capnproto.org/capnproto-c++-${VERSION}.tar.gz
tar xvf capnproto-c++-${VERSION}.tar.gz

pushd capnproto-c++-${VERSION}
patch -p1 < ~/capnp.patch
CXXFLAGS="-fPIC -O2" ./configure --prefix=/usr
make -j4 install
popd

git clone https://github.com/commaai/c-capnproto.git
pushd c-capnproto
git submodule update --init --recursive
autoreconf -f -i -s
CFLAGS="-fPIC -O2" ./configure --prefix=/usr
gcc -O2 -c lib/capn-malloc.c
gcc -O2 -c lib/capn-stream.c
gcc -O2 -c lib/capn.c
ar rcs libcapn.a capn-malloc.o capn-stream.o capn.o
cp libcapn.a /usr/lib

make -j4 install
popd


# ----- zmq stuff
git clone --depth 1 -b v4.3.1 git://github.com/zeromq/libzmq.git libzmq
pushd libzmq
sed -i '461d' CMakeLists.txt
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make -j4
make install
popd

git clone --depth 1 -b v4.2.0 git://github.com/zeromq/czmq.git czmq
pushd czmq
./autogen.sh
CFLAGS=-I/usr LDFLAGS="-L/usr/lib64 -llog" PKG_CONFIG_PATH=/usr/lib64/pkgconfig ./configure --prefix=/usr
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


# Python stuff
cd $HOME
pip2 install pipenv

# Default python2
ln -s /usr/bin/python2 /usr/bin/python
cp /usr/bin/pip2 /usr/bin/pip

pipenv install --deploy --system
