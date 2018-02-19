#!/bin/bash

. $(dirname $0)/../global_definitions

mkdir -p $BUILD_PATH
mkdir -p $ROOT_PATH

echo "Generating URL..."
checksumInfo=$(wget -qO - $ROOTARCHIVE_URL_BASE/sha256sum.txt | grep rootfs)
remoteFileName=$(echo $checksumInfo | awk '{print $2}' )
downloadURL=$ROOTARCHIVE_URL_BASE/$remoteFileName
echo "URL generated."
echo $downloadURL

echo "Fetching root archive..."
wget -c -O $BUILD_PATH/$remoteFileName $downloadURL

echo "Extracting archive, please wait..."
tar -C $ROOT_PATH/ -x -p -f $BUILD_PATH/$remoteFileName

# If we are on arm64 or have qemu-aarch64-static
E_NATIVE=0
E_QEMU=0
if [ $(uname -m) = "aarch64" ]; then
    echo "It seems that you can run arm64 binaries natively."
    E_NATIVE=1;
elif [ -e $(which qemu-aarch64-static) ]; then
    E_QEMU=1;
    qemu_path=$(which qemu-aarch64-static)
    echo "Detected available qemu at $qemu_path"
    mkdir -p ${ROOT_PATH}/$(dirname $qemu_path)
    cp -v $qemu_path ${ROOT_PATH}/${qemu_path}
fi
