audioDir = '/home/erich/EcemWS/TestData';  % Adjust this path
filePattern = fullfile(audioDir, '*_AUDIO_P_CLEAN.wav');
audioFiles = dir(filePattern);

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
    
    [signal, Fs] = audioread(fullFileName);
    fprintf('File read successfully. Sample rate: %d Hz. Number of samples: %d.\n', Fs, length(signal));
    
    identifier = baseFileName(1:3);  % Consider using a more robust method here
    outputDir = fullfile(audioDir, identifier);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    windowedData = segmentSignal(signal);
    for idx = 1:length(windowedData)
        identifier = baseFileName(1:3);
        saveCWT(windowedData(idx).datasamps, Fs, outputDir, identifier, idx);
    end
end

function windowedData = segmentSignal(signal)
    segmentLength = 1024 * 64;
    numSegments = floor(length(signal) / segmentLength);
    windowedData = struct('datasamps', cell(1, numSegments));
    for i = 1:numSegments
        startIndex = (i - 1) * segmentLength + 1;
        endIndex = startIndex + segmentLength - 1;
        windowedData(i).datasamps = signal(startIndex:endIndex);
    end
end

function saveCWT(data, fs, outputDir, identifier, idx)
    [imf, ~, ~] = emd(data, 'Interpolation', 'pchip');
    if isempty(imf)
        fprintf('No IMFs were extracted for %s segment %d. Skipping HHT.\n', identifier, idx);
        return;
    end
    hs = hht(imf, fs);
    fig = figure('visible', 'off');
    imagesc(hs);
    ylim([0 30]);
    xlabel('');
    ylabel('');
    title('');
    legend off;
    colorbar off;
    cwtDir = fullfile(outputDir, 'cwt');
    if ~exist(cwtDir, 'dir')
        mkdir(cwtDir);
    end
    imagePath = fullfile(cwtDir, sprintf('%s_cwt_%d.png', identifier, idx));
    saveas(fig, imagePath);
    close(fig);
end


