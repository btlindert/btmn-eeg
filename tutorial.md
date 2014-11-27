Extracting features from physiological time-series
===

This tutorial illustrates a real data processing use-case that was performed
within the [BATMAN project][batman-proj]. Below I assume that you are
following this tutorial at the _somerengrid_, i.e. at one of the nodes of the
private computing grid of the [Sleep&Cognition][sc] team of the
[Netherlands Institute for Neuroscience][nin]. In particular, the raw data files
that are used in this tutorial are not yet publicly available.

[batman-proj]: http://www.neurosipe.nl/project.php?id=23&sess=6eccc41939665cfccccd8c94d8e0216f
[sc]: http://www.nin.knaw.nl/research_groups/van_someren_group
[nin]: http://www.nin.knaw.nl/


## Objectives/Roadmap

1. [Retrieve the relevant raw data files][getting_raw]. This step is only
   relevant for those of you that are following this tutorial at _somerengrid_.

2. [Split the large (10-25 Gb) files][splitting] that were obtained for
   each subject into smaller, more manageable, files. Note that this step is not
   really required as _meegpipe_ is able to handle such large files directly.
   But, especially when you are building a new workflow, dealing with smaller
   files can speed up the processing considerably and thus facilitate the
   early detection of errors and inconsistencies.

3. [Extract features from the Arterial Blood Pressure (ABP) time-series][abp-feat]
   We want to get such features for each experimental block and for each
   sub-block (`Baseline`, `PVT`, `RS`, and `RSQ`).

4. [Extract heart-rate variability (HRV) features][hrv-feat] from the [ECG][ecg]
   data, for each block and sub-block.

5. Getting [PVT response time statistics][pvt-feat] from the PVT response
   events, for each experimental block and sub-block.
   
[getting_raw]: ./getting_raw_data.md
[splitting]: ./splitting_raw_data.md
[abp-feat]: ./abp_feat.md
[hrv-feat]: ./hrv_feat.md
[pvt-feat]: ./pvt_feat.md
[ecg]: http://en.wikipedia.org/wiki/Electrocardiography


## Final outcome

The tutorial will guide you step-by-step through the MATLAB code that you would
need to write to accomplish the objectives above. The final complete set of
scripts is also part of this project. Follow the instructions below to run the whole tutorial
without going through the step-by-step explanations.

[meegpipe]: http://meegpipe.github.io/meegpipe

To ensure that the tutorial files will work as expected it is highly recommended
(but not required) that you restore your default MATLAB path:

````matlab
restoredefaultpath
````

Then you should add EEGLAB and _meegpipe_ to the MATLAB path, and initialize
_meegpipe_:

````matlab
% If you are not working at somerengrid, edit the paths below accordingly
addpath(genpath('/data1/toolbox/eeglab'));
addpath(genpath('/data1/toolbox/meegpipe'));

meegpipe.initialize;
````

To retrieve and split all raw data files into smaller files simply run:

````matlab
% You will have to edit a few things in btmn.split_files if you are not
% running this at the somerengrid, namely everything that has to do with
% retrieving the raw data files
btmn.split_files
````
Wait until all files have been split and then, to reproduce all other tutorial
steps run:

````matlab
% You will have to edit a few paths and OS-related stuff in these scripts if you
% are not running this at somerengrid
btmn.extract_abp_features
btmn.extract_hrv_features
btmn.extract_pvt_features
````