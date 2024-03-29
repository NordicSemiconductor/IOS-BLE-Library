import os
import sys
import copy_files as cf
import replace_code as rc

if __name__ == '__main__':
    sources_dir = sys.argv[1]

    print('copying files...')
    source = os.path.join(sources_dir, 'iOS-BLE-Library')
    destination = os.path.join(sources_dir, 'iOS-BLE-Library-Mock')
    cf.copy_all_files(source, destination)

    script_path = os.path.join(os.getcwd(), sys.argv[0])
    script_path = os.path.dirname(script_path)
    additional_files_dir = os.path.join(script_path, 'additional_files')

    additional_files_dir_destination = os.path.join(destination, 'Additional Files')
    cf.copy_all_files(additional_files_dir, destination)

    print('arg0: ' + sys.argv[0])

    print('replacing code...')
    # modify all .swift files in the destination directory and its subdirectories
    modified_files = 0
    for root, dirs, files in os.walk(destination):
        for file in files:
            if file.endswith('.swift'):
                file_path = os.path.join(root, file)
                rc.modify_swift_file(file_path)
                modified_files += 1
    print('modified files: ' + str(modified_files))

