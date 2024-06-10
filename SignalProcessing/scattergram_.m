% Define the directory and file pattern for audio files
audioDir = '/home/erich/EcemWS/TestData';  % Adjust this path as necessary
filePattern = fullfile(audioDir, '*_AUDIO_P_CLEAN.wav');
audioFiles = dir(filePattern);

% Check for the existence of files
if isempty(audioFiles)
    error('No audio files found in the specified directory.');
end

% Start a parallel pool if not already started
if isempty(gcp('nocreate'))
    parpool;  % Starts the default parallel pool
end

% Display how many files were found
fprintf('%d files found in the directory.\n', length(audioFiles));

% Process each file
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

    processSignal(signal, Fs, outputDir, identifier);
end

function processSignal(signal, fs, outputDir, identifier)
    % Segment the signal using the segmentSignal function
    segmentedData = segmentSignal(signal);
    
    % Process all segments
    for i = 1:length(segmentedData)
        if isempty(segmentedData(i).datasamps)
            continue; % Skip empty data segments (if any)
        end

        % Create output directory if it does not exist
        scattergramDir = fullfile(outputDir, 'scattergram');
        if ~exist(scattergramDir, 'dir')
            mkdir(scattergramDir);
        end

        generateScattergram(segmentedData(i).datasamps, fs, i, scattergramDir, identifier);
    end
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


function generateScattergram(data, fs, index, scattergramDir, identifier)
    figure('visible', 'off'); % Create a figure that doesn't pop up
    sf = waveletScattering('SignalLength', numel(data), 'SamplingFrequency', fs);
    [S, U] = scatteringTransform(sf, data);
    scattergram(sf, U, 'FilterBank', 2);
    xlabel('');
    ylabel('');
    title('');
    legend off;
    colorbar off;
    
    % Save the figure
    saveas(gcf, fullfile(scattergramDir, sprintf('%s_scattergram_%d.png', identifier, index)));
    close(gcf); % Close figure to free resources
end
