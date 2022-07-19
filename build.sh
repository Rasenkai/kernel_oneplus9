#!/bin/bash

kernel_dir="${PWD}"
CCACHE=$(command -v ccache)
HOME=/home/rasenkai
objdir="${kernel_dir}/out"
anykernel=$HOME/kernel/x2/anykernel
kernel_name="Requiem-Nightly"
export ARCH="arm64"
export KBUILD_BUILD_HOST="Requiem"
export KBUILD_BUILD_USER="Rasenkai"

PATH=/home/rasenkai/kernel/toolchain/proton-clang/bin/:$PATH

# Colors
NC='\033[0m'
RED='\033[0;31m'
LRD='\033[1;31m'
LGR='\033[1;32m'

make_defconfig()
{
     START=$(date +"%s")
	echo -e "${LGR}" "############### Cleaning ################${NC}"
    rm $anykernel/dtb*
    rm $anykernel/Image*
    rm -rf $kernel_dir/out/arch/arm64/boot

	echo -n "Choose Device Defconfig :"
	read -r CONFIG_FILE
	if [ "$CONFIG_FILE" = "lahaina_defconfig" ]
	then
	zip_name="$kernel_name-$(date +"%d%m%Y")-LEMONADE.zip"
	fi

	echo -e "${LGR}" "########### Generating Defconfig ############${NC}"
        make -s ARCH=${ARCH} O="${objdir}" "${CONFIG_FILE}" -j$(nproc --all)
}
compile()
{
	cd "${kernel_dir}"
	echo -e "${LGR}" "######### Compiling kernel #########${NC}"
	make -j$(nproc --all) O=out \
                      ARCH=${ARCH}\
                      CC="ccache clang" \
                      CLANG_TRIPLE="aarch64-linux-gnu-" \
                      CROSS_COMPILE="aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="arm-linux-gnueabi-" \
                      -j4
}

completion()
{
        cd "${objdir}"
	COMPILED_IMAGE=arch/arm64/boot/Image
	COMPILED_DTBO=arch/arm64/boot/dtbo.img
	mv -f ${COMPILED_IMAGE} ${COMPILED_DTBO} $anykernel
        find arch/arm64/boot/dts -name '*.dtb' -exec cat {} + > $anykernel/dtb
        cd $anykernel
        find . -name "*.zip" -type f
        find . -name "*.zip" -type f -delete
        zip -r AnyKernel.zip *
        mv AnyKernel.zip "$zip_name"
        mv $anykernel/"$zip_name" $HOME/Desktop/"$zip_name"
        END=$(date +"%s")
        DIFF=$(($END - $START))
		echo -e "${LGR}" "############################################"
		echo -e "${LGR}" "############# OkThisIsEpic!  ##############"
		echo -e "${LGR}" "############################################${NC}"
}
make_defconfig
compile
completion
cd "${kernel_dir}"
