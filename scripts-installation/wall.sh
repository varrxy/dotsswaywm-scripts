#!/bin/bash

# Color definitions
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"  # Reset color

# Define directories
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
TMP_DIR="/tmp/Wallpapers"

# Function to print a header
print_header() {
    echo -e "${MAGENTA}==========================================${RESET}"
    echo -e "${GREEN}          Wallpaper Setup Script          ${RESET}"
    echo -e "${MAGENTA}==========================================${RESET}"
}

# Function to print a footer
print_footer() {
    echo -e "${MAGENTA}==========================================${RESET}"
    echo -e "${GREEN}  Enjoy your new wallpapers! 🎉          ${RESET}"
    echo -e "${MAGENTA}==========================================${RESET}"
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

# Step 1: Create the Wallpapers directory if it doesn't exist
echo -e "${CYAN}Step 1: Creating wallpapers directory at $WALLPAPER_DIR...${RESET}"
{
    mkdir -p "$WALLPAPER_DIR"
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Success: Wallpapers directory created successfully!${RESET}"
else
    echo -e "${RED}Error: Failed to create wallpapers directory. Exiting.${RESET}"
    print_footer
    exit 1
fi

# Step 2: Check if the wallpapers directory is not empty
echo -e "${CYAN}Step 2: Checking if the wallpapers directory is empty...${RESET}"
if [ "$(ls -A $WALLPAPER_DIR)" ]; then
    echo -e "${YELLOW}Notice: Wallpapers directory is not empty. Exiting.${RESET}"
    print_footer
    exit 0
fi

# Step 3: Clone the wallpapers repository to /tmp
echo -e "${CYAN}Step 3: Cloning wallpapers repository to $TMP_DIR...${RESET}"
{
    git clone https://github.com/varrxy/Wallpapers "$TMP_DIR"
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Success: Wallpapers repository cloned successfully!${RESET}"
else
    echo -e "${RED}Error: Failed to clone the wallpapers repository. Exiting.${RESET}"
    print_footer
    exit 1
fi

# Step 4: Copy wallpapers from /tmp to the Wallpapers directory
echo -e "${CYAN}Step 4: Copying wallpapers from $TMP_DIR to $WALLPAPER_DIR...${RESET}"
{
    cp -r "$TMP_DIR/"* "$WALLPAPER_DIR/"
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Success: Wallpapers copied successfully!${RESET}"
else
    echo -e "${RED}Error: Failed to copy wallpapers. Exiting.${RESET}"
    print_footer
    exit 1
fi

# Step 5: Clean up the temporary directory
echo -e "${CYAN}Step 5: Cleaning up temporary files...${RESET}"
{
    rm -rf "$TMP_DIR"
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Success: Temporary files cleaned up!${RESET}"
else
    echo -e "${RED}Warning: Failed to clean up temporary files.${RESET}"
fi

# Final message
print_footer
