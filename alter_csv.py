import pandas as pd
from pathlib import Path
import os

num = 390

while num <= 390:
    base_path = Path(__file__).parent
    d = str(num) + '_P'
    base_path = base_path/d

    #assign according file names
    filename_transcript = str(num) + '_TRANSCRIPT.csv'
    filename_transcript_final = str(num) + '_TRANSCRIPT_F.csv'

    
    if not os.path.exists(base_path/filename_transcript):
        num += 1
        continue
    else:

        file_path = base_path/filename_transcript 

        df = pd.read_csv(file_path, header=None)

        columns = ['start_time', 'stop_time', 'speaker', 'value']
        df2 = pd.DataFrame(columns=columns)

        for index, row in df.iterrows():
            if index == 0:
                continue
            l = list(row.str.split('\t'))
            l=l[0]

            new_row = {'start_time': float(l[0]), 'stop_time': float(l[1]), 'speaker': l[2], 'value': l[3]}
            df2 = df2._append(new_row, ignore_index=True)

        df2.to_csv(base_path.parent/'Generated_Data'/filename_transcript_final, index=False)
        df2.to_csv(base_path/filename_transcript_final, index=False)

    num += 1


