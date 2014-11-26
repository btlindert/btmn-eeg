function myPipe = temp_split_pipeline(varargin)
% SPLIT_FILES - Split raw data files into single sub-block files
%
% See also: btmn.pipes

import meegpipe.node.*;
import btmn.split_files.*;

% Default options
USE_OGE   = true;
DO_REPORT = true;
QUEUE     = 'long.q@somerenserver.herseninstituut.knaw.nl';


nodeList = {};

%% NODE: import from .mff file

myImporter = physioset.import.mff('Precision', 'single');
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];


%% Extract 30min blocks

% Specify the event selector
mySel    = physioset.event.class_selector('Type', 'nbk+');
offset   = -930;
duration = 1800;

% Block naming policy
splitNaming = @(physObj, ev, evIdx) ...
    btmn.split_files.block_naming_policy(physObj, ev, evIdx, 'block');

% In this stage we are not interested in the EEG data, so it is a good idea 
% to select only non-EEG data when generating the splits so that we have as 
% small data splits as possible. Notice the ~ symbol, which means: select 
% everything except EEG data. The  ~ symbol "negates" a data selector so that 
% it selects the complementary set to the data set that it would normally 
% select. You can check whether a data selector has been negated by 
% inspecting the value of its Negated property.
myDataSel = ~pset.selector.sensor_class('Class', 'EEG');

thisNode = split.new(...
    'DataSelector',      myDataSel, ...
    'EventSelector',     mySel, ...
    'Offset',            offset, ...
    'Duration',          duration, ...
    'SplitNamingPolicy', splitNaming, ...
    'Name',              'block');

nodeList = [nodeList {thisNode}]; %#ok<AGROW>

%% The actual pipeline

myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'temp_split', ...
    'Queue',            QUEUE);


end