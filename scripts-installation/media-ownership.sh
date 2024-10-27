USERNAME=$(whoami) # Get the current username

if [ -z "$USERNAME" ]; then
    echo -e "${RED}Failed to get the username. Exiting.${RESET}"
    exit 1
fi

echo -e "${CYAN}Changing ownership of the media directory...${RESET}"

# Run the chown command in the background
{
    sudo chown -R "$USERNAME:$USERNAME" /media/"$USERNAME"
} &

# Capture the PID of the last background command
PID=$!

# Function to show spinner
show_spinner() {
    local spin='/-\|'
    local i=0
    while kill -0 $1 2>/dev/null; do
        printf "\r${spin:i++%${#spin}:1}  "
        sleep 0.1
    done
    printf "\r"  # Clear the spinner line
}

# Call the spinner function
show_spinner $PID

# Check the exit status of the background command
wait $PID
if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Ownership changed successfully!${RESET}"
else
    echo -e "${RED}Failed to change ownership. Exiting.${RESET}"
    exit 1
fi
