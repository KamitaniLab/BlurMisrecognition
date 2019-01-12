% ComputeScoreSimilarity compute similarity between predicted category
% scores and simulated category score matrices. The user can
% specify the types of samples to use from 'all', 'correct', 'incorrect'

%% Initialization
workDir = pwd;
dataFolder = fullfile(workDir,'data');
resultFolder = fullfile(workDir,'results');
RoiNames = {'V1', 'V2', 'V3', 'V4', 'LOC', 'FFA', 'PPA', 'VC', 'MTG'};

if ~exist('AnalysisType')
    AnalysisType = 'incorrect'; % 'all' (all samples), 'correct' (only correct), 'incorrect' (only incorrect)
end

%% Load simulated and predicted category probability
load(fullfile(resultFolder,'Predicted_Category_Scores.mat'));
load(fullfile(resultFolder,'Simulated_Category_Scores.mat'));

%% Load behavioral data
load(fullfile(dataFolder,'Behavioral_data.mat'));

%% Select data based on analysis type
switch AnalysisType
    case 'all'
        dataselector = true(size(correct));
    case 'correct'
        dataselector = ~~correct;
    case 'incorrect'
        dataselector = ~correct;
    otherwise
        error('Unknown analysis type!');
end

%% Calculate similarities
fprintf('Calculating similarities for the %s condition...\n', AnalysisType);
for subj = 1:length(Subjects)
    fprintf('Subject %s...\n', Subjects{subj});
    for roi = 1:length(RoiNames)
        for layer = 1:8
            datasel = dataselector(subj,:);
            
            X1pred = squeeze(pred_categ_corr(subj,roi,layer,datasel,:));
            X1true = squeeze(true_categ_corr(subj,roi,layer,datasel,:));
            X1orig = squeeze(orig_categ_corr(subj,roi,layer,datasel,:));
                        
            X2behv = squeeze(behmat(subj,layer,datasel,:));
            X2true = squeeze(truemat(layer,datasel,:));
            
            corr_pred_behv(subj, roi, layer) = corr(X1pred(:), X2behv(:));
            corr_pred_true(subj, roi, layer) = corr(X1pred(:), X2true(:));
            
            corr_true_behv(subj, roi, layer) = corr(X1true(:), X2behv(:));
            corr_true_true(subj, roi, layer) = corr(X1true(:), X2true(:));
            
            corr_orig_behv(subj, roi, layer) = corr(X1orig(:), X2behv(:));
            corr_orig_true(subj, roi, layer) = corr(X1orig(:), X2true(:));
        end
        
    end
    
    
end
%% compute the means and confidence intervals for each condition
corr_pred = cat(4,corr_pred_behv,corr_pred_true);
corr_true = cat(4,corr_true_behv,corr_true_true);
corr_orig = cat(4,corr_orig_behv,corr_orig_true);

corr_pred_mean = squeeze(mean(corr_pred,1));
corr_true_mean = squeeze(mean(corr_true,1));
corr_orig_mean = squeeze(mean(corr_orig,1));

corr_pred_ci = squeeze(conf_int(corr_pred,0.05,1));
corr_true_ci = squeeze(conf_int(corr_true,0.05,1));
corr_orig_ci = squeeze(conf_int(corr_orig,0.05,1));
fprintf('Done!\n');


%% Plot results
fprintf('Plotting results...\n');
HH = figure('units','centimeters','outerposition',[1 0 21/2 29.7],'Color',[1,1,1]);

for roi = 1:length(RoiNames)
    subplot(length(RoiNames),1,roi); hold on;
    title(RoiNames{roi});
    
    pltline = squeeze(corr_pred_mean(roi,:,:));
    pltebar = squeeze(corr_pred_ci(roi,:,:));
    errorbar(pltline,pltebar);
        
    ylim([-0.5,1]);
    
    if roi == 1
        legend({'Behavioral', 'True'});
        
    end
    
end
fprintf('Done!\n');