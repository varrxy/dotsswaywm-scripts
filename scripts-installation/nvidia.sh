#!/bin/bash

# Color definitions
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"  # Reset color

# Function to show a spinner while waiting
show_spinner() {
    local pid=$1
    local delay=0.2
    local spin='-\|/'

    while ps -p $pid > /dev/null; do
        for i in $(seq 0 3); do
            echo -ne "\r${BLUE}Processing... ${spin:$i:1}   ${RESET}"
            sleep $delay
        done
    done
    echo -ne "\r${RESET}"  # Clear the spinner line
}

# Update package list
echo -e "${CYAN}Updating package list...${RESET}"
{
    sudo apt update
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Package list updated successfully!${RESET}"
else
    echo -e "${RED}Failed to update package list. Exiting.${RESET}"
    exit 1
fi

# Define the NVIDIA sources line
nvidia_source="deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware"

# Check if the NVIDIA sources line is already present
if ! grep -q "$nvidia_source" /etc/apt/sources.list; then
    echo -e "${CYAN}Adding contrib, non-free, and non-free-firmware to /etc/apt/sources.list...${RESET}"
    {
        echo "$nvidia_source" | sudo tee -a /etc/apt/sources.list
    } &
    show_spinner $!
else
    echo -e "${GREEN}NVIDIA sources already present in /etc/apt/sources.list.${RESET}"
fi

# Update package list again
echo -e "${CYAN}Updating package list again...${RESET}"
{
    sudo apt update
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Package list updated successfully!${RESET}"
else
    echo -e "${RED}Failed to update package list. Exiting.${RESET}"
    exit 1
fi

# Install Linux headers
echo -e "${CYAN}Installing Linux headers...${RESET}"
{
    sudo apt install -y linux-headers-$(uname -r)
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Linux headers installed successfully!${RESET}"
else
    echo -e "${RED}Failed to install Linux headers. Exiting.${RESET}"
    exit 1
fi

# Install NVIDIA driver and firmware
echo -e "${CYAN}Installing NVIDIA driver and necessary firmware...${RESET}"
{
    sudo apt install -y nvidia-driver firmware-misc-nonfree
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}NVIDIA driver and firmware installed successfully!${RESET}"
else
    echo -e "${RED}Failed to install NVIDIA driver and firmware. Exiting.${RESET}"
    exit 1
fi

# Enable 32-bit architecture
echo -e "${CYAN}Enabling 32-bit architecture...${RESET}"
{
    sudo dpkg --add-architecture i386
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}32-bit architecture enabled successfully!${RESET}"
else
    echo -e "${RED}Failed to enable 32-bit architecture. Exiting.${RESET}"
    exit 1
fi

# Update package list for 32-bit libraries
echo -e "${CYAN}Updating package list for 32-bit libraries...${RESET}"
{
    sudo apt update
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Package list for 32-bit libraries updated successfully!${RESET}"
else
    echo -e "${RED}Failed to update package list for 32-bit libraries. Exiting.${RESET}"
    exit 1
fi

# Install 32-bit NVIDIA libraries
echo -e "${CYAN}Installing 32-bit NVIDIA libraries...${RESET}"
{
    sudo apt install -y nvidia-driver-libs:i386
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}32-bit NVIDIA libraries installed successfully!${RESET}"
else
    echo -e "${RED}Failed to install 32-bit NVIDIA libraries. Exiting.${RESET}"
    exit 1
fi

# Enable kernel modesetting
echo -e "${CYAN}Enabling kernel modesetting...${RESET}"
{
    echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nvidia-drm.modeset=1"' | sudo tee /etc/default/grub.d/nvidia-modeset.cfg
    sudo update-grub
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Kernel modesetting enabled successfully!${RESET}"
else
    echo -e "${RED}Failed to enable kernel modesetting. Exiting.${RESET}"
    exit 1
fi

# Install NVIDIA suspend helper scripts
echo -e "${CYAN}Installing NVIDIA suspend helper scripts...${RESET}"
{
    sudo apt install -y nvidia-suspend-common
    sudo systemctl enable nvidia-suspend.service
    sudo systemctl enable nvidia-hibernate.service
    sudo systemctl enable nvidia-resume.service
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}NVIDIA suspend helper scripts installed successfully!${RESET}"
else
    echo -e "${RED}Failed to install NVIDIA suspend helper scripts. Exiting.${RESET}"
    exit 1
fi

# Check and set PreserveVideoMemoryAllocations
echo -e "${CYAN}Checking PreserveVideoMemoryAllocations parameter...${RESET}"
if ! grep -q "PreserveVideoMemoryAllocations: 1" /proc/driver/nvidia/params; then
    echo -e "${CYAN}Setting PreserveVideoMemoryAllocations to 1...${RESET}"
    {
        echo 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' | sudo tee /etc/modprobe.d/nvidia-power-management.conf
    } &
    show_spinner $!
    echo -e "${GREEN}PreserveVideoMemoryAllocations set successfully!${RESET}"
else
    echo -e "${GREEN}PreserveVideoMemoryAllocations is already set to 1.${RESET}"
fi

# Final message
echo -e "${GREEN}NVIDIA driver installation and configuration complete! Please reboot your system.${RESET}"
