function myPipe = temp_in_epochs_pipeline(varargin)
% TEMP_IN_EPOCHS - Average temp values in correlative data epochs

import meegpipe.node.*;
import physioset.event.class_selector;
import pset.selector.event_selector;
import physioset.event.value_selector;

nodeList = {};

%% NODE: Data importer

% The raw data files (in .mff format) have been previously splitted into
% single block files in .pseth format.

% Use AutoDestroyMemMap because the data files can be quite huge 
myImporter = physioset.import.physioset('AutoDestroyMemMap', true);

myNode   = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% NODE: Create a subset of the data that contains only the temp channels

% We prefer to do this instead of using simple selections because the data
% files are quite large and it pays off to release as much VM as possible
% as soon as possible
tempSelector = pset.selector.sensor_class('Type', 'temp');
myNode       = subset.new('DataSelector', tempSelector);
nodeList     = [nodeList {myNode}];

%% NODE: Event generation (specification of data epochs)

% We want to extract average temp values in correlative epochs of 1 min and
% without any overlap between correlative epochs. Note that we could have
% defined overlapping epochs by setting the Period property to a value
% smaller than the value of Duration.
myEvGen = physioset.event.periodic_generator(...
    'Period',   60, ... % A new event (epoch) every 60 seconds
    'Duration', 60, ... % Each epoch lasts for 60 seconds
    'Type',     '__TempEpoch');

myNode = ev_gen.new('EventGenerator', myEvGen);

nodeList = [nodeList {myNode}];

%% NODE: Extract basic features

% * Average temp value in every data epoch at all sensor locations

% At most there are 30 epochs within a block. We
% thus use 30 selectors, each of which will select events with a given
% Value. The trick here is that the periodic_generator event generator that
% we used above set the value property of each generated event to their
% index in the array of all generated events. So if the ev_gen node above
% processes a block (which lasts 30 mins) then it generates 30
% events of type __TempEpoch, with their Value property set to 1, 2, ..., 30.
%
% For more information on events, event generators and event selectors, see:
%
% https://github.com/meegpipe/meegpipe/tree/master/%2Bphysioset/%2Bevent
%
% Each selector below will produce a row of the features table
selector = cell(30, 1);
for i = 1:30
    selector{i} = event_selector(value_selector(i));
end

% List of extracted features for each epoch
% epoch_idx, epoch_onset_abs_time, ..., chan_1, chan_2, ..., chan_12
featList  = cell(16, 1);

featNames = cell(16, 1);
featNames(1:4) = ...
    {...
    'epoch_idx'; ...
    'epoch_onset_abs_time'; ...
    'epoch_onset_in_seconds'; ...
    'epoch_dur_in_seconds'...
    };

featList(1:4) = {...
    @(x, ev, sel) get(ev, 'Value'); ...
    @(x, ev, sel) datestr(get_abs_sampling_time(x, 1)); ...
    @(x, ev, sel) round(get_sampling_time(x, 1)); ...
    @(x, ev, sel) round(size(x,2)/x.SamplingRate) ...
    };

for i = 1:12
    featNames{i+4} = sprintf('chan%d', i);
    % physioset imports 13 temp channels, so here we select 2:13 as the
    % first channels is the Voltage calib channel...
    featList{i+4} = @(x, ev, sel) mean(x(i+1,:)); 
end

myNode = generic_features.new(...
    'TargetSelector',   selector, ...
    'FirstLevel',       featList, ...
    'FeatureNames',     featNames, ...
    'DataSelector',     tempSelector, ...
    'Name',             'temp_in_epochs' ...
    );

nodeList = [nodeList {myNode}];

%% The pipeline

myPipe = pipeline.new(...
    'Name',             'temp_in_epochs', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'TempDir',          @() tempdir);


end