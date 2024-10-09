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
THEME_NAME="catppuccin-macchiato-blue-standard+default"
CURSOR_NAME="catppuccin-macchiato-blue-cursors"
TOKYO_NIGHT_NAME="Tokyonight-Moon"

# Temporary directories
THEME_DIR="/tmp/Theme/$THEME_NAME"
CURSOR_DIR="/tmp/Theme/$CURSOR_NAME"
TOKYO_NIGHT_DIR="/tmp/Theme/$TOKYO_NIGHT_NAME"

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

# Step 1: Create theme and icons directories if they don't exist
mkdir -p ~/.themes ~/.icons

# Step 2: Check if the theme is already installed
echo -e "${CYAN}Step 2: Checking if the theme is already installed...${RESET}"
if [ -d "$HOME/.themes/$THEME_NAME" ]; then
    echo -e "${YELLOW}Notice: The theme '$THEME_NAME' already exists in ~/.themes. No changes will be made.${RESET}"
else
    # Step 3: Clone the repository if the theme does not exist
    echo -e "${CYAN}Step 3: Cloning the repository...${RESET}"
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

    # Step 4: Move the theme to the themes directory
    echo -e "${CYAN}Step 4: Moving theme to ~/.themes...${RESET}"
    {
        mv "$THEME_DIR" "$HOME/.themes/"
    } &
    show_spinner $!

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Success: Theme moved successfully!${RESET}"
    else
        echo -e "${RED}Error: Failed to move theme. Exiting.${RESET}"
        print_footer
        exit 1
    fi
fi

# Step 5: Check if the cursor icons already exist
echo -e "${CYAN}Step 5: Checking if the cursor icons are already installed...${RESET}"
if [ -d "$HOME/.icons/$CURSOR_NAME" ]; then
    echo -e "${YELLOW}Notice: The cursors '$CURSOR_NAME' already exist in ~/.icons. No changes will be made.${RESET}"
else
    # Move the cursors to the icons directory
    echo -e "${CYAN}Step 6: Moving Catppuccin cursors to ~/.icons...${RESET}"
    {
        mv "$CURSOR_DIR" "$HOME/.icons/"
    } &
    show_spinner $!

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Success: Catppuccin cursors moved successfully!${RESET}"
    else
        echo -e "${RED}Error: Failed to move Catppuccin cursors. Exiting.${RESET}"
        print_footer
        exit 1
    fi
fi

# Step 7: Check if the Tokyonight icons already exist
echo -e "${CYAN}Step 8: Checking if the Tokyonight icons are already installed...${RESET}"
if [ -d "$HOME/.icons/$TOKYO_NIGHT_NAME" ]; then
    echo -e "${YELLOW}Notice: The Tokyonight icons '$TOKYO_NIGHT_NAME' already exist in ~/.icons. No changes will be made.${RESET}"
else
    echo -e "${CYAN}Step 9: Moving Tokyonight-Moon icons to ~/.icons...${RESET}"
    {
        mv "$TOKYO_NIGHT_DIR" "$HOME/.icons/"
    } &
    show_spinner $!

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Success: Tokyonight-Moon icons moved successfully!${RESET}"
    else
        echo -e "${RED}Error: Failed to move Tokyonight-Moon icons. Exiting.${RESET}"
        print_footer
        exit 1
    fi
fi

# Step 10: Clean up
echo -e "${YELLOW}Step 11: Cleaning up temporary files...${RESET}"
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
