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

SUBJECTS   = [3:4, 6, 8:9, 11:16, 19:20, 22:28, 30:33, 35:38, 41:43]; %1:2
SESSION    = 'afternoon'; %'morning'
OUTPUT_DIR = '/data2/projects/btmn/analysis/eeg/splitting/blocks/';
        
%% Select the relevant data files

files = link2rec('btmn',... 
    'file_ext', '.mff',... 
    'subject',  SUBJECTS, ...
    'session',  SESSION, ... 
    'folder',   OUTPUT_DIR);
  
if isempty(files),
    error('Could not find any input data file');
end

%% Process all files with the splitting pipeline

% Pipeline options
DO_REPORT = true;
USE_OGE   = true;
QUEUE     = 'meegpipe.q';

myPipe = btmn.pipes.block_split_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'OGE',            USE_OGE, ...
    'Queue',          QUEUE);

run(myPipe, files{:});