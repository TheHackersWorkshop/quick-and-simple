#!/bin/bash

# Prompt for input and output files
read -p "Enter input file path: " infile
read -p "Enter output file path: " outfile

# Run dd with 2M block size and progress
sudo dd if="$infile" of="$outfile" bs=2M status=progress

# Notify completion
echo "Copy completed successfully."
