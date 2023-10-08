lsblk

#Nvme1 = /dev/nvme0n1
#Nvme2 = /dev/nvme2n1

sudo fdisk /dev/nvme0n1
g
n
+800M
t
1

n
t
30
w

sudo fdisk /dev/nvme1n1
g
n
t
30
w

#For automatization of fdisk
#cat <<EOF | sudo fdisk "/dev/$BLOCK_LABEL"
#p
#$PARTITION_TABLE_TYPE
#n
#
#
#
#
#y
#t
#$PARTITION_TYPE_HEX
#w
#EOF

sudo apt-get install lvm2

sudo -i

pvs
lvs
vgs

pvcreate /dev/nvme0n1p2
pvcreate /dev/nvme1n1p1
pvs


VOL_GRP=nvmegroup

vgcreate "$VOL_GRP" /dev/nvme0n1p2 /dev/nvme1n1p1
#vgextend to add?
vgs



adapt_reserved_percent(){

    VIRT_GROUP="$1"
    LV_NAME="$2"
    RESERVED_PERCENT="$3"

    #Amount of space reserved for root can be calculated with "Reserved block count" * "Block Size" Bytes
    sudo tune2fs -l /dev/$VIRT_GROUP/$LV_NAME
    # Decrease space reserved for root and inodes to 2%
    sudo tune2fs -m "$RESERVED_PERCENT" /dev/$VIRT_GROUP/$LV_NAME
}

add_fstab_entry(){
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
}

# ------ Add logical volume for Root (where the OS and applications are installed to)
#stripes = 2 -> 2 stripes -> as there are 2 phsical volumes/devices, we choose 2
#stripesize minimum size of a file where striping starts - higher numbers have better performance on large files, while smaller files are only written to one disk and therefore do not benefit from striping
lvcreate --stripes 2 --stripesize 32k --size 100G -n kubuntu-root nvmegroup
#lvcreate --stripes 2 --stripesize 32k --size 100G -n kubuntu-root "$VOL_GRP"
mkfs.ext4 -L Root /dev/"$VOL_GRP"/kubuntu-root
file -L --special-files /dev/"$VOL_GRP"/kubuntu-root

adapt_reserved_percent "$VOL_GRP" pmarkus 2
#/dev/mapper/"$VOL_GRP"-kubuntu--root / ext4 errors=remount-ro 0 1
#add_fstab_entry /dev/mapper/"$VOL_GRP"-kubuntu--root / ext4 1 errors=remount-ro
#mount /dev/mapper/"$VOL_GRP"-kubuntu--root /

# ------ Add logical volume for user pmarkus
export USER_NAME=pmarkus

lvcreate --stripes 2 --stripesize 32k --size 400G -n "$USER_NAME" "$VOL_GRP"
mkfs.ext4 -L Markus /dev/"$VOL_GRP"/$USER_NAME
file -L --special-files /dev/"$VOL_GRP"/$USER_NAME

adapt_reserved_percent "$VOL_GRP" pmarkus 2
add_fstab_entry /dev/mapper/"$VOL_GRP"-$USER_NAME /home/$USER_NAME ext4
mount /dev/mapper/"$VOL_GRP"-$USER_NAME /home/$USER_NAME

# ------ Add logical volume for flatpak applications
lvcreate --stripes 2 --stripesize 32k --size 40G -n flatpak "$VOL_GRP"
mkfs.ext4 -L Flatpak /dev/"$VOL_GRP"/flatpak
file -L --special-files /dev/"$VOL_GRP"/flatpak

mount /dev/"$VOL_GRP"/flatpak /var/lib/flatpak
#Assemble flatpak fs - mount at boot
#echo '/dev/mapper/"$VOL_GRP"-flatpak /var/lib/flatpak ext4 defaults 0 2' | sudo tee -a /etc/fstab
adapt_reserved_percent "$VOL_GRP" flatpak 2
add_fstab_entry /dev/mapper/"$VOL_GRP"-flatpak /var/lib/flatpak ext4
mount /dev/mapper/"$VOL_GRP"-flatpak /var/lib/flatpak
# ------


SWAP_FILE_SIZE=4G
SWAP_FILE_NAME=swapfile

#Create swap file with 4G
sudo fallocate -l $SWAP_FILE_SIZE /swapfile
ls -lh /$SWAP_FILE_NAME
sudo chmod 600 /$SWAP_FILE_NAME
ls -lh /$SWAP_FILE_NAME
sudo mkswap /$SWAP_FILE_NAME
sudo swapon /$SWAP_FILE_NAME
sudo swapon --show
#/swapfile none swap sw 0 0 --> /etc/fstab
add_fstab_entry /$SWAP_FILE_NAME none swap 0 sw



lvcreate --stripes 2 --stripesize 32k --size 50G -n docker-vol "$VOL_GRP"
mkfs.ext4 -L Docker /dev/"$VOL_GRP"/docker-vol
file -L --special-files /dev/"$VOL_GRP"/docker-vol

adapt_reserved_percent "$VOL_GRP" docker-vol 2
add_fstab_entry /dev/mapper/"$VOL_GRP"-docker--vol /var/lib/docker ext4

mkdir /mnt/temp_docker_mount
mount /dev/mapper/"$VOL_GRP"-docker--vol /mnt/temp_docker_mount
cp -ap /var/lib/docker/* /mnt/temp_docker_mount
umount /mnt/temp_docker_mount

rm -rf /var/lib/docker
mkdir /var/lib/docker
mount /dev/mapper/"$VOL_GRP"-docker--vol /var/lib/docker

lsblk -f


#PARTITION_NAME=boot
#lvcreate --size 624M -n "$PARTITION_NAME" "$VOL_GRP"
#mkfs.ext4 -L Boot /dev/"$VOL_GRP"/"$PARTITION_NAME"
#file -L --special-files /dev/"$VOL_GRP"/"$PARTITION_NAME"
#adapt_reserved_percent "$VOL_GRP" "$PARTITION_NAME" 2
#add_fstab_entry "/dev/mapper/$VOL_GRP-$PARTITION_NAME" /boot ext4 1



