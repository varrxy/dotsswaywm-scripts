#!/bin/bash

# Spinner function
spinner() {
    local pid="$1"
    local delay=0.1
    local spin='/-\|'
    local i=0

    while ps -p "$pid" > /dev/null; do
        local temp="${spin:i++%${#spin}:1}"
        printf "\r$temp  "
        sleep "$delay"
    done
    printf "\r"
}

# Step 1: Create a temporary directory
TEMP_DIR=$(mktemp -d)

# Step 2: Install Neovim
echo "Downloading Neovim..."
curl -L -o "$TEMP_DIR/nvim-linux64.tar.gz" https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz &
spinner $!

# Check if the download was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to download Neovim."
    exit 1
fi

# Step 3: Remove existing Neovim installation if it exists
if [ -e /opt/nvim ]; then
    echo "Removing existing Neovim installation..."
    sudo rm -rf /opt/nvim || { echo "Failed to remove existing Neovim."; exit 1; }
fi

# Step 4: Extract Neovim
echo "Extracting Neovim..."
if ! sudo tar -C /opt -xzf "$TEMP_DIR/nvim-linux64.tar.gz"; then
    echo "Failed to extract Neovim."
    exit 1
fi

# Step 5: Create a symbolic link for nvim
echo "Creating symbolic link for nvim..."
if [ -e /usr/local/bin/nvim ]; then
    echo "Symbolic link /usr/local/bin/nvim already exists."
else
    sudo ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim || { echo "Failed to create symbolic link."; exit 1; }
fi

# Step 6: Ask user for shell preference
echo "Which shell do you use? (bash/zsh)"
read -r shell_choice

case "$shell_choice" in
    bash) shell_config="$HOME/.bashrc" ;;
    zsh) shell_config="$HOME/.zshrc" ;;
    *) echo "Invalid choice, defaulting to bash." && shell_config="$HOME/.bashrc" ;;
esac

# Step 7: Add Neovim to PATH
if ! grep -q '/opt/nvim-linux64/bin' "$shell_config"; then
    echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> "$shell_config"
    echo "Added Neovim to PATH in $shell_config."
else
    echo "Neovim is already in your PATH."
fi

# Step 8: Create the Neovim configuration directory
mkdir -p ~/.config/nvim

# Step 9: Clone the VimVarrxy repository
echo "Cloning VimVarrxy repository..."
git clone https://github.com/varrxy/VimVarrxy "$TEMP_DIR/VimVarrxy" &
spinner $!

# Check if cloning was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to clone VimVarrxy repository."
    exit 1
fi

# Step 10: Copy files to the Neovim configuration directory
echo "Copying VimVarrxy files to Neovim configuration directory..."
if ! cp -r "$TEMP_DIR/VimVarrxy/"* "$HOME/.config/nvim/"; then
    echo "Failed to copy VimVarrxy files."
    exit 1
fi

# Step 11: Install vim-plug
echo "Installing vim-plug..."
if ! sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'; then
    echo "Failed to install vim-plug."
    exit 1
fi

# Step 12: Install additional packages (ripgrep, fd-find)
echo "Installing ripgrep and fd-find..."
if ! sudo apt install -y ripgrep fd-find; then
    echo "Failed to install ripgrep and fd-find."
    exit 1
fi

# Step 13: Install plugins
echo "Installing plugins with vim-plug..."
nvim +PlugInstall +qall

# Check if the plugin installation was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to install plugins with vim-plug."
    exit 1
fi

# Step 14: Cleanup
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

# Step 15: Output color and instructions
echo -e "\033[32mInstallation complete! Open Neovim with \033[34mnvim\033[0m"
echo -e "\033[36mMake sure to restart your terminal or run 'source $shell_config'\033[0m"
