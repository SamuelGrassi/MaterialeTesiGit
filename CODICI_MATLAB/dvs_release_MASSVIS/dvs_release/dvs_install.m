% This is the install script for the Data Visualization Saliency Model

% Get current directory
pathroot = pwd;
%pathroot

% Add gbvs to path
gbvsPath = [pathroot filesep 'dvs_release_MASSVIS/dvs_release/gbvs'];
%gbvsPath
addpath(genpath(gbvsPath), '-begin');


% Add textSaliency to path
tsPath = [pathroot filesep 'dvs_release_MASSVIS/dvs_release/textSaliency'];
%tsPath
addpath(tsPath, '-begin');


% Add dvs to path

dvsPath = [pathroot filesep 'dvs_release_MASSVIS/dvs_release'];
%dvsPath
addpath(dvsPath, '-begin');




% Save new path, so we only have to run this script once
savepath

% Save mypath.mat to gbvs/util as pathroot variable name
pathroot = gbvsPath;
save -mat dvs_release_MASSVIS/dvs_release/gbvs/util/mypath.mat pathroot

%pwd

