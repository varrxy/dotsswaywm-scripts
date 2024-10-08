#!/bin/bash

# Update package list
sudo apt update

# Install Bluetooth packages
sudo apt install -y bluetooth bluez blueman pulseaudio pulseaudio-module-bluetooth

# Enable Bluetooth service
sudo systemctl enable bluetooth
