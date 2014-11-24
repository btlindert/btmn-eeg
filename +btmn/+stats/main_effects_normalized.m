% start with a clean state
close all;
clear all;
clear classes;
clc;

% add meegpipe, fieldtrip, eeglab
addpath(genpath('/data1/toolbox/meegpipe'));
addpath(genpath('/data1/toolbox/fieldtrip'));
addpath(genpath('/data1/projects/batman/scripts_bart/batman/+batman'));

% initialize pipeline 
meegpipe.initialize

% import utilities
import meegpipe.aggregate;
import mperl.file.find.finddepth_regex_match;
import batman.*;
import mperl.join;
import mperl.file.spec.catfile;

% import meegpipe.node.*;
% import somsds.link2files;
% import misc.get_hostname;
% import misc.regexpi_dir;
% import mperl.file.spec.catdir;
% import mperl.file.find.finddepth_regex_match;

opt.Bands       = batman.eeg_bands;
BANDS           = keys(opt.Bands);
opt.Scale       = 'db';
opt.RerefMatrix = meegpipe.node.reref.avg_matrix;
opt.SaveToFile  = '/data1/projects/batman/scripts_bart/analysis/main_effects.mat';

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

% required for design of ft_freqstatistics
LOCATION =  [1 1 1;...
             2 2 1;...
             3 1 2;...
             4 2 2;...
             1 3 3;...
             2 4 3;...
             3 3 4;...
             4 4 4];
             
% cell identifying the columns of MAMNIPULATIONS
EFFECT = {'L', 'P', 'T'};

%% List of files
regex = ['0+(' join('|', SUBJECTS) ').+rs_(' join('|', BLOCKS) ').pseth$'];
files = finddepth_regex_match(INPUT_DIR, regex);

%% create layout and neighbours
disp('loading initial dataset'); 
tmpData = import(physioset.import.physioset, files{1});
select(pset.selector.sensor_class('Class', 'eeg'), tmpData);
tmpData = fieldtrip(tmpData, 'BadData', 'donothing');

% we need this for the ft_freqstatistics later on
%[neighbours, layout] = sensor_geometry(tmpData);

cfg          = [];
cfg.method   = 'distance';
cfg.feedback = 'no';
neighbours   = ft_prepare_neighbours(cfg, tmpData);
cfg          = [];
layout       = ft_prepare_layout(cfg, tmpData);

%% start with postural manipulation, 

% set ft_freqanalysis vars
cfgF = [];
cfgF.method         = 'mtmfft';
cfgF.output         = 'pow';
cfgF.taper          = 'hanning';
cfgF.keeptrials     = 'no';
cfgF.foilim         = [1 30];
%cfgF.keepindividual = 'yes';
cfgF.avgoverfreq    = 'yes';


for subjItr = 1:numel(SUBJECTS)

% select subject
subject = SUBJECTS(subjItr);
disp(['processing files for subject ' num2str(subject)]);

    for blockItr = 1:numel(BLOCKS)
        disp(['processing block ' num2str(blockItr)]);        

        % get the condition from the conditions file
        block = BLOCKS(blockItr);
        cond  = CONDITIONS(subject, block);

        % find file
        regex = ['0+(' join('|', subject) ')_.+rs_(' join('|', block) ').pseth$'];
        file  = finddepth_regex_match(INPUT_DIR, regex, false);

        % make sure to exclude missing data
        if ~isempty(file)
            
            % load the pset file
            data = pset.load(file{1});

            % subset data
            disp('subsetting data'); 
            data = subset(data, 1:size(data,1), 240001:size(data,2));

            % copy data
            disp('copying data');
            data = copy(data);

            % create avg reference matrix for this dataset
            disp('rereferencing data');
            M = opt.RerefMatrix(data); 

            % reference the dataset to average 
            data = reref(data, M);                  

            % chan_time data
            disp('converting to fieldtrip');
            dataFt = fieldtrip(data);

            % reduce to last 1 minute
            dataFt.trial{1}     = dataFt.trial{1};
            dataFt.time{1}      = (1:size(dataFt.trial{1},2)-1)./1000;
            dataFt.time{1}      = [0 dataFt.time{1}];
            dataFt.sampleinfo   = [0, size(dataFt.trial{1},2)];

            % get powspctrm from dataset 
            allData{subjItr, cond-4} = ft_freqanalysis(cfgF, dataFt);

            % clear dataFt to free up memory
            clear dataFt data
        end
    end
end
    

% now normalize data, by averaging across conditions per subject.
% i.e sum/8 for all subjects except 6 which has 1 missing value i.e.
% sum/7

% copy allData
allDatadB         = allData;
allDataPercentage = allData;

cfg = [];

for subjItr = 1:8
    
    % file(5,6) is missing!
    if subjItr == 5;
    	freqAvg = ft_freqgrandaverage(cfg, allData{subjItr, [1:5,7:8]});
    else
        freqAvg = ft_freqgrandaverage(cfg, allData{subjItr, :});
    end
    
    % subtract mean powspctrm from each individual value
    for condItr = 1:8
        if ~isempty(allData{subjItr, condItr}) 
            allDatadB{subjItr, condItr}.powspctrm = ...
                10*log10(allDatadB{subjItr, condItr}.powspctrm./freqAvg.powspctrm);
            
            allDataPercentage{subjItr, condItr}.powspctrm = ... 
                100*((allDataPercentage{subjItr, condItr}.powspctrm - freqAvg.powspctrm)./freqAvg.powspctrm);
        end
    end
end    


% use normalized data to run analyses

% set ft_freqstatistics vars
cfgS                     = [];
cfgS.frequency           = [];
cfgS.avgoverfreq         = 'yes';
cfgS.keepindividual      = 'yes'; 
cfgS.method              = 'montecarlo';
cfgS.statistic           = 'depsamplesT';
cfgS.correctm            = 'cluster';
cfgS.clusteralpha        = 0.05;
cfgS.alpha               = 0.05;
cfgS.numrandomization    = 1000;
cfgS.neighbours          = neighbours;
cfgS.layout              = layout;
cfgS.design              = [ones(1,8) ones(1,8)*2; 1:8 1:8];
cfgS.ivar                = 1;
cfgS.uvar                = 2;


% run through all main effects
for effectItr = 1:numel(EFFECT)

    disp(['calculating main effect for ' BANDS(bandItr) ' power in ' EFFECT{effectItr}]);

    % first find rows corresponding to EFFECT level 1
    % use only the afternoon protocol (rows 5:12)
    rows1 = find(MANIPULATIONS(5:12,effectItr))';

    % then the other rows must be zero
    rows0 = setdiff(1:8, rows1);

    for bandItr = 2:numel(BANDS)
        % pass frequency band to cfg file for ft_freqanalysis
           
        cfg                = [];
        cfg.foilim         = opt.Bands(BANDS(bandItr));
        cfg.keepindividual = 'no';
        
        % to run analyses, first average the conditions across subjects:
        % subj_chan_freq
        % then average the 4 .avg powspctra for each main condition A  and B
        % these 2 .avg are added to ft_freqstatistics
        
        % see pipermail/fieldtrip/2011-February/003474.htm
        % first average across subjects per condition
        for condItr = 1:8
            if condItr == 6
                condAvgdB{condItr}         = ft_freqgrandaverage(cfg, allDatadB{[1:4,6:8], condItr});
                condAvgPercentage{condItr} = ft_freqgrandaverage(cfg, allDataPercentage{[1:4,6:8], condItr});                
            else
                condAvgdB{condItr}         = ft_freqgrandaverage(cfg, allDatadB{:, condItr});
                condAvgPercentage{condItr} = ft_freqgrandaverage(cfg, allDataPercentage{:, condItr});
            end
        end
       
        cfg                = [];
        cfg.keepindividual = 'yes';
        
        % average data for level 0
        data0dB   = ft_freqgrandaverage(cfg, condAvgdB{rows0});
        data0Perc = ft_freqgrandaverage(cfg, condAvgPercentage{rows0});
        
        % average data for level 1
        data1dB   = ft_freqgrandaverage(cfg, condAvgdB{rows1});
        data1Perc = ft_freqgrandaverage(cfg, condAvgPercentage{rows1});
        
        cfgS.design = [];
        cfgS.design = [ones(1,4) ones(1,4)*2; 1:4 1:4];
        
        % run statistics on dB and Percentage data 
        statsdB   = ft_freqstatistics(cfgS, data0dB, data1dB);      
        statsPerc = ft_freqstatistics(cfgS, data0Perc, data1Perc);
                        
        ft_stats              = [];
        ft_stats.effect       = EFFECT{effectItr};
        ft_stats.band         = BANDS(bandItr);
        ft_stats.cond0        = rows0;
        ft_stats.cond1        = rows1;
        ft_stats.layout       = layout;
        ft_stats.neighbours   = neighbours;
        ft_stats.data0dB      = data0dB;
        ft_stats.data1dB      = data1dB;
        ft_stats.data0Perc    = data0Perc;
        ft_stats.data1Perc    = data1Perc;
        ft_stats.statsdB      = statsdB;
        ft_stats.statsPerc    = statsPerc;
        ft_stats.scale        = opt.Scale;
        
        % create save name
        [filePath, fileName, fileExt] = fileparts(opt.SaveToFile);

        if ~isempty(opt.SaveToFile),
            thisSaveFile = [filePath filesep fileName '_' EFFECT{effectItr} '_' BANDS{bandItr} '_' datestr(now, 'yymmdd-HHMMSS')];

%             if ismember(lower(opt.Scale), {'db', 'logarithmic'}),
%                 thisSaveFile = [thisSaveFile '_logarithmic'];
%             end

            save([thisSaveFile fileExt], 'ft_stats');
        end
    
    end
end   
