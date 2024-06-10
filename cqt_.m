% Define the directory and file pattern
audioDir = '/home/erich/EcemWS/TestData';
filePattern = fullfile(audioDir, '*_AUDIO_P_CLEAN.wav');  % Adjusted for .wav files
audioFiles = dir(filePattern);

% Start a parallel pool if not already started
if isempty(gcp('nocreate'))
    parpool;  % Starts the default parallel pool
end

% Display how many files were found
fprintf('%d files found in the directory.\n', length(audioFiles));

% Process each file in parallel
parfor k = 1:length(audioFiles)
    processFile(audioFiles(k), audioDir);
end

function processFile(fileData, audioDir)
    baseFileName = fileData.name;
    fullFileName = fullfile(audioDir, baseFileName);
    fprintf('Now processing %s\n', fullFileName);

    % Load audio file using audioread
    [signal, Fs] = audioread(fullFileName);

    % Process the signal
    windowedData = segmentSignal(signal);
    identifier = baseFileName(1:3);
    saveCQT(windowedData, audioDir, identifier);  % Using strtok to separate identifier
end

function segmentedData = segmentSignal(signal)
    segmentLength = 1024 * 64;  % Set the window length for segments
    numSegments = floor(length(signal) / segmentLength);
    segmentedData = struct('datasamps', cell(1, numSegments));
    for i = 1:numSegments
        startIndex = (i - 1) * segmentLength + 1;
        endIndex = startIndex + segmentLength - 1;
        segmentedData(i).datasamps = signal(startIndex:endIndex);
    end
end

function saveCQT(dataStruct, outputDir, identifier)
    % Define the directory to save the CQT images
    cqtDir = fullfile(outputDir, identifier, 'cqt');
    if ~exist(cqtDir, 'dir')
        mkdir(cqtDir);
    end

    % Generate and save CQT images
    for i = 1:length(dataStruct)
        fig = figure('Visible', 'off');  % Set to 'off' for non-interactive sessions
        % Adjust the frequency limits to maximum of 8000 Hz
        cqt(dataStruct(i).datasamps, 'SamplingFrequency', 16000, 'FrequencyLimits', [47, 8000]);
        title('');
        xlabel('');
        ylabel('');
        colorbar('off');
        saveas(fig, fullfile(cqtDir, sprintf('%s_cqt_%d.png', identifier, i)));
        close(fig);
    end
end

