% PredictFeatures uses the models created by TrainFeatureDecoders script to
% decode the features of blurred images

%% Initialization
clear;
BDTB_path = ''; %should add the path to brain decoder toolbox 2 here
rng('default');
Subjects = {'S1', 'S2', 'S3', 'S4', 'S5'};
DNNlayers = {'DNN1', 'DNN2', 'DNN3', 'DNN4', 'DNN5', 'DNN6', 'DNN7', 'DNN8'};
RoiNames = {'V1', 'V2', 'V3', 'V4', 'LOC', 'FFA', 'PPA', 'VC', 'MTG'};
feat_per_layer = 1000;
addpath(genpath(fullfile(pwd,'lib')));
if ~isempty(BDTB_path)
    addpath(genpath(BDTB_path));
else
    error('Specify the path for BrainDecoderToolbox');
end
workDir = pwd;
dataFolder = fullfile(workDir,'data');


%% Load fMRI data aligned with features
for subject = 1:length(Subjects)
    % load fRMI data file
    fprintf('Loading fMRI data and features from %s\n', Subjects{subject});
    Test(subject) = load(fullfile(dataFolder,['Test_', Subjects{subject}]),'Test');
    
    
end

%% Initialization of feature decoding training
param.numFeatures   = 500; %number of voxels for each ROI
param.layercount    = 8;    %number of layers
param.featurecount  = 1000; %number of features per layer

%% Create the list of decoders
subroicomb = combvec(1:length(Subjects),1:length(RoiNames));
subroicomb = subroicomb';
for combsr = 1:size(subroicomb,1)
    
    modelnames{combsr} = ...
        strcat(Subjects{subroicomb(combsr,1)}, '_', RoiNames{subroicomb(combsr,2)}, '.mat');

    
end

setupdir(fullfile(workDir,'results'));
%% Load decoders and predict features
for combsr = 1:size(subroicomb,1)
    analysisName = modelnames{combsr};
    fprintf('Feature decoding from %s started...\n', analysisName(1:end-4));
    testvox = Test(subroicomb(combsr,1)).Test.x{subroicomb(combsr,2)};
    labels = Test(subroicomb(combsr,1)).Test.labels;
    load(fullfile(workDir,'models', analysisName));
    [predictedf, truef] = test_eachROI(model, testvox, labels, sigma4label, mu4label, sigma4feat, mu4feat, I4feat, param);
    % feature array dimensions are in the form of (layer,feature,image)

    pred_feat{subroicomb(combsr,1),subroicomb(combsr,2)} = predictedf;
    
    fprintf('[Done] Feature decoding from %s...\n', analysisName(1:end-4));
        
end
true_feat =   truef;
DateCreated = date;
fprintf('Feature decodeing done!\n');
fprintf('Saving...\n');
save(fullfile(workDir,'results','Predicted_features.mat'),'pred_feat','true_feat',...
    'Test', 'Subjects','DNNlayers','RoiNames','DateCreated', '-v7.3');
fprintf('Done!\n');