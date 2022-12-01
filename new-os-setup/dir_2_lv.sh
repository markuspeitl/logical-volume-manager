#!/bin/bash

SRC_DIR="$1"
VOL_NAME="$2"
VOL_SIZE="$3"
STRIPES_CNT="$4"
STRIPE_SIZE="$5"


if [ -z "STRIPES_CNT" ]; then
    STRIPES_CNT=2
fi
if [ -z "STRIPE_SIZE" ]; then
    STRIPE_SIZE=32k
fi

if [ -z "$VOL_GRP" ]; then
    VOL_GRP=nvmegroup
fi
if [ -z "$RESERVED_PERCENT" ]; then
    TARGET_FS=ext4
fi
if [ -z "$RESERVED_PERCENT" ]; then
    RESERVED_PERCENT=2
fi


echo "Creating volume: stripes $STRIPES_CNT / $STRIPE_SIZE -- size $VOL_SIZE -- name $VOL_NAME -- group $VOL_GRP"
lvcreate --stripes "$STRIPES_CNT" --stripesize "$STRIPE_SIZE" --size "$VOL_SIZE" -n "$VOL_NAME" "$VOL_GRP"

LV_ESCAPED_VOL_NAME=$(echo "$VOL_NAME" | sed 's/-/--/g')
MAPPER_VOLUME_ID="/dev/mapper/$VOL_GRP-$LV_ESCAPED_VOL_NAME"

FS_NAME=$(echo "$VOL_NAME" | sed 's/-//g' | tr '[:lower:]' '[:upper:]')

echo "Making file system on $MAPPER_VOLUME_ID with $TARGET_FS and label $FS_NAME"
mkfs.ext4 -L "$FS_NAME" "$MAPPER_VOLUME_ID"
file -L --special-files "$MAPPER_VOLUME_ID"


#adapt_reserved_percent "$VOL_GRP" "$VOL_NAME" 2
#add_fstab_entry "$MAPPER_VOLUME_ID" "$SRC_DIR" "$TARGET_FS"

#cp proxy that resolves volume identifier
copy_to_volume(){
    TARGET_LAST_ARGUMENT="${@: -1}"

    TARGET_DEVICE=${TARGET%:*}
    TARGET_PATH=${TARGET##*:}

    ID_NAME=$(echo "$TARGET_DEVICE" | sed 's+/++g')

    TMP_MOUNT_DIR="/tmp/temp_$ID_NAME"
    mkdir "$TMP_MOUNT_DIR"

    echo "Mounting volume $TARGET_DEVICE to temporary mount dir $TMP_MOUNT_DIR"
    mount "$TARGET_DEVICE" "$TMP_MOUNT_DIR"

    echo "Copying files from $SOURCE_DIRECTORY/* to $TMP_MOUNT_DIR"
    #cp -ap "$SOURCE_DIRECTORY/*" "$TMP_MOUNT_DIR"
    cp "${@:1:-1}" "$TMP_MOUNT_DIR/$TARGET_PATH"

    echo "Unmounting $TMP_MOUNT_DIR"
    umount "$TMP_MOUNT_DIR"

    echo "Removing temp dir $TMP_MOUNT_DIR"
    rm -rf "$TMP_MOUNT_DIR"

    #echo "Removing contents of current src dir (that should have been copied to the new volume)"
    #echo "rm -rf $SOURCE_DIRECTORY/*"
    #rm -rf "$SRC_DIR/*"
}

move_contents_to_volume(){

    SOURCE_DIRECTORY="$1"
    TARGET_VOLUME_ID="$2"

    ID_NAME=$(echo "$TARGET_VOLUME_ID" | sed 's+/++g')

    TMP_MOUNT_DIR="/tmp/temp_$ID_NAME"
    mkdir "$TMP_MOUNT_DIR"

    echo "Mounting volume $MAPPER_VOLUME_ID to temporary mount dir $TMP_MOUNT_DIR"
    mount "$MAPPER_VOLUME_ID" "$TMP_MOUNT_DIR"

    echo "Copying files from $SOURCE_DIRECTORY/* to $TMP_MOUNT_DIR"
    cp -ap "$SOURCE_DIRECTORY/*" "$TMP_MOUNT_DIR"

    echo "Unmounting $TMP_MOUNT_DIR"
    umount "$TMP_MOUNT_DIR"

    echo "Removing temp dir $TMP_MOUNT_DIR"
    rm -rf "$TMP_MOUNT_DIR"

    echo "Removing contents of current src dir (that should have been copied to the new volume)"
    echo "rm -rf $SOURCE_DIRECTORY/*"
    #rm -rf "$SRC_DIR/*"
}



echo "Mounting new volume: mount $MAPPER_VOLUME_ID $SRC_DIR"
mount "$MAPPER_VOLUME_ID" "$SRC_DIR"

ls "$SRC_DIR"
lsblk -f
