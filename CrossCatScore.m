% CrossCatProb computes the cross-category probability from the preferred
% image features for each DNN layer

%% Initialization
BDTB_path = ''; %should add the path to brain decoder toolbox 2 here
workDir = pwd;
dataFolder = fullfile(workDir,'data');

load(fullfile(dataFolder,'Preferred_Img_Features.mat'));
load(fullfile(dataFolder,'Feature_Normalization.mat'));

layercount = 8;
categcount = length(categories);
plot = false;

bincase = combvec(1:categcount,1:categcount)'; %all category combinations

%% compute the cross-category scores
fprintf('Calculating cross-category scores\n');
corrmap = zeros(layercount,categcount,categcount);
for layer = 1:8
    for ctpr = 1:size(bincase,1)
        % extract feature vector for the category pair
        x1 = squeeze(catfeat(bincase(ctpr,1),layer,:));
        x2 = squeeze(catfeat(bincase(ctpr,2),layer,:));
        
        % normalize feature vectors
        x1 = x1' - mu4lab(layer,:);
        x1 = x1 ./ sigma4lab(layer,:);
        x2 = x2' - mu4lab(layer,:);
        x2 = x2 ./ sigma4lab(layer,:);
        
        %compute correlation
        corrmap(layer, bincase(ctpr,1), bincase(ctpr,2)) = corr(x1',x2');
    end
    
    % apply softmax normalization to get probability
    for categ = 1:size(corrmap,3)
        corrmap(layer, categ, :) = softmax(squeeze(corrmap(layer, categ, :)));
    end
        
        
end

%% Plot if needed
if plot
    fprintf('Plotting...\n');
    HH = figure('units','centimeters','outerposition',[1 0 21 29.7],'Color',[1,1,1]);
    for layer = 1:8
        subplot(4,2,layer);
        imagesc(squeeze(corrmap(layer,:,:)));
        axis off
        colorbar;
    end
end

%% Save resulting matrix
fprintf('Saving...\n');
save(fullfile(dataFolder,'Cross_category_scores.mat'), 'corrmap');
fprintf('Done!\n');