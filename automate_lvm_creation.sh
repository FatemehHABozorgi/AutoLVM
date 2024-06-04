#!/bin/bash

# OS: Redhat
# Filesystem: xfs

set -ox pipefail

vg_name="vgdata"
lv_name="lvdata"

lsblk -f

echo "Enter the name(s) of the disk(s) to use (e.g., /dev/sdX /dev/sdY):"
read -a disk_names

read -rp "Are you sure you want to use the provided disk(s)? (yes/no): " var

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
    if vgcreate "$vg_name" "${disk_names[@]}"; then
        echo "Volume group '$vg_name' created successfully."
    else
        echo "Error: Failed to create volume group '$vg_name'."
        exit 1
    fi

    echo "#####################################################################"
    echo "Creating logical volume..."
    if lvcreate -n "$lv_name" -l +95%FREE "$vg_name"; then
        echo "Logical volume '$lv_name' created successfully."
    else
        echo "Error: Failed to create logical volume '$lv_name'."
        exit 1
    fi

    echo "#####################################################################"
    echo "Creating file system..."
    if mkfs.xfs /dev/mapper/"$vg_name"-"$lv_name"; then
        echo "File system created successfully."
    else
        echo "Error: Failed to create file system."
        exit 1
    fi

    echo "#####################################################################"
    echo "Mounting logical volume..."
    if mkdir -v /data && mount -v /dev/mapper/"$vg_name"-"$lv_name" /data/; then
        echo "Logical volume mounted successfully."
    else
        echo "Error: Failed to mount logical volume."
        exit 1
    fi

    echo "#####################################################################"
    echo -e "/dev/mapper/$vg_name-$lv_name\t/data\txfs\tdefaults,noatime,nodiratime\t0 0" >> /etc/fstab
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

echo "Don't forget to check /var/log/messages for disk errors."
echo "Done :)"
