function eve = sub_block_event(sbType)
% SUB_BLOCK_EVENT - Event of each sub-block type
%
% Durations are specified in seconds
%
% See also: btmn.split_files

eve = mjava.hash;

eve('baseline') = physioset.event.class_selector('Type', 'nbk+');
eve('nback')    = physioset.event.class_selector('Type', 'pvt+');
eve('pvt')      = physioset.event.class_selector('Type', 'sac+');
eve('saccade')  = physioset.event.class_selector('Type', 'sac+');
eve('subj')     = physioset.event.class_selector('Type', 'eo++');
eve('rs-eo')    = physioset.event.class_selector('Type', 'eoeo');
eve('rs-ec')    = physioset.event.class_selector('Type', 'ecec');

if nargin > 0,
    eve = eve(sbType);
end

end