import pandas as pd
from pydub import AudioSegment
from pathlib import Path
import os

num = 390

while num <= 390:

    print(num)

    base_path = Path(__file__).parent
    d = str(num) + '_P'
    base_path = base_path/d

    #assign according file names
    filename_transcript_final = str(num) + '_TRANSCRIPT_F.csv'
    filename_audio = str(num) + '_AUDIO.wav'
    filename_audio_participant = str(num) + '_AUDIO_P.wav'
    filename_participant_txt = str(num) + '_P_SPEECH.txt'

    if not os.path.exists(base_path/filename_transcript_final):
        num += 1
        continue
    else:

        file_path = base_path/filename_transcript_final 

        df = pd.read_csv(file_path, header=None, names=['start_time', 'stop_time', 'speaker', 'value'])
        df.drop(0, inplace=True)

        #turn type of timestamps to float
        df['start_time'] = (df['start_time'].astype(float) * 1000).astype(int)
        df['stop_time'] = (df['stop_time'].astype(float) * 1000).astype(int)


        audio = AudioSegment.from_wav(base_path/filename_audio)

        #empty audio file
        participant_audio = AudioSegment.silent(duration=0)
        #empty text file
        participant_txt = ''

        for index, row in df.iterrows():
            if row['speaker'] != 'Ellie':
                participant_txt += str(row['value']) + '\n'
                participant_audio += audio[row['start_time']:row['stop_time']]

        # export participant only audio
        participant_audio.export(base_path.parent/'Generated_Data'/filename_audio_participant, format='wav'),
        participant_audio.export(base_path/filename_audio_participant, format='wav')

        with open(base_path.parent/'Generated_Data'/filename_participant_txt, 'w') as file:
            file.write(participant_txt.strip())

        with open(base_path/filename_participant_txt, 'w') as file:
            file.write(participant_txt.strip())

    num += 1
