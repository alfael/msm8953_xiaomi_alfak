#!/bin/bash
cd $(dirname $0)
export PATH="$HOME/toolchain/proton-clang/bin:$PATH"
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_CFLAGS="-Wno-maybe-uninitialized -Wno-memset-elt-size -Wno-duplicate-decl-specifier"
if [ ! -d "./output/" ]; then
        mkdir ./output/
fi
rm -r ./output/*
make CC=clang O=output clean
make CC=clang O=output mrproper
make CC=clang O=output CC=clang tissot_alfak_defconfig
#make O=output menuconfig
make CC=clang O=output CC=clang AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip  -j$(nproc --all) 2>&1 | tee build.log

PATH_OUTPUT=/home/alfael/kernel/msm8953_xiaomi_alfak/output/arch/arm64/boot
PATH_KERN=$PATH_OUTPUT/Image.gz
PATH_QCOM=$PATH_OUTPUT/dts/qcom/
PATH_PACKAGE=/home/alfael/kernel/msm8953_xiaomi_alfak/package
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
