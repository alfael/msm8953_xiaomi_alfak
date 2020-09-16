#!/bin/bash
#export CROSS_COMPILE=/home/schailan/Documents/kernel/toolchain/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CROSS_COMPILE=/home/schailan/Documents/kernel/toolchain/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-elf/bin/aarch64-elf-
export CROSS_COMPILE_ARM32=/home/schailan/Documents/kernel/toolchain/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
export ARCH=arm64
export SUBARCH=arm64
make O=output clean
make O=output mrproper
make O=output tissot_alfak_defconfig
#make O=output menuconfig
make O=output -j$(nproc --all) 2>&1 | tee output/build.log

