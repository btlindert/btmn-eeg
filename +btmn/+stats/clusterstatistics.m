% start with a clean state
close all;
clear all;
clear classes;
clc;

% add meegpipe, fieldtrip, eeglab
addpath(genpath('/data1/toolbox/meegpipe_v0.1.6'));

% initialize pipeline 
meegpipe.initialize

% import utilities
import meegpipe.aggregate;
import mperl.file.find.finddepth_regex_match;
import batman.*;
import mperl.join;
import mperl.file.spec.catfile;

addpath(genpath('/data1/toolbox/fieldtrip'));
% import meegpipe.node.*;
% import somsds.link2files;
% import misc.get_hostname;
% import misc.regexpi_dir;
% import mperl.file.spec.catdir;
% import mperl.file.find.finddepth_regex_match;


% the input directory where the split, cleaned files are located
INPUT_DIR = '/data1/projects/batman/analysis/spectral_analysis';

INPUT_DIR = misc.find_latest_dir(INPUT_DIR);

% the output directory, where we want to store Fieldtrip output
OUTPUT_DIR = 'data1/projects/batman/topoplots/scripts_bart/results';

% get first obtain all files for 
SUBJECTS = [1:4, 6:7, 9:10];

% List of blocks to be aggregated
BLOCKS = [6:9, 11:14];

CONDITIONS = [1,2,4,3,0,5,6,12,7,0,11,8,10,9;...    
              2,3,1,4,0,6,7,5,8,0,12,9,11,10;...
              3,4,2,1,0,7,8,6,9,0,5,10,12,11;...
              4,1,3,2,0,8,9,7,10,0,6,11,5,12;...
              0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
              2,3,1,4,0,10,11,9,12,0,8,5,7,6;...
              3,4,2,1,0,11,12,10,5,0,9,6,8,7;...
              0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
              1,2,4,3,0,9,10,8,11,0,7,12,6,5;...
              4,1,3,2,0,12,5,11,6,0,10,7,9,8];

%% List of subjects/blocks to be aggregated
regex = ['0+(' join('|', SUBJECTS) ').+rs_(' join('|', BLOCKS) ').pseth$'];
DIR = '/data1/projects/batman/analysis/cleaning';
DIR = misc.find_latest_dir(DIR);
files = finddepth_regex_match(DIR, regex);

%% create layout
% load any pset file
tmpData = import(physioset.import.physioset, files{1});
select(pset.selector.sensor_class('Class', 'eeg'), tmpData);
tmpData = fieldtrip(tmpData, 'BadData', 'donothing');

cfg          = [];
cfg.method   = 'distance';
cfg.feedback = 'no';
neighbours   = ft_prepare_neighbours(cfg, tmpData);

cfg          = [];
layout       = ft_prepare_layout(cfg, tmpData);

% merge files into seperate blocks for every condition
%% start with postural manipulation, 
% the supine condition (post = 0) consisted of the following conditions:
% 5,6,9,10
% the upright condition (post = 1) consisted of the following conditions:
% 7,8,11,12

% create empty matrix 
data0 = NaN(1,257);
data1 = NaN(1,257);

data0_avg = NaN(numel(SUBJECTS),257);
data1_avg = NaN(numel(SUBJECTS),257);


for i = 1:numel(SUBJECTS)
    % create vars for iteration of rows to average data across conditions
    a = 1;
    b = 1;
    
    % select subject
    subject = SUBJECTS(i);
    disp(['processing files for subject ' num2str(subject)]);

    for j = 1:numel(BLOCKS)
        disp(['processing block ' num2str(j)]);        
        
        % get the condition from the conditions file
        block   = BLOCKS(j);
        cond    = CONDITIONS(subject, block);

        % find subject+block file
        regex   = ['(' join('|', subject) ')_.+rs_(' join('|', block) ').+alpha.txt$'];
        file    = finddepth_regex_match(INPUT_DIR, regex, false);
        
        % make sure to exclude missing data
        if ~isempty(file)
            % load the txt file, these are power values for each channel
            % chan_
            dat = dlmread(file{1}, ',', 1); 
                                  
            % assign to A or B depending on cond 
            if cond == 5 || cond == 6 || cond == 9 || cond == 10
               % assign to A
               data0(a,:) = dat;
               % ft_freqanalysis output 
               a = a + 1;
            elseif cond == 7 || cond == 8 || cond == 11 || cond == 12
               % assign to B
               data1(b,:) = dat;
               b = b + 1;
            end
        end
    end
    
    % calculate grand average per subject
    data0_avg(i,:) = mean(data0,1);
    data1_avg(i,:) = mean(data1,1);

end


% do clusterbased statitsics using ft_freqstatistics
% input should be subject averaged data for permutation to work
% once all the subject averages have been added to the data we can run
% stats on a paired comparison
% create design
freq0            = tmpData;
freq0.trial      = [];
freq0.time       = [];
freq0.sampleinfo = [];
freq0.powspctrm  = [];
freq0.freq       = 8;
freq0.dimord     = 'subj_chan';

freq1            = freq0;

% copy subj_chan data into fieldtrip struct
freq0.powspctrm = data0_avg;
freq1.powspctrm = data1_avg;


cfg                     = [];
%cfg.channel             = 'EEG';
%cfg.frequency           = [8 13]; %can this be range?
%cfg.avgoverfreq         = 'yes';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'maxsum'; % check
cfg.minnbchan           = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 100;
cfg.neighbours          = neighbours;

cfg.design = [ones(1,8) ones(1,8)*2; 1:8 1:8];
cfg.ivar = 1;
cfg.uvar = 2;

stat = ft_freqstatistics(cfg, freq0, freq1); %format? freqstatistics??

cfg = [];
cfg.alpha = 0.05;
cfg.parameter = 'stat';
cfg.zlim = [-4 4];
cfg.layout = layout;
ft_clusterplot(cfg, stat);

% plot the data 
% first we average across all the subjects with ft_freqdescriptives
cfg = [];
Post0avg = ft_freqdescriptives(cfg, freq0);
Post1avg = ft_freqdescriptives(cfg, freq1);

% add raw effect to stat and plot
stat.raweffect = Post0avg-Post1avg;
cfg             = [];
cfg.alpha       = 0.025; 
% play with threshold to get more or less clusters to plot, or run through all the 
% significant +ve and -ve cluster to find the max p value to be set.
cfg.parameter   = 'raweffect';
cfg.zlim        = [-1e27 1e27];
cfg.layout      = layout; % here, import the fieldtrip layout of the 256 channel EGI net
ft_clusterplot(cfg, stat);

cfg = [];
cfg.layout = layout;
figure 
ft_multiplotTFR(cfg, dataPost0)
ft_topoplotER(cfg, freq1);

% todo, time each of the steps to evaluate performance, if fast, merge for 
% delta, theta, alpha and beta; 
% delta, average over freq_time -> [1 4]_time
% theta, average over freq_time -> [4 8]_time
% alpha, average over freq_time -> [8 13]_time
% beta, average over freq_time  -> [13 30]_time

% do source rconstruction for significant sources

% do connectivity analysis on a priori seed
            
   