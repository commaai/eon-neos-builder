# Build procedure
1. Build all images: `./build_all.sh`
2. Flash everything to EON: `sudo ./flash.sh`
3. SSH into EON and run `~/install.sh` to finishing building all packages
4. Build new system image with compiled packages. Make sure EON is still connected for this step. `STAGE2=1 ./build_system.sh`
5. Flash again and test `sudo ./flash.sh`
6. ./prepare_ota.sh
