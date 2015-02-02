% MAIN - Split raw data files into single sub-block files
close all;
clear all;
clear classes;

import misc.get_hostname;
import somsds.link2rec;
import misc.dir;
import meegpipe.*;
import btmn.*;

%% Splitting parameters

SUBJECTS   = 1:2;
SESSION    = 'morning'; %'afternoon'       
OUTPUT_DIR = '/data2/projects/btmn/analysis/eeg/splitting/sub-blocks/';      

%% Select the relevant data files

files = link2rec('btmn', ... 
    'file_ext', '.mff', ...
    'subject', SUBJECTS, ...
    'session', SESSION, ... 
    'folder', OUTPUT_DIR);
        
if isempty(files),
    error('Could not find any input data file');
end

%% Process all files with the splitting pipeline

% Pipeline options
DO_REPORT = true;
USE_OGE   = true;
QUEUE     = 'short.q@somnode4';

myPipe = btmn.pipes.sub_block_split_pipeline(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);

run(myPipe, files{:});
