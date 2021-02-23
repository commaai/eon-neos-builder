#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/..

QT_PACKAGE_VERSION=5.13.2
QT_PACKAGE_URL="https://ftp.osuosl.org/pub/blfs/conglomeration/qt5/qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz"

WORK_DIR=$ROOT/mindroid/qt-everywhere-src-${QT_PACKAGE_VERSION}

SYSROOT=/data/data/com.termux/files
TERMUX_PREFIX=$SYSROOT/usr
TERMUX_TOOLCHAIN=$ROOT/mindroid/termux-toolchain

cd $ROOT/mindroid

if [[ ! -d "$TERMUX_PREFIX" ]]; then
    echo "Termux sysroot is not populated or symlinked"
    exit 0
fi

if [[ ! -d "$TERMUX_TOOLCHAIN" ]]; then
    echo "Termux toolchain is not populated"
    exit 0
fi

### download/cleanup

rm -rf $WORK_DIR

wget -nc --tries=3 $QT_PACKAGE_URL
tar xf qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz

### patches

pushd $WORK_DIR
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.11.2_qtbase_src_network_kernel_qdnslookup_unix.cpp.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.11.2_qtbase_src_network_kernel_qhostinfo_unix.cpp.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtbase_src_gui_configure.json.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtbase_src_plugins_platforms_eglfs_deviceintegration_deviceintegration.pro.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtmultimedia_src_plugins_opensles_qopenslesaudioinput.cpp.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtmultimedia_src_plugins_opensles_qopenslesengine.cpp.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtmultimedia_src_plugins_plugins.pro.patch
popd

cp -rf $DIR/qt/qtbase $WORK_DIR

### toolchain

export PATH=$TERMUX_TOOLCHAIN/bin:$PATH

### configure
# ditch sysroot bleh

cd $WORK_DIR

./configure -v \
    -opensource \
    -confirm-license \
    --disable-rpath \
    -xplatform neos-cross \
    -sysroot "${SYSROOT}" \
    -no-gcc-sysroot \
    -prefix "/usr" \
    -docdir "/usr/share/doc/qt" \
    -headerdir "/usr/include/qt" \
    -archdatadir "/usr/lib/qt" \
    -datadir "/usr/share/qt" \
    -sysconfdir "/usr/etc/xdg" \
    -examplesdir "/usr/share/doc/qt/examples" \
    -plugindir "/usr/libexec/qt" \
    -force-pkg-config \
    -no-warnings-are-errors \
    -nomake examples \
    -nomake tests \
    -qt-pcre \
    -system-zlib \
    -qt-harfbuzz \
    -qt-libpng \
    -qt-libjpeg \
    -sql-sqlite \
    -ssl \
    -skip qtdeclarative

### cc build

make -j$(nproc) module-qtbase module-qtmultimedia
make module-qtbase-install_subtargets module-qtmultimedia-install_subtargets

### cc host tools

cd $WORK_DIR/qtbase

# save actual host tools
mkdir -p bin.host lib.host
cp -a bin/* bin.host
cp -a lib/{libQt5Bootstrap.a,libQt5Bootstrap.prl} lib.host

# remove host tools from prefix
find "bin" -mindepth 1 -exec rm -rf "${TERMUX_PREFIX}/{}" \;
rm -rf ${TERMUX_PREFIX}/lib/{libQt5Bootstrap.a,libQt5Bootstrap.prl}

# bootstrap
pushd ${WORK_DIR}/qtbase/src/tools/bootstrap
make clean
${WORK_DIR}/qtbase/bin/qmake -spec ${WORK_DIR}/qtbase/mkspecs/neos-cross
make -j$(nproc)
install -Dm644 ${WORK_DIR}/qtbase/lib/libQt5Bootstrap.a "${TERMUX_PREFIX}/lib/libQt5Bootstrap.a"
install -Dm644 ${WORK_DIR}/qtbase/lib/libQt5Bootstrap.prl "${TERMUX_PREFIX}/lib/libQt5Bootstrap.prl"
popd

for i in moc qlalr qvkgen rcc uic; do
    pushd ${WORK_DIR}/qtbase/src/tools/$i
    make clean
    ${WORK_DIR}/qtbase/bin/qmake -spec ${WORK_DIR}/qtbase/mkspecs/neos-cross
    sed -i "s@-lpthread@@g" Makefile
    make -j$(nproc)
    install -Dm700 "../../../bin/${i}" "${TERMUX_PREFIX}/bin/${i}"
    popd
done
unset i

# restore
cp -rf bin.host/* bin
cp -rf lib.host/{libQt5Bootstrap.a,libQt5Bootstrap.prl} lib

### post patches
find "${TERMUX_PREFIX}/lib" -type f -name '*.prl' \
    -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' "{}" \;

find "${TERMUX_PREFIX}/lib" -type f -name '*.prl' \
    -exec sed -i -e "s|${TERMUX_TOOLCHAIN}\/sysroot\/usr\/lib\/aarch64-linux-android\/24|/system\/lib64|g" "{}" \;

find "${TERMUX_PREFIX}/lib" -type f -name '*.pri' \
    -exec sed -i -e "s|${TERMUX_TOOLCHAIN}\/sysroot\/usr\/lib\/aarch64-linux-android\/24|/system\/lib64|g" "{}" \;

find "${TERMUX_PREFIX}/lib" -type f -name '*.cmake' \
    -exec sed -i -e "s|${TERMUX_TOOLCHAIN}\/sysroot\/usr\/lib\/aarch64-linux-android\/24|/system\/lib64|g" "{}" \;

find "${TERMUX_PREFIX}/lib" -type f -name '*.pc' \
    -exec sed -i -e "s|${TERMUX_TOOLCHAIN}\/sysroot\/usr\/lib\/aarch64-linux-android\/24|/system\/lib64|g" "{}" \;

find "${TERMUX_PREFIX}/lib" -type f -name '*.pc' \
    -exec sed -i -e "s|/usr\/lib\/libQt|/data\/data\/com.termux\/files\/usr\/lib|g" "{}" \;

find "${TERMUX_PREFIX}/lib" -iname \*.la -delete

sed -i \
    's|/lib/qt//mkspecs/neos-cross"|/lib/qt/mkspecs/neos"|g' \
    "${TERMUX_PREFIX}/lib/cmake/Qt5Core/Qt5CoreConfigExtrasMkspecDir.cmake"
