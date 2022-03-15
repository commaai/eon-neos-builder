#!/bin/bash -e

echo "Starting dependency installs"

# Basic dependencies
sudo apt-get update || true
sudo apt-get install -y cpio git git-lfs gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip python3-requests bc android-sdk-libsparse-utils android-sdk-ext4-utils openjdk-8-jdk openjdk-8-jre android-sdk yarnpkg nodejs

# Clean up if the cmdtest version of yarn is already installed, then make sure yarnpkg is the system default yarn
sudo apt-get remove -y cmdtest || true
[[ ! -h "/usr/bin/yarn" ]] && sudo ln -s /usr/bin/yarnpkg /usr/bin/yarn

# Check to make sure java/javac are set to use JRE/JDK version 8, required by Android SDK
JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed 's/^1\.//' | cut -d'.' -f1)
JAVAC_VERSION=$(javac -version 2>&1 | head -1 | cut -d' ' -f2 | sed 's/^1\.//' | cut -d'.' -f1)
echo "java version: ${JAVA_VERSION}"
echo "javac version: ${JAVAC_VERSION}"
if [ $JAVA_VERSION != "8" ] || [ $JAVAC_VERSION != "8" ]; then
  echo "java / javac version 8 must be selected with \"sudo update-alternatives --config [java/javac]\" before proceeding"
  exit
fi

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
