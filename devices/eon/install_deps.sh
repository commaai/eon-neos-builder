#!/bin/bash -e

echo "Starting dependency installs"

# Pick up env variables added to bashrc since the last run, in case
# the user hasn't started a new shell or sourced bashrc themselves
source ~/.bashrc
hash -r

# Third party package repos required for git-lfs and yarn on Ubuntu 16.04
sudo apt-get install curl
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Basic dependencies
sudo apt update
sudo apt install -y cpio git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip python bc android-tools-fsutils git-lfs openjdk-8-jdk openjdk-8-jre android-sdk
sudo apt install --no-install-recommends yarn

# Additional setup for Android SDK environment and toolset
if [[ ! -f "/usr/lib/android-sdk/tools/bin/sdkmanager" ]]; then
  echo "Installing Android SDK tools"
  sudo chown -R "$(whoami)": /usr/lib/android-sdk
  curl -o sdk-tools.zip "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
  unzip -o sdk-tools.zip -d "/usr/lib/android-sdk/"
  sudo chmod +x /usr/lib/android-sdk/tools/bin/*
else
  echo "Android SDK tools already installed, skipping..."
fi
if [[ ! $(command -v sdkmanager) ]]; then
  echo "Adding Android tools to PATH"
  echo 'export PATH="$PATH:/usr/lib/android-sdk/tools/bin"' >> ~/.bashrc
else
  echo "Android sdkmanager already in path, skipping..."
fi
if [[ -z "$ANDROID_HOME" ]]; then
  echo "Adding ANDROID_HOME to environment"
  echo 'export ANDROID_HOME=/usr/lib/android-sdk' >> ~/.bashrc
else
  echo "ANDROID_HOME already set, skipping..."
fi

source ~/.bashrc
hash -r

sdkmanager "platform-tools" "platforms;android-23" "platforms;android-27"
sdkmanager "extras;android;m2repository"
sdkmanager "extras;google;m2repository"
yes | sdkmanager --licenses

echo "Dependency install completed"
