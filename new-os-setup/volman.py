#!/usr/bin/env python

#volman create flatpak
#volman remove flatpak
#volman migrate /var/lib/flatpak flatpak nvmegroup 32k 2
#volman overlay 
#volman partition sda partitions.def
#volman create-module
#volman init audio-module

#python3 volman.py create "somevolname" "1G" "nvmegroup"
#python3 volman.py create \"gaming-volume\" \"150G\" \"nvmegroup\" --stripes 2 --stripesize 32k"
#python3 volman.py list
#python3 volman.py remove somevolname


import os
import subprocess
import os.path as path 

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Manage logical volumes and mount them in different points in the system."
    )

    parser.add_argument('-v','--version', action="store_true", help="show version")

    subparsers = parser.add_subparsers(dest='command', help='Available commands for volman: create, remove, migrate, overlay, partition, module')
    create_parser = subparsers.add_parser("create", help="Create new logical volume")
    list_parser = subparsers.add_parser("list", help="List existing logical volumes")
    remove_parser = subparsers.add_parser("remove", help="Remove logical volume by name")
    migrate_parser = subparsers.add_parser("migrate", help="Migrate from a directory to a new volume mount and transfer data")

    #STRIPES_CNT=2 STRIPES_SIZE=32k TARGET_FS_TYPE=ext4 RESERVED_PERCENT=2 create_logical_volume.sh flatpakvolumename 50G nvmegroup
    create_parser.add_argument('name', help="New logical volume name")
    create_parser.add_argument('size', help="Volume Size eg 50G, 10M, 1000K")
    create_parser.add_argument('group', help="Volume Group")
    create_parser.add_argument('-n', '--stripes', nargs='?', default=2, const=2, help="Number of stripes = number of physical devices in group", type=int)
    create_parser.add_argument('-s', '--stripesize', nargs='?', default="32k", const="32k", help="Size of a stripe, every file that is bigger than this size, uses striping -> higher write/read performance")
    create_parser.add_argument('-f', '--fstype', nargs='?', default="ext4", const="ext4", help="Target filesystem type (ext4,)")
    create_parser.add_argument('-r', '--reserved', nargs='?', default=2, const=2, help="Amount of the volume in percent reserved for root and inode storage", type=int)

    migrate_parser.add_argument('dir', help="Target directory that should be replaced by volume and holds files")
    migrate_parser.add_argument('name', help="New logical volume name")
    migrate_parser.add_argument('size', help="Volume Size eg 50G, 10M, 1000K")
    migrate_parser.add_argument('group', help="Volume Group")
    migrate_parser.add_argument('-n', '--stripes', nargs='?', default=2, const=2, help="Number of stripes = number of physical devices in group", type=int)
    migrate_parser.add_argument('-s', '--stripesize', nargs='?', default="32k", const="32k", help="Size of a stripe, every file that is bigger than this size, uses striping -> higher write/read performance")
    migrate_parser.add_argument('-f', '--fstype', nargs='?', default="ext4", const="ext4", help="Target filesystem type (ext4,)")
    migrate_parser.add_argument('-r', '--reserved', nargs='?', default=2, const=2, help="Amount of the volume in percent reserved for root and inode storage", type=int)
    migrate_parser.add_argument('-m', '--mprio', nargs='?', default=2, const=2, help="Mount priority in fstab entry 1 root efi early, 2 home, etc. or 0 disabled", type=int)

    remove_parser.add_argument('name', help="Volume Name")
    remove_parser.add_argument('-g', '--group', nargs='?', help="Volume group to delete logical volume from", type=int)

    arguments = parser.parse_args()

    print(arguments)
    #print(unknown)

    if arguments.command == 'create':
        script_location=path.join(path.dirname(__file__),"create_logical_volume.sh")
        script_runner="sudo " + script_location
        COMMAND=f"MOUNT_PRIORITY={arguments.mprio} STRIPES_CNT={arguments.stripes} STRIPES_SIZE={arguments.stripesize} TARGET_FS_TYPE={arguments.fstype} RESERVED_PERCENT={arguments.reserved} {script_runner} {arguments.name} {arguments.size} {arguments.group}"
        print("VOLMAN: Executing command:")
        print(COMMAND)
        os.system(COMMAND)

    if arguments.command == 'migrate':
        script_location=path.join(path.dirname(__file__),"convert_dir_logical_volume.sh")
        script_runner="sudo " + script_location
        COMMAND=f"MOUNT_PRIORITY={arguments.mprio} STRIPES_CNT={arguments.stripes} STRIPES_SIZE={arguments.stripesize} TARGET_FS_TYPE={arguments.fstype} RESERVED_PERCENT={arguments.reserved} {script_runner} {arguments.dir} {arguments.name} {arguments.size} {arguments.group}"
        print("VOLMAN: Executing command:")
        print(COMMAND)
        os.system(COMMAND)

    elif arguments.command == 'list':
        #script_location=path.join(path.dirname(__file__),"create_logical_volume.sh")
        script_runner="sudo " + "lvs"
        COMMAND=f"{script_runner}"
        #os.system(COMMAND)
        #CMD="konsole -e '" + COMMAND + "'"
        #subprocess.call(COMMAND, shell=True)
        #process = subprocess.Popen(COMMAND.split(), shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        os.system(COMMAND)

    elif arguments.command == 'remove':
        #script_location=path.join(path.dirname(__file__),"create_logical_volume.sh")
        
        list_output = str(subprocess.check_output(['sudo','lvs']))
        
        import re

        #Sub multiple spaces with 1
        list_output = re.sub('\s+',' ',list_output)
        list_output = list_output.replace("'","")
        
        lines = list_output.split('\\n')
        entries = lines[1:len(lines) - 1]
        #print(entries)

        vol_names=[]
        vol_groups=[]

        for entry in entries:
            parts=entry.split(' ')
            vol_names.append(parts[1])
            vol_groups.append(parts[2])

        #print(vol_names)
        #print(vol_groups)

        matching_names=[]
        matching_groups=[]

        for x in range(0, len(vol_names)):

            if vol_names[x] == arguments.name:

                matching_names.append(vol_names[x])
                matching_groups.append(vol_groups[x])
        
        match_count=len(matching_names) 

        #print("Matches:")
        #print(matching_names)

        if match_count <= 0:
            print(f"'{arguments.name}' not found in logical volume list")
            exit()
        if len(matching_names) > 1:
            for x in range(0, len(matching_names)):
                print(str(x) + ". NAME: " + matching_names[x] + " GROUP: " + matching_groups[x])
                
            print(str(len(matching_names)) + ". Abort.")
            print('Please select a volume to delete:')
            answer = input()
            sel_number = int(answer)

            if sel_number < 0 or sel_number >= len(matching_names):
                exit()
            else:
                selected_name = matching_names[sel_number]
                selected_group = matching_groups[sel_number]
        else:
            selected_name = matching_names[0]
            selected_group = matching_groups[0]

        print("Deleting '" + selected_name + "' of group '" + selected_group + "'")

        print('Are you sure? (y/n)')
        answer = input()

        if(answer == 'y' or answer == 'yes'):
        
            device_id=f"/dev/{selected_group}/{selected_name}"
            print(f"Unmounting: {device_id}")
            os.system(f"sudo umount {device_id}")

            script_runner = "sudo lvremove"
            COMMAND = f"{script_runner} {device_id}"
            os.system(COMMAND)
        

    elif arguments.command == 'remove':
        print("Remove selected")
