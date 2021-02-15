%
% some constants used across different calls to gbvs()
%

function [grframe,param] = initGBVS(param, imgsize)
disp('initGBVS');
mymessage(param,'initializing....\n');

% logical consistency checking of parameters
if ( min(param.levels) < 2 )
    mymessage(param,'oops. cannot use level 1.. trimming levels used\n');
    param.levels = param.levels(param.levels>1);
end

if ( param.useIttiKochInsteadOfGBVS )
    param.activationType = 2;
    param.normalizationType = 3;
    param.normalizeTopChannelMaps = 1;
end

param.maxcomputelevel = max(param.levels);
if (param.activationType==2)
    param.maxcomputelevel = max( param.maxcomputelevel , max(param.ittiCenterLevels)+max(param.ittiDeltaLevels) );
end

w = imgsize(2); 
h = imgsize(1); 
%di quanto dobbiamo ridurre in scala per avere la saliency map in uscita
%lungo la dimensione massima
scale = param.salmapmaxsize / max(w,h);
%dimensioni a cui vogliamo arrivare per la mappa di salienza in uscita
%Y = round(X) rounds each element of X to the nearest integer. In the case 
%of a tie, where an element has a fractional part of exactly 0.5, the round 
%function rounds away from zero to the integer with larger magnitude.
salmapsize = round( [ h w ] * scale );

% weight matrix
%non entriamo qui perche' usiamo ITTI
if ( ~param.useIttiKochInsteadOfGBVS )
    disp('initGBVS -> param.useIttiKochInsteadOfGBVS=0');
  load mypath;
  %s = num2str(A) converts a numeric array into a character array that represents 
  %the numbers
  %str = sprintf(formatSpec,A1,...,An) formats the data in arrays A1,...,An 
  %using the formatting operators specified by formatSpec and returns the resulting text in str.
  ufile = sprintf('%s__m%s__%s.mat',num2str(salmapsize),num2str(param.multilevels),num2str(param.cyclic_type));
  ufile(ufile==' ') = '_';
  %f = fullfile(filepart1,...,filepartN) builds a full file specification 
  %from the specified folder and file names
  pathroot
  ufile
  ufile = fullfile( pathroot , 'initcache' ,  ufile );
  if ( exist(ufile) )
      %load(filename) loads data from filename
      disp('initGBVS exist ufile -> grframe = load(ufile) ');
    grframe = load(ufile);
    grframe = grframe.grframe;
  else
      disp('initGBVS not exist ufile -> grframe = graphsalinit ');
      %graphsalinit.m
    grframe = graphsalinit( salmapsize , param.multilevels , 2, 2, param.cyclic_type );
    save(ufile,'grframe');
  end
else
  disp('initGBVS -> param.useIttiKochInsteadOfGBVS=1');
  grframe = [];
end


% gabor filters CREATION
gaborParams.stddev = 2;
gaborParams.elongation = 2;
gaborParams.filterSize = -1;
gaborParams.filterPeriod = pi;
for i = 1 : length(param.gaborangles)
    theta = param.gaborangles(i);
    %makeGaborFilterGBVS.m
    gaborFilters{i}.g0 = makeGaborFilterGBVS(gaborParams, theta, 0);
    gaborFilters{i}.g90 = makeGaborFilterGBVS(gaborParams, theta, 90);
end

param.gaborParams = gaborParams;
param.gaborFilters = gaborFilters;
param.salmapsize = salmapsize;
param.origimgsize = imgsize;
disp('param after initGBVS');
param
