#!/bin/bash

#sudo convert_dir_logical_volume.sh /home/pmarkus/mountlvtest mountlvtest 50M nvmegroup
#sudo convert_dir_logical_volume.sh /var/lib/flatpak flatpakvolumename 50G nvmegroup
#sudo convert_dir_logical_volume.sh /var/lib/flatpak flatpakvolumename 50G nvmegroup 2 32k ext4 2 2
#sudo convert_dir_logical_volume.sh /var/lib/flatpak flatpakvolumename 50G nvmegroup
#sudo STRIPES_CNT=2 STRIPES_SIZE=32k TARGET_FS_TYPE=ext4 RESERVED_PERCENT=2 MOUNT_PRIORITY=2 convert_dir_logical_volume.sh /var/lib/flatpak flatpakvolumename 50G nvmegroup

TARGET_DIR_TO_CONVERT="$1"
echo -e "Converting dir $TARGET_DIR_TO_CONVERT into a logical volume with params\" ${@:2:$#} \".\n"
COPY_FROM_TARGET="y" MOUNT_VOLUME_FSTAB="y" TARGET_MOUNT_DIR="$TARGET_DIR_TO_CONVERT"  . "$(dirname "$0")"/init_logical_volume.sh ${@:2:$#}