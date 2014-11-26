Temperature analysis
===

The temperature manipulation is, together with the light and posture manipulation, a core
part of __BATMAN__ project. Both the light and posture manipulation were visually checked 
throughout the experiment, but the efficacy of the skin temperature manipulation needed to 
be checked offline, because the thermistors were multiplexed into a single EEG channel. This 
meant that during the experiment only the multiplexed voltages were visual and not the 
actual temperatures in degrees Celsius.

Therefore the first step is to check if the manipulation itself was successful.
 
# Analysis strategy for the temperature recordings.

1. Split the raw file into 4 (morning) or 8 (afternoon) blocks. Using the event specified 
   below, ignoring the EEG data to create smaller files:

Event  | Split name                     | Offset from `t` (mins) | Duration (mins)
-------|--------------------------------| ---------------------- | ------------------
`nbk+` | `[dataName]_block_[block#]`    | -15.5                  | 30

2. If all went well, the multiplexed channel should be un-multiplexed when importing the 
   raw `.mff` file creating 12 individual temperature channels:

Channel   | Body location             
----------|------------------------------------
`temp 1`  | foot, non-dominant side
`temp 2`  | foot, dominant side
`temp 3`  | calf, non-dominant side
`temp 4`  | mid thigh, front, non-dominant side
`temp 5`  | stomach, 2cm above navel
`temp 6`  | infra-clavicular, non-dominant side
`temp 7`  | lower arm, mid and dorsal, non-dominant side
`temp 8`  | hand palm, non-dominant side
`temp 9`  | hand palm, dominant side
`temp 10` | fingertip index finger, non-dominant side
`temp 11` | core body temperature, 10cm into rectum
`temp 12` | room temperature

3. Within each block extract the temperatures of the water baths and entering and leaving 
   the suit from the events. These temperatures are sent once per minute by the NCC 
   software to EGI's NetStation on event channel ECI TCP/IP 55516 using a TEMP event with 
   sub-fields:   

Label  | Sub-field  | Description              
-------|------------|---------------------------------------------------------
`TEMP` | `PSET`     | Set-point temperature of the proximal water bath
`TEMP` | `PCUR`     | Current temperature of the proximal water bath
`TEMP` | `PINP`     | Temperature of the water entering the proximal suit
`TEMP` | `POUT`     | Temperature of the water leaving the proximal suit
`TEMP` | `DSET`     | Set-point temperature of the distal water bath
`TEMP` | `DCUR`     | Current temperature of the distal water bath
`TEMP` | `DINP`     | Temperature of the water entering the distal suit
`TEMP` | `DOUT`     | Temperature of the water leaving the distal suit

4. Aggregate all temperatures to once per minute and export to R.

5. Run a model in R on the last 6 minutes of each block (resting-state eeg) to test if the 
   manipulation was successful.
   
   
