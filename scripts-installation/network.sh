#!/bin/bash

# Function to display a spinner
spinner() {
    local pid=$1
    local delay=0.75
    local spinchars='/-\|'
    local i=0

    while ps -p $pid > /dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\r${spinchars:$i:1}  "
        sleep $delay
    done
    printf "\r   \r"  # Clear the spinner
}

# Function for colored output
print_color() {
    local color_code="$1"
    shift
    printf "\e[${color_code}m%s\e[0m\n" "$@"
}

# Check if NetworkManager is installed
if dpkg -l | grep -q '^ii  network-manager'; then
    print_color "33" "NetworkManager is already installed."
else
    print_color "34" "Installing NetworkManager..."
    {
        sudo apt install -y network-manager
    } & spinner $!
fi

# Check if NetworkManager GNOME is installed
if dpkg -l | grep -q '^ii  network-manager-gnome'; then
    print_color "33" "NetworkManager GNOME is already installed."
else
    print_color "34" "Installing NetworkManager GNOME..."
    {
        sudo apt install -y network-manager-gnome
    } & spinner $!
fi

# Check the current configuration
expected_config="[main]\nplugins=keyfile\n\n[ifupdown]\nmanaged=false"
current_config=$(sudo cat /etc/NetworkManager/NetworkManager.conf)

if [ "$current_config" == "$expected_config" ]; then
    print_color "33" "NetworkManager is already configured correctly. No changes made."
    exit 0
fi

# Update package list
print_color "34" "Updating package list..."
sudo apt update

# Configure NetworkManager
print_color "34" "Configuring NetworkManager..."
{
    sudo tee /etc/NetworkManager/NetworkManager.conf > /dev/null <<EOL
[main]
plugins=keyfile

[ifupdown]
managed=false
EOL
} & spinner $!

# Clean up interfaces file
print_color "34" "Cleaning up /etc/network/interfaces..."
{
    echo -e "auto lo\niface lo inet loopback" | sudo tee /etc/network/interfaces > /dev/null
} & spinner $!

# Remove ifupdown package if it's installed
if dpkg -l | grep -q '^ii  ifupdown'; then
    print_color "34" "Removing ifupdown package..."
    {
        sudo apt remove -y ifupdown
    } & spinner $!
fi

# Restart NetworkManager
print_color "34" "Restarting NetworkManager..."
{
    sudo systemctl restart NetworkManager
} & spinner $!

# Completion message
print_color "32" "NetworkManager setup completed successfully!"
