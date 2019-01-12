% ComputeSimCategProb generated the simulated category probability based on
% behavioral data and on ground truth

%% Initialization
workDir = pwd;
dataFolder = fullfile(workDir,'data');
resultFolder = fullfile(workDir,'results');
layercount = 8;

%% Load behavioral data and cross-category probability
load(fullfile(dataFolder,'Behavioral_data.mat'));
load(fullfile(dataFolder,'Cross_category_scores.mat'));

%% Initialize probability matrices
behmat = zeros(length(Subjects), layercount, size(vrsp,2), size(corrmap,2)); %behavioral
truemat = zeros(layercount, size(vrsp,2), size(corrmap,2)); % ground truth

%% Assign the values from the cross-category correlation to the matrices
for subj = 1:length(Subjects)
    fprintf('Assigning simulated category scores for subject %s\n', Subjects{subj});
    for layer = 1:layercount
        for smp = 1:size(vrsp,2)
            currsmp = vrsp(subj,smp);
            if currsmp == 0
                behmat(subj,layer,smp,:) = 0.2*ones(5,1);
            else
                behmat(subj,layer,smp,:) = squeeze(corrmap(layer, currsmp, :));

            end
            currtrue = floor(tbeh(subj,smp)/100);
            truemat(layer,smp,:) = squeeze(corrmap(layer, currtrue, :));
        end
    end
end
fprintf('Saving...\n');
save(fullfile(workDir,'results','Simulated_Category_Scores.mat'), 'behmat', 'truemat');
fprintf('Done!\n');