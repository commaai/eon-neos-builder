#!/bin/bash
# in sync with commaai/termux-packages, scripts/build/termux_step_setup_toolchain.sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/..

NDK=/tmp/ndk
TERMUX_PREFIX=/data/data/com.termux/files/usr
TERMUX_ANDROID_HOME=/data/data/com.termux/files/home
TERMUX_PKG_API_LEVEL=24
TERMUX_NDK_VERSION=20
TERMUX_HOST_PLATFORM=aarch64-linux-android
TERMUX_STANDALONE_TOOLCHAIN=$ROOT/mindroid/termux-toolchain
_TERMUX_TOOLCHAIN_TMPDIR=/tmp/termux-toolchain
TERMUX_ARCH=aarch64

rm -rf $NDK $TERMUX_STANDALONE_TOOLCHAIN $_TERMUX_TOOLCHAIN_TMPDIR
mkdir -p $NDK $TERMUX_STANDALONE_TOOLCHAIN $_TERMUX_TOOLCHAIN_TMPDIR
cd /tmp

###

mkdir -p $NDK
cd $NDK/..
rm -Rf $(basename $NDK)
echo "Downloading android ndk..."
curl --fail --retry 3 -o ndk.zip \
    https://dl.google.com/android/repository/android-ndk-r${TERMUX_NDK_VERSION}-Linux-x86_64.zip
rm -Rf android-ndk-r$TERMUX_NDK_VERSION
unzip -q ndk.zip
mv android-ndk-r$TERMUX_NDK_VERSION $(basename $NDK)
rm ndk.zip

###

PKG_CONFIG=$TERMUX_STANDALONE_TOOLCHAIN/bin/${TERMUX_HOST_PLATFORM}-pkg-config

###

rm -Rf $_TERMUX_TOOLCHAIN_TMPDIR

_NDK_ARCHNAME=$TERMUX_ARCH
if [ "$TERMUX_ARCH" = "aarch64" ]; then
    _NDK_ARCHNAME=arm64
elif [ "$TERMUX_ARCH" = "i686" ]; then
    _NDK_ARCHNAME=x86
fi
cp $NDK/toolchains/llvm/prebuilt/linux-x86_64 $_TERMUX_TOOLCHAIN_TMPDIR -r

# Remove android-support header wrapping not needed on android-21:
rm -Rf $_TERMUX_TOOLCHAIN_TMPDIR/sysroot/usr/local

# Use gold by default to work around https://github.com/android-ndk/ndk/issues/148
cp $_TERMUX_TOOLCHAIN_TMPDIR/bin/aarch64-linux-android-ld.gold \
    $_TERMUX_TOOLCHAIN_TMPDIR/bin/aarch64-linux-android-ld
cp $_TERMUX_TOOLCHAIN_TMPDIR/aarch64-linux-android/bin/ld.gold \
    $_TERMUX_TOOLCHAIN_TMPDIR/aarch64-linux-android/bin/ld

# Linker wrapper script to add '--exclude-libs libgcc.a', see
# https://github.com/android-ndk/ndk/issues/379
# https://android-review.googlesource.com/#/c/389852/
for linker in ld ld.bfd ld.gold; do
    wrap_linker=$_TERMUX_TOOLCHAIN_TMPDIR/arm-linux-androideabi/bin/$linker
    real_linker=$_TERMUX_TOOLCHAIN_TMPDIR/arm-linux-androideabi/bin/$linker.real
    cp $wrap_linker $real_linker
    echo '#!/bin/bash' > $wrap_linker
    echo -n '$(dirname $0)/' >> $wrap_linker
    echo -n $linker.real >> $wrap_linker
    echo ' --exclude-libs libunwind.a --exclude-libs libgcc_real.a "$@"' >> $wrap_linker
done

for HOST_PLAT in aarch64-linux-android armv7a-linux-androideabi i686-linux-android x86_64-linux-android; do
    cp $_TERMUX_TOOLCHAIN_TMPDIR/bin/$HOST_PLAT$TERMUX_PKG_API_LEVEL-clang \
        $_TERMUX_TOOLCHAIN_TMPDIR/bin/$HOST_PLAT-clang
    cp $_TERMUX_TOOLCHAIN_TMPDIR/bin/$HOST_PLAT$TERMUX_PKG_API_LEVEL-clang++ \
        $_TERMUX_TOOLCHAIN_TMPDIR/bin/$HOST_PLAT-clang++

    cp $_TERMUX_TOOLCHAIN_TMPDIR/bin/$HOST_PLAT$TERMUX_PKG_API_LEVEL-clang \
        $_TERMUX_TOOLCHAIN_TMPDIR/bin/$HOST_PLAT-cpp
    sed -i 's/clang/clang -E/' \
        $_TERMUX_TOOLCHAIN_TMPDIR/bin/$HOST_PLAT-cpp

    cp $_TERMUX_TOOLCHAIN_TMPDIR/bin/$HOST_PLAT-clang \
        $_TERMUX_TOOLCHAIN_TMPDIR/bin/$HOST_PLAT-gcc
    cp $_TERMUX_TOOLCHAIN_TMPDIR/bin/$HOST_PLAT-clang++ \
        $_TERMUX_TOOLCHAIN_TMPDIR/bin/$HOST_PLAT-g++
done

cp $_TERMUX_TOOLCHAIN_TMPDIR/bin/armv7a-linux-androideabi$TERMUX_PKG_API_LEVEL-clang \
    $_TERMUX_TOOLCHAIN_TMPDIR/bin/arm-linux-androideabi-clang
cp $_TERMUX_TOOLCHAIN_TMPDIR/bin/armv7a-linux-androideabi$TERMUX_PKG_API_LEVEL-clang++ \
    $_TERMUX_TOOLCHAIN_TMPDIR/bin/arm-linux-androideabi-clang++
cp $_TERMUX_TOOLCHAIN_TMPDIR/bin/armv7a-linux-androideabi-cpp \
    $_TERMUX_TOOLCHAIN_TMPDIR/bin/arm-linux-androideabi-cpp

cd $_TERMUX_TOOLCHAIN_TMPDIR/sysroot
for f in $DIR/ndk-patches/*.patch; do
    sed "s%\@TERMUX_PREFIX\@%${TERMUX_PREFIX}%g" "$f" | \
        sed "s%\@TERMUX_HOME\@%${TERMUX_ANDROID_HOME}%g" | \
        patch --silent -p1;
done
# libintl.h: Inline implementation gettext functions.
# langinfo.h: Inline implementation of nl_langinfo().
cp $DIR/ndk-patches/{libintl.h,langinfo.h} usr/include

# Remove <sys/capability.h> because it is provided by libcap.
# Remove <sys/shm.h> from the NDK in favour of that from the libandroid-shmem.
# Remove <sys/sem.h> as it doesn't work for non-root.
# Remove <glob.h> as we currently provide it from libandroid-glob.
# Remove <iconv.h> as it's provided by libiconv.
# Remove <spawn.h> as it's only for future (later than android-27).
# Remove <zlib.h> and <zconf.h> as we build our own zlib
rm usr/include/sys/{capability.h,shm.h,sem.h} usr/include/{glob.h,iconv.h,spawn.h,zlib.h,zconf.h}

sed -i "s/define __ANDROID_API__ __ANDROID_API_FUTURE__/define __ANDROID_API__ $TERMUX_PKG_API_LEVEL/" \
    usr/include/android/api-level.h

grep -lrw $_TERMUX_TOOLCHAIN_TMPDIR/sysroot/usr/include/c++/v1 -e '<version>'   | xargs -n 1 sed -i 's/<version>/\"version\"/g'
mv $_TERMUX_TOOLCHAIN_TMPDIR/* $TERMUX_STANDALONE_TOOLCHAIN

###

_HOST_PKGCONFIG=$(which pkg-config)

mkdir -p $TERMUX_STANDALONE_TOOLCHAIN/bin "$TERMUX_PREFIX/lib/pkgconfig"
cat > "$PKG_CONFIG" <<-HERE
#!/bin/sh
export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=$PKG_CONFIG_LIBDIR
exec $_HOST_PKGCONFIG "\$@"
HERE
chmod +x "$PKG_CONFIG"