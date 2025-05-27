import os

# Prompt user for the source directory
source_dir = input("Enter the directory containing files to combine: ").strip()

# Validate directory
if not os.path.isdir(source_dir):
    print(f"Error: '{source_dir}' is not a valid directory.")
    exit(1)

# Get all regular files in the directory, sorted alphabetically
files = sorted([
    f for f in os.listdir(source_dir)
    if os.path.isfile(os.path.join(source_dir, f))
])

if not files:
    print("No files found in the specified directory.")
    exit(0)

# Output file will be created in the current working directory
output_file = 'combined_list.txt'
output_path = os.path.join(os.getcwd(), output_file)

with open(output_path, 'w', encoding='utf-8') as outfile:
    for filename in files:
        filepath = os.path.join(source_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as infile:
            outfile.write(f"# --- Start of {filename} ---\n")
            outfile.write(infile.read())
            outfile.write("\n\n")

print(f"{len(files)} file(s) have been combined into '{output_file}' in {os.getcwd()}.")
