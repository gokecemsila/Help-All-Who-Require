import os
import shutil

num = 300

while num<=500:
    src_b = '/home/meta/Desktop/Ecem/Low'
    dest_b = '/home/meta/Desktop/Ecem/Low1'

    src_b = os.path.join(src_b, str(num))

    if not os.path.exists(src_b):
        num += 1
        continue
    else:
        src_base = os.path.join(src_b, 'hht')
        dest_base = os.path.join(dest_b, str(num), 'hht')

        if not os.path.exists(dest_base):
            os.makedirs(dest_base)

        allfiles = os.listdir(src_base)

        for f in allfiles:
            src_path = os.path.join(src_base, f)
            print(src_path)
            dst_path = os.path.join(dest_base, f)
            print(dst_path)
            shutil.move(src_path, dst_path)
        
        os.rmdir(src_base)
        os.rmdir(src_b)

        num += 1