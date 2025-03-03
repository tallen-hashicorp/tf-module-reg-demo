#!/bin/bash

# Install Terraform
apt-get update && apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
tee /etc/apt/sources.list.d/hashicorp.list
apt update
apt-get install terraform -y

# Clone our repo
cd /home/ubuntu
git clone https://github.com/tallen-hashicorp/tf-module-reg-demo.git

# Set the correct ownership for the cloned repo
chown -R ubuntu:ubuntu /home/ubuntu/tf-module-reg-demo

# Allow incoming
ufw default allow incoming

# Simulate Airgap
ufw default deny outgoing

# Allow TFC
ufw allow out to 75.2.98.97
ufw allow out to 99.83.150.238

# Allow DNS
ufw allow out 53

# Enable Firewall
ufw enable

# Print Status to /home/ubuntu/fw.txt
ufw status verbose > /home/ubuntu/fw.txt