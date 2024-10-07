#!/bin/bash

# Function for colored output
color_output() {
    case $1 in
        info) echo -e "\e[32m[INFO] $2\e[0m" ;;   # Green
        warn) echo -e "\e[33m[WARNING] $2\e[0m" ;; # Yellow
        error) echo -e "\e[31m[ERROR] $2\e[0m" ;; # Red
        *) echo "$2" ;;
    esac
}

# Spinner function
spinner() {
    local pid=$1
    local delay=0.75
    local spin='/-\|'
    local i=0

    while ps -p $pid > /dev/null; do
        local temp=${spin:i++%${#spin}:1}
        echo -ne "\r$temp Creating swap file..."
        sleep $delay
    done
    echo -ne "\r\033[K"  # Clear the line
}

# Function to get swap size from user
get_swap_size() {
    read -p "Enter the desired swap size (e.g., 1G, 2G, 2.12G): " SWAPSIZE
    if [[ ! $SWAPSIZE =~ ^[0-9]+(\.[0-9]+)?G$ ]]; then
        color_output error "Invalid input. Please enter a valid size (e.g., 1G, 2G, 2.12G)."
        exit 1
    fi
}

# Get swap size from user
get_swap_size

# Swap file settings
SWAPFILE="/swapfile"

# Check for existing swap space
if sudo swapon --show; then
    color_output info "Swap space already exists. Exiting."
    exit 0
fi

# Create the swap file
color_output info "Creating swap file of size $SWAPSIZE..."
{
    sudo fallocate -l $SWAPSIZE $SWAPFILE &&
    sudo chmod 600 $SWAPFILE &&
    sudo mkswap $SWAPFILE &&
    sudo swapon $SWAPFILE
} & spinner $!

# Verify swap creation
if sudo swapon --show; then
    color_output info "Swap file created and activated successfully."
else
    color_output error "Failed to create or activate swap file."
    exit 1
fi

# Check for duplicate entry in /etc/fstab
if ! grep -q "$SWAPFILE" /etc/fstab; then
    echo "$SWAPFILE swap swap defaults 0 0" | sudo tee -a /etc/fstab
    color_output info "Swap file entry added to /etc/fstab."
else
    color_output warn "Swap file entry already exists in /etc/fstab."
fi

color_output info "Swap file setup is complete!"
