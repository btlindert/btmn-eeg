function condName = conditions(condID, SESSION)

import btmn.*;
import mperl.file.spec.catfile;
import mperl.join;

% Capitalize first letter of SESSION
session = regexprep(SESSION, '(\<[a-z])', '${upper($1)}');

fName = catfile(root_path, 'data', ['conditions' session '.csv']);

% Read numeric contents
condContent = csvread(fName, 1, 1);

if strcmpi(SESSION, 'Afternoon')
    
    % Extract headers
    fid = fopen(fName);
    C = textscan(fid, '%s%s%s%s', 1, 'delimiter', ',');
    fclose(fid);

    % Drop first column
    varNames = {C{1,2}, C{1,3}, C{1,4}}; 

    % Create condition names: e.g. light1_posture1_dpg1
    % Again rows = conditions
    condName = [char(varNames{1}), num2str(condContent(condID, 1)), '_', ...
        char(varNames{2}), num2str(condContent(condID, 2)), '_', ...
        char(varNames{3}), num2str(condContent(condID, 3))];
    
elseif strcmpi(SESSION, 'Morning')
    
    % Extract headers
    fid = fopen(fName);
    C = textscan(fid, '%s%s%s', 1, 'delimiter', ',');
    fclose(fid);

    % Drop first column
    varNames = {C{1,2}, C{1,3}}; 

    % Create condition names: e.g. light1_posture1_dpg1
    % Again rows = conditions
    condName = [char(varNames{1}), num2str(condContent(condID, 1)), '_', ...
        char(varNames{2}), num2str(condContent(condID, 2))];    

end

end