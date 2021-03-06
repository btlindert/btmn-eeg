Event selectors
===

There are numerous event markers in the EEG recordings. Some events mark the onset of a new
sub-block, a sub-section of a sub-block, a stimulus or a response. Each of these event markers
can be used to select specific parts of the data. The events can be selected in a node:

````matlab

nodeList = {};

%% NODE: import from .mff file

myImporter = physioset.import.mff('Precision', 'single');
myNode     = meegpipe.node.physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];


%% Select block data

mySel    = physioset.event.class_selector('Type', 'nbk+');
offset   = -930;
duration = 1800;

thisNode = meegpipe.node.split.new(...
    'EventSelector',        mySel, ...
    'Offset',               offset, ...
    'Duration',             duration, ...
    'Name',                 'block');

nodeList = [nodeList {thisNode}];

%% The actual pipeline

myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'split_files', ...
    'Queue',            QUEUE);

````

Below is list of events in the data:

Code | Label               | cel# | Description
-----|---------------------|------|-----------------------------------------------------
CELL |                     |      | CellNumbers from the E-Prime script indicating the individual procedures, ISIs and targets
CELL | Target              | #1   | Target in the N-Back, should match a left mouse button press
CELL | NoTarget            | #2   | No target in the N-Back, should match a right mouse button press
CELL | Block               | #3   | Block session
CELL | Baseline            | #4   | Baseline session
CELL | Tasks               | #5   | Tasks session
CELL | SubjectiveQuestions | #6   | Subjective questions session
CELL | EEG                 | #7   | EEG session
CELL | NBack               | #8   | N-Back task
CELL | PVT                 | #9   | PVT task
CELL | Saccade             | #10  | Saccade task
CELL | 1000ms              | #11  | 1 second ISI of PVT
CELL | 2000ms              | #12  | 2 second ISI of PVT
CELL | 3000ms              | #13  | 3 second ISI of PVT
CELL | 4000ms              | #14  | 4 second ISI of PVT
CELL | Series1             | #15  | Series 1 of N-Back
CELL | Series2             | #16  | Series 2 of N-Back
CELL | Series3             | #17  | Series 3 of N-Back
CELL | Series4             | #18  | Series 4 of N-Back
CELL | Series5             | #19  | Series 5 of N-Back
CELL | L20                 | #20  | Left 20 degrees saccade stimulus
CELL | L15                 | #21  | Left 15 degrees saccade stimulus
CELL | L10                 | #22  | Left 10 degrees saccade stimulus
CELL | R10                 | #23  | Right 10 degrees saccade stimulus
CELL | R15                 | #24  | Right 15 degrees saccade stimulus
CELL | R20                 | #25  | Right 20 degrees saccade stimulus
CELL | Effort              | #26  | Effort session
CELL | FSSProc             | #27  | FSS session
CELL | SevenProc           | #28  | Subjective questions with 7-point Likert scale
CELL | Sensation           | #29  | Thermal sensation question
CELL | Comfort             | #30  | Thermal comfort question
CELL | Preference          | #31  | Thermal preference
CELL | EOProc              | #32  | Eyes-open session
CELL | ECProc              | #33  | Eyes-closed session
SESS | morning_4           |      | Onset of morning protocol with 4 sub-blocks
SESS | afternoon_8         |      | Onset of afternoon protocol with 8 sub-blocks
bgin |                     |      | Beginning of a trial
TRSP |                     |      | Trial information
resp |                     |      | Trial response information
nbk+ |                     |      | Onset of the N-Back instructions / N-Back session
nisi |                     |      |￼Onset of N-Back inter stimulus interval
nstm |                     |      | Onset of N-Back auditory stimulus
pvt+ |                     |      | Onset of the PVT instructions / PVT session
pisi |                     |      | Onset of PVT inter stimulus interval
pstm |                     |      | Onset of PVT auditory stimulus
sac+ |                     |      | Onset of Saccade instructions / Saccade session
sfix |                     |      | Onset of Saccade inter stimulus interval (duration 1 second)
sstm |                     |      | Onset of visual Saccade stimulus (duration 1 second)
effo |                     |      | Onset of effort question
fssq |                     |      | Onset of the FSS
ques |                     |      | Onset of a subjective question
eo++ |                     |      | Onset of the eyes-open instructions (duration 10 seconds)
eoeo |                     |      | Beginning of the 3 minute eyes-open session￼
ec++ |                     |      | Onset of the eyes-closed instructions (duration 10 seconds)
ecec |                     |      | Beginning of the 3 minute eyes-closed session
ec–  |                     |      | Onset of auditory stimulus at the end of the 3 minutes eyes-closed session

__TRSP__ events occur in every trial of a task and have the following keys indicating the properties of the stimulus in that trial:
cel#, obs#, rsp#, eval, rtim, trl#. The cel# refers to the number in the table above.

To correct for the timing delays in the stimulus onset, we also recorded event markers on the 
digital input channel of the EEG amplifier using the AV-tester. These events were given the 
following properties:

Code  | Label         | Type           | Track | Description
------|---------------|----------------|-------|-----------------------------------------------------
`AUD` | auditory stim | Stimulus event | DIN1  | Audio onset recorded with AVtester
`SAC` | saccade       | Stimulus event | DIN1  | Saccade onset recorded with AVtester
`LM`  | left mouse    | Stimulus event | DIN1  | Left mouse button press
`RM`  | right mouse   | Stimulus event | DIN1  | Right mouse button press
`MM`  | middle mouse  | Stimulus event | DIN1  | Middle mouse button press


## TRAN event

The __TRAN__ event marks the transition between 2 conditions and could be used to split the 
data into 30 minute sub-blocks. It has the following properties:

Code   | Label  | Type             | Track        | Description
-------|--------|------------------|--------------|---------------------
`TRAN` |        | Stimulus event   | TCP/IP 55516 | Transition between blocks

There is usually 1 extra __TRAN__ event in the list marking the end of the protocol so 
selection should run to 4 (morning) or 8 (afternoon) events. Event better, use the __nbk+__ 
event (see Baseline data). 


## Baseline data

The __nbk+__ event occured 930000ms (15.5 minutes) after the onset of a new block, by sending a pulse from
the PC running the NCC software to the serial port of the E-Prime PC starting the task battery.
This event can be used to select the preceding __baseline__ period (offset = -900 sec, duration = 900 sec) 
as well as an entire __block__ (offset = -900 sec, duration = 1800 sec). 

Split    | Event  | Offset (sec) | Duration (sec) 
---------|--------|--------------|---------------
baseline | `nbk+` | -930         | 930
block    | `nbk+` | -930         | 1800


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

The __saccade__ period too is selected using the end marker, for the 
same reason as the __nback__ period above. The onset of the XXXXXXX marks the end of the fixed duration 1-minute saccade task.

Split   | Event  | Offset (sec) | Duration (sec) 
--------|--------|--------------|---------------
saccade | ``     | -60          | 60


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


## N-Back ERPs



## PVT ERPs



## Temperature events

The __TEMP__ event occurs every minute and contains all the temperatures related to the 
temperature manipulation in its sub-keys, i.e. the temperature of the water in both water baths (proximal
and distal) and the temperature of the water entering and leaving the suit. 

Code    | Label   | Type           | Track          | Description
--------|--------|-----------------|----------------|-----------------------------------------------------
`NSIP`  |        | Stimulus event  | TCP/IP 55516   | 
 `TEMP` |        | Event key       | TCP/IP 55516   | 
 `PSET` | 00.00  | Event key       | TCP/IP 55516   | Set-point temperature of the proximal water bath
 `PCUR` | 00.00  | Event key       | TCP/IP 55516   | Current temperature of the proximal water bath
 `PINP` | 00.00  | Event key       | TCP/IP 55516   | Temperature of the water entering the proximal suit
 `POUT` | 00.00  | Event key       | TCP/IP 55516   | Temperature of the water leaving the proximal suit
 `DSET` | 00.00  | Event key       | TCP/IP 55516   | Set-point temperature of the distal water bath
 `DCUR` | 00.00  | Event key       | TCP/IP 55516   | Current temperature of the distal water bath
 `DINP` | 00.00  | Event key       | TCP/IP 55516   | Temperature of the water entering the distal suit
 `DOUT` | 00.00  | Event key       | TCP/IP 55516   | Temperature of the water leaving the distal suit


### Extra events


Code    | Label                | Type           | Track            | Description
--------|----------------------|----------------|------------------|-----------------------------------------------------
`NSIP`  |                      | Stimulus event | ECI TCP/IP 55516 |
 `TIME` | 20.Time Stamp        | Event key      | ECI TCP/IP 55516 | Time stamp #
 `ATIM` | dd/mmm/yyyy HH:MM:SS | Event key      | ECI TCP/IP 55516 | Absolute time
 `RTIM` | 0-HH:MM:SS           | Event key      | ECI TCP/IP 55516 | Time relative to protocol onset
`NSIP`  |                      | Stimulus event | ECI TCP/IP 55516 |
 `PVTB` | 01.Start PVT         | Event key      | ECI TCP/IP 55516 | Onset of E-Prime session / N-Back


To extract the results from each of the sessions, use these events:

Task    | Variable            | Events 
--------|---------------------|----------------------------------
N-Back  | correct target      | AUD, TRSP, cell #1, left mouse
N-Back  | correct no target   | AUD, TRSP, cell #2, right mouse
N-Back  | incorrect target    | AUD, TRSP, cell #1, right mouse
N-Back  | incorrect no target | AUD, TRSP, cell #2, left mouse
N-Back  | reaction time       | AUD, left mouse, right mouse
PVT     | reaction time       | AUD, left mouse
Saccade |                     | SAC


## Additional information

The [Advisory Notices][notice] from [EGI][egi] on timing issues in the NetStation software 
describe the delay between the DIN event channels and the EEG.

[notice]: timing.md
[egi]:    http://www.egi.com
