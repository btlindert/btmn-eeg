Splitting files
===

The recorded raw data files will be split into smaller chunks of data to facilitate data 
analysis. [Events][events] in the data are used to select the relevant data periods. The data
in the __BATMAN__ project is splitted into blocks and sub-blocks:


Split    | Event  | Offset (sec) | Duration (sec) 
---------|--------|--------------|---------------
block    | `nbk+` | -930         | 1800
baseline | `nbk+` | -930         | 930
nback    | `pvt+` | -180         | 180
pvt      | `sac+` | -180         | 180
saccade  | `sac+` | 0            | 120
subj     | `eo++` | -120         | 120
rs-eo    | `eoeo` | 0            | 180
rs-ec    | `ecec` | 0            | 180


[events]: /+btmn/+event_selectors/README.md

## Block data

Usually we immediately split data into the smallest possible sub-blocks. However, to check 
the temperature manipulation we made an exception. Here data was split into 30 min blocks and then 
temperature was averaged across 1 min epochs. However, to reduce file size we removed the EEG
from the .pset file.

Split    | Event  | Offset (sec) | Duration (sec) 
---------|--------|--------------|---------------
block    | `nbk+` | -930         | 1800

## Baseline data

The __nbk+__ event occured 930000ms (15.5 minutes) after the onset of a new block, by sending a pulse from
the PC running the NCC software to the serial port of the E-Prime PC starting the task battery.
This event can be used to select the preceding __baseline__ period (offset = -930 sec, duration = 930 sec) 
as well as an entire __block__ (offset = -930 sec, duration = 1800 sec). 

Split    | Event  | Offset (sec) | Duration (sec) 
---------|--------|--------------|---------------
baseline | `nbk+` | -930         | 930


## N-Back data

To select the __nback__ period, we use an event that marks the end of the task. The 
N-Back is preceded by instructions that have variable duration because the participant had 
to manually click the mouse to proceed. The onset of the instructions of the following task 
(PVT) marks the end of the fixed duration 3-minute N-Back.

Split  | Event  | Offset (sec) | Duration (sec) 
-------|--------|--------------|---------------
nback  | `pvt+` | -180         | 180
  

## PVT data

The __pvt__ period is also selected using the end marker, for the 
same reason as the __nback__ period above. The onset of the instructions of the following task 
(SACCADE) marks the end of the fixed duration 3-minute PVT.

Split  | Event  | Offset (sec) | Duration (sec) 
-------|--------|--------------|---------------
pvt    | `sac+` | -180         | 180

## Saccade data

The __saccade__ period is selected using the onset marker. Although the test only lasts 1 minute we set 
the period to 120 seconds to account for the variable duration of the instrcutions.

Split   | Event  | Offset (sec) | Duration (sec) 
--------|--------|--------------|---------------
saccade | `sac+` | 0            | 120

## Subjective data

The __subjective__ period is selected using the end marker. This period had variable duration, but generally
lasted no longer than 90 seconds. To be on the save side, we set the duration to 120 seconds.

Split   | Event  | Offset (sec) | Duration (sec) 
--------|--------|--------------|---------------
saccade | `eo++` | -120            | 120



## Resting-state eyes-open data

The __rs-eo__ period is selected using the onset marker of the 3-minute 
resting-state eyes-open session. 

Split  | Event  | Offset (sec) | Duration (sec) 
-------|--------|--------------|---------------
rs-eo  | `eoeo` | 0            | 180


## Resting-state eyes-closed data

The __rs-ec__ period is selected using the onset marker of the 3-minute 
resting-state eyes-open session.  

Split  | Event  | Offset (sec) | Duration (sec) 
-------|--------|--------------|---------------
rs-ec  | `ecec` | 0            | 180


## Example pipeline

````matlab

nodeList = {};

% Node 1: Load the physioset

myNode   = meegpipe.node.physioset_import.new('Importer', physioset.import.physioset);

nodeList = [nodeList {myNode}];

% Node 2: Extract a 30min block

mySel    = physioset.event.class_selector('Type', 'nbk+');
offset   = -930;
duration = 1800;

% Block naming policy
splitNaming = @(physObj, ev, evIdx) ...
    btmn.split_files.block_naming_policy(physObj, ev, evIdx, 'block');

thisNode = split.new(...
    'EventSelector',     mySel, ...
    'Offset',            offset, ...
    'Duration',          duration, ...
    'SplitNamingPolicy', splitNaming, ...
    'Name',              'block');

% Build the pipeline

myPipe = meegpipe.node.pipeline.new('NodeList', nodeList, ...
    'Name',           'pvt', ...
    'GenerateReport', false, ...
    'OGE',            false, ...
    'Queue',          'short.q@somerenserver.herseninstituut.knaw.nl', ...
    'Save',           true ...
);

````
