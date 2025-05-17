#!/bin/bash

# Clear the screen at the start
clear

# Function to check for APT availability
check_apt() {
    if ! command -v apt >/dev/null 2>&1; then
        echo "Error: APT is not available on this system. This script requires APT to function."
        exit 1
    fi
}

# Function to validate a package exists in APT
validate_package() {
    local package=$1
    apt-cache show "$package" >/dev/null 2>&1
    return $?
}

# Function to suggest similar packages
suggest_packages() {
    local package=$1
    echo "Searching for similar packages..."
    apt-cache search "$package" | head -5
}

# Main script logic
check_apt

# Prompt the user for the tool name
read -rp "Enter the name of the tool to check: " tool
tool=$(echo "$tool" | tr '[:upper:]' '[:lower:]') # Convert to lowercase

# Check if the tool is installed
if command -v "$tool" >/dev/null 2>&1; then
    echo "Tool '$tool' is installed."
    echo "Location: $(command -v "$tool")"

    # Try to get version information
    echo "Checking version..."
    if "$tool" --version >/dev/null 2>&1; then
        "$tool" --version
    elif "$tool" -v >/dev/null 2>&1; then
        "$tool" -v
    else
        echo "Version information is not available for '$tool'."
    fi
else
    echo "Tool '$tool' is not installed."

    # Validate the package in APT
    if validate_package "$tool"; then
        echo "Package Details:"
        apt-cache show "$tool" | grep -m 1 -E '^Description:' | sed 's/Description: //'
        read -rp "Do you want to install '$tool'? (y/N): " install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            echo "Installing '$tool'..."
            sudo apt install "$tool" -y
        else
            echo "Skipping installation."
        fi
    else
        echo "Package '$tool' is not available in the APT repository."

        # Suggest similar packages
        echo "Searching for similar packages..."
        suggestions=$(apt-cache search "$tool" | head -5)
        if [[ -z "$suggestions" ]]; then
            echo "No similar packages were found."
        else
            echo "Did you mean:"
            echo "$suggestions" | nl
            read -rp "Enter the number of a package to install or 'N' to cancel: " suggestion_choice

            # Handle empty input or "N"
            if [[ -z "$suggestion_choice" || "$suggestion_choice" =~ ^[Nn]$ ]]; then
                echo "Exiting without installation."
            else
                selected_package=$(echo "$suggestions" | sed -n "${suggestion_choice}p" | awk '{print $1}')
                if [[ -n "$selected_package" ]]; then
                    echo "Installing '$selected_package'..."
                    sudo apt install "$selected_package" -y
                else
                    echo "Invalid selection. Exiting."
                fi
            fi
        fi
    fi
fi

echo "Done."
