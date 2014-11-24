batman
======

This repository contains the code and instructions necessary to reproduce
the data analyses of the [STW][stw]-funded project [BATMAN][batman].

In the documentation that follows we will assume a Linux-like OS, and that
the BATMAN dataset is managed by [somsds][somsds] data management system.
This is the case if you are trying to reproduce the data analyses at
the `somerengrid` (our lab's private computing grid).

[somsds]: https://germangh.com/somsds
[batman]: http://www.neurosipe.nl/project.php?id=23&sess=6eccc41939665cfccccd8c94d8e0216f
[stw]: http://www.stw.nl/en/

===

These instructions are based off German's tutorial, but updated to reflect any changes that
have occured since that tutorial was written.

## Experimental data

The BATMAN (Behavior, Alertness, and Thermoregulation: a Multivariate ANalysis)
project pursues to identify major thermoregulatory system parameters, and their
effects on behaviour and alertness, in a completely unrestrained ambulatory
setting. Achieving this goal will involve ambulatory measurement of all relevant
inputs and outputs: physical activity, posture, environmental light and
body temperature, electrocardiography, and skin temperature by means of a
multi-sensor system as well as questionnaires and reaction times assessed on a
PDA. These parameters will be validated against those derived under strictly
controlled laboratory manipulations. In the case of the laborary experiments we
record also high-density [EEG][eeg] (hdEEG).

[eeg]: http://en.wikipedia.org/wiki/Electroencephalography


### Experimental (lab) protocol

In a nutshell, the laboratory protocol involved various environmental manipulations
(posture, skin temperature, ambient light) that are expected to trigger
relevant thermoregulatory system responses as well as to have profound effects on alertness. 
Such responses were characterized using a diverse set of variables: arterial blood pressure, 
ECG, skin and core temperature, and hdEEG. In order to assess effects on behavior and alertness, the
subjects performed an auditory 2-back task, an auditory response-time task (psychomotor 
vigilance task), a saccade test, answered subjective questions on fatigue and effort to 
perform these tasks, and eyes-open and eyes-closed resting-state all while being subjected 
to these experimental manipulations.
In total there were 12 experimental blocks, as illustrated in the diagram below:

![Experimental protocol](../batman/img/batman-protocol.png "Experimental protocol")

Note that each __experimental block__ consisted of six __sub-blocks__:
A _baseline_ sub-block when the subject was instructed to simply wait with
her eyes open, a _NBACK_ sub-block that involved an auditory 2-back working memory task,
a _PVT_ sub-block that involved a simple reaction-time task, a _SAC_ sub-block that involved
tracking a horizontally moving dot with the eyes, a _SUBJ_ sub-block that contained the 
subjective questions, a _RS-EO_ sub-block when the subject stared at a cross hair, and a
_RS-EC_ sub-block when the subject rested with the eyes closed.

The _NBACK_, _PVT_, _RS-EO_ and _RS-EC_ all lasted 3 minutes. The _SAC_ sub-block lasted 1 minute.
The _SUBJ_ had variable duration depending on how fast the questions were answered.

## What have we done with the BATMAN dataset?

The table below lists all the analyses and processing tasks that have been or will be 
performed on the BATMAN dataset so far, roughly in chronological order.

What?                                                 | Documentation
----------------------------------------------------- | -------------
Data splitting                                        | [+batman/+splitting/README.md][split]
Pre-processing                                        | [+batman/+preproc/README.md][preproc]
Extraction of temperature values                      | [+batman/+temp/README.md][temp]
Extraction of N-Back ERPs                             | [+batman/+nback/README.md][nback] 
Extraction of PVT ERPs                                | [+batman/+pvt/README.md][pvt]
Extraction of resting state power features            | [+batman/+features/README.md][features]
Extraction of heart rate variability (HRV) features   | [+batman/+features/README.md][features]
Extraction of arterial blood pressure features        | [+batman/+abp/README.md][abp]
Statistical analysis of effects on EEG power features | [+batman/+stats/README.md][stats]

[split]: ./batman/+splitting/README.md
[preproc]: ./+batman/+preproc/README.md
[temp]: ./+batman/+temp/README.md
[nback]: ./+batman/+nback/README.md
[pvt]: ./+batman/+pvt.README.md
[features]: ./+batman/+features/README.md
[stats]: ./+batman/+stats/README.md
[abp]: ./+batman/+abp/README.md