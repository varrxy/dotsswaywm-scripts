#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'  # No Color

# Function to handle errors
error_exit() {
    echo -e "${RED}$1${RESET}" 1>&2
    exit 1
}

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

# Function to execute commands and check for errors
run_command() {
    "$@" &  # Run the command in the background
    show_spinner $!  # Show spinner while command is running
    if [ $? -ne 0 ]; then
        error_exit "Command '$*' failed."
    fi
}

# Step 1: Update the package list and install essential dependencies.
echo -e "${BLUE}Updating package list and installing dependencies...${RESET}"
run_command sudo apt update
run_command sudo apt install -y build-essential libpam0g-dev libxcb-xkb-dev git sway

# Step 2: Clone the Ly Reloaded repository into /tmp.
echo -e "${BLUE}Cloning the Ly Reloaded repository...${RESET}"
run_command git clone --recurse-submodules https://github.com/SartoxSoftware/ly-reloaded /tmp/ly-reloaded

# Step 3: Navigate into the cloned directory.
cd /tmp/ly-reloaded || error_exit "Failed to change directory!"

# Step 4: Compile the source code.
echo -e "${BLUE}Compiling the source code...${RESET}"
run_command make

# Step 5: Install Ly and its systemd service file.
echo -e "${BLUE}Installing Ly...${RESET}"
run_command sudo make install

# Step 6: Enable the Ly service to start at boot.
echo -e "${BLUE}Enabling the Ly service for automatic start at boot...${RESET}"
run_command sudo systemctl enable ly.service

# Step 7: Disable getty on tty2 to avoid conflicts.
echo -e "${BLUE}Disabling getty on tty2...${RESET}"
run_command sudo systemctl disable getty@tty2.service

# Step 8: Check for NVIDIA GPU and modify sway.desktop accordingly.
echo -e "${BLUE}Checking for NVIDIA GPU...${RESET}"
SWAY_DESKTOP="/usr/share/wayland-sessions/sway.desktop"

# Create a backup if sway.desktop exists
if [[ -f $SWAY_DESKTOP ]]; then
    echo -e "${YELLOW}Backing up existing sway.desktop to sway.desktop.bak...${RESET}"
    run_command sudo cp $SWAY_DESKTOP ${SWAY_DESKTOP}.bak
fi

if lspci | grep -i nvidia &> /dev/null; then
    echo -e "${GREEN}NVIDIA GPU detected. Modifying sway.desktop to use --unsupported-gpu...${RESET}"
    run_command bash -c "echo '[Desktop Entry]
Name=Sway
Comment=An i3-compatible Wayland compositor
Exec=/usr/bin/sway --unsupported-gpu
Type=Application' | sudo tee $SWAY_DESKTOP"
else
    echo -e "${GREEN}No NVIDIA GPU detected. Modifying sway.desktop to remove --unsupported-gpu...${RESET}"
    run_command bash -c "echo '[Desktop Entry]
Name=Sway
Comment=An i3-compatible Wayland compositor
Exec=/usr/bin/sway
Type=Application' | sudo tee $SWAY_DESKTOP"
fi

echo -e "${GREEN}sway.desktop has been configured based on your GPU.${RESET}"

# Final Step: Configuration file location.
echo -e "${YELLOW}The configuration file is located at /etc/ly/config.ini. Modify it as needed!${RESET}"
echo -e "${YELLOW}Ly setup complete! Don't forget to configure your .xinitrc for your desktop environment.${RESET}"
echo -e "${YELLOW}Example .xinitrc content:${RESET}"
echo -e "${YELLOW}exec sway${RESET}"

# Confirmation message
echo -e "${GREEN}-------------------------------------------------${RESET}"
echo -e "${GREEN}LY has been successfully installed and configured!${RESET}"
echo -e "${GREEN}You can now log in using LY and enjoy your Wayland experience!${RESET}"
echo -e "${GREEN}-------------------------------------------------${RESET}"
