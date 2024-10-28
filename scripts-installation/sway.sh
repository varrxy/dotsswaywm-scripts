#!/bin/bash

# Define colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Define log file
LOG_DIR="./log"
LOG_FILE="$LOG_DIR/sway.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Update System
log "${YELLOW}Updating system...${NC}"
if sudo apt update && sudo apt upgrade -y &>> "$LOG_FILE"; then
    log "${GREEN}System updated successfully.${NC}"
else
    log "${RED}Failed to update system.${NC}"
    exit 1
fi

# Install Sway and Related Applications
packages=(
    "sway"
    "swayidle"
    "swaybg"
    "sway-notification-center"
    "swaylock"
    "wofi"
    "waybar"
    "wlogout"
    "qt5ct"
    "grim"
    "slurp"
    "thunar"
    "xwayland"
    "xdg-desktop-portal-wlr"
    "libglib2.0-bin"
    "guvcview"
    "btop"
    "lxpolkit"
)

# Install packages
for package in "${packages[@]}"; do
    log "${YELLOW}Installing $package...${NC}"
    if sudo apt install -y "$package" &>> "$LOG_FILE"; then
        log "${GREEN}$package installed successfully.${NC}"
    else
        log "${RED}Failed to install $package.${NC}"
        exit 1
    fi
done

# Check and add QT_QPA_PLATFORMTHEME to /etc/environment
LINE="QT_QPA_PLATFORMTHEME=qt5ct"
if grep -Fxq "$LINE" /etc/environment; then
    log "${YELLOW}The line '$LINE' already exists in /etc/environment.${NC}"
else
    echo "$LINE" | sudo tee -a /etc/environment
    log "${GREEN}Added the line '$LINE' to /etc/environment.${NC}"
fi

# Clone the GitHub repository
log "${YELLOW}Cloning GitHub repository...${NC}"
if git clone https://github.com/varrxy/swaywm-setup.git /tmp/swaywm-setup &>> "$LOG_FILE"; then
    log "${GREEN}Repository cloned successfully.${NC}"
else
    log "${RED}Failed to clone repository.${NC}"
    exit 1
fi

# Create necessary directories if they don't exist
log "${YELLOW}Creating necessary directories...${NC}"
mkdir -p ~/.config/ ~/.icons/ ~/.themes/ ~/Pictures/Wallpapers

# Copy configuration files
log "${YELLOW}Copying configuration files...${NC}"
cp -r /tmp/swaywm-setup/.config/* ~/.config/ &>> "$LOG_FILE" && \
cp -r /tmp/swaywm-setup/.themes/* ~/.themes/ &>> "$LOG_FILE" && \
cp -r /tmp/swaywm-setup/.icons/* ~/.icons/ &>> "$LOG_FILE" && \
cp -r /tmp/swaywm-setup/wallpapers/* ~/Pictures/Wallpapers &>> "$LOG_FILE"

log "${GREEN}Configuration files copied successfully.${NC}"

# Clean up
log "${YELLOW}Cleaning up...${NC}"
rm -rf /tmp/swaywm-setup
log "${GREEN}Installation script completed.${NC}"
