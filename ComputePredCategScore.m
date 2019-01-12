% ComputePredCategScore uses the decoded features to compute the category
% scores using template matching using preferred image templates

%% Initialization
workDir = pwd;
dataFolder = fullfile(workDir,'data');
resultFolder = fullfile(workDir,'results');

load(fullfile(resultFolder,'Predicted_features.mat'));

load(fullfile(dataFolder,'Preferred_Img_Features.mat'));
load(fullfile(dataFolder,'Feature_Normalization.mat'));
load(fullfile(dataFolder,'Behavioral_data.mat'));


modtxt = {'0%','6%', '12%','25%'};


%% extract only original image true features
tfeat = true_feat;
m = m(1, :); % extract modification level (same for all subjects)
ofeat = tfeat(:, :, m == 1);
ofeat = repelem(ofeat, 1, 1, length(modtxt));

%% Compute category scores for predicted, true, original true

for subj = 1:length(Subjects)
    fprintf('Computing category scores for %s...\n', Subjects{subj});
    for roi = 1:length(RoiNames)
       
       pfeat = pred_feat{subj,roi};
       
       for layer = 1:size(pfeat,1)
           for img = 1:size(pfeat,3)
               xp1 = squeeze(pfeat(layer,:,img)); % predicted features
               xt1 = squeeze(tfeat(layer,:,img)); % true features
               xo1 = squeeze(ofeat(layer,:,img)); % original true features
               
               xp1 = reshape(xp1, length(xp1), 1);
               xt1 = reshape(xt1, length(xt1), 1);
               xo1 = reshape(xo1, length(xo1), 1);
               
               for categ = 1:length(categories)
                   xc = squeeze(catfeat(categ,layer,:)); % preferred image features
                   xc = xc' - mu4lab(layer,:);
                   xc = xc ./ sigma4lab(layer,:);
                   xc = reshape(xc, length(xc), 1);
                   
                   % compute category scores
                   pred_categ_corr(subj, roi, layer, img, categ) = corr(xp1, xc);
                   true_categ_corr(subj, roi, layer, img, categ) = corr(xt1, xc);
                   orig_categ_corr(subj, roi, layer, img, categ) = corr(xo1, xc);
                   
               end
               
               % compute softmax to get probabilities
               pred_categ_corr(subj, roi, layer, img, :) = ...
                   softmax(squeeze(pred_categ_corr(subj, roi, layer, img, :)));
               true_categ_corr(subj, roi, layer, img, :) = ...
                   softmax(squeeze(true_categ_corr(subj, roi, layer, img, :)));
               orig_categ_corr(subj, roi, layer, img, :) = ...
                   softmax(squeeze(orig_categ_corr(subj, roi, layer, img, :)));


           end
       end
       
    end
    
end

fprintf('Saving...\n');
save(fullfile(resultFolder,'Predicted_Category_Scores.mat'), 'pred_categ_corr', 'true_categ_corr', 'orig_categ_corr');
fprintf('Done!\n');

