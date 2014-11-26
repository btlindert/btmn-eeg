function dur = sub_block_duration(sbType)
% SUB_BLOCK_DURATION - Duration of each sub-block type
%
% Durations are specified in seconds
%
% See also: btmn.split_files

dur = mjava.hash;

dur('baseline') = 930;
dur('nback')    = 180;
dur('pvt')      = 180;
dur('saccade')  = 120;
dur('subj')     = 120;
dur('rs-eo')    = 180;
dur('rs-ec')    = 180;


if nargin > 0,
    dur = dur(sbType);
end

end