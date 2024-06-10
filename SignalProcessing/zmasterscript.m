% List of scripts to run
scriptsToRun = {'betterspectogram_.m', 'cqt_.m', 'cwt_.m', 'fsst_.m', 'generalkurtogram_.m', 'hht_.m', 'instfreq_.m', 'kurtogram_.m', 'powerspectrum_.m', 'scalogram_.m', 'scattergram_.m', 'sfdr_.m', 'spectralkurtosis_.m'};

% Loop through each script and execute it
for i = 1:length(scriptsToRun)
    scriptName = scriptsToRun{i};
    try
        % Execute script
        run(scriptName);
        fprintf('Successfully ran %s\n', scriptName);
    catch ME
        % Error handling
        fprintf('Failed to run %s: %s\n', scriptName, ME.message);
    end
end
