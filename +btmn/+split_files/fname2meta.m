function meta = fname2meta(fName)
% FNAME2META - Translate file names into several meta-tags
%
%
% See also: btmn

import btmn.block2condition;

regex = 'btmn_(?<subject>\d+)_eeg_(?<session>\w+).*_(?<sub_block>[^_]+)_(?<block>\d+)';

meta = regexp(fName, regex, 'names');

meta.subject = meta.subject;

warning('off', 'block2condition:InvalidBlockID');
[condID, condName] = block2condition(str2double(meta.subject), ...
    str2double(meta.block), meta.session);
warning('on', 'block2condition:InvalidBlockID');

meta.cond_id   = condID;
meta.cond_name = condName;

end