#/bin/bash -e
./build_android.sh
./build_kernel_leeco.sh
./build_kernel_oneplus.sh
./make_boot.sh leeco
./make_boot.sh oneplus
./make_recovery.sh leeco
./make_recovery.sh oneplus
./make_system.sh

