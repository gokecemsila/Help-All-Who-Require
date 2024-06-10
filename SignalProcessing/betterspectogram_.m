% Define the directory and file pattern for audio files
audioDir = '/home/erich/EcemWS/TestData';  % Adjust this path as necessary
filePattern = fullfile(audioDir, '*_AUDIO_P_CLEAN.wav');
audioFiles = dir(filePattern);

% Start a parallel pool if not already started
if isempty(gcp('nocreate'))
    parpool;  % Starts the default parallel pool
end

% Display the number of files found
fprintf('%d files found in the directory.\n', length(audioFiles));

% Process each file in parallel
parfor k = 1:length(audioFiles)
    baseFileName = audioFiles(k).name;
    fullFileName = fullfile(audioDir, baseFileName);
    fprintf('Now processing %s\n', fullFileName);
    
    % Read audio file
    [signal, Fs] = audioread(fullFileName);
    fprintf('File read successfully. Sample rate: %d Hz. Number of samples: %d.\n', Fs, length(signal));
    
    % Create a unique directory for each file's output based on its identifier
    identifier = baseFileName(1:3);
    outputDir = fullfile(audioDir, identifier);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Segment the signal and save spectrograms
    windowedData = segmentSignal(signal);
    saveSpectrogram(windowedData, outputDir, Fs, identifier);
end

function segmentedData = segmentSignal(signal)
    % Function to segment the signal
    segmentLength = 1024 * 64;  % Define segment length
    numSegments = floor(length(signal) / segmentLength);
    segmentedData = struct('datasamps', cell(1, numSegments));
    for i = 1:numSegments
        startIndex = (i - 1) * segmentLength + 1;
        endIndex = startIndex + segmentLength - 1;
        segmentedData(i).datasamps = signal(startIndex:endIndex);
    end
end

function saveSpectrogram(dataStruct, outputDir, samplingRate, identifier)
    % Function to generate and save spectrograms
    spectrogramDir = fullfile(outputDir, 'betterspectogram');
    if ~exist(spectrogramDir, 'dir')
        mkdir(spectrogramDir);
    end
    
    for i = 1:length(dataStruct)
        figure;
        spectrogram(dataStruct(i).datasamps, 256, [], [], samplingRate, "yaxis"); % Adjust window size for spectrogram
        ylim([0 12]);  % Set Y-axis limit for better visualization
        xlabel('');
        ylabel('');
        title('');
        saveas(gcf, fullfile(spectrogramDir, sprintf('%s_betterspectogram_%d.png', identifier, i)));
        close(gcf);
    end
end

