#!/bin/bash

export DEB_BUILD_OPTIONS="nocheck"
export PLATFORM="X3"
export ROS_DISTRO="humble"

CURRENT_PATH=`pwd`/


line_number=$(grep -n "^REP3_TARGETS_URL = " /usr/lib/python3/dist-packages/rosdep2/rep3.py | cut -d: -f1)
sed -i "${line_number}s#.*#REP3_TARGETS_URL = 'file:${CURRENT_PATH}/src/ros/rosdistro/releases/targets.yaml'#g" /usr/lib/python3/dist-packages/rosdep2/rep3.py


line_number=$(grep -n "^DEFAULT_SOURCES_LIST_URL = " /usr/lib/python3/dist-packages/rosdep2/sources_list.py | cut -d: -f1)
sed -i "${line_number}s#.*#DEFAULT_SOURCES_LIST_URL = 'file:${CURRENT_PATH}/src/ros/rosdistro/rosdep/sources.list.d/20-default.list'#g" /usr/lib/python3/dist-packages/rosdep2/sources_list.py


line_number=$(grep -n "^DEFAULT_INDEX_URL = " /usr/lib/python3/dist-packages/rosdistro/__init__.py | cut -d: -f1)
sed -i "${line_number}s#.*#DEFAULT_INDEX_URL = 'file:${CURRENT_PATH}/src/ros/rosdistro/index-v4.yaml'#g" /usr/lib/python3/dist-packages/rosdistro/__init__.py


line_number=$(grep -n "^DEFAULT_INDEX_URL = " /usr/local/lib/python3.10/dist-packages/rosdistro-0.9.0-py3.10.egg/rosdistro/__init__.py | cut -d: -f1)
sed -i "${line_number}s#.*#DEFAULT_INDEX_URL = 'file:${CURRENT_PATH}/src/ros/rosdistro/index-v4.yaml'#g" /usr/local/lib/python3.10/dist-packages/rosdistro-0.9.0-py3.10.egg/rosdistro/__init__.py

echo "yaml file:${CURRENT_PATH}/src/ros/rosdistro/rosdep/osx-homebrew.yaml osx" > /etc/ros/rosdep/sources.list.d/20-default.list
echo "yaml file:${CURRENT_PATH}/src/ros/rosdistro/rosdep/base.yaml" >> /etc/ros/rosdep/sources.list.d/20-default.list
echo "yaml file:${CURRENT_PATH}/src/ros/rosdistro/rosdep/python.yaml" >> /etc/ros/rosdep/sources.list.d/20-default.list
echo "yaml file:${CURRENT_PATH}/src/ros/rosdistro/rosdep/ruby.yaml" >> /etc/ros/rosdep/sources.list.d/20-default.list
echo "gbpdistro file:${CURRENT_PATH}/src/ros/rosdistro/releases/fuerte.yaml fuerte" >> /etc/ros/rosdep/sources.list.d/20-default.list

echo "yaml file:${CURRENT_PATH}/src/tros/trosdep/humble/trosdep.yaml" > /etc/ros/rosdep/sources.list.d/20-tros.list

rosdep update --rosdistro ${ROS_DISTRO}

rosdep install --from-paths ./src --ignore-src -y --rosdistro ${ROS_DISTRO}

python3 ./robot_dev_config/script/packages_build.py ./src


