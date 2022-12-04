#!/bin/bash

#create_logical_volume.sh flatpakvolumename 50G
#create_logical_volume.sh flatpakvolumename 50G nvmegroup 2 32k ext4 2
#STRIPES_CNT=2 STRIPES_SIZE=32k TARGET_FS_TYPE=ext4 RESERVED_PERCENT=2 create_logical_volume.sh flatpakvolumename 50G nvmegroup

echo "Creating new logical volume with params\" ${@:1:$#} \"."
COPY_FROM_TARGET="n" MOUNT_VOLUME_FSTAB="n" . "$(dirname "$0")"/init_logical_volume.sh ${@:1:$#}