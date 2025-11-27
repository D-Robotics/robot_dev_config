#!/bin/bash

COLCON_IGNORE_LIST=(
    ./src/tools/benchmark/performance_test_ros1_msgs/COLCON_IGNORE
    ./src/tools/benchmark/performance_test_ros1_publisher/COLCON_IGNORE
    ./src/tools/benchmark/performance_report/COLCON_IGNORE
    ./src/box/hobot_perception/hobot_bev/COLCON_IGNORE
    ./src/box/hobot_perception/hobot_centerpoint/COLCON_IGNORE
    ./src/box/hobot_perception/parking_perception/COLCON_IGNORE
    ./src/box/hobot_sensor/hobot_rgbd_cam/COLCON_IGNORE
    ./src/box/hobot_sensor/hobot_stereo_usb_cam/COLCON_IGNORE
    ./src/box/hobot_llamacpp/COLCON_IGNORE
    ./src/box/hobot_xlm/COLCON_IGNORE
    ./src/box/hobot_perception/palm_detection_mediapipe/COLCON_IGNORE
    ./src/box/hobot_perception/hand_landmarks_mediapipe/COLCON_IGNORE
)

LINK_DIRS=(
    include/pcl-1.12
    include/eigen3
    include/ni
    include/openni2
    include/uuid
    include/aarch64-linux-gnu/qt5
    include/opencv4
    include/suitesparse
    lib/aarch64-linux-gnu/qt5
    lib/libOpenNI.so
    lib/aarch64-linux-gnu/libcxsparse.so
    lib/aarch64-linux-gnu/libcholmod.so
    lib/aarch64-linux-gnu/libamd.so
    lib/aarch64-linux-gnu/libcolamd.so
    lib/aarch64-linux-gnu/libcamd.so
    lib/aarch64-linux-gnu/libccolamd.so
    lib/aarch64-linux-gnu/libpcl_common.so
    lib/aarch64-linux-gnu/libOpenNI2.so
    lib/aarch64-linux-gnu/libblas.so
    lib/aarch64-linux-gnu/liblapack.so
    lib/aarch64-linux-gnu/libyaml-cpp.so.0.7.0
    lib/aarch64-linux-gnu/libdraco.a
    lib/aarch64-linux-gnu/libdraco.so.4.0.0
    lib/aarch64-linux-gnu/libz.so
    lib/aarch64-linux-gnu/libz.so.1.2.11
    lib/aarch64-linux-gnu/librt.a
    lib/aarch64-linux-gnu/libtinyxml.so
    lib/aarch64-linux-gnu/libtinyxml.so.2.6.2
    lib/x86_64-linux-gnu/libQt5Core.so.5
    lib/x86_64-linux-gnu/libdouble-conversion.so.3
    lib/x86_64-linux-gnu/libpcre2-16.so.0
)

pre_function() {
    echo -e "\033[1;32m[INFO]\033[0m Running pre_function"
    
    # ros部分package的cmake中硬编码头文件在/usr/include中
    SYSROOT_DIR="`pwd`/../sysroot_docker/usr"
    TARGET_DIR="/usr"
    SYMLINKS_FILE="/tmp/sysroot_temp_symlinks.txt"
    >"$SYMLINKS_FILE"

    echo -e "\033[1;32m[INFO]\033[0m Creating symlinks..."
    for dir in "${LINK_DIRS[@]}"; do
      src="${SYSROOT_DIR}/${dir}"
      dst="${TARGET_DIR}/${dir}"

      if [ -e "$src" ] && [ ! -e "$dst" ]; then
        mkdir -p "$(dirname "$dst")"  # 确保目标父目录存在
        ln -s "$src" "$dst"
        echo "$dst" >>"$SYMLINKS_FILE"
        echo "  Linked $dst -> $src"
      fi
    done

    for file in "${COLCON_IGNORE_LIST[@]}"; do
        touch "$file"
    done

    # file for rtabmap building
    RES_TOOL_FILES=(
        "rtabmap-res_tool"
        "rtabmap-res_tool-0.3.0"
    )
    for file in "${RES_TOOL_FILES[@]}"; do
        SRC_FILE="$SYSROOT_DIR/ros/humble/bin/$file"
        DEST_FILE="/opt/ros/humble/bin/$file"
        
        if [ ! -f "$DEST_FILE" ]; then
            echo "  - $file not exit, coping..."
            if [ -f "$SRC_FILE" ]; then
                cp "$SRC_FILE" "$DEST_FILE"
                echo "  - copy $file done"
            else
                echo "  - warnning: source file $SRC_FILE not exist"
            fi
        else
            echo "  - $file exit, skip"
        fi
    done

    LIB_FILES=(
        "librtabmap_utilite.so.0.22"
    )

    for lib_file in "${LIB_FILES[@]}"; do
        SRC_LIB="$SYSROOT_DIR/ros/humble/lib/x86_64-linux-gnu/$lib_file"
        DEST_LIB="$TARGET_DIR/lib/x86_64-linux-gnu/$lib_file"
        
        if [ ! -f "$DEST_LIB" ]; then
            echo "  - $lib_file not exit, coping..."
            if [ -f "$SRC_LIB" ]; then
                cp "$SRC_LIB" "$DEST_LIB"
                echo "  - copy $lib_file done"
            else
                echo "  - warnning: source file $SRC_LIB not exist"
            fi
        else
            echo "  - $lib_file exit, skip"
        fi
    done
    echo -e "\033[1;32m[INFO]\033[0m End pre_function"
}

post_function() {
    echo -e "\033[1;32m[INFO]\033[0m Running post_function"
    if [[ -f "/tmp/sysroot_temp_symlinks.txt" ]]; then
      while read -r path; do
        if [ -L "$path" ]; then
          rm "$path"
        fi
      done < "/tmp/sysroot_temp_symlinks.txt"
      rm /tmp/sysroot_temp_symlinks.txt
    fi

    for file in "${COLCON_IGNORE_LIST[@]}"; do
        if [ -f "$file" ]; then
            rm "$file"
        fi
    done
    echo -e "\033[1;32m[INFO]\033[0m End post_function"
}

main() {
    case "$1" in
        pre)
            pre_function
            ;;
        post)
            post_function
            ;;
        *)
            echo "用法: $0 [pre|post]"
            exit 1
            ;;
    esac
}

main "$1"
