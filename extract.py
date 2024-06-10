from pathlib import Path
import zipfile
import os

num = 456

while num <= 492:

    base_path = Path(__file__).parent

    file_name = str(num) + '_P.zip'
    file_dest = str(num) + '_P'

    if not os.path.exists(base_path/file_name):
        num += 1
        continue
    else:
        with zipfile.ZipFile(base_path/file_name, 'r') as z:
            z.extractall(base_path/file_dest)
        os.remove(base_path/file_name)
    
    num += 1
