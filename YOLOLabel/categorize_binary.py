import pandas as pd
import os
import shutil
from pydub import AudioSegment

#read csv files
df_dev = pd.read_csv("D:\\Ecme\\Dataset Documents\\dev_split_Depression_AVEC2017.csv", header=0)
df_test = pd.read_csv("D:\\Ecme\\Dataset Documents\\full_test_split.csv", header=0)
df_train = pd.read_csv("D:\\Ecme\\Dataset Documents\\train_split_Depression_AVEC2017.csv", header=0)

#initialize empty set for patients
participants = set()
rows_to_add = []

#for dev
na_idx = df_dev['Participant_ID'].isna()

for idx, row in df_dev.iterrows():
    if idx == 0 or na_idx[idx]: continue
    participants.add(int(row['Participant_ID']))

    new_row = {'Participant_ID': int(row['Participant_ID']), 'PHQ8_Binary': int(row['PHQ8_Binary']), 'PHQ8_Score': int(row['PHQ8_Score'])}
    rows_to_add.append(new_row)

#for test
na_idx = df_test['Participant_ID'].isna()

for idx, row in df_test.iterrows():
    if idx == 0 or na_idx[idx]: continue
    participants.add(int(row['Participant_ID']))

    new_row = {'Participant_ID': int(row['Participant_ID']), 'PHQ8_Binary': int(row['PHQ_Binary']), 'PHQ8_Score': int(row['PHQ_Score'])}
    rows_to_add.append(new_row)

#for train
na_idx = df_train['Participant_ID'].isna()

for idx, row in df_train.iterrows():
    if idx == 0 or na_idx[idx]: continue
    participants.add(int(row['Participant_ID']))
    
    new_row = {'Participant_ID': int(row['Participant_ID']), 'PHQ8_Binary': int(row['PHQ8_Binary']), 'PHQ8_Score': int(row['PHQ8_Score'])}
    rows_to_add.append(new_row)

columns = ['Participant_ID', 'PHQ8_Binary', 'PHQ8_Score']
df_participants = pd.DataFrame(rows_to_add, columns=columns)
df_participants[columns] = df_participants[columns].astype(int)

risk_participants = set()

for idx, row in df_participants.iterrows():

    if row['PHQ8_Binary'] != 0:
        risk_participants.add(row['Participant_ID'])


base_path = 'D:\Ecme\Dataset'


hi_risk = AudioSegment.silent(duration=0)
lo_risk = AudioSegment.silent(duration=0)

hi_risk_list = ""
lo_risk_list = ""

for p in participants:

    d = str(p) + '_P'

    path = os.path.join(base_path, d)
    filename_audio_clean = str(p) + '_AUDIO_P_CLEAN.wav'
    src = os.path.join(path, filename_audio_clean)

    if p in risk_participants:
        dest = os.path.join(base_path, 'HighRisk')
        hi_risk_list += str(p)
        hi_risk_list += " "
        

    else:
        dest = os.path.join(base_path, 'LowRisk')
        lo_risk_list += str(p)
        lo_risk_list += " "

    destination_file = os.path.join(dest, os.path.basename(src))

    shutil.copy2(src, destination_file)

hi = os.path.join(base_path, 'HighRisk', 'hi_risk_list.txt')
lo = os.path.join(base_path, 'LowRisk', 'lo_risk_list.txt')

with open(hi, 'w') as file:
    file.write(hi_risk_list.strip())

with open(lo, 'w') as file:
    file.write(lo_risk_list.strip())
