function [out,motionInfo] = gbvs(img,param,prevMotionInfo)
disp('GBVS');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                                     %                            
% This computes the GBVS (Graph-Based Visual Saliency) map for an image and puts it in master_map.    %
%                                                                                                     %
% If this image is part of a video sequence, motionInfo needs to be recycled in a                     %
% loop, and information from the previous frame/image will be used if                                 %
% "flicker" or "motion" channels are employed.                                                        %
% You need to initialize prevMotionInfo to [] for the first frame  (see demo/flicker_motion_demo.m)   %
%                                                                                                     %
%  input                                                                                              %
%    - img can be a filename, or image array (double or uint8, grayscale or rgb)                      %
%    - (optional) param contains parameters for the algorithm (see makeGBVSParams.m)                  %
%                                                                                                     %
%  output structure 'out'. fields:                                                                    %
%    - master_map is the GBVS map for img. (.._resized is the same size as img)                       %
%    - feat_maps contains the final individual feature maps, normalized                               %
%    - map_types contains a string description of each map in feat_map (resp. for each index)         %
%    - intermed_maps contains all the intermediate maps computed along the way (act. & norm.)         %
%      which are used to compute feat_maps, which is then combined into master_map                    %
%    - rawfeatmaps contains all the feature maps computed at the various scales                       %
%                                                                                                     %
%  Jonathan Harel, Last Revised Aug 2008. jonharel@gmail.com                                          %
%                                                                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ( ischar(img) == 1 ) 
    img = imread(img); 
end
%teoricamente l'immagine e' gia' double per quanto datto in dvs e quindi
%non dovrebbe entrare qui dentro
if ( strcmp(class(img),'uint8') == 1 ) 
    disp('GBVS -> Image uint8');
    img = double(img)/255; 
end
%check on image dimension
if ( (size(img,1) < 128) || (size(img,2) < 128) )
    fprintf(2,'GBVS Error: gbvs() meant to be used with images >= 128x128\n');
    out = [];
    return;
end
%we don't enter here
if ( (nargin == 1) || (~exist('param')) || isempty(param) ) 
    param = makeGBVSParams; 
end

%disp('press to continue');
%pause

%some constants used across different calls to gbvs()
%essendo che usiamo ITTI a noi il primo argomento rimane vuoto e ci
%modifichiamo solo gli altri parametri aggiungendo quelli di GABOR e
%modificando quello della mappa di salienza legandolo alla dimensione
%massima dell'immagine (che avevamo gia' fatto prima quindi sono modifiche
%inutili quelle sulla dimensione della mappa di salienza)
[grframe,param] = initGBVS(param,size(img));

%disp('end initGBVS. Press to continue');
%pause

if ( (nargin < 3) || (~exist('prevMotionInfo')) )
    disp('GBVS -> nargin<3 true');
    prevMotionInfo = [];
end

if ( param.useIttiKochInsteadOfGBVS )
    disp('GBVS -> param.useIttiKochInsteadOfGBVS=1');
    mymessage(param,'NOTE: Computing STANDARD Itti/Koch instead of Graph-Based Visual Saliency (GBVS)\n\n');
end

%disp('Press to continue to STEP 1');
%pause

%%%% 
%%%% STEP 1 : compute raw feature maps from image
%%%%
disp('GBVS -> COMPUTING RAW FEATURE MAPS');

mymessage(param,'computing feature maps...\n');

if ( size(img,3) == 3 ) 
    imgcolortype = 1; %unused value?
else
    imgcolortype = 2; %unused value?
end

%il warning e' solo per separare con virgole gli output
%motionInfo is useless, nel senso che non viene usato nel codice dopo
[rawfeatmaps motionInfo] = getFeatureMaps( img , param , prevMotionInfo );

%rawfeatmaps %struct with fields: intensity: [1×1 struct] labcolor: [1×1 struct] orientation: [1×1 struct]


%disp('rawfeatmaps.intensity');
%rawfeatmaps.intensity %struct with fields: info: [1×1 struct], description: 'intensity', maps: [1×1 struct]
%rawfeatmaps.intensity.info %struct with fields: weight: 1, numtypes: 1, descriptions: {'Intensity'}
%rawfeatmaps.intensity.maps.val %1×1 cell array {1×5 cell}
%hanno tutte la stessa dimensione per il resize che siamo andati a fare.
%La prima cella e' uno 0x0 double perche' quando scorriamo i livelli
%partiamo da 2 e quindi nella matrice lui alla prima posizione che non
%scorriamo assegna secondo me uno 0x0 di default
%rawfeatmaps.intensity.maps.val{1} %1×5 cell array {0×0 double}    {78×90 double}    {78×90 double}    {78×90 double}    {78×90 double}
%queste sotto derivano da quelle del sottocampionamento
%rawfeatmaps.intensity.maps.origval{1} %1×5 cell array {0×0 double}    {157×180 double}    {78×90 double}    {39×45 double}    {19×22 double}

%per le altre due caratteristiche le map sono delle matrici 

%disp('rawfeatmaps.labcolor');
%rawfeatmaps.labcolor
%disp('rawfeatmaps.orientation');
%rawfeatmaps.orientation

%disp('Press to continue to STEP 2');
%pause

%%%% 
%%%% STEP 2 : compute activation maps from feature maps
%%%%
disp('GBVS -> STEP2: COMPUTING ACTIVATION MAPS');

%fieldnames(S) returns the field names of the structure array S in a cell array.
%sono i nomi dei campi della struct rawfeatmaps e li mette in un array
%questi nomi
mapnames = fieldnames(rawfeatmaps);
%mapnames

%vettore che salva i pesi dei 3 campi nella struct rawfeatmaps
%si usano nello step 5
mapweights = zeros(1,length(mapnames));

%sono solo i nomi dei 3 campi della struct
map_types = {};

allmaps = {};
i = 0;
mymessage(param,'computing activation maps...\n');
for fmapi=1:length(mapnames)
    %estraggo uno alla volta i campi della struct rawfeatmaps che sono
    %intensity, labcolor e orientation nell'ordine rispettivamente
    mapsobj = eval( [ 'rawfeatmaps.' mapnames{fmapi} ';'] );
    
    numtypes = mapsobj.info.numtypes;
    mapweights(fmapi) = mapsobj.info.weight;
    map_types{fmapi} = mapsobj.description;
    
    for typei = 1 : numtypes
        %param.activationType == 2 per il nostro settaggio
        if ( param.activationType == 1 )
            disp('GBVS -> param.activationType == 1');
            for lev = param.levels                
                mymessage(param,'making a graph-based activation (%s) feature map.\n',mapnames{fmapi});
                i = i + 1;
                [allmaps{i}.map,tmp] = graphsalapply( mapsobj.maps.val{typei}{lev} , ...
                    grframe, param.sigma_frac_act , 1 , 2 , param.tol );
                allmaps{i}.maptype = [ fmapi typei lev ];
            end
        else %entriamo in questo else per i parametri che abbiamo inserito e perche' stiamo facendo ITTI
            %disp('GBVS -> param.activationType != 1');
            for centerLevel = param.ittiCenterLevels %ittiCenterLevels: [2 3]  valori di scala
                for deltaLevel = param.ittiDeltaLevels %ittiDeltaLevels: 2 valori del surround (che ci prende una delle mappe sottocampionate)
                    mymessage(param,'making a itti-style activation (%s) feature map using center-surround subtraction.\n',mapnames{fmapi});
                    
                    %inizializzato a zero prima del doppio for
                    i = i + 1;  
                    
                    %estraiamo la mappa estratta dal feature channel in getfeaturemaps prima del
                    %resize alla dimensione che vogliamo della saliency
                    center_ = mapsobj.maps.origval{typei}{centerLevel};
                    
                    %mapnames{fmapi}
                    %centerLevel
                    %deltaLevel
                    
                    %center_ e' un mega vettore con dimensioni che variano
                    %in base alle dimensioni dei vettori double che ci sono
                    %in maps.origval di  rawfeatmaps ed e' appunto la mappa
                    %estratta dal canale che avevamo salvato nel campo origval
                    %size(center_)
                    sz_ = size(center_);
                    
                    %imresize(I,scale) returns image J that is scale times the size of I. 
                    %The input image I can be a grayscale, RGB, binary, or categorical image.
                    %Andiamo ad ingrandire una delle mappe sottocampionate
                    %alla scala che stiamo percorrendo con la mappa
                    %estratta giusto qui sopra perche' poi si deve fare il
                    %confronto tra queste due per valutare le differenze
                    %che ci sono
                    surround_ = imresize( mapsobj.maps.origval{typei}{centerLevel+deltaLevel}, sz_ , 'bicubic' );  
                    
                    %facciamo la differenza tra l'immagine ad un
                    %determinato valore di scala e quella sottocampionata
                    allmaps{i}.map = (center_ - surround_).^2;
                    %i
                    %imshow(allmaps{i}.map)
                    %disp('press to continue')
                    %pause
                    %salviamo queste informazioni aggiuntive alla mappa che
                    %ci siamo andati a salvare
                    allmaps{i}.maptype = [ fmapi centerLevel deltaLevel ];
                end
            end
        end
    end
end

%allmaps e' %1×16 cell array con ciascuna posizione che e' una struct con i
%campi map che e' un vettore di double (di dimensioni variabile in base a quale
%resize dell'immagine stiamo affrontando) e maptype che e' un vettore con le
%informazioni del campo della struct rawfeatmaps (il numero di canale che stiamo 
%scorrendo), il centerlevel e il deltalevel.

%disp('Press to continue to STEP 3');
%pause

%%%% 
%%%% STEP 3 : normalize activation maps
%%%%
disp('GBVS -> STEP3: NORMALIZE ACTIVATION MAPS');
mymessage(param,'normalizing activation maps...\n');
%vettore di celle in cui mi salvo le mappe normalizzate che ha la stessa
%configurazione di allmaps con due campi in cui maptype resta lo stesso
norm_maps = {};

%scorro ognuna della 16 mappe che mi sono salvato in allmaps nello step 2
%precedente
for i=1:length(allmaps)
    mymessage(param,'normalizing a feature map (%d)... ', i);
    
    %per noi
    %param.normalizationType=3 perchè il parametro  useIttiKoch..=1
    if ( param.normalizationType == 1 )
        mymessage(param,' using fast raise to power scheme\n ', i);
        algtype = 4;
        [norm_maps{i}.map,tmp] = graphsalapply( allmaps{i}.map , grframe, param.sigma_frac_norm, param.num_norm_iters, algtype , param.tol );        
    elseif ( param.normalizationType == 2 )
        mymessage(param,' using graph-based scheme\n');
        algtype = 1;
        [norm_maps{i}.map,tmp] = graphsalapply( allmaps{i}.map , grframe, param.sigma_frac_norm, param.num_norm_iters, algtype , param.tol );                
    else %noi entriamo in questo else qui in base al parametro che abbiamo settato
        mymessage(param,' using global - mean local maxima scheme.\n');
        %Si richiama maxNormalizeStdGBVS.m in cui si usa la 
        %maxNormalizeStd - normalization based on local maxima.
        %    Normalize data by multiplying it with 
        %    (max(data) - avg(localMaxima))^2 as described in;
        %    L. Itti, C. Koch, E. Niebur, A Model of Saliency-Based 
        
        %mat2gray(A,[amin amax]) converts the matrix A to a grayscale image I 
        %that contains values in the range 0 (black) to 1 (white). amin and 
        %amax are the values in A that correspond to 0 and 1 in I. Values 
        %less than amin are clipped to 0, and values greater than amax are 
        %clipped to 1. Quelli intermedi sono lasciati cosi'.
        
        %mat2gray(A) sets the values of amin and amax to the minimum and 
        %maximum values in A. Pixels show a range of grayscale colors, which 
        %makes the location of the edges more apparent.
        norm_maps{i}.map = maxNormalizeStdGBVS( mat2gray(imresize(allmaps{i}.map,param.salmapsize, 'bicubic')) );
        %imshow(norm_maps{i}.map)
        %i
        %disp('press to continue')
        %pause
    end
    norm_maps{i}.maptype = allmaps{i}.maptype;
end

%disp('Press to continue to STEP 4');
%pause

%%%% 
%%%% STEP 4 : average across maps within each feature channel
%%%%
disp('GBVS -> STEP4: AVERAGE ACROSS MAPS WITHIN EACH FEATURE CHANNEL');

%combiniamo mappe diverse sullo stesso campo di struct di rawfeatmaps
%vettore di celle in cui ci salviamo le combinazioni tra le varie mappe
%la combinazione la effettuiamo tra le mappe normalizzate
comb_norm_maps = {};

%vettore dei campi della struct che compone rawfeatmaps
cmaps = {};

for i=1:length(mapnames) 
    cmaps{i}=0; 
end

%contiene il numero di mappe associate a questo campo della struct di rawfeatmaps
%per avere la combinazione divisa poi per il numero di mappe associate ad
%un dato campo
Nfmap = cmaps;

mymessage(param,'summing across maps within each feature channel.\n');
%scorro tutte le 16 mappe normalizzate calcolate allo step precedente
for j=1:length(norm_maps)
      %salviamo temporaneamente la mappa
      map = norm_maps{j}.map;
      
      %ricordiamo che  maptype e' un vettore con le informazioni del campo della 
      %struct rawfeatmaps, il centerlevel e il deltalevel.
      %Ricordiamo che i campi della struct rawfeatmaps sono
      %intensity, labcolor e orientation
      fmapi = norm_maps{j}.maptype(1);
      %fmapi
      %aggiorniamo il numero di mappe che abbiamo legato a quel canale che
      %e' campo di struct di rawfeatmaps
      Nfmap{fmapi} = Nfmap{fmapi} + 1;
      
      %combiniamo mappe diverse associate allo stesso campo di struct di rawfeatmaps
      cmaps{fmapi} = cmaps{fmapi} + map;
end

%%% divide each feature channel by number of maps in that channel

%scorriamo i campi della struct di rawfeatmaps che per tipo la prima
%immagine in samplepics

%disp('GBVS -> Nfmap');
%Nfmap %1×3 cell array {[2]}    {[6]}    {[8]}

%scorriamo sui 3 canali
for fmapi = 1 : length(mapnames)
  if ( param.normalizeTopChannelMaps) %lo abbiamo settato ad 1
      mymessage(param,'Performing additional top-level feature map normalization.\n');
      %per noi param.normalizationType==3
      if ( param.normalizationType == 1 ) 
          algtype = 4;
          [cmaps{fmapi},tmp] = graphsalapply( cmaps{fmapi} , grframe, param.sigma_frac_norm, param.num_norm_iters, algtype , param.tol );
      elseif ( param.normalizationType == 2 )
          algtype = 1;
          [cmaps{fmapi},tmp] = graphsalapply( cmaps{fmapi} , grframe, param.sigma_frac_norm, param.num_norm_iters, algtype , param.tol );
      else %entra qui per le prime immagini di samplepics che abbiamo
          %richiamiamo lo script in cui 
          % maxNormalizeStd - normalization based on local maxima.
          %richiamiamo lo stesso script di normalizzazione gia' usato prima
          %che tanto riceve sempre un solo argomento in ingresso da
          %trattare
        cmaps{fmapi} = maxNormalizeStdGBVS( cmaps{fmapi} );
      end
  end
  comb_norm_maps{fmapi} = cmaps{fmapi};
end

%disp('Press to continue to STEP 5');
%pause

%%%% 
%%%% STEP 5 : sum across feature channels
%%%%
disp('GBVS -> STEP5: SUM ACROSS FEATURE CHANNELS');

mymessage(param,'summing across feature channels into master saliency map.\n');

%aggiungiamo una mappa in piu' che sara' la mastermap a quelle della combinazione normalizzata per
%raggruppare tutte quelle precedenti con una somma opportunamente pesata
master_idx = length(mapnames) + 1;

%disp('GBVS -> master_idx');
%master_idx %4 correttamente perche' inizialmente 3 erano i canali
%utilizzati nei campi della struct che compongono la rawfeatmaps

%i mapweights sono stati inizializzati nello step 2 estraendoli dalle varie
%informazioni che avevamo a disposizione dalle feature map
%disp('GBVS -> mapweights');
%mapweights %1     1     1  -> ed erano quelli che aveamo estratto inizialmente
%dalle informazioni

comb_norm_maps{master_idx} = 0;
for fmapi = 1 : length(mapnames)
  mymessage(param,'adding in %s map with weight %0.3g (max = %0.3g)\n', map_types{fmapi}, mapweights(fmapi) , max( cmaps{fmapi}(:) ) );
  comb_norm_maps{master_idx} = comb_norm_maps{master_idx} + cmaps{fmapi} * mapweights(fmapi);
end

master_map = comb_norm_maps{master_idx};

%richiamiamo uno script
% attentuateBorders - linearly attentuates the border of data.
% result = attenuateBorders(data,borderSize)
%   linearly attenuates a border region of borderSize
%   on all sides of the 2d data array

%imshow(master_map)
%disp('Press to continue');
%pause
%image(master_map)
%disp('Press to continue');
%pause
master_map = attenuateBordersGBVS(master_map,4);
%imshow(master_map)
%disp('Press to continue');
%pause
%image(master_map)
%disp('Press to continue');
%pause
%Convert matrix to grayscale image che ho gia' riportato da qualche altra
%parte
master_map = mat2gray(master_map);
%imshow(master_map)
%disp('Press to continue');
%pause
%image(master_map)


%disp('Press to continue to STEP 6');
%pause

%%%%
%%%% STEP 6: blur for better results
%%%%
disp('GBVS -> STEP6: BLUR FOR BETTER RESULTS');

%dal settaggio dei parametri avevamo questa descrizione
% final blur to apply to master saliency map
% (in standard deviations of gaussian kernel,
%  expressed as fraction of image width)
% Note: use value 0 to turn off this feature.
blurfrac = param.blurfrac; %blurfrac: 0.0200

if ( param.useIttiKochInsteadOfGBVS )
    % apply final blur to master saliency map
    % (not in original Itti/Koch algo. but improves eye-movement predictions)
  blurfrac = param.ittiblurfrac; %ittiblurfrac: 0.0300
end

%se il parametro e' zero la caratteristica blur e' come se non venisse in
%pratica utilizzata
if ( blurfrac > 0 )
  mymessage(param,'applying final blur with with = %0.3g\n', blurfrac);
  
  %script che restituisce un vettore normalizzato estratto da una
  %distribuzione normale dove il primo argomento e' la deviazione standard
  %che associamo
  k = mygausskernel( max(size(master_map)) * blurfrac , 2 );
  
  %penso vada ad eseguire una convoluzione
  master_map = myconv2(myconv2( master_map , k ),k');
  %converte in grayscale come gia' trattato e forse inutile perche' gia'
  %fatto qualche passaggio sopra
  master_map = mat2gray(master_map);
end

%nelle prime immagini qui e' zero unCenterBias quindi non entriamo qui
if ( param.unCenterBias )  
  invCB = load('invCenterBias');
  invCB = invCB.invCenterBias;
  centerNewWeight = 0.5;
  invCB = centerNewWeight + (1-centerNewWeight) * invCB;
  invCB = imresize( invCB , size( master_map ) );
  master_map = master_map .* invCB;
  master_map = mat2gray(master_map);
else
    disp('GBVS->STEP 6->unCenterBias=0')
end

%%%% 
%%%% save descriptive, rescaled (0-255) output for user
%%%%

feat_maps = {};

for i = 1 : length(mapnames)
  feat_maps{i} = mat2gray(comb_norm_maps{i});
end

intermed_maps = {};

%sovrascriviamo in grayscale
for i = 1 : length(allmaps)
 allmaps{i}.map = mat2gray( allmaps{i}.map );
 norm_maps{i}.map = mat2gray( norm_maps{i}.map );
end

intermed_maps.featureActivationMaps = allmaps;
intermed_maps.normalizedActivationMaps = norm_maps;

%riscaliamo la mappa alle dimensioni dell'immagine originale a cui poi
%dobbiamo sovrapporre
master_map_resized = mat2gray(imresize(master_map,[size(img,1) size(img,2)]));

%size(master_map_resized) %630   720
%salviamo i dati che ci servono in output che e' la variabile che
%restituiamo indietro
out = {};
out.master_map = master_map;
out.master_map_resized = master_map_resized;
out.top_level_feat_maps = feat_maps; %sono quelle dei 3 canali principali combinate e normalizzate
out.map_types = map_types;
out.intermed_maps = intermed_maps; %sono tutte le mappe intermedie e quelle normalizzate
out.rawfeatmaps = rawfeatmaps; %sono le mappe dei 3 canali principali originali estratte
out.paramsUsed = param; %ci saliamo la configurazione sotto cui abbiamo operato

if ( param.saveInputImage ) %0 in quanto comunque l'immagine iniziale e' globale quindi la tiriamo fuori da li'
    out.inputimg = img;
end
