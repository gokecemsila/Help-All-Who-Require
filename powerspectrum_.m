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
    processAndSavePersistence(signal, Fs, outputDir, identifier);
end

function processAndSavePersistence(signal, fs, outputDir, identifier)
    segmentLength = 1024 * 64; % Length of each segment
    overlap = segmentLength;       % Overlap between segments
    numSegments = floor((length(signal) - segmentLength) / overlap) + 1;

    powspecDir = fullfile(outputDir, 'powerspectrum');
    if ~exist(powspecDir, 'dir')
        mkdir(powspecDir);
    end

    for i = 1:numSegments
        startIndex = 1 + (i - 1) * overlap;
        if startIndex + segmentLength - 1 > length(signal)
            break;
        end
        segment = signal(startIndex:startIndex + segmentLength - 1);

        % Compute and plot persistence spectrum
        figure('Visible', 'off');
        pspectrum(segment, fs);
        xlabel('');
        ylabel('');
        title(sprintf('Segment %d', i));
        legend off;

        % Save the figure
        saveas(gcf, fullfile(powspecDir, sprintf('%s_powerspectrum_%d.png', identifier, i)));
        close(gcf);
    end
end

