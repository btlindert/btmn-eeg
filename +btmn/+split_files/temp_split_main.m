% MAIN - Split raw data files into single sub-block files
%

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

OUTPUT_DIR = '/data2/projects/btmn/analysis/splitting/temperature/';
        

% Pipeline options
USE_OGE   = true;
DO_REPORT = true;
QUEUE     = 'long.q@somerenserver.herseninstituut.knaw.nl';


%% Select the relevant data files

files = link2rec('btmn', 'file_ext', '.mff', 'subject', SUBJECTS, ...
    'session', 'morning', 'folder', OUTPUT_DIR);
        

if isempty(files),
    error('Could not find any input data file');
end

%% Process all files with the splitting pipeline

myPipe = btmn.pipes.temp_split_pipeline(...
    'GenerateReport',   true, ...
    'Queue',            QUEUE, ...
    'Parallelize',      true);

run(myPipe, files{:});
