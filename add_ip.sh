#!/bin/bash

# Prompt user for name and IP address
echo "Enter the hostname:"
read name
echo " "
echo "Enter the IP address:"
read ip

# Add the new entry to /etc/hosts
echo "$ip    $name" | sudo tee -a /etc/hosts
echo " "
echo "Entry added: $ip    $name"
