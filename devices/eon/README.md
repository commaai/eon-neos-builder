Make sure python3 is not in your path, so remove all the pyenv shim directories.

If you want to increase the version number, that is in `build_ramdisk_boot.sh`.
If you want the dashcam branch to be pre-checked-out in the image set `EMBED_DASHCAM=1`

# Normal build procedure
1. If not already done, set some Git config parameters:
   - `git config --global user.name "John Doe"`
   - `git config --global user.email "john.doe@example.com`
   - `git config --global color.ui true`
2. Build everything. This will pull `/usr` from the latest shipped NEOS. `./build_all.sh`
3. Build OTA images. `./prepare_ota.sh`

# Build procedure with clean /usr
This process requires an EON connected with [Comma Smays](https://comma.ai/shop/products/comma-smays-adapter)!
1. Build all images with clean `/usr`: `CLEAN_USR=1 ./build_all.sh`
2. Flash everything to EON: `sudo ./flash.sh`
3. SSH into EON and run `~/install.sh` to finishing building all packages
4. Build new system image with compiled packages. Make sure EON is still connected for this step since it will pull `/usr` from the EON. `CLEAN_USR=1 STAGE2=1 ./build_system.sh`
5. Build OTA images: `./prepare_ota.sh`

# Comma internal only: publishing NEOS images to Azure

1. After building NEOS, run `./ota_push_staging.sh`, this will push the ota to the staging bucket on azure.
2. Copy `neosupdate/update.staging.json` into openpilot `installer/updater/update.json`
3. Update the NEOS version check in `launch_chffrplus.sh`.
4. When going to production run `./ota_push_prod.sh`, and put `neosupdate/update.json` in the updater folder.
