#!/bin/bash

# Update system
dnf update -y

# Install NFS utilities for EFS mounting
dnf install -y nfs-utils

# Create EFS mount directory
mkdir -p /mnt/efs

# Mount EFS filesystem
echo "${efs_dns_name}:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab

# Mount immediately
mount -a

# Create a test file to verify EFS is working
echo "EFS mounted successfully on $(hostname)" > /mnt/efs/efs-test.txt
date >> /mnt/efs/efs-test.txt

# Set proper permissions
chmod 755 /mnt/efs
