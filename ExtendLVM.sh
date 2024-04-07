#!/bin/bash

lsblk -f

echo -e "\nEnter the name of the disk to use (e.g., /dev/sdX):"
read disk_name

# Check if the disk already belongs to the volume group
if pvs -o vg_name "$disk_name" &>/dev/null; then
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
                    lsblk -f
                    echo "#####################################################################"
                    fdisk -l
                    echo "#####################################################################"
                    df -h
                    echo "Don't forget to check /var/log/message for disk errors."
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
