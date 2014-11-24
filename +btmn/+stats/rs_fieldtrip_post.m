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
INPUT_DIR = '/data1/projects/batman/analysis/cleaning';
INPUT_DIR = misc.find_latest_dir(INPUT_DIR);

% the output directory, where we want to store Fieldtrip output
OUTPUT_DIR = '/data1/projects/batman/scripts_bart';

% obtain all files for the follwing subjects
SUBJECTS = [1:4, 6:7, 9:10];

% List of blocks to be aggregated
BLOCKS = [6:9, 11:14];

% this is a subject-by-block matrix
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

% this is a condition-by-{light,posture,temperature} matrix
MANIPULATIONS = [1,1,2;...
                 1,0,2;...
                 0,1,2;...
                 0,0,2;...
                 1,1,0;...
                 1,1,1;...
                 1,0,0;...
                 1,0,1;...
                 0,1,0;...
                 0,1,1;...
                 0,0,0;...
                 0,0,1];

% cell identifying the columns of MAMNIPULATIONS
EFFECT        = {'L', 'P', 'T'};


%% List of subjects/blocks to be aggregated
regex = ['0+(' join('|', SUBJECTS) ').+rs_(' join('|', BLOCKS) ').pseth$'];
files = finddepth_regex_match(INPUT_DIR, regex);

%% create layout
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

% create template data struct by loading one file
dataPost0           = tmpData;
dataPost0.time{1}   = (1:size(dataPost0.trial{1},2) - 1)/1000;
dataPost0.time{1}   = [0 dataPost0.time{1}];
dataPost0.trial{1}  = [];

dataPost1           = dataPost0;

for i = 1:numel(SUBJECTS)
    % create iteration var
    a = 1;
    b = 1;
    
    % select subject
    subject = SUBJECTS(i);
    disp(['processing files for subject ' num2str(subject)]);

    for j = 1:numel(BLOCKS)
        disp(['processing block ' num2str(j)]);        
        
        % get the condition from the conditions file
        block = BLOCKS(j);
        cond = CONDITIONS(subject, block);

        % find file
        regex = ['0+(' join('|', subject) ')_.+rs_(' join('|', block) ').pseth$'];
        file = finddepth_regex_match(INPUT_DIR, regex, false);
        
        % make sure to exclude missing data
        if ~isempty(file)
            % load the pset file
            data = pset.load(file{1});
            
            % chan_time data
            dataFt = fieldtrip(data);
               
            % reduce to last 1 minute
            dataFt.trial{1}     = dataFt.trial{1}(:,240001:end);
            dataFt.time{1}      = (1:size(dataFt.trial{1},2)-1)./1000;
            dataFt.time{1}      = [0 dataFt.time{1}];
            dataFt.sampleinfo   = [0, size(dataFt.trial{1},2)];
            
            
            cfg             = [];
            cfg.method      = 'mtmfft';
            cfg.output      = 'pow';
            cfg.taper       = 'hanning';
            cfg.foilim      = [8 13];

            % run through all EFFECTS
            for k = 1:numel(EFFECT)
                % first find rows corresponding to EFFECT level 1
                % use only the afternoon protocol (rows 5:12)
                rows1 = find(MANIPULATIONS(5:12,k))';
                
                % then the other rows must be zero
                rows0 = setdiff(1:8, rows1);
                
            end
                
                
            
            % assign to A or B depending on cond 
            if cond == 5 || cond == 6 || cond == 9 || cond == 10
               % assign to A
               data0{a} = ft_freqanalysis(cfg, dataFt);
               data0{a}.powspctrm = log10(data0{a}.powspctrm+1);
               
               % ft_freqanalysis output 
               a = a + 1;
            elseif cond == 7 || cond == 8 || cond == 11 || cond == 12
               % assign to B
               data1{b} = ft_freqanalysis(cfg, dataFt);
               data1{b}.powspctrm = log10(data1{b}.powspctrm+1);
               b = b + 1;
            end
            
            clear dataFt
        end
    end

    cfg = [];
    
    % calculate grand average per subject
    if numel(data0) == 4
        freqPost0avg{i} = ft_freqgrandaverage(cfg, data0{1}, data0{2}, data0{3}, data0{4});
    elseif numel(data0) == 3
        freqPost0avg{i} = ft_freqgrandaverage(cfg, data0{1}, data0{2}, data0{3});    
    end
    
    if numel(data1) == 4
        freqPost1avg{i} = ft_freqgrandaverage(cfg, data1{1}, data1{2}, data1{3}, data1{4});
    elseif numel(data1) == 3
        freqPost1avg{i} = ft_freqgrandaverage(cfg, data1{1}, data1{2}, data1{3});
    end

end


% do clusterbased statitsics using ft_freqstatistics
% input should be subject averaged data for permutation to work
% once all the subject averages have been added to the data we can run
% stats on a paired comparison
% create design
freq0           = freqPost0avg{1};
freq0.powspctrm = [];
freq0.dimord    = 'subj_chan_freq';

freq1           = freq0;

for i = 1:numel(SUBJECTS)
    % prepare fieldtrip struct for ft_freqstatistics 
    freq0.powspctrm(i,:,:) = freqPost0avg{i}.powspctrm;
    
    freq1.powspctrm(i,:,:) = freqPost0avg{i}.powspctrm;
end


cfg                     = [];
%cfg.channel             = 'EEG';
cfg.frequency           = [9 11];
cfg.avgoverfreq         = 'yes';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'wcm'; % check
cfg.minnbchan           = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 500;
cfg.neighbours          = neighbours;

cfg.design  = [ones(1,8) ones(1,8)*2; 1:8 1:8];
cfg.ivar    = 1;
cfg.uvar    = 2;

stat = ft_freqstatistics(cfg, freq0, freq1);

cfg             = [];
cfg.alpha       = 0.05;
cfg.parameter   = 'stats';
cfg.zlim        = [-4 4];
cfg.layout      = layout;

ft_clusterplot(cfg, stats);

% plot the data 
% first we average across all the subjects with ft_freqdescriptives? or
% ft_freqgrandaverage
cfg         = [];
Post0avg    = ft_freqdescriptives(cfg, freq0);%
Post1avg    = ft_freqdescriptives(cfg, freq1);

% add raw effect to stat and plot
stat.raweffect  = Post0avg-Post1avg;
cfg             = [];
cfg.alpha       = 0.025; 

% play with threshold to get more or less clusters to plot, or run through all the 
% significant +ve and -ve cluster to find the max p value to be set.
cfg.parameter   = 'raweffect';
cfg.zlim        = [-1e27 1e27];
cfg.layout      = layout; % here, import the fieldtrip layout of the 256 channel EGI net

ft_clusterplot(cfg, stat);

cfg         = [];
cfg.layout  = layout;
cfg.zlim    = 'maxmin';

dat = data0{3};
dat.powspctrm = log10(dat.powspctrm+1);

ft_topoplotER(cfg, dat);

% todo, time each of the steps to evaluate performance, if fast, merge for 
% delta, theta, alpha and beta; 
% delta, average over freq_time -> [1 4]_time
% theta, average over freq_time -> [4 8]_time
% alpha, average over freq_time -> [8 13]_time
% beta, average over freq_time  -> [13 30]_time

% do source rconstruction for significant sources

% do connectivity analysis on a priori seed
            
   