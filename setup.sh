#!/bin/bash

mkfs.ext4 /dev/sda

mkdir -p /data

mount -t ext4 /dev/sda /data

timedatectl set-timezone Asia/Calcutta

echo "Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y
