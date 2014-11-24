 Two-back analysis
===

The aim of the auditory 2-back task was to test the effects of light, posture and body 
temperature on working memory.

The auditory 2-back task was implemented in E-Prime and communicated with EGI's 
NetStation using the E-Prime Extension for NetStation (EENS) package. This package provided
the means to send trial events from E-Prime to NetStation. However, testing in our lab 
revealed a delay between the timing of the event markers (from the auditory) in NetStation 
and the actual occurence of the stimuli.
 
# Achieving millisecond accurate timing.

To correct for the incorrect timing of the E-Prime events in NetStation we used the 
EGI's AV-tester throughout the experiment to mark the actual occurence of stimuli. Therefore,
rather than using E-Prime events we used the following events to calculate reaction times:

Event         | Description                    
--------------|------------------------------------------------
`AUD`         | Onset of the auditory 2-Back stimulus
`left mouse`  | Onset of the left mouse button press
`right mouse` | Onset of the right mouse button press
`TRSP`        | cell #1 is a target, cell #2 is no target
 
# Analysis strategy for the reaction times

1. Create a list of all stimulus onsets

2. Find the `TRSP` event nearest each stimulus onset to check if it is a `target` or 
   `no target`

3. Find the first `left mouse` or `right mouse` press after each stimulus onset

3. Export the list of calculated reaction times, as well as a list of targets and 
   corresponding responses to R for analysis:
   
Event          | Description  | Response        | Score                  
---------------|-----------------------------------------------------
`TRSP cell #1` | target       | `left mouse`    | correct target
`TRSP cell #1` | target       | `left mouse`    | incorrect target
`TRSP cell #2` | no target    | `right mouse`   | correct no target
`TRSP cell #2` | no target    | `right mouse`   | incorrect no target
   

