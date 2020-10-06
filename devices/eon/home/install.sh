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

mkdir /tmp/build
cd /tmp/build

# -------- GCC
mkdir gcc
pushd gcc

BINUTILS=binutils-2.32
GCC=gcc-4.7.1
PREFIX=/usr

mkdir src
pushd src
wget --tries=inf ftp://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.bz2
tar -xf $BINUTILS.tar.bz2
popd

mkdir -p build/$BINUTILS
pushd build/$BINUTILS
../../src/$BINUTILS/configure --target=arm-none-eabi \
  --build=aarch64-unknown-linux-gnu \
  --prefix=$PREFIX --with-cpu=cortex-m4 \
  --with-mode=thumb \
  --disable-nls \
  --disable-werror
make -j4 all
make install
popd

mkdir -p src
pushd src
wget --tries=inf ftp://ftp.gnu.org/gnu/gcc/$GCC/$GCC.tar.bz2
tar -xf $GCC.tar.bz2
cd $GCC
contrib/download_prerequisites
popd

export PATH="$PREFIX/bin:$PATH"

mkdir -p build/$GCC
pushd build/$GCC
../../src/$GCC/configure --target=arm-none-eabi \
  --build=aarch64-unknown-linux-gnu \
  --disable-libssp --disable-gomp --disable-libstcxx-pch --enable-threads \
  --disable-shared --disable-libmudflap \
  --prefix=$PREFIX --with-cpu=cortex-m4 \
  --with-mode=thumb --disable-multilib \
  --enable-interwork \
  --enable-languages="c" \
  --disable-nls \
  --disable-libgcc
make -j4 all-gcc
make install-gcc
popd


# replace stdint.h with stdint-gcc.h for Android compatibility
mv $PREFIX/lib/gcc/arm-none-eabi/4.7.1/include/stdint-gcc.h $PREFIX/lib/gcc/arm-none-eabi/4.7.1/include/stdint.h

popd

# -------- Capnp stuff
VERSION=0.6.1

wget --tries=inf https://capnproto.org/capnproto-c++-${VERSION}.tar.gz
tar xvf capnproto-c++-${VERSION}.tar.gz

pushd capnproto-c++-${VERSION}

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
# ZMQ is build on the host, and copied in
# VERSION="4.2.0"
# wget --tries=inf https://github.com/zeromq/libzmq/releases/download/v$VERSION/zeromq-$VERSION.tar.gz
# tar xvf zeromq-$VERSION.tar.gz
# pushd zeromq-$VERSION
# CFLAGS="-fPIC -O2 -DCZMQ_HAVE_ANDROID=1" CXXFLAGS="-fPIC -O2 -DCZMQ_HAVE_ANDROID=1" ./configure --prefix=/usr --enable-drafts=no
# make -j4
# make install
# popd

# VERSION="4.0.2"
# wget --tries=inf https://github.com/zeromq/czmq/releases/download/v$VERSION/czmq-$VERSION.tar.gz
# tar xvf czmq-$VERSION.tar.gz
# pushd czmq-$VERSION
# CFLAGS="-fPIC -O2 -DCZMQ_HAVE_ANDROID=1" LDFLAGS="-llog" ./configure --prefix=/usr --enable-drafts=no --with-liblz4=no
# make -j4
# make install
# popd

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

# -------- Python
VERSION=3.8.2

wget --tries=inf https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tar.xz
tar xvf Python-${VERSION}.tar.gz

apt purge python

# compile
# TO-DO: specific profiling to cut down time
pushd Python-${VERSION}
CFLAGS="-O3 -fno-semantic-interposition" LDFLAGS="$LDFLAGS -fno-semantic=interposition" ./configure --prefix=/usr \
                          ac_cv_file__dev_ptmx=yes ac_cv_file__dev_ptc=no ac_cv_func_wcsftime=no \
                          ac_cv_posix_semaphores_enabled=no ac_cv_func_ftime=no ac_cv_func_faccessat=no \
                          ac_cv_func_gethostbyname_r=no ac_cv_func_linkat=no ac_cv_buggy_getaddrinfo=no \
                          ac_cv_func_sem_open=no ac_cv_func_sem_timedwait=no ac_cv_func_sem_getvalue=no ac_cv_func_sem_unlink=no \
                          --enable-loadable-sqlite-extensions \
                          --with-system-ffi --without-ensurepip \
                          --enable-optimizations --with-computed-gotos --with-lto
make -j4 EXTRA_CFLAGS="-03  -fno-semantic-interposition"
make EXTRA_CFLAGS="-03" install 
popd

# usr bin
pushd /usr/bin
ln -s idle3.8 idle
ln -s python3.8 python
ln -s python3.8-config python-config
ln -s pydoc3 pydoc
cd /usr/share/man/man1
ln -s python3.8.1 python.1
popd

# pip
if [ ! -f "$TERMUX_PREFIX/bin/pip" ]; then
    rm -Rf ${TERMUX_PREFIX}/lib/python${_MAJOR_VERSION}/site-packages/pip-*.dist-info
fi

python -m ensurepip --upgrade --default-pip

# ------- Install python packages
cd $HOME

pip install pipenv
pipenv install --deploy --system
