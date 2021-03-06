function myPipe = pvt_analysis(varargin)
% PVT_ANALYSIS - PVT feature extraction pipeline

import meegpipe.node.*;
import misc.process_arguments;
import misc.split_arguments;

nodeList = {};

% Node: Merge data files from stage2
myImporter = physioset.import.physioset;
thisNode   = physioset_import.new('Importer', myImporter);
nodeList   = [nodeList {thisNode}];

% Node: Extract event features
evSelector = batman.pvt.event_selector; 
featList   = {'Time', 'Sample', 'cel', 'obs', 'rsp', 'rtim', 'trl'};
thisNode = ev_features.new(...
    'EventSelector',    evSelector, ...
    'Features',         featList);
nodeList = [nodeList {thisNode}];

% The actual pipeline
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             false,  ...
    'Name',             'batman-pvt', ...
    varargin{:});


end