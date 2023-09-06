import os
import shutil

def copy_all_files(source, destination):
    '''
    copy with replace all files and directories from source to destination
    '''
    created_directories = 0
    created_files = 0
    for root, dirs, files in os.walk(source):
        for dir in dirs:
            source_dir = os.path.join(root, dir)
            destination_dir = source_dir.replace(source, destination)
            if not os.path.exists(destination_dir):
                os.makedirs(destination_dir)
                created_directories += 1
        for file in files:
            source_file = os.path.join(root, file)
            destination_file = source_file.replace(source, destination)
            if os.path.exists(destination_file):
                os.remove(destination_file)
            shutil.copy(source_file, destination_file)
            created_files += 1
    print('created directories: ' + str(created_directories))
    print('created files: ' + str(created_files))

