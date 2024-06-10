% Define the directory for audio files and create a list of files
audioDir = '/home/erich/EcemWS/TestData';
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

    % Prepare output directory for persistence spectrum images
    identifier = baseFileName(1:3);
    outputDir = fullfile(audioDir, identifier);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % Process and save persistence spectrum
    processAndSaveWSST(signal, Fs, outputDir, identifier);
end

function processAndSaveWSST(audioData, sampleRate, outputDir, identifier)
    segmentLength = 1024 * 64;  % Define the length of each signal segment
    overlap = segmentLength;
    numSegments = floor(length(audioData) / segmentLength);

    % Ensure the output directory exists
    wsstDir = fullfile(outputDir, 'wsst');
    if ~exist(wsstDir, 'dir')
        mkdir(wsstDir);
    end

    % Loop through each segment
    for i = 1:numSegments
        startIndex = (i - 1) * (segmentLength - overlap) + 1;
        endIndex = startIndex + segmentLength - 1;
        
        % Handle last segment case
        if endIndex > length(audioData)
            endIndex = length(audioData);
        end

        % Extract the segment
        segment = audioData(startIndex:endIndex);

        % Compute the WSST
        [wsstData, f] = wsst(segment, sampleRate);

        % Create figure
        figure('Visible', 'off');
        imagesc(1:size(wsstData, 2), f, abs(wsstData));
        axis tight;
        ylim([0 sampleRate/2])  % Adjust to show relevant frequency range
        set(gca, 'YDir', 'normal');  % Correct the y-axis direction
        xlabel('Time');
        ylabel('Frequency (Hz)');
        title(sprintf('WSST for Segment %d', i));

        % Save the figure
        saveas(gcf, fullfile(wsstDir, sprintf('%s_wsst_%d.png', identifier, i)));
        close(gcf);
    end
end

