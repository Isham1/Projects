# Sort files based on their extensions and move them into appropriate folders
import os, shutil

sort_folder_path = r"FOLDER PATH WITH UNSORTED FILES"
# r here is used to indicate raw text. Using that, python wont cause an issue with all the forward-slashes and colons

# Create a new method to only return non-hidden files
def list_non_hidden_files(path):
    non_hidden_files = [file for file in os.listdir(path) if not file.startswith('.')]
    return non_hidden_files

files = list_non_hidden_files(sort_folder_path)
print('These are the files present in inside the path provided: ', files)

# Extract all the unique extensions present in the folder
extension_set = set()
folder_set = set()
for names in files:
    extension = names.split(".", 1)[1]
    extension_set.add(extension)
    folder_set.add(extension + '_folder')

print('These are the unique extensions present: ', extension_set)

print('Creating following folders: ', folder_set)

# Create a folder for the extension name if not present
for number in range(0, len(folder_set)):
    for names in folder_set:
        if not os.path.exists(sort_folder_path + names):
            os.makedirs(sort_folder_path + names)

print('Moving files into their respective folder.')            

# Move the files into their respective folder
for extension_name in extension_set:
    for file in files:
        if file.endswith('.' + extension_name):
            source_path = os.path.join(sort_folder_path, file)
            destination_path = os.path.join(sort_folder_path, extension_name + '_folder', file)
            shutil.move(source_path, destination_path) 

print('Files moved successfully.')