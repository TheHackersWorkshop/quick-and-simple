#!/bin/bash

# Ask the user for the directory path to scan
read -p "Enter the directory path to scan: " folder_path

# Check if the directory exists
if [ ! -d "$folder_path" ]; then
  echo "Directory not found!"
  exit 1
fi

# Get the list of directories and save to 'directories_list.txt' in the current working directory
output_file="./directories_list.txt"
find "$folder_path" -maxdepth 1 -type d -exec basename {} \; > "$output_file"

echo "Directory list saved to $output_file"
