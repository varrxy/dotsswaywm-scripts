#!/bin/bash

# Color definitions
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"  # Reset color

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

# Update package list
echo -e "${CYAN}Updating package list...${RESET}"
{
    sudo apt update
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Package list updated successfully!${RESET}"
else
    echo -e "${RED}Failed to update package list. Exiting.${RESET}"
    exit 1
fi

# Install Zsh and Git
echo -e "${CYAN}Installing Zsh and Git...${RESET}"
{
    sudo apt install -y zsh git
} &
show_spinner $!

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Zsh and Git installed successfully!${RESET}"
else
    echo -e "${RED}Failed to install Zsh and Git. Exiting.${RESET}"
    exit 1
fi

# Change default shell to Zsh
if ! [ "$SHELL" == "$(which zsh)" ]; then
    echo -e "${CYAN}Changing default shell to Zsh...${RESET}"
    if chsh -s "$(which zsh)"; then
        echo -e "${GREEN}Default shell changed to Zsh successfully!${RESET}"
    else
        echo -e "${RED}Failed to change default shell to Zsh. Exiting.${RESET}"
        exit 1
    fi
else
    echo -e "${YELLOW}Default shell is already Zsh. No changes made.${RESET}"
fi

# Install Zsh Autosuggestions
echo -e "${CYAN}Installing Zsh Autosuggestions...${RESET}"
ZSH_AUTOSUGGESTIONS_DIR="$HOME/.zsh-autosuggestions"

if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
    echo -e "${YELLOW}Zsh Autosuggestions already exists. Skipping installation.${RESET}"
else
    {
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_AUTOSUGGESTIONS_DIR"
    } &
    show_spinner $!

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Zsh Autosuggestions installed successfully!${RESET}"
    else
        echo -e "${RED}Failed to install Zsh Autosuggestions. Exiting.${RESET}"
        exit 1
    fi
fi

# Install Zsh Syntax Highlighting
echo -e "${CYAN}Installing Zsh Syntax Highlighting...${RESET}"
ZSH_SYNTAX_HIGHLIGHTING_DIR="$HOME/.zsh-syntax-highlighting"

if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
    echo -e "${YELLOW}Zsh Syntax Highlighting already exists. Skipping installation.${RESET}"
else
    {
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
    } &
    show_spinner $!

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Zsh Syntax Highlighting installed successfully!${RESET}"
    else
        echo -e "${RED}Failed to install Zsh Syntax Highlighting. Exiting.${RESET}"
        exit 1
    fi
fi

# Clone Powerlevel10k
echo -e "${CYAN}Cloning Powerlevel10k...${RESET}"
POWERLEVEL10K_DIR="$HOME/.powerlevel10k"

if [ -d "$POWERLEVEL10K_DIR" ]; then
    echo -e "${YELLOW}Powerlevel10k already exists. Skipping installation.${RESET}"
else
    {
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$POWERLEVEL10K_DIR"
    } &
    show_spinner $!

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Powerlevel10k cloned successfully!${RESET}"
    else
        echo -e "${RED}Failed to clone Powerlevel10k. Exiting.${RESET}"
        exit 1
    fi
fi

# Configure .zshrc
if ! grep -q 'source ~/.zsh-autosuggestions/zsh-autosuggestions.zsh' ~/.zshrc; then
    echo -e "${CYAN}Configuring .zshrc...${RESET}"
    {
        echo 'source ~/.zsh-autosuggestions/zsh-autosuggestions.zsh'
        echo 'source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
        echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme'
    } >> ~/.zshrc
    echo -e "${GREEN}.zshrc configured successfully!${RESET}"
else
    echo -e "${YELLOW}.zshrc is already configured. Skipping.${RESET}"
fi

# Notify user to restart terminal
echo -e "${GREEN}Installation complete! Please restart your terminal or run 'zsh' to start using it.${RESET}"
