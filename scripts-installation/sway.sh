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
            echo -ne "\r${CYAN}Processing... ${spin:$i:1}   ${RESET}"
            sleep $delay
        done
    done
    echo -ne "\r${RESET}"  # Clear the spinner line
}

# Update package list
echo -e "${CYAN}Updating package list...${RESET}"
if sudo apt update; then
    echo -e "${GREEN}Package list updated successfully!${RESET}"
else
    echo -e "${RED}Failed to update package list. Exiting.${RESET}"
    exit 1
fi

# Install Sway and related packages
echo -e "${CYAN}Installing Sway and related packages...${RESET}"
{
    sudo apt install -y sway swaybg swayidle swaylock xwayland xdg-desktop-portal-wlr waybar wofi wlogout sway-notification-center qt5ct libglib2.0-bin grim slurp lxpolkit thunar
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Sway and related packages installed successfully!${RESET}"
else
    echo -e "${RED}Failed to install Sway and related packages. Exiting.${RESET}"
    exit 1
fi

# Set environment variables for Qt
echo -e "${CYAN}Setting environment variables for Qt...${RESET}"
{
    {
        grep -q "QT_QPA_PLATFORMTHEME=qt5ct" /etc/environment || echo "QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a /etc/environment
    }
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Environment variables set successfully!${RESET}"
else
    echo -e "${RED}Failed to set environment variables. Exiting.${RESET}"
    exit 1
fi

# Clone the configuration repository into /tmp
TEMP_DIR="/tmp/dots-swaywm"
echo -e "${CYAN}Cloning Sway configuration repository into ${TEMP_DIR}...${RESET}"
{
    git clone https://github.com/varrxy/dots-swaywm "$TEMP_DIR"
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Configuration repository cloned successfully!${RESET}"
else
    echo -e "${RED}Failed to clone the repository. Exiting.${RESET}"
    exit 1
fi

# Remove the .git directory immediately after cloning
echo -e "${YELLOW}Removing .git directory...${RESET}"
rm -rf "$TEMP_DIR/.git"

# Create the config directory if it doesn't exist
echo -e "${CYAN}Creating config directory...${RESET}"
mkdir -p ~/.config

# Copy the cloned configuration files to the config directory
echo -e "${CYAN}Copying configuration files...${RESET}"
{
    cp -r "$TEMP_DIR/"* ~/.config
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Configuration files copied successfully!${RESET}"
else
    echo -e "${RED}Failed to copy configuration files. Exiting.${RESET}"
    exit 1
fi

# Clean up the cloned repository
echo -e "${YELLOW}Cleaning up...${RESET}"
rm -rf "$TEMP_DIR"

# Final message
echo -e "${GREEN}Sway setup successfully completed!${RESET}"
