import os
import shutil

src_b = '/home/meta/Desktop/Ecem/Dataset/LTrain/Labels'
dest_b = '/home/meta/Desktop/Ecem/Dataset/Train/Labels'


if not os.path.exists(dest_b):
    os.makedirs(dest_b)

allfiles = os.listdir(src_b)

for f in allfiles:
    src_path = os.path.join(src_b, f)
    print(src_path)
    dst_path = os.path.join(dest_b, f)
    print(dst_path)
    shutil.move(src_path, dst_path)

os.rmdir(src_b)


