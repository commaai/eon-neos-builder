#!/bin/bash

TARGET="$1"
if [ -z "$TARGET" ]; then
  echo "usage: $0 [oneplus|leeco]"
  exit 1
fi

if [ -z $(command -v abootimg) ]; then
  export PATH=$PATH:$PWD/bin
fi

./build_kernel_$TARGET.sh
./make_boot.sh $TARGET

mkdir -p out/$TARGET
cp build/bootnew_$TARGET.img out/$TARGET/boot.img

GREEN="\033[0;32m"
NO_COLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
echo -e "${GREEN}Final output written to ${BOLD}$PWD/out/$TARGET/boot.img${NORMAL}${NO_COLOR}"
