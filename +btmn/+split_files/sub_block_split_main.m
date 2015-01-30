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

SUBJECTS = 9;
       
OUTPUT_DIR = '/data2/projects/btmn/analysis/splitting/sub-blocks/';      

%% Select the relevant data files

files = link2rec('btmn', 'file_ext', '.mff', 'subject', SUBJECTS, ...
    'session', 'morning', 'folder', OUTPUT_DIR);
        
if isempty(files),
    error('Could not find any input data file');
end

%% Process all files with the splitting pipeline

% Pipeline options
DO_REPORT = true;
USE_OGE   = true;
QUEUE     = 'meegpipe.q@somerenserver.herseninstituut.knaw.nl';

myPipe = btmn.pipes.sub_block_split_pipeline(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);

run(myPipe, files{:});
