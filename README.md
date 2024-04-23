# Volman - Logical Volume manager

Scripts for: 
- Setting up logical volumes
- Migrating data to the lvms
- Adding fstab entries for automounting on os startup
- Removing lvms

Available scripts and operations can be used via the *volman* tool/script.
``python3 operations/volman.py --help``

Calibrated for striped setup of disks and creation, deletion and extension of
logical volumes.
Also has an option to migrate a directory of the filesystem onto its
own logical volume partition. (directory replaced by a mount)
