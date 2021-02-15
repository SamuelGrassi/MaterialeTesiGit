function out = ittikochmap( img, channels )
disp('ittikochmap');
params = makeGBVSParams;
%it is a struct
disp('ittikochmap->parameters ');
params

%disp('press to continue ');
%pause 

params.useIttiKochInsteadOfGBVS = 1;

%we check the Number of function input arguments
if nargin == 1
    disp('NARGIN 1');
    params.channels = 'LIO';
elseif nargin == 2
    disp('NARGIN 2');
    params.channels = channels;
end
%the same as we set in makeGBVSParams.m
params.verbose = 0; %quello dei messaggi su schermo o su file
params.unCenterBias = 0;

%
% uncomment the line below (ittiDeltaLevels = [2 3]) for more faithful implementation 
% (however, known to give crappy results for small images i.e. < 640 in height or width )
%
% params.ittiDeltaLevels = [ 2 3 ];
%

%the same distinction as in dvs.m
if ( ischar(img) == 1 ) 
    disp('Image char');
    img = imread(img); 
end
%teoricamente l'immagine e' gia' double per quanto datto in dvs e quindi
%non dovrebbe entrare qui dentro
if ( strcmp(class(img),'uint8') == 1 ) 
    disp('ittikochmap -> Image uint8');
    img = double(img)/255; 
end

params.salmapmaxsize = round( max(size(img))/8 );
disp('ittikochmap -> params after modification:');
%params.salmapmaxsize
params

%disp('press to continue and pass to GBVS');
%pause
%we call gbvs.m
out = gbvs(img,params);
