function dur = sub_block_duration(sbType)
% SUB_BLOCK_DURATION - Duration of each sub-block type
%
% Durations are specified in seconds
%
% See also: batman.split_files

dur = mjava.hash;

dur('baseline')   = 15.5*60;
dur('nback')      = 3*60;
dur('pvt')        = 3*60;
dur('saccade')    = 1*60;
dur('subjective') = 2*60; %%%%%
dur('rs-eo')      = 3*60;
dur('rs-ec')      = 3*60;


if nargin > 0,
    dur = dur(sbType);
end

end