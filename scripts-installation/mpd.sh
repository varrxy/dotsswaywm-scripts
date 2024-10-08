#!/bin/bash

# Create a directory for playlists
mkdir -p ~/Music/playlists

# Install MPD and Ario (Assuming you're using a Debian-based system)
sudo apt update
sudo apt install -y mpd ario

# Enable the MPD service for the current user
systemctl --user enable mpd.service

echo "Setup complete! MPD and Ario installed, and MPD service enabled."
