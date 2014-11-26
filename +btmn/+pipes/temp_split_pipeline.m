function myPipe = temp_split_files(varargin)
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

mySel    = physioset.event.class_selector('Type', 'nbk+');
offset   = -930;
duration = 1800;

thisNode = meegpipe.node.split.new(...
    'EventSelector',        mySel, ...
    'Offset',               offset, ...
    'Duration',             duration, ...
    'Name',                 'block');

nodeList = [nodeList {thisNode}]; %#ok<AGROW>

%% The actual pipeline

myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'split_files', ...
    'Queue',            QUEUE);


end