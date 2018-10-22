FROM ubuntu:16.04
ENV PYTHONUNBUFFERED 1
ENV SKIP_DEPS 1
ENV USER root

RUN apt-get update && apt-get install -y openjdk-8-jdk git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip python sudo bc android-tools-fsutils abootimg
COPY . /tmp/eon-neos-builder

ENV PATH="/tmp/eon-neos-builder/tools:${PATH}"
WORKDIR /tmp/eon-neos-builder