#!/bin/bash

# Color definitions
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"  # Reset color

# Define the repository and theme/icon names
REPO_URL="https://github.com/varrxy/Theme"
THEME_DIR="/tmp/Theme/catppuccin-macchiato-blue-standard+default"
CURSOR_DIR="/tmp/Theme/catppuccin-macchiato-blue-cursors"
TOKYO_NIGHT_DIR="/tmp/Theme/Tokyonight-Moon"

# Function to print a header
print_header() {
    echo -e "${MAGENTA}==========================================${RESET}"
    echo -e "${GREEN}          Theme Installation Script        ${RESET}"
    echo -e "${MAGENTA}==========================================${RESET}"
}

# Function to print a footer
print_footer() {
    echo -e "${MAGENTA}==========================================${RESET}"
    echo -e "${GREEN}  Theme and icons installed successfully! 🎉 ${RESET}"
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

# Step 1: Check if the theme is already installed
echo -e "${CYAN}Step 1: Checking if the theme is already installed...${RESET}"
if [ -d "/usr/share/themes/catppuccin-macchiato-blue-standard+default" ]; then
    echo -e "${YELLOW}Notice: The theme already exists. No changes will be made.${RESET}"
    print_footer
    exit 0
fi

# Step 2: Clone the repository
echo -e "${CYAN}Step 2: Cloning the repository...${RESET}"
{
    git clone "$REPO_URL" /tmp/Theme
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Success: Repository cloned successfully!${RESET}"
else
    echo -e "${RED}Error: Failed to clone the repository. Exiting.${RESET}"
    print_footer
    exit 1
fi

# Step 3: Move the theme to the themes directory
echo -e "${CYAN}Step 3: Moving theme to /usr/share/themes...${RESET}"
{
    sudo mv "$THEME_DIR" /usr/share/themes/
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Success: Theme moved successfully!${RESET}"
else
    echo -e "${RED}Error: Failed to move theme. Exiting.${RESET}"
    print_footer
    exit 1
fi

# Step 4: Move the cursors and Tokyonight icons to the icons directory
echo -e "${CYAN}Step 4: Moving icons to /usr/share/icons...${RESET}"

# Move Catppuccin cursors
{
    sudo mv "$CURSOR_DIR" /usr/share/icons/
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Success: Catppuccin cursors moved successfully!${RESET}"
else
    echo -e "${RED}Error: Failed to move Catppuccin cursors. Exiting.${RESET}"
    print_footer
    exit 1
fi

# Move Tokyonight-Moon icons
{
    sudo mv "$TOKYO_NIGHT_DIR" /usr/share/icons/
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Success: Tokyonight-Moon icons moved successfully!${RESET}"
else
    echo -e "${RED}Error: Failed to move Tokyonight-Moon icons. Exiting.${RESET}"
    print_footer
    exit 1
fi

# Step 5: Clean up
echo -e "${YELLOW}Step 5: Cleaning up temporary files...${RESET}"
{
    rm -rf /tmp/Theme
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Success: Cleanup successful!${RESET}"
else
    echo -e "${RED}Warning: Failed to clean up temporary files.${RESET}"
fi

# Final message
print_footer
