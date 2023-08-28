#!/bin/bash
######################################################
######################################################
############## CHAIN OS INSTALL SCRIPT ###############
######################################################
######################################################
printf "Please enter your Diskname:\n"
read disk
loadkeys us
ls /sys/firmware/efi/efivars 1>/dev/null &&
echo "Running in UEFI Mode\n"
ping -c 4 archlinux.org 1>/dev/null &&
echo "Online" || (echo "Offline, exiting...\n"& exit 0)
timedatectl set-ntp true &&
timedatectl status
printf "Creating Bootpartition..."
# gfdisk /dev/$disk
sgdisk -n 1:0:+500MiB -c 1:"EFI System Partition" -t 1:ef00 "${echo /dev/$disk'1'}" &&
printf "Done." || ( printf "Faliled to create Bootpartition... exiting\n"& exit 0)
parted -s /dev/$disk mkpart -f System btrfs 510MiB 100% &&
printf "Created System partition" || ( printf "Faliled to create System partition... exiting\n"& exit 0)
mkfs.fat $(echo /dev/$disk'1') &&
printf "Created fat FS" || ( printf "Failed to create fat FS exiting...\n"& exit 0 )
mkfs.btrfs $(echo /dev/$disk'2') &&
printf "Created btrfs FS" || ( printf "Failed to create btrfs FS exiting...\n"& exit 0 )
mount $(echo /dev/$disk'2') /mnt 1>/dev/null &&
printf "Mounted $(echo /dev/$disk'2') on /mnt\n"
btrfs subvolume create /mnt/@ 1>/dev/null &&
printf "Created subvolume @\n"
btrfs subvolume create /mnt/@root 1>/dev/null &&
printf "Created subvolume @root\n"
btrfs subvolume create /mnt/@var 1>/dev/null &&
printf "Created subvolume @var\n"
btrfs subvolume create /mnt/@home 1>/dev/null &&
printf "Created subvolume @home\n"
btrfs subvolume create /mnt/@snapshots 1>/dev/null &&
printf "Created subvolume @snapshots\n"
umount $(echo /dev/$disk'2') &&
printf "Unmounted /dev/$disk'2')\n"
mount -o subvol=@ $(echo /dev/$disk'2') /mnt 1>/dev/null &&
printf "Mounted subvolume @ on /mnt\n"
mkdir /mnt/.snapshots /mnt/home /mnt/root /mnt/var /mnt/boot 1>/dev/null &&
printf "Created directories in /mnt\n"
mount -o subvol=@root $(echo /dev/$disk'2') /mnt/root 1>/dev/null &&
printf "Mounted @root\n"
mount -o subvol=@home $(echo /dev/$disk'2') /mnt/home 1>/dev/null &&
printf "Mounted @home\n"
mount -o subvol=@var $(echo /dev/$disk'2') /mnt/var 1>/dev/null &&
printf "Mounted @var\n"
mount -o subvol=@snapshots $(echo /dev/$disk'2') /mnt/.snapshots 1>/dev/null &&
printf "Mounted @snapshots\n"
mount $(echo /dev/$disk'1') /mnt/boot 1>/dev/null &&
printf "Mounted ESP on /mnt/boot\n"
printf "Starting pacstrap ...\n"
pacstrap /mnt base base-devel linux-zen &&
printf "Finished pacstrap\n"
genfstab -U /mnt >> /mnt/etc/fstab &&
printf "Generated fstab\n"
cp pkgs.txt /mnt/root/ &&
cp chroot-install.sh /mnt/root/ &&
printf "Copied scripts into chroot\n"
printf "Please run arch-chroot /mnt and bash ./chroot-install.sh\n"
