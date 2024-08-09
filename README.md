# AutoLVM: Automated LVM Creation and Management

## Description
`AutoLVM` is a set of Bash scripts designed for Red Hat-based systems that automate the process of creating and extending Logical Volume Management (LVM) partitions. These scripts simplify the management of physical volumes, volume groups, logical volumes, and the associated file systems, specifically using the XFS file system. They also handle mounting and updating the `/etc/fstab` file for persistent storage across reboots.

### Scripts Included:
1. **LVM Creation Script** (`automate_lvm_creation.sh`): Automates the creation of LVM, including physical volumes, volume groups, logical volumes, and file systems.
2. **LVM Extension Script** (`automate_lvm_extension.sh`): Automates the extension of an existing LVM by adding new disks and extending the logical volume and file system.

## Features
- **LVM Creation Script**:
  - Automatically creates physical volumes from specified disks.
  - Creates a volume group and logical volume.
  - Formats the logical volume with the XFS file system.
  - Mounts the logical volume to a specified directory.
  - Updates `/etc/fstab` for persistent mounting.

- **LVM Extension Script**:
  - Checks if disks are already part of another volume group.
  - Extends an existing volume group with new disks.
  - Extends an existing logical volume.
  - Grows the file system to utilize the newly extended space.

## Requirements
- **Operating System**: Red Hat-based distributions (e.g., RHEL, CentOS, Fedora).
- **Filesystem**: XFS.
- **Dependencies**: 
  - `lsblk`
  - `pvs`
  - `vgcreate`
  - `lvcreate`
  - `mkfs.xfs`
  - `vgextend`
  - `lvextend`
  - `xfs_growfs`

## Usage

### 1. Clone the Repository
First, clone the repository to your local machine:
```
git clone https://github.com/FatemehHABozorgi/AutoLVM.git
cd AutoLVM
```

2. Make the Scripts Executable
Make both scripts executable:

```
chmod +x automate_lvm_creation.sh
chmod +x automate_lvm_extension.sh
```
3. Run the Scripts
LVM Creation Script
Execute the automate_lvm_creation.sh script to create a new LVM:
```
./create_lvm.sh
```
The script will prompt you to enter the disk(s) you wish to use for the LVM creation.
Confirm your selection when prompted.


LVM Extension Script
Execute the automate_lvm_extension.sh script to extend an existing LVM:
```
./extend_lvm.sh
```
The script will prompt you to enter the disk(s) you wish to add to the existing volume group.
Confirm your selection when prompted.


4. Completion
Upon successful completion, the scripts will:

LVM Creation Script: Display the new disk layout, the current file system usage, and update /etc/fstab.
LVM Extension Script: Display the extended disk layout, the new file system size, and provide reminders to check for any disk errors.
Example
LVM Creation Script Example
bash
Copy code
lsblk -f

Enter the name(s) of the disk(s) to use (e.g., /dev/sdX /dev/sdY): /dev/sdb
Are you sure you want to use the provided disk(s)? (yes/no): yes

Creating physical volumes...
Physical volume created successfully on /dev/sdb.

Creating volume group...
Volume group 'vgdata' created successfully.

Creating logical volume...
Logical volume 'lvdata' created successfully.

Creating file system...
File system created successfully.

Mounting logical volume...
Logical volume mounted successfully.

Updated /etc/fstab:
...

Done :)
LVM Extension Script Example
bash
Copy code
lsblk -f

Enter the name(s) of the disk(s) to use (e.g., /dev/sdX /dev/sdY): /dev/sdc
Are you sure you want to use the provided disk(s)? (yes/no): yes

Creating physical volume on /dev/sdc...
Physical volume created successfully.

Extending volume group with /dev/sdc...
Volume group extended successfully.

Extending logical volume...
Logical volume extended successfully.

Growing file system...
File system grown successfully.

Don't forget to check /var/log/messages for disk errors.
Done :)
Troubleshooting
If you encounter any issues, please ensure:

The disks you specified are not already part of another volume group when running the extension script.
You are running the scripts with sufficient privileges (e.g., as root or using sudo).
Check /var/log/messages for any disk-related errors.

Contributing
Contributions are welcome! Please fork the repository and create a pull request with your changes.

License
This project is licensed under the MIT License. See the LICENSE file for more details.

Author
Created by Your Name.
