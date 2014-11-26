function off = sub_block_offset(sbType)
% SUB_BLOCK_OFFSET - Offset from PVT onset for each sub-block type
%
% Offsets are specified in seconds
%
% See also: batman.split_files

off = mjava.hash;

off('baseline') = -930;
off('nback')    = -180;
off('pvt')      = -180;
off('saccade')  = 0;
off('subj')     = -120;
off('rs-eo')    = 0;
off('rs-ec')    = 0;

if nargin > 0,
    off = off(sbType);
end


end