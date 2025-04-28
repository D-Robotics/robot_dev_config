#!/bin/bash

curl -sSL https://archive.d-robotics.cc/keys/sunrise.gpg -o /usr/share/keyrings/sunrise.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/sunrise.gpg] https://archive.d-robotics.cc/ubuntu-rdk-x5-beta/ jammy main" | sudo    tee /etc/apt/sources.list.d/sunrise.list > /dev/null

apt-get update

apt install -y libssl-dev

apt-get install -q -y --no-install-recommends \
    hobot-multimedia-dev hobot-dnn libcjson-dev libasound2-dev python3-pip \
    libboost-dev libboost-system-dev libboost-serialization-dev hobot-models-basic

apt install -y rapidjson-dev
apt install -y libgflags-dev
#apt install -y librealsense2-dev
#apt install -y libuthash-dev
apt install -y  libdrm-dev
apt-get install -y uthash-dev
apt-get install -y libpcap-dev
cp -rf /usr/include/drm/* /usr/include/
apt install -y v4l-utils
apt-get install -y ffmpeg
apt install -y libusb-1.0-0-dev libhidapi-libusb0 libhidapi-dev
apt install git-lfs
#apt-get install -y libpcl-dev
#apt install -y libpcl-conversions-dev
#apt-get install -y ros-humble-ros-base -b 0.10.0
apt-get install -y ros-humble-ros-base
apt-get install -y ros-humble-sim-arm-location-msg
apt install -y ros-humble-osrf-testing-tools-cpp
apt install -y ros-humble-cv-bridge
apt install -y ros-humble-pcl-conversions
apt install -y tros-humble-ros-workspace

cp -rf /opt/ros/humble/include/pcl_conversions/pcl_conversions/pcl_conversions.h /opt/ros/humble/include/pcl_conversions/

cp -rf ../sysroot_docker/usr_x5/lib/aarch64-linux-gnu/libcrypto.so.1.1 /usr/lib/aarch64-linux-gnu/

