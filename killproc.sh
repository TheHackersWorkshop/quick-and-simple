#!/bin/bash

# Check for argument before anything
if [ -z "$1" ]; then
    echo "Usage: killproc <PID|process name>"
    exit 1
fi

# Elevate to root only when needed
if [ "$EUID" -ne 0 ]; then
    echo "Elevating privileges with sudo..."
    exec sudo "$0" "$@"
fi

target=$1

# Function to kill a single PID
kill_by_pid() {
    echo "Killing process with PID: $1"
    kill -9 "$1" && echo "Process $1 killed." || echo "Failed to kill process $1."
}

# Function to find and kill processes by name with selection
kill_by_name() {
    pids=$(pgrep -f "$1")

    if [ -z "$pids" ]; then
        echo "No process found containing name: $1"
        exit 1
    fi

    echo "Found the following processes:"
    echo
    printf "%-8s %-s\n" "PID" "Command"
    echo "$pids" | while read -r pid; do
        cmd=$(ps -p "$pid" -o cmd=)
        printf "%-8s %s\n" "$pid" "$cmd"
    done
    echo

    read -p "Enter PID(s) to kill (e.g., 1234 or 1234 5678), or type 'all' to kill all: " input

    if [[ "$input" == "all" ]]; then
        echo "$pids" | while read -r pid; do
            kill -9 "$pid" && echo "Killed PID $pid" || echo "Failed to kill PID $pid"
        done
    elif [[ "$input" =~ ^[0-9\ ,]+$ ]]; then
        # Clean and split input into array
        input=$(echo "$input" | tr ',' ' ')
        for pid in $input; do
            kill -9 "$pid" && echo "Killed PID $pid" || echo "Failed to kill PID $pid"
        done
    else
        echo "Invalid input or abort requested. No processes killed."
    fi
}

# Main logic
if [[ "$target" =~ ^[0-9]+$ ]]; then
    kill_by_pid "$target"
else
    kill_by_name "$target"
fi
