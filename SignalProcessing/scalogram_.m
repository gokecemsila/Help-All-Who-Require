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
    
    % Prepare output directory for scattergrams
    identifier = baseFileName(1:3); % Example: Using first 3 characters for folder name
    outputDir = fullfile(audioDir, identifier);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    processScalograms(signal, Fs, outputDir, identifier);
end

function processScalograms(signal, samplingFrequency, outputDir, identifier)
    % Initial segment setup
    segmentLength = 1024 * 64;
    overlap = segmentLength; % Define the overlap
    numSegments = floor((length(signal) - segmentLength) / overlap) + 1;

    % Preallocate structure for windowed data
    windowedData(numSegments).datasamps = [];
    
    % Fill the structure with segments of the signal
    for i = 1:numSegments
        startIndex = (i-1) * overlap + 1;
        endIndex = startIndex + segmentLength - 1;
        if endIndex > length(signal)
            break; % Avoid indexing beyond the signal length
        end
        windowedData(i).datasamps = signal(startIndex:endIndex);
    end

    scalogramDir = fullfile(outputDir, 'scalogram');
    if ~exist(scalogramDir, 'dir')
        mkdir(scalogramDir);
    end

    % Process each segment
    for i = 1:length(windowedData)
        if isempty(windowedData(i).datasamps)
            continue; % Skip empty data segments (if any)
        end
        % Wavelet scattering transform
        sf = waveletScattering('SignalLength', numel(windowedData(i).datasamps), 'SamplingFrequency', samplingFrequency);
        [S, U] = scatteringTransform(sf, windowedData(i).datasamps);
        scattergram(sf, U);


        fileName = fullfile(scalogramDir, sprintf('%s_scalogram_%d.png', identifier, i));
        saveas(gcf, fileName);
        close(gcf); % Close the figure to manage resources
    end
end

