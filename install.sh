#!/bin/bash

# ASCII Art
cat << "EOF"
░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓███████▓▒░░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 ░▒▓█▓▒▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 ░▒▓█▓▒▒▓█▓▒░░▒▓████████▓▒░▒▓███████▓▒░░▒▓███████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░
  ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░
  ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░
   ░▒▓██▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░
EOF

# Attribution
echo -e "          Created by https://github.com/varrxy          "
echo -e "=========================================="

# Set the directory for the scripts
SCRIPT_DIR="./scripts-installation"

# Function to run a script and check for success
run_script() {
    echo "Running $1..."
    if ! bash "$SCRIPT_DIR/$1"; then
        echo "Failed to run $1. Exiting."
        exit 1
    fi
}

# Ask user if they want to install NVIDIA
read -p "Do you want to setup SWAPFILE? (y/n): " setup_swap
if [[ "$setup_swap" == "y" ]]; then
    run_script "swap.sh"
fi

# Install prerequisites
run_script "prerequisites.sh"

# Ask user if they want to install NVIDIA
read -p "Do you want to install NVIDIA drivers? (y/n): " install_nvidia
if [[ "$install_nvidia" == "y" ]]; then
    run_script "nvidia.sh"
fi

# Ask user if they want to install Sway
read -p "Do you want to install Sway? (y/n): " install_sway
if [[ "$install_sway" == "y" ]]; then
    run_script "sway.sh"
fi

# Clone wallpapers
run_script "wall.sh"

# Ask user if they want to install themes
read -p "Do you want to install themes? (y/n): " install_themes
if [[ "$install_themes" == "y" ]]; then
    echo "Installing themes..."
    run_script "theme.sh"
fi

# Ask user if they want to install fonts
read -p "Do you want to install fonts? (y/n): " install_fonts
if [[ "$install_fonts" == "y" ]]; then
    echo "Installing fonts..."
    run_script "font.sh"
fi

# Ask user if they want to install the login manager (ly)
read -p "Do you want to install the login manager (ly)? (y/n): " install_login_manager
if [[ "$install_login_manager" == "y" ]]; then
    run_script "ly.sh"
fi

# Install Zsh last
read -p "Do you want to install Zsh? (y/n): " install_zsh
if [[ "$install_zsh" == "y" ]]; then
    run_script "zsh.sh"
fi

# Execute install.sh and bluetooth.sh after Zsh installation
run_script "network.sh"
run_script "bluetooth.sh"

# Final message and reboot prompt
echo "Setup complete! Would you like to reboot now? (y/n): "
read -p "Reboot now? (y/n): " reboot_now
if [[ "$reboot_now" == "y" ]]; then
    echo "Rebooting..."
    sudo reboot
else
    echo "Setup complete! You can reboot later."
fi
