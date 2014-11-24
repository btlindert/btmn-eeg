Timing issues
===

## Event marker correction

Based on the Advisory Notice below we have to correct the EEG relative to the real-time DIN events. 
In the BATMAN project we sampled at a 1000 Hz, so the real-time EEG is 8ms later than the corresponding
DIN event.  


## Electrical Geodesics, Inc. Advisory Notice: Anti-Alias Filter Effects on EEG Timing

This advisory notice is to alert users of EGI’s GES 300 and 400 series amplifiers to the delay 
of EEG data inherent in the anti-aliasing filters of these amplifiers. These delay values have 
not been effectively communicated to EGI customers and need to be considered when aligning 
events (such as events generated from E-Prime or from digital inputs) to the EEG.

The digital Finite Impulse Response filters used prior to A/D conversion delay the 
EEG by a fixed interval. This interval is known for each sampling rate and amplifier model:
 
Sampling Rate |	NA 300
--------------|-------------
1000 s/s	  | 8 ms	
500 s/s	      | 18 ms	
250 s/s	      | 36 ms	
125 s/s	      | 72 ms	
 	 	 
Without adjustment, the EEG is delayed with respect to real time and to event markers that 
are aligned with real time. This delay does not affect timing of events manually entered by 
the user with respect to the EEG during acquisition.

Particularly for the Net Amps 400, 405, and 410 models at lower sampling rates, the delays 
may be significant in considering EEG and ERP timing. To adjust for this delay, users must 
add a positive value in the “Offset Segment” field in the segmentation tool, in addition to 
E-Prime Event or digital input event (DIN) offsets.

This adjustment is only required for real time events that are recorded during acquisition. 
Events entered during review or from the operations of tools after data acquisition are 
already aligned correctly with the EEG.

To make the delays clear to each user, both the EGI technical manuals and EGI Support 
training will be modified to underscore the importance of including these delays in the 
event alignment and segmentation process. In addition, the Net Station software (version 5.1.1) 
will provide an option for automatic adjustment.
