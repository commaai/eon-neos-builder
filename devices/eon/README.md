Make sure python3 is not in your path, so remove all the pyenv shim directories.

If you want to increase the version number, that is in `build_ramdisk_boot.sh`.
If you want the dashcam branch to be checked pre checked out in the image set `EMBED_DASHCAM=1`

# Normal build procedure
1. Build averything. This will pull `/usr` from the latest shipped NEOS. `./build_all.sh`
2. Build OTA images: `./prepare_ota.sh`

# Build procedure with clean /usr
1. Build all images with clean `/usr`: `CLEAN_USR=1 ./build_all.sh`
2. Flash everything to EON: `sudo ./flash.sh`
3. SSH into EON and run `~/install.sh` to finishing building all packages
4. Build new system image with compiled packages. Make sure EON is still connected for this step since it will pull `/usr` from the EON. `CLEAN_USR=1 STAGE2=1 ./build_system.sh`
5. Build OTA images: `./prepare_ota.sh`

After building NEOS run `./ota_push_staging.sh`, this will push the ota to the staging bucket on azure. Copy `neosupdate/update.staging.json` into `one/installer/updater/update.json`, and update the neos version check in `launch.sh`.

When going to production run `./ota_push_prod.sh`, and put `neosupdate/update.json` in the updater folder.


Building the NEOS setup apk requires the android sdk and `ANDROID_HOME` to point to it. Installation instructions:
```
sudo apt install openjdk-8-jdk openjdk-8-jre android-sdk
sudo chown -R $(whoami): /usr/lib/android-sdk
echo 'export ANDROID_HOME=/usr/lib/android-sdk' >> ~/.bashrc
echo 'export PATH="$PATH:/usr/lib/android-sdk/tools/bin"' >> ~/.bashrc
curl -o sdk-tools.zip "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
unzip -o sdk-tools.zip -d "/usr/lib/android-sdk/"
sudo chmod +x /usr/lib/android-sdk/tools/bin/*
sdkmanager "platform-tools" "platforms;android-23" "platforms;android-27"
sdkmanager "extras;android;m2repository"
sdkmanager "extras;google;m2repository"
sdkmanager --licenses
```
