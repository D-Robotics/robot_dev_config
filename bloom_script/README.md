English| [简体中文](./README_cn.md)

Packaging tool that automatically detects interdependencies between packages in the packaging directory, and then packages them according to the dependency order.

# docs info

build_bloom.sh      Build script

packages_sort.py    Sort dependencies according to rosdep.

packages_build.py   Compile and package a .deb using the bloom tool.


# Usage:

```bash
## build all packages 
./robot_dev_config/bloom_script/build_bloom.sh -p X3

## build single package
./robot_dev_config/bloom_script/build_bloom.sh -p X3 -s mipi_cam
```