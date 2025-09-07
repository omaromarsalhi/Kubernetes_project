#!/bin/bash

# Simple Ansible installation script for bastion host - Amazon Linux 2023
dnf update -y
dnf install -y python3 python3-pip
pip3 install ansible

# Copy the SSH key from repository and set proper permissions
cat > /home/ec2-user/.ssh/id_rsa << 'EOF'
${ssh_private_key}
EOF
chmod 600 /home/ec2-user/.ssh/id_rsa
chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa

echo "Ansible installed and SSH key configured"
