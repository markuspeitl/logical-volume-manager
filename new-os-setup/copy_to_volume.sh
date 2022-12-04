 #!/bin/bash

echo "${@}"

#cp proxy that resolves volume identifier
#copy_to_volume(){

#for TARGET_LAST_ARGUMENT; do true; done
#echo $TARGET_LAST_ARGUMENT

#TARGET_LAST_ARGUMENT="${@:$#:$#}" || exit
TARGET_LAST_ARGUMENT="${!#}" || exit
echo "Selected path to device resolve: $TARGET_LAST_ARGUMENT"

TARGET_DEVICE=${TARGET_LAST_ARGUMENT%:*} || exit
echo "Selected device volume/partition: $TARGET_DEVICE"
TARGET_PATH=${TARGET_LAST_ARGUMENT##*:} || exit
echo "Selected path on device to copy to: $TARGET_PATH"

if [ -z "$TARGET_DEVICE" ]; then
    exit
fi


ID_NAME=$(echo "$TARGET_DEVICE" | sed 's+/++g')

TMP_MOUNT_DIR="/tmp/temp_$ID_NAME"
mkdir -p "$TMP_MOUNT_DIR"

echo "Mounting volume \"$TARGET_DEVICE\" to temporary mount dir \"$TMP_MOUNT_DIR\""
sudo mount "$TARGET_DEVICE" "$TMP_MOUNT_DIR" || exit

echo "Copying files: \"cp ${@:1:$# -1} $TMP_MOUNT_DIR/$TARGET_PATH\""
#echo "Copying files: \"cp ${*%${!#-1}} $TMP_MOUNT_DIR/$TARGET_PATH\""
#cp -ap "$SOURCE_DIRECTORY/*" "$TMP_MOUNT_DIR"
#From 1st argument to Length - 1 argument (ignore cp and ignore the last-target path)
sudo cp ${@:1:$# -1} "$TMP_MOUNT_DIR/$TARGET_PATH"
#sudo cp ${*%${!#-1}} "$TMP_MOUNT_DIR/$TARGET_PATH" || exit


echo "Unmounting $TMP_MOUNT_DIR"
sudo umount "$TMP_MOUNT_DIR" || exit

echo "Removing temp dir $TMP_MOUNT_DIR"
rm -rf "$TMP_MOUNT_DIR"

#echo "Removing contents of current src dir (that should have been copied to the new volume)"
#echo "rm -rf $SOURCE_DIRECTORY/*"
#rm -rf "$SRC_DIR/*"
#}

#echo -e "\n ------------------------ COPYVOLUME: \ncopy_to_volume ${@}"
#echo "X$(basename -- "$0")"
#copy_to_volume ${@}
