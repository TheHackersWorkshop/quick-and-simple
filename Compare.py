import difflib
import os

def compare_files(file1_path, file2_path):
    # Check if files exist
    if not os.path.exists(file1_path):
        print(f"Error: '{file1_path}' does not exist.")
        return
    if not os.path.exists(file2_path):
        print(f"Error: '{file2_path}' does not exist.")
        return

    # Open and read both files as whole text blocks
    with open(file1_path, 'r') as file1, open(file2_path, 'r') as file2:
        file1_content = file1.readlines()
        file2_content = file2.readlines()

    # Create a Differ object to compare the files' contents
    differ = difflib.Differ()
    diff = list(differ.compare(file1_content, file2_content))

    # Filter and print only differences
    has_diff = False
    for line in diff:
        if line.startswith("+ ") or line.startswith("- ") or line.startswith("? "):
            print(line, end='')
            has_diff = True

    if not has_diff:
        print("The files are identical.")

if __name__ == '__main__':
    file1_path = input("Enter the path for the first file: ").strip()
    file2_path = input("Enter the path for the second file: ").strip()
    compare_files(file1_path, file2_path)
