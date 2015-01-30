function name = block_naming_policy(data, ev, idx, subBlockType)
% BLOCK_NAMING_POLICY - Naming policy for the data file splits
%
%
% block_naming_policy(data, ev, idx, subBlockType)
%
% See also: btmn.split_files

import physioset.event.class_selector;
import btmn.split_files.sub_block_offset;
import btmn.split_files.sub_block_duration;


% Check the session of this recording.
dataName  = get_name(data);
regex     = '.+_eeg_(?<session>\w+)';
sessionId = regexp(dataName, regex, 'names');

if strcmpi(sessionId.session, 'morning')
    nBlocks = 4;
elseif strcmpi(sessionId.session, 'afternoon')
    nBlocks = 8;
end


% Give a warning if there are too many events for the session.
if idx > nBlocks,
    warning('naming_policy:TooManyEvents', ...
        'Event with index %d exceeds the number of blocks (%d) in %s', ...
        idx, nBlocks, get_name(data));
    name = NaN;
    return;
end

blockIdx = idx;

name = [subBlockType '_' num2str(blockIdx)]; 

end