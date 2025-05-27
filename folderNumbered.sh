#!/bin/bash

# Prompt for optional directory name prefix
read -p "Directory name prefix (leave blank for just numbers): " prefix

# Prompt for how many directories to create
read -p "Enter the number of directories to create in the current folder ($(pwd)): " num

# Validate input: must be a positive integer
if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -le 0 ]; then
    echo "Please enter a valid positive integer."
    exit 1
fi

# Use the current working directory
target_dir="$(pwd)"

# Create the directories with optional prefix
for i in $(seq -w 1 "$num"); do
    dirname="${prefix}${i}"
    mkdir "$target_dir/$dirname"
done

echo "$num directories (from ${prefix}01 to ${prefix}$(printf "%02d" "$num")) have been created in $target_dir."
