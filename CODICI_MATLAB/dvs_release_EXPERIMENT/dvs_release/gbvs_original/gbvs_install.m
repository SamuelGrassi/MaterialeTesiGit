
pathroot = pwd;
save -mat dvs_release/gbvs_original/util/mypath.mat pathroot
addpath(genpath( pathroot ), '-begin');
savepath