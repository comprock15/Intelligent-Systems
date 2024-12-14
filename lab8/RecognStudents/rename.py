import os

path = ".\Dataset1"

for folder in os.listdir(path):
    path_folder = os.path.join(path, folder)
    for i, filename in enumerate(os.listdir(path_folder)):
        path_folder_fn = os.path.join(path_folder, filename)
        path_folder_fn_new = os.path.join(path_folder, f"{folder}_V_{i}.png")
        os.rename(path_folder_fn, path_folder_fn_new)