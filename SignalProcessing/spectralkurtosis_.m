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
    processAndSaveKurtosis(signal, Fs, outputDir, identifier);
end

function processAndSaveKurtosis(signal, sampleRate, outputDir, identifier)
    segmentLength = 1024 * 64;  % Define the length of each signal segment
    overlap = segmentLength;  % Overlap between segments in samples
    numSegments = floor((length(signal) - segmentLength) / overlap) + 1;

    speckurtDir = fullfile(outputDir, 'spectralkurtosis');
    if ~exist(speckurtDir, 'dir')
        mkdir(speckurtDir);
    end

    j = 1;  % Starting index for segmentation

    % Loop through segments
    for i = 1:numSegments
        endIndex = j + segmentLength - 1;
        if endIndex > length(signal)
            break;  % Avoid accessing indices beyond the signal length
        end

        % Extract the segment
        segment = signal(j:endIndex);
        j = j + overlap;  % Move to the next segment start, considering overlap

        % Compute spectral kurtosis
        kurtosisValue = pkurtosis(segment, sampleRate);  % Assuming pkurtosis is a placeholder for actual kurtosis computation

        % Create figure to save the kurtosis plot
        figure('Visible', 'off');
        plot(kurtosisValue);
        xlabel('Frequency Bin');
        ylabel('Kurtosis');
        title(sprintf('Spectral Kurtosis for Segment %d', i));

        % Save the figure
        saveas(gcf, fullfile(speckurtDir, sprintf('%s_spectralkurtosis_%d.png', identifier, i)));
        close(gcf);
    end
end

