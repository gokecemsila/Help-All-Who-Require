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
    
    processSignal(signal, outputDir, identifier, Fs);
end

function processSignal(signal, outputDir, identifier, fs)
    segmentLength = 1024 * 64;  % Set the window length for segments
    numSegments = floor(length(signal) / segmentLength);

    % Process and save each segment
    for i = 1:numSegments
        startIndex = (i - 1) * segmentLength + 1;
        if startIndex + segmentLength - 1 > length(signal)
            break;  % Avoid indexing beyond the signal
        end
        dataSegment = signal(startIndex:startIndex + segmentLength - 1);
        saveHHT(dataSegment, fs, outputDir, i, identifier);
    end
end

function saveHHT(data, fs, outputDir, idx, identifier)
    [imf, ~, ~] = emd(data, 'Interpolation', 'pchip');
    hs = hht(imf, fs);
    fig = figure('visible', 'off');
    imagesc(hs);
    ylim([0 30]);
    xlabel('');
    ylabel('');
    title('');
    legend off;
    colorbar off;
    hhtDir = fullfile(outputDir, 'hht');
    if ~exist(hhtDir, 'dir')
        mkdir(hhtDir);
    end
    imagePath = fullfile(hhtDir, sprintf('%s_hht_%d.png', identifier, idx));
    saveas(fig, imagePath);
    close(fig);
end

