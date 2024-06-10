import librosa
import os
import soundfile as sf
import numpy as np
from pathlib import Path
from scipy.signal import butter, filtfilt

num = 424

while num <= 447:
    
    base_path = Path(__file__).parent
    d = str(num) + '_P'
    base_path = base_path/d

    #assign according file names
    filename_audio_p = str(num) + '_AUDIO_P.wav'
    filename_audio_clean = str(num) + '_AUDIO_P_CLEAN.wav'

    if not os.path.exists(base_path/filename_audio_p):
        num += 1
        continue
    else:
        audio, sr = librosa.load(base_path/filename_audio_p, sr=None)

        # High-pass filter function
        def high_pass_filter(data, cutoff, fs, order=5):
            nyq = 0.5 * fs
            normal_cutoff = cutoff / nyq
            b, a = butter(order, normal_cutoff, btype='high', analog=False)
            y = filtfilt(b, a, data)
            return y

        # Apply high-pass filter
        hp_cutoff_hz = 100
        audio_highpassed = high_pass_filter(audio, hp_cutoff_hz, sr)

        # Frequency-specific noise reduction
        def freq_specific_reduction(audio, sr):
            stft = librosa.stft(audio)
            magnitude, phase = librosa.magphase(stft)
            freq_bins, times = magnitude.shape

            # Frequency-dependent thresholds
            thresholds = np.linspace(-35, -20, num=freq_bins)

            for i in range(freq_bins):
                threshold = thresholds[i]
                magnitude[i, :] = np.where(librosa.amplitude_to_db(magnitude[i, :]) > threshold, magnitude[i, :], 0)

            processed_audio = librosa.istft(magnitude * phase)
            return processed_audio

        # Apply noise reduction with frequency-specific adjustments
        audio_processed = freq_specific_reduction(audio_highpassed, sr)

        # Temporal smoothing
        def temporal_smoothing(audio, window_len=10):
            smoothed_audio = np.convolve(audio, np.ones(window_len)/window_len, mode='same')
            return smoothed_audio

        # Apply temporal smoothing
        smoothed_audio = temporal_smoothing(audio_processed)

        # Save the result
        sf.write(base_path/filename_audio_clean, smoothed_audio, sr)
        sf.write(base_path.parent/'Generated_Data'/filename_audio_clean, smoothed_audio, sr)
        
    num += 1

    



    

    


