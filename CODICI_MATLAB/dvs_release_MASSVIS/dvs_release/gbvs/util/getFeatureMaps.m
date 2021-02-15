function [rawfeatmaps, motionInfo] = getFeatureMaps( img , param , prevMotionInfo )
disp('getFeatureMaps');
param
%
% this computes feature maps for each cannnel in featureChannels/
%

load mypath;

%%%%
%%%% STEP 1 : form image pyramid and prune levels if pyramid levels get too small.
%%%%

mymessage(param,'forming image pyramid\n');

levels = [2 : param.maxcomputelevel];
%estraggo terza componente della dimensione dell'immagine e verifico che
%sia 3, cioe' che l'immagine sia colorata
is_color = (size(img,3) == 3); %true
%scompongo nei 3 colori
imgr = []; 
imgg = []; 
imgb = [];
if ( is_color ) 
    disp('getFeatureMaps->is_color');
    %estraggo i 3 piani di colore
    %function [r,g,b,ii] = mygetrgb( img )
     %r = img(:,:,1); %-> size(img(:,:,1)) ans = 630   720
     %g = img(:,:,2);
     %b = img(:,:,3);
     %tanto il massimo e' associativo come operatore
     %credo che tenga il massimo confrontando componente per componente
     %quindi ii contiene una matrice 630x720 di componenti massime
     %ii = max(max(r,g),b);
     %imgi e' quindi un'immagine di componenti massime tra i 3 canali
    [imgr,imgg,imgb,imgi] = mygetrgb( img );
else
    imgi = img; 
end

%le parentesi graffe fanno riferimento a celle nel vettore
imgL = {};

%C++ in cui penso faccia un semplice sottocampionamento per ridurre la
%dimensione delle matrici in argomento dato che la mappa di salienza che
%otteniamo in uscita e' più piccola.
%L'indice 1 sta facendo riferimento al fatto che e' il primo
%sottocampionamento che viene eseguito.
imgL{1} = mySubsample(imgi);
%size(imgL{1}) %315   360 -> il sottocampionamento avviene secondo la meta'
imgR{1} = mySubsample(imgr); 
imgG{1} = mySubsample(imgg); 
imgB{1} = mySubsample(imgb);

%levels = [2 : param.maxcomputelevel];
%come dice inizialmente il codice, qui andiamo a spezzare l'immagine in
%varie piramidine sempre più piccole e quindi si tratta di continuare a
%sottocampionare di fatto
for i=levels
    imgL{i} = mySubsample( imgL{i-1} );
    if ( is_color )
        imgR{i} = mySubsample( imgR{i-1} );
        imgG{i} = mySubsample( imgG{i-1} );
        imgB{i} = mySubsample( imgB{i-1} );
    else
        %se non sono nel caso colorato non ho la scomposizione nei vari
        %canali
        disp('NOT COLORED')
        imgR{i} = []; 
        imgG{i} = []; 
        imgB{i} = [];
    end
    %il warning dice solo che si potrebbe rimpiazzare | con ||
    if ( (size(imgL{i},1) < 3) | (size(imgL{i},2) < 3 ) )
        mymessage(param,'reached minimum size at level = %d. cutting off additional levels\n', i);
        %aggiorno levels a quanti strati ho effettivamente calcolato e
        %generato perche' serve dopo
        levels = [ 2 : i ];
        param.maxcomputelevel = i;
        break;
    end

end

%%% update previous frame estimate based on new frame
%flickerNewFrameWt->This parameter is the weight used to update the previous frame estimate.
%in our case prevMotionInfo is empty
%param.flickerNewFrameWt == 1 per noi e quindi entriamo sempre nella prima
%parte dell'if
if ( (param.flickerNewFrameWt == 1) || (isempty(prevMotionInfo) ) )
    disp('getFeatureMaps -> (param.flickerNewFrameWt == 1) || (isempty(prevMotionInfo) =true ');
    %motionInfo-> output variable of the function (useless)
    motionInfo.imgL = imgL;
else    
    w = param.flickerNewFrameWt;    
    for i = levels
        %%% new frame gets weight flickerNewFrameWt
        motionInfo.imgL =  w * imgL{i} + ( 1 - w ) * prevMotionInfo.imgL{i};
    end
end
    
%%%
%%% STEP 2 : compute feature maps
%%%

mymessage(param,'computing feature maps...\n');
disp('getFeatureMaps -> computing feature maps');
%inizializing vector
rawfeatmaps = {};

%%% get channel functions in featureChannels/directory
%disp('getFeatureMaps -> pathroot');
%pathroot %'/Users/samuel/Documents/MATLAB/dvs_release/gbvs'
%dir-> lists files and folders in the current folder.
channel_files = dir( [pathroot '/util/featureChannels/*.m'] );
%disp('getFeatureMaps -> channel_files ');
%channel_files %8×1 struct array with fields: name, folder, date, bytes, isdir, datenum

motionInfo.imgShifts = {};

for ci = 1 : length(channel_files)
    %%% parse the channel letter and name from filename
    %regexp(str,expression) returns the starting index of each substring of 
    %str that matches the character patterns specified by the regular expression. 
    %If there are no matches, startIndex is an empty array.
    
    %regexp(str,expression,outkey) returns the output specified by outkey. 
    %For example, if outkey is 'match', then regexp returns the substrings 
    %that match the expression rather than their starting indices.
    
    %Per come e' fatta la expression che secondo me crea la struttura di
    %due campi: un campo di letter e un campo di rest perche' diciamo che
    %andiamo a specificare nell'expression come si presenta il nome nella
    %cartella degli script di feature channels
    parts = regexp( channel_files(ci).name , '^(?<letter>\w)_(?<rest>.*?)\.m$' , 'names');
    %parts %in the last iteration->struct with fields: letter: 'R' rest: 'contrast'

    %continue passes control to the next iteration of a for or while loop.
    if ( isempty(parts) )
        disp('invalid channel file name');
        continue; 
    end 
    
    channelLetter = parts.letter;
    channelName = parts.rest;
    
    %creiamo la funzione associata al canale a cui corrisponde lo script
    %nella cartella in cui ci siamo attualmente posizionati che una volta
    %richiamata e' una delle funzioni presenti nella cartella
    %featureChannels
    channelfunc = str2func(sprintf('%s_%s',channelLetter,channelName));
    
    %uso solo gli script associati ai canali che ho messo nei parametri
    %useChannel se channelLetter trova almeno una corrispondenza in quello
    %che abbiamo messo nei parametri dei canali in param
    useChannel = sum(param.channels==channelLetter) > 0;

    %la prima condizione di if e' un problema perche' ci entra quando non
    %e' colorata e quindi non ha senso andare ad estrarre caratteristiche
    %di colore per un'immmagine non colorata
    if ( ((channelLetter == 'C') || (channelLetter=='D') || (channelLetter=='L')) && useChannel && (~is_color) )
        mymessage(param,'oops! cannot compute color channel on black and white image. skipping this channel\n');
        continue;
    elseif (useChannel) 
        disp('getFeatureMaps -> computing feature maps effectively for channel');
        %intensity, labcolor, orientation e' l'ordine in cui i canali
        %vengono analizzati
        channelName
        
        %disp('presso to continue and calculate the script');
        %pause
        
        mymessage(param,'computing feature maps of type "%s" ... \n', channelName);

        obj = {};
        %channelfunc e' il riferimento allo script che ci siamo creati
        %sopra e che quindi ci richiama il corretto script per estrarre le
        %caratteristiche che ci servono
        obj.info = channelfunc(param);
        obj.description = channelName;

        obj.maps = {};
        obj.maps.val = {};

        %%% call the channelfunc() for each desired image resolution (level in pyramid)
        %%%  and for each type index for this channel.
        %vedendo gli script delle feature channels dovrebbero essere 3 i
        %numtypes in base al richiamo delle channelfunc() con un solo
        %argomento per L, 1 per I, per 0 e' il numero di filtri di gabor
        %che stiamo utilizzando
        for ti = 1 : obj.info.numtypes            
            obj.maps.val{ti} = {};
            mymessage(param,'..pyramid levels: ');
            
            %levels sono i livelli di mappe piramidi che abbiamo
            %effettivamente creato sopra e che ci siamo salvati ad inizio
            %dello script
            for lev = levels                
                mymessage(param,'%d (%d x %d)', lev, size(imgL{lev},1), size(imgL{lev},2));
                
                %entriamo sempre nell'else di questo if
                if ( (channelLetter == 'F') || (channelLetter == 'M') ) 
                    disp('getFeatureMaps -> (channelLetter == F) || (channelLetter == M) =true ');
                    if ( ~isempty(prevMotionInfo) )
                        prev_img = prevMotionInfo.imgL{lev};
                    else
                        prev_img = imgL{lev};
                    end
                    
                    if ( ~isempty(prevMotionInfo) && isfield(prevMotionInfo,'imgShifts') && (channelLetter == 'M') )
                      prev_img_shift = prevMotionInfo.imgShifts{ti}{lev};
                    else
                      prev_img_shift = 0;
                    end

                    map = channelfunc(param,imgL{lev},prev_img,prev_img_shift,ti);                    
                    if (isfield(map,'imgShift'))
                       motionInfo.imgShifts{ti}{lev} = map.imgShift; 
                    end                    
                else
                    %disp('getFeatureMaps -> (channelLetter == F) || (channelLetter == M) =false ');
                    
                    %uso le chiamate degli script delle feature channel con
                    %piu' di un argomento
                    map = channelfunc(param,imgL{lev},imgR{lev},imgG{lev},imgB{lev},ti);
                end 
                
                obj.maps.origval{ti}{lev} = map.map;
                
                %imresize(A,scale) returns image B that is scale times the size of A.
                %If scale is in the range [0, 1], B is smaller than A. If scale is 
                %greater than 1, B is larger than A. By default, imresize uses bicubic interpolation.
                %Bicubic interpolation: the output pixel value is a weighted average 
                %of pixels in the nearest 4-by-4 neighborhood
                map = imresize( map.map , param.salmapsize , 'bicubic' );
                %sempre 79 90 perche' nella riga qui sopra facciamo un
                %resize e quindi alla fine giungono tutte alla stessa
                %dimensione
                %size(map)
                
                %imshow(map)
                %disp('presso to continue');
                %pause
                
                obj.maps.val{ti}{lev} = map;
            end
            mymessage(param,'\n');
        end

        %%% save output to rawfeatmaps structure (per il canale che abbiamo
        %%% analizzato)
        %eval(expression) returns the outputs from expression in the specified variables.
        eval( sprintf('rawfeatmaps.%s = obj;', channelName) );

    end
end

