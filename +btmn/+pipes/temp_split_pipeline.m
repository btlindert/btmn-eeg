function myPipe = temp_split_pipeline(varargin)
% SPLIT_FILES - Split raw data files into single sub-block files
%
% See also: btmn.pipes

import meegpipe.*;
import physioset.*;
%import btmn.split_files.*;

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

% Remove the EEG data, keep physiology + events.
myDataSel = ~pset.selector.sensor_class('Class', 'EEG');

myNode = meegpipe.node.split.new(...
    'DataSelector',         myDataSel, ...
    'EventSelector',        mySel, ...
    'Offset',               offset, ...
    'Duration',             duration, ...
    'SplitNamingPolicy',    splitNaming, ...
    'Name',                 'block');

nodeList = [nodeList {myNode}]; %#ok<AGROW>

%% The actual pipeline

myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'Name',             'temp_split', ...
    varargin{:});


end