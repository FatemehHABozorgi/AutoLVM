#!/bin/bash

lsblk -f

echo -e "\nEnter y or n:"

read var

if [[ "$var" == "y" ]]; then
	echo "#####################################################################"

	echo -e "\nEnter the name(s) of the disk(s) to use (e.g., /dev/sdX /dev/sdY):"
	read -a disk_names

	# Check if any of the disks are already part of the volume group
	for disk_name in "${disk_names[@]}"; do
		if pvs -o vg_name "$disk_name" &>/dev/null; then
			echo "Error: The disk '$disk_name' is already part of a volume group."
			exit 1
		fi
	done

	for disk_name in "${disk_names[@]}"; do
		if [[ -b "$disk_name" ]]; then
			echo "#####################################################################"
			echo "Creating physical volume on $disk_name..."
			if pvcreate "$disk_name"; then
				echo "Physical volume created successfully."
				echo "#####################################################################"
				echo "Extending volume group with $disk_name..."
				if vgextend vgdata "$disk_name"; then
					echo "Volume group extended successfully with $disk_name."
				else
					echo "Error: Failed to extend volume group with $disk_name."
					exit 1
				fi
			else
				echo "Error: Failed to create physical volume on $disk_name."
				exit 1
			fi
		else
			echo "Error: The specified disk '$disk_name' does not exist or is not a block device."
			exit 1
		fi
	done

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
			echo "#####################################################################"
			
			echo "Don't forget to check /var/log/message for disk errors."
			echo "Done :)"
		else
			echo "Error: Failed to grow file system."
		fi
	else
		echo "Error: Failed to extend logical volume."
	fi
fi
