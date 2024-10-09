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

echo "Removing existing Neovim installation..."
sudo rm -rf /opt/nvim

echo "Extracting Neovim..."
sudo tar -C /opt -xzf "$TEMP_DIR/nvim-linux64.tar.gz" &
spinner $!

# Step 3: Create a symbolic link for sudo
echo "Creating symbolic link for sudo..."
sudo ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim

# Step 4: Ask user for shell preference
echo "Which shell do you use? (bash/zsh)"
read -r shell_choice

if [[ "$shell_choice" == "bash" ]]; then
    shell_config="$HOME/.bashrc"
elif [[ "$shell_choice" == "zsh" ]]; then
    shell_config="$HOME/.zshrc"
else
    echo "Invalid choice, defaulting to bash."
    shell_config="$HOME/.bashrc"
fi

# Step 5: Add Neovim to PATH
if ! grep -q '/opt/nvim-linux64/bin' "$shell_config"; then
    echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> "$shell_config"
fi

# Step 6: Create the Neovim configuration directory
mkdir -p ~/.config/nvim

# Step 7: Clone the VimVarrxy repository to a temporary directory
echo "Cloning VimVarrxy repository..."
git clone https://github.com/varrxy/VimVarrxy "$TEMP_DIR/VimVarrxy" &
spinner $!

# Step 8: Copy files to the existing Neovim configuration directory
echo "Copying VimVarrxy files to existing Neovim configuration directory..."
cp -r "$TEMP_DIR/VimVarrxy/"* "$HOME/.config/nvim/" & spinner $!

# Step 9: Install vim-plug
echo "Installing vim-plug..."
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' &
spinner $!

# Step 10: Install additional packages (ripgrep, fd-find)
echo "Installing ripgrep and fd-find..."
sudo apt install -y ripgrep fd-find &
spinner $!

# Step 11: Install plugins
echo "Installing plugins with vim-plug..."
nvim +PlugInstall +qall &

# Step 12: Cleanup
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

# Step 13: Output color and instructions
echo -e "\033[32mInstallation complete! Open Neovim with \033[34mnvim\033[0m"
echo -e "\033[36mMake sure to restart your terminal or run 'source $shell_config'\033[0m"
