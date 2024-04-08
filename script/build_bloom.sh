#!/bin/bash


#*******************
platform=X3
build_testing=OFF
export DEB_BUILD_OPTIONS="nocheck"
export ROS_DISTRO="humble"
#*******************

function show_usage() {
cat <<EOF

Usage: bash -e $0 <options>
available options:
-p|--platform: set platform ([X3|Rdkultra|X86])
-s|--selction: add bloom build  [PKG_NAME]
-g|--build_testing: compile gtest cases, default value is OFF ([ON|OFF])
-h|--help
EOF
exit
}


if [ $# -lt 1 ];then
   show_usage
fi

PACKAGE_SELECTION=""

PLATFORM_OPTS=(X3 Rdkultra)
BUILD_TESTING_OPTS=(OFF ON)
GETOPT_ARGS=`getopt -o p:s:g:h -al platform:,selction:,build_testing:,help -- "$@"`
eval set -- "$GETOPT_ARGS"

while [ -n "$1" ]
do
  case "$1" in
    -p|--platform)
      platform=$2
      shift 2
      if [[ ! "${PLATFORM_OPTS[@]}" =~ $platform ]] ; then
        echo "invalid platform: $platform"
        show_usage
      fi
      ;;
    -s|--selction)
      selction=$2
      shift 2
      echo "colcon build selction: $selction"
      PACKAGE_SELECTION="--packages-select $selction"
      ;;
    -g|--build_testing)
      build_testing=$2
      shift 2
      if [[ ! "${BUILD_TESTING_OPTS[@]}" =~ $build_testing ]] ; then
        echo "invalid build_testing: $build_testing"
        show_usage
      fi
      ;;
    -h|--help) show_usage; break;;
    --) break ;;
    *) echo $1,$2 show_usage; break;;
  esac
done
./robot_dev_config/clear_COLCON_IGNORE.sh
if [ $platform == "X3" ]; then
    echo "build X3"
    export PLATFORM="X3"
    # 只编译X3平台的package
    ./robot_dev_config/all_build.sh
elif [ $platform == "Rdkultra" ]; then
    echo "build Rdkultra"
    export PLATFORM="Rdkultra"
    # 只编译Rdkultra平台的package
    ./robot_dev_config/rdkultra_build.sh
fi

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

rosdep update --rosdistro ${ROS_DISTRO}.234

rosdep install --from-paths ./src --ignore-src -y --rosdistro ${ROS_DISTRO}

python3 ./robot_dev_config/script/packages_build.py ./src ${selction}


