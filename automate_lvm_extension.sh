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

	for disk_name in "${disk_names[@]}"; do
		if [[ -b "$disk_name" ]]; then
			echo "#####################################################################"
			echo "Creating physical volume on $disk_name..."
			if pvcreate "$disk_name"; then
				echo "Physical volume created successfully."
				echo "#####################################################################"
				echo "Extending volume group with $disk_name..."
				if vgextend "$vg_name" "$disk_name"; then
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
	if lvextend -l +95%FREE /dev/"$vg_name"/"$lv_name"; then
		echo "Logical volume extended successfully."
		echo "#####################################################################"
		echo "Growing file system..."
		if xfs_growfs /dev/mapper/"$vg_name"-"$lv_name"; then
			echo "File system grown successfully."
			echo "#####################################################################"
			lsblk -f
			echo "#####################################################################"
			fdisk -l
			echo "#####################################################################"
			df -h
			echo "#####################################################################"
			
			echo "Don't forget to check /var/log/messages for disk errors."
			echo "Done :)"
		else
			echo "Error: Failed to grow file system."
		fi
	else
		echo "Error: Failed to extend logical volume."
	fi
fi
