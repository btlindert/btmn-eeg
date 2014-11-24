Psychomotor vigilance task (PVT) analysis
===

The aim of the psychomotor vigilance task was to test the effects of light, posture and body 
temperature on simple reaction times.

The Psychomotor vigilance task was implemented in E-Prime and communicated with EGI's 
NetStation using the E-Prime Extension for NetStation (EENS) package. This package provided
the means to send trial events from E-Prime to NetStation. However, testing in our lab 
revealed a delay between the timing of the event markers (from auditory and visual stimuli) 
in NetStation and the actual occurence of the stimuli.
 
# Achieving millisecond accurate timing.

To correct for the incorrect timing of the E-Prime events in NetStation we used the 
EGI's AV-tester throughout the experiment to mark the actual occurence of stimuli. Therefore,
rather than using E-Prime events we used the following events to calculate reaction times:

Event        | Description                    
-------------|------------------------------------------------
`AUD`        | Onset of the auditory PVT stimulus
`left mouse` | Onset of the button press from the response box

# Analysis strategy for the reaction times

1. Create a list of all stimulus onsets

2. Find the first `left mouse` press after each stimulus onset

3. Export the list of calculated reaction times to R for analysis
