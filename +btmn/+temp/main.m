% MAIN - Obtain temp values in correlative 1-min windows
%

import misc.get_hostname;
import misc.dir;
import somsds.link2files;
import misc.regexpi_dir;
import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% User-defined parameters

INPUT_DIR = '/data2/projects/btmn/analysis/splitting/temp/';
OUTPUT_DIR = ['/data2/projects/btmn/analysis/temperature/temp_' ...
    datestr(now, 'yymmdd-HHMMSS')];

%% Select the relevant files and start the data processing jobs
regex = '_afternoon_block_\d\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex, false);

link2files(files, OUTPUT_DIR);
regex = '_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

%% Process all files with the temp feature extraction pipeline

% Pipeline options
DO_REPORT   = true;
USE_OGE     = true;
QUEUE       = 'meegpipe.q@somerenserver.herseninstituut.knaw.nl';

myPipe = btmn.pipes.split_pipeline(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);

run(myPipe, files{:});
