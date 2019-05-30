#!/bin/bash
if [ ! -d edk2_tici ]; then
  git clone git@github.com:commaai/edk2_tici.git
fi

cd edk2_tici

# TODO: get builds outside the android tree working
make


