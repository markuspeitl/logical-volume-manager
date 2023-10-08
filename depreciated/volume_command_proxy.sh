

#TODO Implement -> move to python or node -> easier to implement
# HOW:
# Search for volume label paths in passed command
# Mount all device partitions that were found in the command
# Replace volume label indicators in all paths with the now mounted temp dirs
# Execute the passed and modified command
# Unmount and clean up temp files



TARGET_LAST_ARGUMENT="${@: -1}"
echo "$TARGET_LAST_ARGUMENT"


TARGET_DEVICE=${TARGET_LAST_ARGUMENT%:*}
echo "Selected device volume/partition: $TARGET_DEVICE"
TARGET_PATH=${TARGET_LAST_ARGUMENT##*:}
echo "Selected path on device to copy to: $TARGET_PATH"

ID_NAME=$(echo "$TARGET_DEVICE" | sed 's+/++g')

TMP_MOUNT_DIR="/tmp/temp_$ID_NAME"
mkdir -p "$TMP_MOUNT_DIR"

echo "Mounting volume $TARGET_DEVICE to temporary mount dir $TMP_MOUNT_DIR"
sudo mount "$TARGET_DEVICE" "$TMP_MOUNT_DIR" || exit

echo "Copying files: \"cp ${@:1:$#-1} $TMP_MOUNT_DIR/$TARGET_PATH\""
#cp -ap "$SOURCE_DIRECTORY/*" "$TMP_MOUNT_DIR"
sudo cp ${@:1:$#-1} "$TMP_MOUNT_DIR/$TARGET_PATH"

echo "Unmounting $TMP_MOUNT_DIR"
sudo umount "$TMP_MOUNT_DIR" || exit

echo "Removing temp dir $TMP_MOUNT_DIR"
rm -rf "$TMP_MOUNT_DIR"

#echo "Removing contents of current src dir (that should have been copied to the new volume)"
#echo "rm -rf $SOURCE_DIRECTORY/*"
#rm -rf "$SRC_DIR/*"
