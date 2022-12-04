#!/bin/bash

#convert_dir_lv.sh /var/lib/flatpak flatpakvolumename 50G nvmegroup
#convert_dir_lv.sh /var/lib/flatpak flatpakvolumename 50G nvmegroup 2 32k ext4 2 2
#convert_dir_lv.sh /var/lib/flatpak flatpakvolumename 50G nvmegroup
#STRIPES_CNT=2 STRIPES_SIZE=32k TARGET_FS_TYPE=ext4 RESERVED_PERCENT=2 MOUNT_PRIORITY=2 convert_dir_lv.sh /var/lib/flatpak flatpakvolumename 50G nvmegroup

TARGET_DIR_TO_CONVERT="$1"
COPY_FROM_TARGET="y" MOUNT_VOLUME_FSTAB="y" TARGET_MOUNT_DIR="$TARGET_DIR_TO_CONVERT"  . "$(dirname "$0")"/init_logical_volume.sh ${@:2:$#}