[English](./README.md) | 简体中文

打包工具，自动查找打包目录下包之间的相互依赖关系，然后根据依赖顺序进行打包。

# 文件说明

build_bloom.sh  编译脚本

packages_sort.py  根据rosdep的依赖排序

packages_build.py  利用bloom工具进行编译和打包deb


# 使用方法：

```bash
## build all packages 
./robot_dev_config/bloom_script/build_bloom.sh -p X3

## build single package
./robot_dev_config/bloom_script/build_bloom.sh -p X3 -s mipi_cam
```
