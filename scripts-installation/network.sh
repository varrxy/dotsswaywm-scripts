#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt update

# Install NetworkManager
echo "Installing NetworkManager..."
sudo apt install -y network-manager

# Configure NetworkManager to disable ifupdown management
echo "Configuring NetworkManager..."
sudo tee /etc/NetworkManager/NetworkManager.conf > /dev/null <<EOL
[main]
plugins=keyfile

[ifupdown]
managed=false
EOL

# Enable NetworkManager to start at boot
echo "Enabling NetworkManager to start at boot..."
sudo systemctl enable NetworkManager

# Optional: Add current user to netdev group
echo "Adding user to netdev group (optional)..."
sudo usermod -aG netdev $USER

echo "NetworkManager installed and configured successfully."
echo "Log out and back in for group changes to take effect."
