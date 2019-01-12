% Run analysis runs all the steps after generating the decoded features until plotting
% Make sure that you have run TrainFeatureDecoders and PredictFeatures before

%% Generate simulated category scores
CrossCatScore;
ComputeSimCategScore;

%% Generate decoded category scores
ComputePredCategScore;

%% Compute and plot similarity results
AnalysisType = 'incorrect'; % 'all' (all samples), 'correct' (only correct), 'incorrect' (only incorrect)
ComputeScoreSimilarity;