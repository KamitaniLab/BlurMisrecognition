# Blur Image Sharpening

This repository contains the demo code to reproduce the results in our manuscript: "[Conflicting Bottom-up and Top-down Signals during Misrecognition of Visual Objects]()". 
We demonstrate in this paper that during misrecognition, lower visual areas mimic representation of the actual stimulus category while deeper semantic areas mimic representation of the behavioral response. For more details, please refer to the manuscript.

## Data

To apply the algorithm on our data to be able to reproduce the results reported in the manuscript, you should [download]() the data (from a separate repository) and load it to the data subfolder.
Data includes fMRI data for five subjects (decoder training and blurred test images) and visual features of DNN layers from 1 to 8 (extracted via [Matconvnet](http://www.vlfeat.org/matconvnet/)).
Also behavioral response data from the five subjects and image representative category vectors. Data is available to download from [FigShare]().

Data files:

- [Behavioral_data.mat]()
- [Preferred_Img_Features.mat]()
- [Feature_Normalization.mat]()
- [Training_S1.mat]()
- [Training_S2.mat]()
- [Training_S3.mat]()
- [Training_S4.mat]()
- [Training_S5.mat]()
- [Test_S1.mat]()
- [Test_S2.mat]()
- [Test_S3.mat]()
- [Test_S4.mat]()
- [Test_S5.mat]()


### Prerequisites

This code uses functions from [BrainDecoderToolbox2](https://github.com/KamitaniLab/BrainDecoderToolbox2/) format. The path should be inserted into the codes.

This code was created and tested using MATLAB R2016a
Required MATLAB toolboxes:
* Neural Network Toolbox (v9.0)
* Statistics and Machine Learning Toolbox (v10.2)

## Usage

The folder organization should be as follows

```
   ./ --+-- TrainFeatureDecoders.m (Train the feature decoders)
        |
        +-- PredictFeatures.m (Use the trained feature decoders to predict features from test fMRI data)
        |
        +-- Run_Analysis.m (Runs the analysis after feature prediction)
        |
        +-- ComputePredCategScore.m (Calculates the decoded cateogry score matrices for all subjects)
        |
        +-- ComputeSimCategScore.m (Calculates the behavioral and true cateogry score matrices for all subjects)
        |
        +-- CrossCatScore.m (Support function for ComputeSimCategScore.m)
        |
        +-- ComputeScoreSimilarity.m  (Computes category score similarities and plots them)
        |
        data/ --+-- Training_S1.mat (Training fMRI data and DNN features, subject 1)
        |       |
        |       +-- Test_S1.mat (Test fMRI data and DNN features, subject 1)
        |       |
        |       +-- Training_S2.mat (Training fMRI data and DNN features, subject 2)
        |       |
        |       +-- Test_S2.mat (Test fMRI data and DNN features, subject 2)
        |       |
        |       +-- Training_S3.mat (Training fMRI data and DNN features, subject 3)
        |       |
        |       +-- Test_S3.mat (Test fMRI data and DNN features, subject 3)
        |       |
        |       +-- Training_S4.mat (Training fMRI data and DNN features, subject 4)
        |       |
        |       +-- Test_S4.mat (Test fMRI data and DNN features, subject 4)
        |       |
        |       +-- Training_S5.mat (Training fMRI data and DNN features, subject 5)
        |       |
        |       +-- Test_S5.mat (Test fMRI data and DNN features, subject 5)
        |       |
        |       +-- Behavioral_data.mat (Behavioral response results, all subjects)
        |       |
        |       +-- Preferred_Img_Features.mat (Category representative DNN feature vectors)
        |       |
        |       +-- Feature_Normalization.mat (DNN feature mean and standard deviation, used in the decoder training)
        |
        lib/ (contains all the support functions needed)
        |
        models/ (to store the DNN feature models)
        |
        results/ (to store all resulting matrices)
        |
        tmp/ (Support folder to support parallelization of decoder training)
```

You can start by first training the decoders running *TrainFeatureDecoders*.

The function *TrainFeatureDecoders* takes a very long time and could instead be run in parallel for faster computations. It has the functionality to skip jobs that are already running on another cluster.
Trained decoder will be saved in **models** directory with the name *{SubjectID}_{ROI}.mat*. You need to specify the BDTB path in this code.

Then when all decoders are trained (total 45), you can run the *PredictFeatures* script
Predicted features, will be saved in **results** folder with the name *Predicted_Features.mat*. You need to specify the BDTB path in this code.

Then, you can run the analysis script *Run_Analysis.m* that automatically runs all other codes. Inside that code, you can select the kind of data to use from (all, correct, incorrect). The manuscript mainly focuses on the incorrect data.
This code will plot the values of similarity between decoded category score matrix and behavioral and true cateogry score matrices.
