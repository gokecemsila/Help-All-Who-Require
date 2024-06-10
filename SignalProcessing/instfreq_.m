% Define the directory and file pattern for audio files
audioDir = '/home/erich/EcemWS/TestData';  % Adjust this path as necessary
filePattern = fullfile(audioDir, '*_AUDIO_P_CLEAN.wav');
audioFiles = dir(filePattern);

% Start a parallel pool if not already started
if isempty(gcp('nocreate'))
    parpool;  % Starts the default parallel pool
end

% Display how many files were found
fprintf('%d files found in the directory.\n', length(audioFiles));

% Process each file in parallel
parfor k = 1:length(audioFiles)
    baseFileName = audioFiles(k).name;
    fullFileName = fullfile(audioDir, baseFileName);
    fprintf('Now processing %s\n', fullFileName);
    
    [signal, Fs] = audioread(fullFileName);
    fprintf('File read successfully. Sample rate: %d Hz. Number of samples: %d.\n', Fs, length(signal));
    
    % Create a unique directory for each file's output based on its identifier
    identifier = baseFileName(1:3);
    outputDir = fullfile(audioDir, identifier);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Process the signal
    processAndSaveInstFreq(signal, Fs, outputDir, identifier);
end

function processAndSaveInstFreq(signal, fs, outputDir, identifier)
    segmentLength = 1024 * 64; % Define segment length
    overlap = segmentLength;
    j = 1; % Start index for the first segment
    idx = 1; % Initialize segment counter
    nyquistFreq = fs / 2; % Calculate the Nyquist frequency based on the sampling rate

    while j + segmentLength - 1 <= length(signal)
        % Extract segment
        dataSegment = signal(j:j+segmentLength-1);
        
        % Calculate instantaneous frequency within the valid frequency range
        instFreq = instfreq(dataSegment, fs, "FrequencyLimits", [1 nyquistFreq]);
        
        % Generate and save the plot
        fig = figure('visible', 'off');
        plot(instFreq);
        ylim([0 nyquistFreq]); % Adjust y-axis limits to Nyquist frequency
        xlabel('');
        ylabel('');
        title('');
        legend off;
        colorbar off;
        instfreqDir = fullfile(outputDir, 'instfreq');
        if ~exist(instfreqDir, 'dir')
            mkdir(instfreqDir);
        end
        saveas(fig, fullfile(instfreqDir, sprintf('%s_instfreq_%d.png', identifier, idx)));
        close(fig);
        
        % Update indices for next segment
        j = j + overlap;
        idx = idx + 1;
    end
end

