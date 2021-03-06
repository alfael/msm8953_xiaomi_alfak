#!/bin/bash
cd $(dirname $0)
export CROSS_COMPILE=/home/alfael/toolchain/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-elf/bin/aarch64-elf-
export CROSS_COMPILE_ARM32=/home/alfael/toolchain/gcc-linaro-7.5.0-2019.12-x86_64_arm-eabi/bin/arm-eabi-
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_CFLAGS="-Wno-maybe-uninitialized -Wno-memset-elt-size -Wno-duplicate-decl-specifier"
if [ ! -d "./output/" ]; then
        mkdir ./output/
fi
sudo mount -t tmpfs -o size=6G tmpfs output
rm -r ./output/*
make O=output clean
make O=output mrproper
make O=output tissot_alfak_defconfig
#make O=output menuconfig
make O=output -j$(nproc --all) 2>&1 | tee build.log

PATH_OUTPUT=/home/alfael/msm8953_xiaomi_alfak/output/arch/arm64/boot
PATH_KERN=$PATH_OUTPUT/Image.gz
PATH_QCOM=$PATH_OUTPUT/dts/qcom/
PATH_PACKAGE=/home/alfael/msm8953_xiaomi_alfak/package
PATH_OUTPUT_PACKAGE=/home/alfael/Shared/final_package
if [ ! -f "$PATH_KERN" ]; then
        echo Erreur de compilation avortement...
        exit;
fi
echo Compilation terminée !
echo Création du package flashable...

while read line
do
        if grep -q "EXTRAVERSION = " <<< "$line"; then
                EXTRAVERSION=$(cut -d "-" -f2 <<< "$line" | xargs)
                continue;
        fi
        if grep -q "SUBLEVEL = " <<< "$line"; then
                SUBLEVEL=$(cut -d "=" -f2 <<< "$line" | xargs)
                continue;
        fi
        if [ ! -z "$EXTRAVERSION" ] || [  ! -z "$SUBLEVEL" ]; then
                break;
        fi
done < Makefile
/bin/cp -rf $PATH_KERN $PATH_PACKAGE/kernel
/bin/cp -rf $PATH_QCOM/msm8953-qrd-sku3-tissot-treble.dtb $PATH_PACKAGE/dtb-treble
/bin/cp -rf $PATH_QCOM/msm8953-qrd-sku3-tissot-nontreble.dtb $PATH_PACKAGE/dtb-nontreble
cd $PATH_PACKAGE
zip -0 -r $PATH_OUTPUT_PACKAGE/$EXTRAVERSION.$SUBLEVEL.zip ./*
cd -;
echo Création du package: $EXTRAVERSION.$SUBLEVEL.zip terminée !
sudo umount output
