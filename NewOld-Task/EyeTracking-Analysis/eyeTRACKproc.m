function [] = eyeTRACKproc(cleanedDataLOC, saveLOC, eyeData_pt)

% Set data paths
if ~exist(cleanedDataLOC,'dir')
    mkdir(cleanedDataLOC)
end

% [For every file in eyeDATA, loop through to run analyses?]
% save cleaned files in new folder to only have raw data in this folder
% need to cd to new folder to save

% CD to mainPath for raw data
cd(saveLOC);

% % Get contents of eyeDATA as a variable
% test = dir('*.mat');
% fileList = {test.name};

% for loop to loop throguh fileList
%for fileS = 1:length(fileList)

    tempFile_name = eyeData_pt;

    % Set tempFile_name
    saveFile_name1 = ['cl_', tempFile_name];

    % Load in file
    load(tempFile_name, 'variantS'); 

    % Set tempEye- loop through every eye in every variant within variantS
    % Go into variantS and determine # variants there
    varSnum = length(fieldnames(variantS));

    % Other option: Extract field names of variantS ahead of time
    varSfieldN = fieldnames(variantS);
    % Extract field names of each variant in variantS


    for i = 1:varSnum
        % name of variant
        currentVariant = variantS.(varSfieldN{i});

        % create # field names in var3 and then actual field names
        eyeNum = length(fieldnames(currentVariant));
        % Variable for field names of current variant
        varCurrent_fieldN = fieldnames(currentVariant);

        % Loop through each eye in variant
        for eyE = 1:eyeNum
            tempEye = currentVariant.(varCurrent_fieldN{eyE});

            %%%%%%%%%%%%%% EYE PROCCESSING CODE %%%%%%%%%%%%%%%%%%%%%%
            % chop data into trials and make sure all are same length - trim back
            % to make all same size/length. find shortest trial time and make all rest the same
            
            cleanPupil_size = tempEye.oT_pupilS_mean < 120; %create logical vector
            tempEye.oT_pupilS_mean(cleanPupil_size) = nan; % overwriting rows of field that x want with nans
            tempEye_clean = tempEye;

            varEye  = tempEye_clean.oT_pupilS_raw;
            for num = 1:height(varEye)

                Eye_clean = varEye{num,1};

                if sum(Eye_clean <= 120) ~= 0
                    eyeNaNindex = find(Eye_clean <= 120);
                    minEye_in = min(eyeNaNindex);
                    maxEye_in = max(eyeNaNindex);
                    eyeNaNindex2 = minEye_in-15:maxEye_in+15;
                    if min(eyeNaNindex2) < 1
                        eyeNaNindex2 = 1:maxEye_in+15;
                    elseif max(eyeNaNindex2) > length(Eye_clean)
                        eyeNaNindex2 = minEye_in-15:length(Eye_clean);
                    end
                    Eye_clean(eyeNaNindex2) = nan(length(eyeNaNindex2),1); %problem
                    varEye{num,1} = Eye_clean;
                end
            end

            % Input cleaned values in varEye into tempEye_clean.oT_pupilS_raw
            tempEye_clean.oT_pupilS_raw = varEye;

            %%% Trim values to be all the same length

            % Find shortest row in column 6
            min_varEye = min(cellfun(@(x) numel(x), varEye, 'UniformOutput', true));
            % Trim all rows in col 6 to shortest length
            for trim = 1:height(varEye)
                varEye{trim} = varEye{trim}(1:min_varEye);

            end

            % Input cleaned values in varEye into tempEye_clean.oT_pupilS_raw
            tempEye_clean.oT_pupilS_raw = varEye;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Save cleaned data into variantS
            variantS.(varSfieldN{i}).(varCurrent_fieldN{eyE}) = tempEye_clean;

        end

    end
    cd(cleanedDataLOC);
    save(saveFile_name1, 'variantS');
%end



end