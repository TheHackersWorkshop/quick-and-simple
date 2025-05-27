 
import subprocess

def search_files():
    # Prompt the user for the search pattern (e.g., *.sh)
    file_pattern = input("Enter the file pattern to search for (e.g., '*.sh'): ")

    # Prompt the user for the directory to search (default to /media)
    directory = input("Enter the directory to search in (default: /media): ") or "/media"

    # Form the find command
    command = f"sudo find {directory} -type f -name \"{file_pattern}\" 2>/dev/null"

    # Execute the command and capture the output
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        # Print the result (files found)
        if result.stdout:
            print(f"Found files:\n{result.stdout}")
        else:
            print("No files found.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e.stderr}")

# Run the search function
search_files()
