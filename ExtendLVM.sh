#!/bin/bash

lsblk

echo -e "\nEnter the name of the disk to use (e.g., /dev/sdX):"
read disk_name

# Check if the disk already belongs to the volume group
if vgs "$disk_name" &>/dev/null; then
    echo "Error: The disk '$disk_name' is already part of a volume group."
    exit 1
fi

if [[ -b "$disk_name" ]]; then
    echo "#####################################################################"
    echo "Creating physical volume..."
    if pvcreate "$disk_name"; then
        echo "Physical volume created successfully."
        echo "#####################################################################"
        echo "Extending volume group..."
        if vgextend vgdata "$disk_name"; then
            echo "Volume group extended successfully."
            echo "#####################################################################"
            echo "Extending logical volume..."
            if lvextend -l +95%FREE /dev/vgdata/lvdata; then
                echo "Logical volume extended successfully."
                echo "#####################################################################"
                echo "Growing file system..."
                if xfs_growfs /dev/mapper/vgdata-lvdata; then
                    echo "File system grown successfully."
                    echo "#####################################################################"
                    lsblk
                    echo "#####################################################################"
                    fdisk -l
                    echo "#####################################################################"
                    df -h
                    echo "Done :)"
                else
                    echo "Error: Failed to grow file system."
                fi
            else
                echo "Error: Failed to extend logical volume."
            fi
        else
            echo "Error: Failed to extend volume group."
        fi
    else
        echo "Error: Failed to create physical volume."
    fi
else
    echo "Error: The specified disk '$disk_name' does not exist or is not a block device."
fi
