%extract heat map from fixation points
function map=extractHeatMapFromFixations(im, fixations, params)
if nargin < 3
    params = struct(); 
end
if ~isfield(params,'sigma')
    params.sigma = 32; 
end % Gaussian sigma to blur fixations by

if ~isfield(params,'scaleFact')
    params.scaleFact = 1; 
end

map = makeMap(fixations,size(im,1),size(im,2),params);
map = map/max(map(:)); %-> non sono sicuro che ci voglia, ma lui plotta con questo
end