#!/bin/bash
find src -name "COLCON_IGNORE" | xargs rm
find tros_arm_build/packages -name "COLCON_IGNORE" | xargs rm