function myPipe = split_pipeline(varargin)
% SPLIT_FILES - Split raw data files into single sub-block files
%
% See also: btmn.pipes

import meegpipe.node.*;
import batman.split_files.*;

% Default options
USE_OGE    = true;
DO_REPORT  = true;
QUEUE      = 'long.q@somerenserver.herseninstituut.knaw.nl';


nodeList = {};

%% NODE: import from .mff file

myImporter = physioset.import.mff('Precision', 'single');
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];


%% NODES: Extract baseline, nback, pvt, saccade, subj, rs-eo, and rs-ec sub-blocks

sbTypes = keys(sub_block_duration);

for sbTypeItr = 1:numel(sbTypes)

    thisSbType = sbTypes{sbTypeItr};
    mySel      = sub_block_event(thisSbType);
    offset     = sub_block_offset(thisSbType);
    duration   = sub_block_duration(thisSbType);
    
    namingPolicy = @(physO, ev, evIdx) ...
        btmn.block_naming_policy(physO, ev, evIdx, thisSbType);

    thisNode = meegpipe.node.split.new(...
        'EventSelector',        mySel, ...
        'SplitNamingPolicy',    namingPolicy, ...
        'Offset',               offset, ...
        'Duration',             duration, ...
        'Name',                 thisSbType);

    nodeList = [nodeList {thisNode}]; %#ok<AGROW>
end

%% The actual pipeline

myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'split', ...
    'Queue',            QUEUE);

end