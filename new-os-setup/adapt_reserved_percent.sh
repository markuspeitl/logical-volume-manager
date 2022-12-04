. "$(dirname "$0")"/../common_bash/arg-default.sh

adapt_reserved_percent(){

    LV_VOLUME_NAME="$1"
    RESERVED_PERCENT=$(setArgEnvDefault "$2" "$RESERVED_PERCENT" 2)
    #Optional for adapting logical volumes
    VIRTUAL_GROUP="$3"



    DEVICE_ID=/dev/$VIRTUAL_GROUP/$LV_VOLUME_NAME
    if [ -z "$VIRTUAL_GROUP" ]; then
        DEVICE_ID=/dev/$LV_VOLUME_NAME
    fi
    
    #Amount of space reserved for root can be calculated with "Reserved block count" * "Block Size" Bytes
    sudo tune2fs -l "$DEVICE_ID"
    # Decrease space reserved for root and inodes to 2%
    sudo tune2fs -m "$RESERVED_PERCENT" "$DEVICE_ID"
}

echo "adapt_reserved_percent ${@}"
#echo "X$(basename -- "$0")"
adapt_reserved_percent ${@}