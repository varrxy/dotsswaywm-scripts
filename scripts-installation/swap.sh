#!/bin/bash

# Define colors
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Function to show a spinner
spinner() {
    local pid=$!
    local delay=0.1
    local spinchars="/-\|"
    local i=0
    while ps -p $pid > /dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r${YELLOW}Processing... ${spinchars:i:1}${NC}"
        sleep $delay
    done
    printf "\r"
}

# Check if a swap file already exists
if sudo swapon --show | grep -q "/swapfile"; then
    echo -e "${YELLOW}A swap file already exists. Skipping creation.${NC}"
else
    # Prompt the user for the swap file size in GB
    read -p "Enter the size of the swap file in GB (e.g., 1 for 1G): " SWAP_SIZE_GB

    # Validate input
    if ! [[ $SWAP_SIZE_GB =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid input. Please enter a number.${NC}"
        exit 1
    fi

    # Convert GB to bytes for fallocate
    SWAP_SIZE="${SWAP_SIZE_GB}G"
    SWAPFILE="/swapfile"

    # Create the swap file
    echo -e "${GREEN}Creating swap file of size $SWAP_SIZE...${NC}"
    {
        sudo fallocate -l $SWAP_SIZE $SWAPFILE
    } & spinner

    # Set the correct permissions
    echo -e "${GREEN}Setting permissions on $SWAPFILE...${NC}"
    {
        sudo chmod 600 $SWAPFILE
    } & spinner

    # Set up the swap space
    echo -e "${GREEN}Setting up swap space...${NC}"
    {
        sudo mkswap $SWAPFILE
    } & spinner

    # Enable the swap file
    echo -e "${GREEN}Enabling swap file...${NC}"
    {
        sudo swapon $SWAPFILE
    } & spinner

    # Confirm the swap is active
    echo -e "${GREEN}Current swap space:${NC}"
    sudo swapon --show

    # Optionally, make the change permanent by adding it to fstab
    if ! grep -q "$SWAPFILE" /etc/fstab; then
        echo -e "${GREEN}Adding swap file to /etc/fstab for persistence...${NC}"
        {
            echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab
        } & spinner
    fi
fi

echo -e "${GREEN}Script executed successfully.${NC}"
