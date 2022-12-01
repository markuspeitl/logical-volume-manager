#!/bin/bash

DEVICE_VOLUME="$1"
MOUNT_POINT="$2"
FILE_SYSTEM="$3"
MOUNT_ORDER="$4"
OPTIONS="$5"

if [ -z "$MOUNT_ORDER" ]; then
    MOUNT_ORDER=2
fi

if [ -z "$OPTIONS" ]; then
    OPTIONS=defaults
fi

FSTAB_CONFIG=/etc/fstab


echo "Current /etc/fstab:"
cat "$FSTAB_CONFIG"
echo -e "\n"

FS_TABLE_ENTRY="$DEVICE_VOLUME $MOUNT_POINT $FILE_SYSTEM $OPTIONS 0 $MOUNT_ORDER"

echo "Fstab entry to write:"
echo "$FS_TABLE_ENTRY"

DEVICE_FOUND=$(echo "$FSTAB_CONFIG" | grep $DEVICE_VOLUME)

if [ -z "$DEVICE_FOUND" ]; then
    echo "$FS_TABLE_ENTRY" | sudo tee -a /etc/fstab
else
    echo "Device: $DEVICE_VOLUME is already mounted in $FSTAB_CONFIG , please open and resolve manually!"
    echo "Would have written:"
    echo $FS_TABLE_ENTRY
fi
