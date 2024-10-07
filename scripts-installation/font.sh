#!/bin/bash

# Color definitions
RED="\033[0;31m"
GREEN="\033[0;32m"
Y="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"  # Reset color

# Define variables
VERSION="v3.2.1"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/$VERSION/JetBrainsMono.zip"
INSTALL_DIR="/usr/share/fonts/truetype/JetBrainsMono"

# Cleanup on exit
trap 'rm -f "/tmp/JetBrainsMono.zip"' EXIT

# Function to print a header
print_header() {
    echo -e "${MAGENTA}==========================================${RESET}"
    echo -e "${GREEN}          Font Installation Script         ${RESET}"
    echo -e "${MAGENTA}==========================================${RESET}"
}

# Function to print a footer
print_footer() {
    echo -e "${MAGENTA}==========================================${RESET}"
    echo -e "${GREEN}  Font installation completed! 🎉         ${RESET}"
    echo -e "${MAGENTA}==========================================${RESET}"
}

# Function to check for required tools
check_tools() {
    command -v wget >/dev/null 2>&1 || { echo -e "${RED}Error: wget is required but not installed. Exiting.${RESET}"; exit 1; }
    command -v unzip >/dev/null 2>&1 || { echo -e "${RED}Error: unzip is required but not installed. Exiting.${RESET}"; exit 1; }
}

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

# Start of the script
print_header
check_tools

# Step 1: Check if the font is already installed
echo -e "${CYAN}Step 1: Checking if JetBrains Mono is already installed...${RESET}"
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${Y}Notice: JetBrains Mono Nerd Font is already installed. Exiting.${RESET}"
    print_footer
    exit 0
fi

# Step 2: Download the font
echo -e "${CYAN}Step 2: Downloading JetBrains Mono Nerd Font version $VERSION...${RESET}"
{
    wget -q "$FONT_URL" -O "/tmp/JetBrainsMono.zip"
} &
show_spinner $!

if [[ $? -ne 0 || ! -f "/tmp/JetBrainsMono.zip" ]]; then
    echo -e "${RED}Error: Failed to download JetBrains Mono. Exiting.${RESET}"
    print_footer
    exit 1
fi

echo -e "${GREEN}Success: Download successful!${RESET}"

# Step 3: Unzip the font files directly to the install directory
echo -e "${CYAN}Step 3: Unzipping the font files to $INSTALL_DIR...${RESET}"
mkdir -p "$INSTALL_DIR"
{
    sudo unzip -q "/tmp/JetBrainsMono.zip" -d "$INSTALL_DIR"
} &
show_spinner $!

if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error: Failed to unzip font files. Exiting.${RESET}"
    print_footer
    exit 1
fi

echo -e "${GREEN}Success: Fonts unzipped successfully!${RESET}"

# Step 4: Clean up
echo -e "${Y}Step 4: Cleaning up temporary files...${RESET}"
{
    rm -f "/tmp/JetBrainsMono.zip"
} &
show_spinner $!

if [[ $? -ne 0 ]]; then
    echo -e "${RED}Warning: Failed to clean up temporary files.${RESET}"
fi

# Step 5: Update font cache
echo -e "${CYAN}Step 5: Updating font cache...${RESET}"
if fc-cache -f -v; then
    echo -e "${GREEN}Success: Font cache updated successfully!${RESET}"
else
    echo -e "${RED}Error: Failed to update font cache. Exiting.${RESET}"
    print_footer
    exit 1
fi

# Final message
print_footer
