function myPipe = split_files(varargin)
% SPLIT_FILES - Split raw data files into single sub-block files
%
% See also: batman.pipes

import meegpipe.node.*;
import batman.split_files.*;

% Default options
USE_OGE     = true;
DO_REPORT   = true;
QUEUE       = 'long.q@somerenserver.herseninstituut.knaw.nl';


nodeList = {};

%% NODE: import from .mff file

myImporter = physioset.import.mff('Precision', 'single');
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];



%% Extract baseline, pvt, saccade, subj, rs-eo, and rs-ec sub-blocks

% 1401028 - THIS STAGE SHOULD BE EXPANDED FOR THE NBACK, PVT, SACCADE,
% SUBJECTIVE QUESTIONS, EYES-OPEN RESTING STATE, EYES-CLOSED RESTING STATE
% Instead of using a single event to get all files, use individual events
% for every period:

% nback -> check!
% pvt   -> pvt+
% sac   -> sac+
% eo    -> eo




% This will select the first PVT event during the PVT sub-block

% 141105 - MODIFY TO INCLUDE EVENTS OFR EACH SUB-BLOCK

eventSelectors    = {'batman.preproc.baseline_selector',...
    'batman.preproc.nback_selector',...
    'batman.preproc.pvt_selector',...
    'batman.preproc.subj_selector',...
    'batman.preproc.rs-eo_selector',...
    'batman.preproc.rs-ec_selector'};

sbTypes = keys(sub_block_duration);


for sbTypeItr = 1:numel(sbTypes)

    mySel      = eventSelectors{sbTypes};
    thisSbType = sbTypes{sbTypeItr};
    naming   = @(d, ev, idx) block_naming_policy(d, ev, idx, thisSbType);
    offset   = sub_block_offset(thisSbType);
    duration = sub_block_duration(thisSbType);

    thisNode = meegpipe.node.split.new(...
        'EventSelector',        mySel, ...
        'Offset',               offset, ...
        'Duration',             duration, ...
        'SplitNamingPolicy',    naming, ...
        'Name',                 thisSbType);

    nodeList = [nodeList {thisNode}]; %#ok<AGROW>
end

%% The actual pipeline

myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'split_files', ...
    'Queue',            QUEUE);

end