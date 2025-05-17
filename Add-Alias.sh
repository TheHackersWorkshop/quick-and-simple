
# File where aliases are stored
ALIAS_FILE="/etc/.aliases"

# Function to check for duplicate alias
check_duplicate() {
    grep -q "alias $1=" "$ALIAS_FILE"
}

# Function to prompt user for alias and command
add_alias() {
    while true; do
        # Ask for alias name
        echo "Enter the alias name (starting with a capital letter recommended): "
        read alias_name

        # Check if alias already exists
        if check_duplicate "$alias_name"; then
            echo "Error: Alias '$alias_name' already exists in $ALIAS_FILE."
            echo "Please enter a different alias name."
        else
            # Ask for the command to be aliased
            echo "Enter the command for alias '$alias_name': "
            read command

            # Display the alias line for confirmation
            echo ""
            echo "You are about to add the following alias:"
            echo "alias $alias_name='$command'"
            echo ""
            echo "Is this correct? (y/n): "
            read confirmation

            if [[ $confirmation == "y" || $confirmation == "Y" ]]; then
                # Add the alias to the .aliases file
                echo "alias $alias_name='$command'" | sudo tee -a "$ALIAS_FILE" > /dev/null
                echo "Alias '$alias_name' added successfully."
                break
            else
                echo "Alias not added."
                break
            fi
        fi
    done
}

# Start the alias addition process
add_alias
