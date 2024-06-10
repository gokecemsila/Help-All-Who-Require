import os
import shutil

num = 300

while num<=500:
    src_b = '/home/meta/Desktop/Ecem/High1'
    dest_b = '/home/meta/Desktop/Ecem/High1'

    src_b = os.path.join(src_b, str(num))

    if not os.path.exists(src_b):
        num += 1
        continue
    else:
        if not os.path.exists(dest_b):
            os.makedirs(dest_b)

        allfiles = os.listdir(src_b)

        for f in allfiles:
            src_path = os.path.join(src_b, f)
            af = os.listdir(src_path)
            for file in af:
                s_path = os.path.join(src_path, file)
                print(s_path)
                d_path = os.path.join(dest_b, file)
                shutil.move(s_path, d_path)
        
            os.rmdir(src_path)
        os.rmdir(src_b)

        num += 1