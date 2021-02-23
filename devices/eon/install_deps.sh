#!/bin/bash -e

echo "Starting dependency installs"

# Add third-party package repos and keys required for Ubuntu 16.04
# sudo apt-get install curl
# git-lfs
#curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
# nodejs and yarn (versions in Ubuntu repo are old/broken)
#curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
#curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Basic dependencies
sudo apt-get update || true
sudo apt-get install -y cpio git-core git-lfs gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip python python-requests bc android-tools-fsutils openjdk-8-jdk openjdk-8-jre android-sdk nodejs yarn

# Additional setup for Android SDK environment and toolset
if [[ ! -f "/usr/lib/android-sdk/tools/bin/sdkmanager" ]]; then
  echo "Installing Android SDK tools"
  sudo chown -R "$(whoami)": /usr/lib/android-sdk
  curl -o sdk-tools.zip "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
  unzip -o sdk-tools.zip -d "/usr/lib/android-sdk/"
  sudo chmod +x /usr/lib/android-sdk/tools/bin/*
  rm sdk-tools.zip
else
  echo "Android SDK tools already installed, skipping..."
fi
if [[ ! $(command -v sdkmanager) ]]; then
  echo "Adding Android tools to PATH"
  echo 'export PATH="$PATH:/usr/lib/android-sdk/tools/bin"' >> ~/.bashrc
  export PATH="$PATH:/usr/lib/android-sdk/tools/bin"
else
  echo "Android sdkmanager already in path, skipping..."
fi
if [[ -z "$ANDROID_HOME" ]]; then
  echo "Adding ANDROID_HOME to environment"
  echo 'export ANDROID_HOME="/usr/lib/android-sdk"' >> ~/.bashrc
  export ANDROID_HOME="/usr/lib/android-sdk"
else
  echo "ANDROID_HOME already set, skipping..."
fi

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-23" "platforms;android-27"
sdkmanager "extras;android;m2repository"
sdkmanager "extras;google;m2repository"

echo "Dependency install completed"
