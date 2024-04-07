#!/bin/bash

# OS: Redhat
# Filesystem: xfs

lsblk -f

echo "\nEnter the name(s) of the disk(s) to use (e.g., /dev/sdX /dev/sdY):"
read -a disk_names

echo -e "\nConfirm the disk list with yes or no:"
read var

if [[ "$var" == "yes" ]]; then
    echo "#####################################################################"
    # Check if any of the disks are already part of the volume group
    for disk_name in "${disk_names[@]}"; do
        if pvs -o vg_name "$disk_name" &>/dev/null; then
            echo "Error: The disk '$disk_name' is already part of a volume group."
            exit 1
        fi
    done

    echo "#####################################################################"
    echo "Creating physical volumes..."
    for disk_name in "${disk_names[@]}"; do
        if [[ -b "$disk_name" ]]; then
            if pvcreate "$disk_name"; then
                echo "Physical volume created successfully on $disk_name."
            else
                echo "Error: Failed to create a physical volume on $disk_name."
                exit 1
            fi
        else
            echo "Error: The specified disk '$disk_name' does not exist or is not a block device."
            exit 1
        fi
    done

    echo "#####################################################################"
    echo "Creating volume group..."
    if vgcreate vgdata "${disk_names[@]}"; then
        echo "Volume group 'vgdata' created successfully."
    else
        echo "Error: Failed to create volume group 'vgdata'."
        exit 1
    fi

    echo "#####################################################################"
    echo "Creating logical volume..."
    if lvcreate -n lvdata -l +95%FREE vgdata; then
        echo "Logical volume 'lvdata' created successfully."
    else
        echo "Error: Failed to create logical volume 'lvdata'."
        exit 1
    fi

    echo "#####################################################################"
    echo "Creating file system..."
    if mkfs.xfs /dev/mapper/vgdata-lvdata; then
        echo "File system created successfully."
    else
        echo "Error: Failed to create file system."
        exit 1
    fi

    echo "#####################################################################"
    echo "Mounting logical volume..."
    if mkdir -v /data && mount -v /dev/mapper/vgdata-lvdata /data/; then
        echo "Logical volume mounted successfully."
    else
        echo "Error: Failed to mount logical volume."
        exit 1
    fi

    echo "#####################################################################"
    echo -e "/dev/mapper/vgdata-lvdata\t/data\txfs\tdefaults,noatime,nodiratime\t0 0" >> /etc/fstab
    echo "Updated /etc/fstab:"
    cat /etc/fstab

    echo "#####################################################################"
    lsblk
    echo "#####################################################################"
    fdisk -l
    echo "#####################################################################"
    df -h
    echo "#####################################################################"
fi

echo "Don't forget to check /var/log/message for disk errors."
echo "Done :)"
