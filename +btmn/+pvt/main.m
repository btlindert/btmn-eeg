% MAIN - PVT feature extraction

%% Import meegpipe stuff

import somsds.link2files;
import misc.regexpi_dir;
import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import mperl.join;
import batman.*;

%% Analysis parameters

INPUT_DIR = '/data1/projects/batman/analysis/splitting';

OUTPUT_DIR = ['/data1/projects/batman/analysis/pvt_' ...
    datestr(now, 'yymmdd-HHMMSS')];

%% Select the relevant files and start the data processing jobs.

regex = '_pvt_\d+\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex, false);

link2files(files, OUTPUT_DIR);
regex = '_pvt_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);


%% Process all files with the pvt pipeline.

% Pipeline options.
DO_REPORT = true;
USE_OGE   = true;
QUEUE     = 'meegpipe.q';


myPipe = batman.pipes.pvt_analysis(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);

if ~isempty(files),
    run(myPipe, files{:});
end