#!/bin/bash

# Variables
SWAP_FILE="/swapfile"  # Change this if your swap file is located elsewhere

# Function to check if command succeeded
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Check if the swap file exists
if [ ! -f "$SWAP_FILE" ]; then
    echo "Swap file $SWAP_FILE not found!"
    exit 1
fi

# Get the UUID of the root partition
UUID=$(findmnt / -o UUID -n)
check_command "Failed to get UUID of the root partition."

# Get the swap file's offset
OFFSET=$(sudo filefrag -v "$SWAP_FILE" | awk 'NR==4{gsub(/\./,"");print $4;}')
check_command "Failed to get swap file offset."

# Update /etc/default/grub
GRUB_CONFIG="/etc/default/grub"

# Check if hibernation is already configured
if grep -q "resume=UUID=$UUID resume_offset=$OFFSET" "$GRUB_CONFIG"; then
    echo "Hibernation is already set up correctly."
    exit 0
fi

if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" "$GRUB_CONFIG"; then
    sudo sed -i.bak "s|GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"|GRUB_CMDLINE_LINUX_DEFAULT=\"\1 resume=UUID=$UUID resume_offset=$OFFSET\"|" "$GRUB_CONFIG"
    check_command "Failed to update GRUB configuration."
else
    echo "GRUB_CMDLINE_LINUX_DEFAULT not found in $GRUB_CONFIG."
    exit 1
fi

# Create or update /etc/initramfs-tools/conf.d/resume
RESUME_CONFIG="/etc/initramfs-tools/conf.d/resume"

if grep -q "RESUME=UUID=$UUID resume_offset=$OFFSET" "$RESUME_CONFIG"; then
    echo "Hibernation configuration is already present in $RESUME_CONFIG."
else
    echo "RESUME=UUID=$UUID resume_offset=$OFFSET" | sudo tee "$RESUME_CONFIG" > /dev/null
    check_command "Failed to update initramfs resume configuration."
fi

# Update grub and initramfs
sudo update-grub
check_command "Failed to update GRUB."
sudo update-initramfs -u
check_command "Failed to update initramfs."

# Confirmation message
echo "Hibernation configuration complete. You can test it with 'systemctl hibernate'."
