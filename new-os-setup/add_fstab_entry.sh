#!/bin/bash

#add_fstab_entry.sh /dev/mapper/nvmegroup-kubuntu--root / ext4 1
#add_fstab_entry.sh "$DEVICE_VOLUME" "$MOUNT_POINT" "$FILE_SYSTEM" "$MOUNT_PRIORITY" "$OPTIONS"

DEVICE_VOLUME="$1"
MOUNT_POINT="$2"
FILE_SYSTEM="$3"
MOUNT_PRIORITY="$4"
OPTIONS="$5"

echo "Creating fstab mountpoint entry for: $DEVICE_VOLUME at $MOUNT_POINT"


if [ -z "$MOUNT_PRIORITY" ]; then
    MOUNT_PRIORITY=2
fi

if [ -z "$OPTIONS" ]; then
    OPTIONS=defaults
fi

FSTAB_CONFIG=/etc/fstab


echo "Current /etc/fstab:"
cat "$FSTAB_CONFIG"
echo -e "\n"

FS_TABLE_ENTRY="$DEVICE_VOLUME $MOUNT_POINT $FILE_SYSTEM $OPTIONS 0 $MOUNT_PRIORITY"

echo "Fstab entry to write:"
echo "$FS_TABLE_ENTRY"

DEVICE_FOUND=$(cat "$FSTAB_CONFIG" | grep -o "$DEVICE_VOLUME")

if [ -z "$DEVICE_FOUND" ]; then
    echo "$FS_TABLE_ENTRY" | sudo tee -a /etc/fstab
else
    echo "Device: $DEVICE_VOLUME is already mounted in $FSTAB_CONFIG , please open and resolve manually!"
    echo "Would have written:"
    echo $FS_TABLE_ENTRY
fi
