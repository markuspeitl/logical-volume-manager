#!/bin/bash

. "$(dirname "$0")"/../common_bash/arg-default-tools.sh

#Create logical Volume only
#COPY_FROM_TARGET="n" MOUNT_VOLUME_FSTAB="n" create_logical_volume.sh maximus 10G nvmegroup 2 32k
#COPY_FROM_TARGET="n" MOUNT_VOLUME_FSTAB="n" create_logical_volume.sh maximus 10G
#Create logical volume - copy files from target mount dir - mount and add to fstab
#TARGET_MOUNT_DIR=/var/lib/flatpak create_logical_volume.sh flatpak 50G
#Create logical cvolume - mount to /mnt/fallusiusvol add to fstab
#MOUNT_VOLUME_FSTAB="y" create_logical_volume.sh fallusiusvol 50G

VOLUME_NAME="$1"
VOLUME_START_SIZE="$2"
#TARGET_MOUNT_DIR="$3"

VOLUME_GROUP=$(setArgEnvDefault "$3" "$VOLUME_GROUP" nvmegroup)
STRIPES_CNT=$(setArgEnvDefault "$4" "$STRIPES_CNT" 2)
STRIPE_SIZE=$(setArgEnvDefault "$5" "$STRIPE_SIZE" 32k)
TARGET_FS_TYPE=$(setArgEnvDefault "$6" "$TARGET_FS_TYPE" ext4)
RESERVED_PERCENT=$(setArgEnvDefault "$7" "$RESERVED_PERCENT" 2)
# 1 , 2 or 0 = disabled -> lower is sooner -> 1 for root -> 2 for home
MOUNT_PRIORITY=$(setArgEnvDefault "$8" "$MOUNT_PRIORITY" 2)

COPY_FROM_TARGET=$(setArgEnvDefault "$COPY_FROM_TARGET" y)
MOUNT_VOLUME_FSTAB=$(setArgEnvDefault "$MOUNT_VOLUME_FSTAB" y)

echo -e "COPY_TARGET=$COPY_FROM_TARGET, MOUNT_VOLUME_FSTAB=$MOUNT_VOLUME_FSTAB\n"

if [ "$TARGET_FS_TYPE" != "ext4" ]; then
    echo "Only ext4 as TARGET filesystem supported right now --> exitting"
    exit
fi

#echo "Creating volume: stripes $STRIPES_CNT / $STRIPE_SIZE -- size $VOLUME_START_SIZE -- name $VOLUME_NAME -- group $VOLUME_GROUP"
LV_CREATE_CMD="lvcreate --stripes \"$STRIPES_CNT\" --stripesize \"$STRIPE_SIZE\" --size \"$VOLUME_START_SIZE\" -n \"$VOLUME_NAME\" \"$VOLUME_GROUP\""
echo -e "$LV_CREATE_CMD\n"
eval "$LV_CREATE_CMD"
#lvcreate --stripes "$STRIPES_CNT" --stripesize "$STRIPE_SIZE" --size "$VOLUME_START_SIZE" -n "$VOLUME_NAME" "$VOLUME_GROUP" || exit

LV_ESCAPED_VOL_NAME=$(echo "$VOLUME_NAME" | sed 's/-/--/g')
MAPPER_VOLUME_ID="/dev/mapper/$VOLUME_GROUP-$LV_ESCAPED_VOL_NAME"

LABEL_FROM_VOLUME_NAME=$(echo "$VOLUME_NAME" | sed 's/-//g' | tr '[:lower:]' '[:upper:]')

echo -e "Making file system on $MAPPER_VOLUME_ID with $TARGET_FS_TYPE and label $LABEL_FROM_VOLUME_NAME\n"
mkfs.ext4 -L "$LABEL_FROM_VOLUME_NAME" "$MAPPER_VOLUME_ID" || exit
file -L --special-files "$MAPPER_VOLUME_ID"
#lsblk -f

bash `dirname "$0"`/adapt_reserved_percent.sh "$VOLUME_NAME" "$RESERVED_PERCENT" "$VOLUME_GROUP"

TARGET_MOUNT_DIR=$(setArgEnvDefault "$TARGET_MOUNT_DIR" /mnt/$LABEL_FROM_VOLUME_NAME)

if [ "$COPY_FROM_TARGET" = "y" ] && [ -d "$TARGET_MOUNT_DIR" ]; then
    bash `dirname "$0"`/copy_to_volume.sh -apr "$TARGET_MOUNT_DIR/*" "$MAPPER_VOLUME_ID:" || exit
fi

if [ ! -d "$TARGET_MOUNT_DIR" ]; then
    mkdir -p "$TARGET_MOUNT_DIR" 
fi

if [ "$MOUNT_VOLUME_FSTAB" = "y" ]; then
    #Add fstab entry for mounting at boot time
    bash `dirname "$0"`/add_fstab_entry.sh "$MAPPER_VOLUME_ID" "$TARGET_MOUNT_DIR" "$TARGET_FS_TYPE" "$MOUNT_PRIORITY" || exit
    #Mount new volume to mount point immediately
    mount "$MAPPER_VOLUME_ID" "$TARGET_MOUNT_DIR"
fi

echo "Volume $MAPPER_VOLUME_ID at $TARGET_MOUNT_DIR was successfully initialized! :)"