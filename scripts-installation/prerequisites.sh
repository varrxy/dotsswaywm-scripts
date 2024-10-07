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

# Install prerequisites
echo -e "${CYAN}Installing prerequisites...${RESET}"
{
    sudo apt install -y build-essential git unzip pipewire-audio pulseaudio-utils brightnessctl libnotify-bin
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Prerequisites installation complete!${RESET}"
else
    echo -e "${RED}Failed to install prerequisites. Exiting.${RESET}"
    exit 1
fi
