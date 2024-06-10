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

% Process each file in parallel
parfor k = 1:length(audioFiles)
    baseFileName = audioFiles(k).name;
    fullFileName = fullfile(audioDir, baseFileName);
    fprintf('Now processing %s\n', fullFileName);
    
    % Read audio file
    [signal, Fs] = audioread(fullFileName);
    fprintf('File read successfully. Sample rate: %d Hz. Number of samples: %d.\n', Fs, length(signal));
    
    % Create a unique directory for each file's output based on its identifier
    identifier = baseFileName(1:3);  % Assuming first 3 chars are the identifier
    outputDir = fullfile(audioDir, identifier);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % Process and save kurtogram
    processAndSaveKurtogram(signal, Fs, outputDir, identifier);
end

function processAndSaveKurtogram(signal, fs, outputDir, identifier)
    % Define parameters
    segmentLength = 1024 * 64;  % Set the window length for segments
    numSegments = floor(length(signal) / segmentLength);
    overlap = segmentLength;

    % Create output directory for the kurtograms
    kurtogramDir = fullfile(outputDir, 'kurtogram');
    if ~exist(kurtogramDir, 'dir')
        mkdir(kurtogramDir);
    end

    % Generate and save kurtograms for each segment
    for i = 1:numSegments
        j = 1 + (i-1) * overlap;
        segment = signal(j:j+segmentLength-1);

        % Generate kurtogram
        figure('Visible', 'off');
        kurtogram(segment, fs);
        ylim([0 12]);  % Set Y-limits for the kurtogram
        xlabel('');
        ylabel('');
        title('');
        legend off;
        colorbar off;

        % Save the figure
        saveas(gcf, fullfile(kurtogramDir, sprintf('%s_kurtogram_%d.png', identifier, i)));
        close(gcf);
    end
end

