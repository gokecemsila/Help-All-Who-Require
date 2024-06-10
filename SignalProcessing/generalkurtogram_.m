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

% Ensure that audioFiles is not empty
if isempty(audioFiles)
    error('No audio files found in the specified directory.');
end

% Process each file in parallel
parfor k = 1:length(audioFiles)
    baseFileName = audioFiles(k).name;
    fullFileName = fullfile(audioDir, baseFileName);
    fprintf('Now processing %s\n', fullFileName);
    
    [signal, Fs] = audioread(fullFileName);
    segmentLength = 1024 * 64;  % Set the window length for segments
    numSegments = floor(length(signal) / segmentLength);
    overlap = 64; % Overlap between segments

    fprintf('File read successfully. Sample rate: %d Hz. Number of samples: %d.\n', Fs, length(signal));
    
    % Create a unique directory for each file's output based on its identifier
    identifier = baseFileName(1:3);
    outputDir = fullfile(audioDir, identifier);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    processSignal(signal, Fs, numSegments, segmentLength, overlap, outputDir, identifier);
end

function processSignal(signal, fs, numSegments, segmentLength, overlap, outputDir, identifier)
    % Segment the signal and generate kurtograms
    j = 1024; % Initial offset for segmenting the signal
    for i = 1:numSegments
        if i == 1
            dataSegment = signal(1:segmentLength);
        else
            if (j + segmentLength - 1) > length(signal)
                break; % Stop if the next segment goes beyond the signal length
            end
            dataSegment = signal(j:j + segmentLength - 1);
            j = j + overlap; % Move the starting point for the next segment
        end
        generateKurtogram(dataSegment, fs, i, outputDir, identifier);
    end
end

function generateKurtogram(data, fs, index, outputDir, identifier)
    figure('visible', 'off'); % Create a figure that doesn't pop up
    kurtogram(data, fs);
    xlabel('');
    ylabel('');
    title('');
    legend off;
    colorbar off;
    kurtogramDir = fullfile(outputDir, 'generalkurtogram');
    if ~exist(kurtogramDir, 'dir')
        mkdir(kurtogramDir);
    end
    saveas(gcf, fullfile(kurtogramDir, sprintf('%s_generalkurtogram_%d.png', identifier, index))); % Save figure
    close(gcf); % Close figure to free resources
end

