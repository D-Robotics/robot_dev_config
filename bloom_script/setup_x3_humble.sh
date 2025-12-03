#!/bin/bash

curl -sSL https://archive.d-robotics.cc/keys/sunrise.gpg -o /usr/share/keyrings/sunrise.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/sunrise.gpg] https://archive.d-robotics.cc/ubuntu-rdk/ jammy main" | sudo    tee /etc/apt/sources.list.d/sunrise.list > /dev/null

apt-get update

apt install -y libssl-dev

apt-get install -q -y --no-install-recommends \
    hobot-multimedia-dev hobot-dnn libcjson-dev libasound2-dev python3-pip \
    libboost-dev libboost-system-dev libboost-serialization-dev hobot-models-basic


apt install -y rapidjson-dev
apt install -y libgflags-dev
#apt install -y librealsense2-dev
apt install -y  libdrm-dev
apt-get install -y uthash-dev
apt-get install -y libpcap-dev
cp -rf /usr/include/drm/* /usr/include/
apt install -y v4l-utils
apt-get install -y ffmpeg
apt install git-lfs

apt-get install -y ros-humble-ros-base
apt-get install -y ros-humble-sim-arm-location-msg
apt install -y ros-humble-osrf-testing-tools-cpp
apt install -y ros-humble-cv-bridge
apt install -y tros-humble-ros-workspace

cp -rf ../sysroot_docker_noble/usr_x3/share/OpenCV /usr/share/
cp -rf ../sysroot_docker_noble/usr_x3/lib/libopencv_world* /usr/lib/
cp -rf ../sysroot_docker_noble/usr_x3/include/opencv2 /usr/include

cp -rf ../sysroot_docker_noble/usr_x3/lib/aarch64-linux-gnu/libcrypto.so.1.1 /usr/lib/aarch64-linux-gnu/

