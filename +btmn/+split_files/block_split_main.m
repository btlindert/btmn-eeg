% MAIN - Split raw data files into single block files
close all;
clear all;
clear classes;

import misc.get_hostname;
import somsds.link2rec;
import misc.dir;
import meegpipe.*;
import btmn.*;

%% Splitting parameters

SUBJECTS = 9;

OUTPUT_DIR = '/data2/projects/btmn/analysis/splitting/blocks/';
        
%% Select the relevant data files

files = link2rec('btmn', 'file_ext', '.mff', 'subject', SUBJECTS, ...
    'session', 'morning', 'folder', OUTPUT_DIR);
        
%% Process all files with the splitting pipeline

% Pipeline options
DO_REPORT = true;
USE_OGE   = true;
QUEUE     = 'meegpipe.q';

myPipe = btmn.pipes.block_split_pipeline(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ... %'Parallelize',      true
    'Queue',            QUEUE);

run(myPipe, files{:});
