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

    % Prepare output directory for SFDR images
    identifier = baseFileName(1:3);
    outputDir = fullfile(audioDir, identifier);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % Calculate number of segments based on the length of the signal
    numSegments = floor(length(signal) / 1024);

    % Process and save SFDR
    processSFDR(signal, Fs, numSegments, outputDir, identifier);
end

function processSFDR(signal, sampleRate, numSegments, outputDir, identifier)
    segmentLength = 1024 * 64; % Length of each signal segment
    j = 1; % Initialize the start index for segmenting

    sfdrDir = fullfile(outputDir, 'sfdr');
    if ~exist(sfdrDir, 'dir')
        mkdir(sfdrDir);
    end
    
    % Loop over segments
    for i = 1:numSegments
        endIndex = j + segmentLength - 1;
        if endIndex > length(signal)
            break; % Stop if the segment extends beyond the signal
        end
        segment = signal(j:endIndex);
        j = j + segmentLength; % Move to the next segment

        % Compute SFDR
        sfdrValue = sfdr(segment, sampleRate);

        % Plotting and saving the signal's spectrum with SFDR annotation
        figure('Visible', 'off');
        [Pxx, F] = periodogram(segment, [], 1024, sampleRate);
        plot(F, 10*log10(Pxx));
        hold on; % Hold the current plot
        % Highlight the SFDR value on the plot
        plot([0 max(F)], [sfdrValue sfdrValue], 'r--'); % Plot SFDR level
        hold off;
        xlabel('Frequency (Hz)');
        ylabel('Power/Frequency (dB/Hz)');
        title(sprintf('SFDR = %.2f dB for Segment %d', sfdrValue, i));
        legend('Spectrum', 'SFDR Level');

        saveas(gcf, fullfile(sfdrDir, sprintf('%s_sfdr_%d.png', identifier, i)));
        close(gcf); % Close figure to free resources
    end
end

