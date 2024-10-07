#!/bin/bash

# Color definitions
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"  # Reset color

# Function to execute a command and check its success
execute_command() {
    local command="$1"
    echo -e "${CYAN}Executing: $command${RESET}"
    
    # Execute the command
    eval "$command"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to execute: $command. Exiting.${RESET}"
        exit 1
    fi
}

# Update package list
execute_command "sudo apt update"

# Define the NVIDIA sources line
nvidia_source="deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware"

# Check if the NVIDIA sources line is already present
if ! grep -qF "$nvidia_source" /etc/apt/sources.list; then
    echo -e "${CYAN}Adding NVIDIA sources to /etc/apt/sources.list...${RESET}"
    execute_command "echo \"$nvidia_source\" | sudo tee -a /etc/apt/sources.list"
else
    echo -e "${GREEN}NVIDIA sources already present in /etc/apt/sources.list.${RESET}"
fi

# Update package list again
execute_command "sudo apt update"

# Install Linux headers
execute_command "sudo apt install -y linux-headers-\$(uname -r)"

# Install NVIDIA driver and firmware
execute_command "sudo apt install -y nvidia-driver firmware-misc-nonfree"

# Enable 32-bit architecture
execute_command "sudo dpkg --add-architecture i386"

# Update package list for 32-bit libraries
execute_command "sudo apt update"

# Install 32-bit NVIDIA libraries
execute_command "sudo apt install -y nvidia-driver-libs:i386"

# Enable kernel modesetting
echo -e "${CYAN}Enabling kernel modesetting...${RESET}"
echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nvidia-drm.modeset=1"' | sudo tee /etc/default/grub.d/nvidia-modeset.cfg
execute_command "sudo update-grub"

# Install NVIDIA suspend helper scripts
execute_command "sudo apt install -y nvidia-suspend-common"
execute_command "sudo systemctl enable nvidia-suspend.service"
execute_command "sudo systemctl enable nvidia-hibernate.service"
execute_command "sudo systemctl enable nvidia-resume.service"

# Check and set PreserveVideoMemoryAllocations
echo -e "${CYAN}Checking PreserveVideoMemoryAllocations parameter...${RESET}"
if ! grep -q "PreserveVideoMemoryAllocations: 1" /proc/driver/nvidia/params; then
    echo -e "${CYAN}Setting PreserveVideoMemoryAllocations to 1...${RESET}"
    execute_command "echo 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' | sudo tee /etc/modprobe.d/nvidia-power-management.conf"
    echo -e "${GREEN}PreserveVideoMemoryAllocations set successfully!${RESET}"
else
    echo -e "${GREEN}PreserveVideoMemoryAllocations is already set to 1.${RESET}"
fi

# Final message
echo -e "${GREEN}NVIDIA driver installation and configuration complete! Please reboot your system.${RESET}"
