% splitting
%
% Usage:
% batman.setup
% batman.preproc.splitting;
%
% Splitting the large .mff files that contain 14 blocks into 14
% single-block files.

import batman.get_username;
import batman.pending_files;

%% User parameters

SUBJECTS_PVT = 1:100;

OUTPUT_DIR = '/data1/projects/btmn/analysis/splitting';

% Pipeline options
USE_OGE     = true;
DO_REPORT   = true;
QUEUE       = 'long.q@somerenserver.herseninstituut.knaw.nl';


%% Select relevant data files and process them with the corresp. pipeline
files1 = somsds.link2rec('btmn', 'file_ext', '.mff', ...
    'subject', SUBJECTS_ARS, 'folder', OUTPUT_DIR);

files2 = somsds.link2rec('btmn', 'file_ext', '.mff', ...
    'subject', SUBJECTS_RS_PVT, 'folder', OUTPUT_DIR);

files3 = somsds.link2rec('btmn', 'file_ext', '.mff', ...
    'subject', SUBJECTS_PVT, 'folder', OUTPUT_DIR);

% Process only those files that have been splitted yet
% If you want to re-split an already splitted file then you will have to
% manually delete the corresponding .meegpipe dir in the output directory

myPipe1 = batman.pipes.split_rs_ars(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);

if ~isempty(files1)
    run(myPipe1, files1{:});
end

myPipe2 = batman.pipes.split_rs_pvt(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);

if ~isempty(files2)
    run(myPipe2, files2{:});
end

myPipe3 = batman.pipes.split_pvt(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);

if ~isempty(files3),
    run(myPipe3, files3{:});
end