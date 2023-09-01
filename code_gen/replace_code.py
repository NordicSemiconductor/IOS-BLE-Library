import re

# Define a regular expression pattern to match the code blocks
pattern = r"//CG_REPLACE\n(.*?)//CG_WITH\n(/\*.*?\*/\n)?//CG_END\n"

# Function to modify code blocks in a Swift file
def modify_swift_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

    # Use re.DOTALL to match across multiple lines
    matches = re.findall(pattern, content, re.DOTALL)

    if not matches:
        return

    for match in matches:
        replace_block = match[0]
        with_block = match[1]

        # Remove the CG_REPLACE block and associated artifact code
        content = content.replace(f"//CG_REPLACE\n", "")
        content = content.replace(replace_block, "")
        content = content.replace(f"//CG_WITH\n", "")

        # Remove the CG_END block
        content = content.replace("//CG_END", "")

        # Comment out the code in CG_REPLACE
        content = content.replace(replace_block, f"/*\n{replace_block}*/\n")

        # Uncomment the code in CG_WITH if it exists
        if with_block:
            # Remove the /* and */ from the beginning and end of the block
            uncommented_block = with_block.strip('/*').strip()
            uncommented_block = uncommented_block.strip('*/').strip()
            content = content.replace(f"{with_block}", uncommented_block)

    # Write the modified content back to the file
    with open(file_path, 'w') as file:
        file.write(content)
