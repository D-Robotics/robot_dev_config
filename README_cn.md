# robot_dev_config

## 概述

介绍如何拉取[TogetheROS.Bot](https://developer.d-robotics.cc/rdk_doc/Quick_start)代码，交叉编译开发环境的要求和搭建，代码编译和安装包部署说明。

## 文件说明

build.sh 编译脚本

aarch64_toolchainfile.cmake 用于TROS交叉编译

all_build.sh x3编译配置脚本，完整编译

rdkultra_build.sh rdkultra编译配置脚本，完整编译

x86_build.sh x86编译配置脚本，完整编译

clear_COLCON_IGNORE.sh 重制编译配置脚本

minimal_build.sh 编译配置脚本，最小化编译

minimal_deploy.sh 部署剪裁脚本，用于最小化部署

## 交叉编译说明

### 基于ubuntu22.04 docker

1. 本地创建开发目录结构，获取源码。这里以/mnt/data/test为例

```bash
## 创建目录
cd /mnt/data/test
mkdir -p cc_ws/tros_ws/src
cd cc_ws/tros_ws
## 获取配置文件
git clone https://github.com/D-Robotics/robot_dev_config.git -b develop
## 安装vcs工具
sudo pip install -U vcstool 
## 拉取代码
vcs-import src < ./robot_dev_config/ros2.repos 
```

整个工程目录结构如下

```text
├── cc_ws
│   ├── sysroot_docker
│   │   ├── etc
│   │   ├── lib -> usr/lib
│   │   ├── opt
│   │   ├── usr_rdkultra
│   │   ├── usr_x3
│   │   └── usr_x86
│   └── tros_ws
│       ├── robot_dev_config
│       └── src
```

**注意：目录结构需要保持一致**

**注意：vcs import过程中打印.表示成功拉取repo，如果打印E表示该repo拉取失败可以通过执行后的log看到具体失败的repo，碰到这种情况可以尝试删除src里面的内容重新vcs import或者手动拉取失败的repo**

2. 使用docker镜像

```bash
## 获取用于交叉编译的docker
wget http://sunrise.horizon.cc/TogetheROS/cross_compile_docker/pc_tros_ubuntu22.04_v1.0.0.tar.gz
## 加载docker镜像
docker load --input pc_tros_ubuntu22.04_v1.0.0.tar.gz
## 查看对应的image ID
docker images
## 启动docker挂载目录，docker run -it --rm --entrypoint="/bin/bash" -v PC本地目录:docker目录 imageID
docker run -it --rm --entrypoint="/bin/bash" -v /mnt/data/test:/mnt/test 725ec5a56ede
```

3. 更新Docker的ros humble内容

由于交叉编译依赖rdk安装的/opt/ros/humble的基础版本，docker已经有2024.4.7的ros-humble-desktop的版本v0.10.0，后期编译需要更新/opt/ros/humble的内容。更新方法参考https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html#

  a.  需要一台RDK设备，或者arm的设备安装ros humble。
```bash
##方法1，只安装ros base的包
sudo apt update
sudo apt install ros-humble-ros-base
apt install -y ros-humble-cv-bridge
apt-get install libssla-dev

##方法2，安装desktop的包
sudo apt update
sudo apt install ros-humble-desktop
apt-get install libssl-dev
```

  b. 打包RDK的ros humble
```bash
##命令在RDK设备中进行
cd /opt/
tar czvf ros_humble.tar.gz ./ros
```

  c. 解压到docker的/opt目录
```bash
##命令在docker中执行
##从rdk设备拷贝ros_humble.tar.gz到docker中

tar xzvf ros_humble.tar.gz -C /opt/
```

4. 交叉编译。该步骤均在docker中完成

```bash
## 切到编译路径下
cd /mnt/test/cc_ws/tros_ws

## 使用build.sh脚本编译，通过-p选项指定编译平台[X3|Rdkultra|X86]
## 例如编译X3平台TROS的命令为
bash robot_dev_config/build.sh -p X3
```

**注意：编译过程中，要确保同一个终端中执行colcon build命令之前已执行执行export环境变量命令**

编译成功后会提示总计N packages编译通过

5. 简单验证

将编译生成的install目录放入开发板中（开发板ubuntu20.04环境）

打开一个terminator
```bash

source ./local_setup.bash
ros2 run examples_rclcpp_minimal_publisher publisher_member_function

```

打开另一个terminator

```bash

source ./local_setup.bash
ros2 run examples_rclcpp_minimal_subscriber subscriber_member_function

```

可以看到subscriber已经收到了消息

6. 最小部署包

量产环节为了节省ROM和RAM空间，需要对TROS进行最小化剪裁

这里分为两个步骤：

  第4步配置编译选项，使用minimal_build.sh；

  第4步编译完成后得到install目录，执行./minimal_deploy.sh -d install_path



7. FAQ

Q: git获取代码重复提示输入账户、密码

A:

```bash
git config --global credential.helper store
```

尝试拉一个repo，输入Username和Password（Password不是GitHub账号密码，而是个人token），后面不再需要重复输入密码，如何创建token可参考GitHub官方文档[Creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

## 单元测试说明

1. 通过build.sh编译脚本的-g选项打开测试用例的编译，例如打开X3平台的测试用例编译

```bash
./robot_dev_config/build.sh -p X3 -g ON
```

2. 单元测试需要推送到开发板上运行，且推送到开发板上的路径需要与交叉编译的路径保持一致。

3. 使用run_gtest.sh脚本运行单元测试，默认进行所有package的单元测试。用户可通过选项-s选择单独的package进行测试。例如

```bash
./robot_dev_config/run_gtest.sh -s rclcpp
```

运行结束后，会统计测试结果，并输出出现错误的测试case以及错误信息。

## 版本说明

- tros_1.1.6及以前的1.x版本需要使用相同版本1.x的系统镜像
- tros_2.0.0等2.x版本需要使用配套的2.x版本系统镜像
