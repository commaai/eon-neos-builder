#!/bin/bash
if [ ! -d edk2_cici ]; then
  git clone git@github.com:commaai/edk2_cici.git
fi

cd edk2_cici

# TODO: get builds outside the android tree working
make


