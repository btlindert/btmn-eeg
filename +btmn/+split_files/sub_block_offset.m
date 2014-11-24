function off = sub_block_offset(sbType)
% SUB_BLOCK_OFFSET - Offset from PVT onset for each sub-block type
%
% Offsets are specified in seconds
%
% See also: batman.split_files

off = mjava.hash;

off('baseline') = 0;
off('nback')    = 0;
off('pvt')      = 0;
off('saccade')  = 0;
off('subj')     = 0;
off('rs-eo')    = 0;
off('rs-ec')    = 0;

if nargin > 0,
    off = off(sbType);
end


end