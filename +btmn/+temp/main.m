% MAIN - Obtain temp values in correlative 1-min windows

import misc.get_hostname;
import misc.dir;
import somsds.link2files;
import misc.regexpi_dir;
import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% User-defined parameters
INPUT_DIR  = '/someren/projects/btmn/analysis/eeg/splitting/blocks/';
OUTPUT_DIR = ['/someren/projects/btmn/analysis/eeg/temperature/temperature_', ...
    datestr(now, 'yymmdd-HHMMSS')];
SESSION    = 'afternoon'; %'morning'

%% Select the relevant files and start the data processing jobs
regex = ['_' SESSION '_block_\d\.pseth?$']; %'morning'
files = finddepth_regex_match(INPUT_DIR, regex, false);

link2files(files, OUTPUT_DIR);
regex = '_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

%% Process all files with the temp feature extraction pipeline

% Pipeline options
DO_REPORT   = true;
USE_OGE     = true;
QUEUE       = 'meegpipe.q';

myPipe = btmn.pipes.temp_in_epochs_pipeline(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);

run(myPipe, files{:}); % test on only two files first!
