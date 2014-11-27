Timing issues
===

## Event marker correction

Based on the Advisory Notices below we have to correct the EEG relative to the real-time DIN events. 
In the __BATMAN__ project we sampled at a 1000 Hz, so the real-time EEG is 8ms later than the corresponding
timing (DIN) event.  

## November 2014: Electrical Geodesics, Inc. Update to Anti-Alias Filter Effects on EEG Timing Advisory Notice

This is an update to an advisory notice issued to users of EGI’s GES 300 and 400 series 
amplifiers on the delay of EEG data inherent in the anti-alias filters of these amplifiers.

In the original advisory notice, it was noted that the digital Finite Impulse Response filters 
used after analog-to-digital conversion delay the EEG by a fixed interval by the following values:
 
Sampling Rate |	NA 300	
--------------|----------
1000 s/s	  | 8 ms (0.52)
500 s/s	      | 18 ms (0.63)
250 s/s	      | 36 ms (2.07)
125 s/s	      | 72 ms (2.53)	 	 	 

Without adjustment, the EEG is delayed with respect to real time and to event markers that 
are aligned with real time. This delay does not affect timing of events manually entered 
by the user with respect to the EEG during acquisition.

The delay values in the original Advisory Notice were verified with the most recent versions 
of Net Station 4.5 and 5.0, representing the software versions that are most widely used by 
our customer base. The original Advisory Notice was issued immediately after this verification effort.

Since releasing the original Advisory Notice on 28 August 2014, we have continued our 
verification testing to confirm these delay values in all other versions of Net Station 
associated with the NA 300 amplifier, in order to provide our customers not using 
Net Station 4.5 or 5.0 with more specific guidance.

With the NA 300 amplifier, we found that the filter delay is only present in Net Station 
version 4.4 and later; events are correctly aligned with the EEG data when acquired with 
earlier versions of Net Station (4.3.1 and earlier). Furthermore, we found that for data 
recorded with Net Station versions 4.4 through 4.5.7, the correction values for the default 
250 s/s sampling rate (which is likely used by the majority of customers) is 8 ms.

For data acquired with the NA 400, NA 405 and NA 410 amplifiers, there is no modification 
to the delay values presented in the original Advisory Notice.


## August 2014: Electrical Geodesics, Inc. Advisory Notice: Anti-Alias Filter Effects on EEG Timing

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
