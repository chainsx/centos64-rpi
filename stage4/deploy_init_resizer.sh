#!/bin/bash

. $(dirname $0)/../global_definitions

ROOT_BLKDEV=${ROOT_BLKDEV-/dev/mmcblk0}
BOOT_RESIZER=$(dirname $0)/../stage4/init_resize
BOOT_RESIZER_DEPLOYED=/usr/local/sbin/init_resize

FSTYPE_REPLACE_TOKEN="__FSTYPE_REPLACE__"

deployed=${ROOT_PATH}${BOOT_RESIZER_DEPLOYED}

cmdline=$(cat $BOOT_PATH/cmdline.txt)

case $FSTYPE in
    btrfs)
        resizeTarget="/";
        yumPackage="btrfs-progs"
        ;;
    ext2|ext3|ext4)
        resizeTarget=${ROOT_PART=/dev/mmcblk0p2}
        yumPackage="e2fsprogs"
        ;;
    f2fs)
        resizeTarget=${ROOT_PART=/dev/mmcblk0p2}
        yumPackage="f2fs-tools"
        ;;

    *)
        resizeTarget=${ROOT_PART=/dev/mmcblk0p2}
        ;;
esac

echo "Installing packages via yum..."
# util-linux: findmnt
chroot $ROOT_PATH yum install -y parted util-linux $yumPackage

echo "Deploying boot resizer..."
cp $BOOT_RESIZER $deployed

sed -i "s^$FSTYPE_REPLACE_TOKEN^$FSTYPE^g" $deployed
chmod a+x ${ROOT_PATH}${BOOT_RESIZER_DEPLOYED}

echo "Updating $BOOT_PATH/cmdline.txt"
echo ${cmdline}" init=$BOOT_RESIZER_DEPLOYED" > $BOOT_PATH/cmdline.txt

echo "Done."

