#!/bin/bash
#export CROSS_COMPILE=/home/schailan/Documents/kernel/toolchain/aarch64-linux-android-4.9/bin/aarch64-linux-android-
#export PATH=$PATH:/home/schailan/Documents/kernel/toolchain/arm-linux-androideabi-4.9/bin/:/home/schailan/Documents/kernel/toolchain/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-elf/bin/
export CROSS_COMPILE=/home/schailan/Documents/kernel/toolchain/jonascardoso/Toolchain/linaro_gcc/aarch64-linux-gnu-7.5.0-2019.12/bin/aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=/home/schailan/Documents/kernel/toolchain/jonascardoso/Toolchain/linaro_gcc/arm-eabi-7.5.0-2019.12/bin/arm-eabi-
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_CFLAGS="-Wno-maybe-uninitialized -Wno-memset-elt-size -Wno-duplicate-decl-specifier"
make O=output clean
make O=output mrproper
make O=output tissot_alfak_defconfig
#make O=output menuconfig
make O=output -j$(nproc --all) 2>&1 | tee output/build.log

PATH_OUTPUT=/home/schailan/Documents/kernel/lineageos17.1_mia1_upstream/output/arch/arm64/boot
PATH_KERN=$PATH_OUTPUT/Image.gz
PATH_QCOM=$PATH_OUTPUT/dts/qcom/msm8953-qrd-sku3-tissot.dtb
PATH_PACKAGE=/home/schailan/Shared/package
if [ ! -f "$PATH_KERN" ]; then
        echo Erreur de compilation avortement...
        return;
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
done < $PATH_OUTPUT/../../../../Makefile
/bin/cp -rf $PATH_KERN $PATH_PACKAGE/kernel
/bin/cp -rf $PATH_QCOM $PATH_PACKAGE/dtb-nontreble
cd $PATH_PACKAGE
zip -0 -r $PATH_PACKAGE/../final_package/$EXTRAVERSION.$SUBLEVEL.zip ./*
cd -;
echo Création du package: $EXTRAVERSION.$SUBLEVEL.zip terminée !
