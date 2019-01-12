%TrainFeatureDecoders.m script trains decoders to predict DNN features from
%fMRI data

%% Initialization
BDTB_path = ''; %should add the path to brain decoder toolbox 2 here
clear;
rng('default');
Subjects = {'S1', 'S2', 'S3', 'S4', 'S5'};
DNNlayers = {'DNN1', 'DNN2', 'DNN3', 'DNN4', 'DNN5', 'DNN6', 'DNN7', 'DNN8'};
RoiNames = {'V1', 'V2', 'V3', 'V4', 'LOC', 'FFA', 'PPA', 'VC', 'MTG'};
feat_per_layer = 1000;
addpath(genpath(fullfile(pwd,'lib')));
workDir = pwd;
lockDir = fullfile(workDir,'tmp');
if ~isempty(BDTB_path)
    addpath(genpath(BDTB_path));
else
    error('Specify the path for BrainDecoderToolbox');
end

dataFolder = fullfile(workDir,'data');

%% Load fMRI data
for subject = 1:length(Subjects)
    % load fRMI data and features file
    fprintf('Loading fMRI data and DNN features from %s\n', Subjects{subject});
    Train(subject) = load(fullfile(dataFolder,['Training_', Subjects{subject}]));
        
end

%% Initialization of feature decoding training
param.numFeatures   = 500; %number of voxels for each ROI
param.Ntrain        = 2000; % # of total training iteration (note that the number of iterations in the manuscript was 2000)
param.Nskip         = param.Ntrain;     % skip steps for display info
param.layercount    = 8;    %number of layers
param.featurecount  = 1000; %number of features per layer

%% Create the list of decoders to build
subroicomb = combvec(1:length(Subjects),1:length(RoiNames));
subroicomb = subroicomb';
for combsr = 1:size(subroicomb,1)
    
    modelnames{combsr} = ...
        strcat(Subjects{subroicomb(combsr,1)}, '_', RoiNames{subroicomb(combsr,2)}, '.mat');

    
end

%% Check if models already exist
model_exist = false(length(Subjects)*length(RoiNames),1);
if exist(fullfile(workDir,'models'))
    model_files = dir(fullfile(workDir,'models','*.mat'));
    for fi = 1:length(model_files)
        model_exist = model_exist | strcmp(model_files(fi).name,modelnames)';
        fprintf('Decoder %s model already exists... Skipped\n', model_files(fi).name(1:end-4));
    end
else
    mkdir(fullfile(workDir,'models'));
end

% remove decoders that already exist from creation list
subroicomb(model_exist,:) = [];
modelnames(model_exist) = [];

%% Train decoders and save them
for combsr = 1:size(subroicomb,1)
    analysisName = modelnames{combsr};
    % if model exists skip
    if exist(fullfile(workDir,'models',analysisName))
        fprintf('Decoder %s model already exists... Skipped\n', analysisName(1:end-4));
        continue;
    end
    
    % if locked then skip 
    if islocked(analysisName, lockDir)
        fprintf('Decoder %s training is already running... Skipped\n', analysisName(1:end-4));
        continue;
    end
    % lock current process
    lockcomput(analysisName, lockDir);
    % start training
    fprintf('Decoder %s training started\n', analysisName(1:end-4));
    trainingvox = Train(subroicomb(combsr,1)).x{subroicomb(combsr,2)};
    labels = Train(subroicomb(combsr,1)).labels;
    [model, sigma4label, mu4label, sigma4feat, mu4feat, I4feat] = train_eachROI(labels,trainingvox,param);
    
    % save model
    save(fullfile(workDir,'models',modelnames{combsr}),'model','sigma4label','mu4label','sigma4feat','mu4feat','I4feat', '-v7.3');
    fprintf('Decoder %s training finished\n', analysisName(1:end-4));
    unlockcomput(analysisName, lockDir);
        
end
fprintf('Decoders training finished!\n');