function [ S ] = textSaliency( img_in )
disp('TEXT SALIENCY')
%TEXTSALIENCY Summary of this function goes here
% main function that computes the 'saliency' or probability that there is
% text at a specific location of the input image

% 'img_in': input image array
% 'S': output map of the same size as input image

% Marshall Wang 06/21/16


%   Detailed explanation goes here

%vettore di vari fattori di scala da 0.4 a 1.4
scales = 0.4:0.2:1.4;

imgsize = size(img_in);
%imgsize %630   720     3

%ci creiamo una matrice di zeri grossa come l'immagine di partenza vista
%sul piano ed e' la matrice che facciamo ritornare indietro da questa
%funzione
S = zeros(imgsize(1),imgsize(2));

%tanti commenti che ho messo nel ciclo di dimensioni ecc sono relativi al
%primo ciclo, cioe' con il primo valore di scala
for scale = scales  % loop through each scale
    %cambio scala all'immagine
    disp('TEXT SALIENCY->scale')
    
    %0.4000
    %0.6000
    %0.8000
    %1.0000
    %1.2000
    %1.4000
    scale 
    
    scaledimg = imresize(img_in, scale);
    
    %figure
    %imshow(scaledimg)
    %pause
    
    %disp('TEXT SALIENCY->resized image')
    %252   288     3
    %379   433     3
    %630   720     3
    %504   576     3
    %756   864     3
    %size(scaledimg)
    
    dim_img = size(scaledimg);
    
    %se entriamo nella prima condizione di if significa che siamo con un
    %immagine con 3 canali di colori RGB.
    %se entriamo nella seconda condizione allora non abbiamo i 3 canali di
    %colore e quindi l'immagine e' gia' in scala di grigi
    if (length(dim_img) == 3 && dim_img(3) == 3)
        %rgb2gray(RGB) converts the truecolor image RGB to the grayscale image I. 
        %The rgb2gray function converts RGB images to grayscale by eliminating 
        %the hue and saturation information while retaining the luminance.
        grayimg = rgb2gray(scaledimg);
    elseif (length(dim_img) == 2)
        grayimg = scaledimg;
    end
    
    %estraiamo l'altezza e lo spessore dell'immagine
    H = dim_img(1);
    W = dim_img(2);
    
    %[regions,cc] = detectMSERFeatures(I)optionally returns MSER regions in a connected component structure.
    %detectMSERFeatures(I) returns an MSERRegions object, regions, containing 
    %information about MSER features detected in the 2-D grayscale input image, I. 
    %This object uses Maximally Stable Extremal Regions (MSER) algorithm to find regions.
    %An MSERRegion is an Object for storing MSER regions. This object describes MSER regions and corresponding 
    %ellipses that have the same second moments as the regions. The object can also be 
    %used to manipulate and plot the data returned by these functions.
    %MSER is a method for blob detection in images. The MSER algorithm extracts from an image 
    %a number of co-variant regions, called MSERs: an MSER is a stable connected component of 
    %some gray-level sets of the image. MSER is based on the idea of taking regions which 
    %stay nearly the same through a wide range of thresholds. 
    %
    %Maximally stable extremal regions (in sigla: MSER), in italiano: Regioni estremali stabili 
    %massimamente è un metodo usato per il riconoscimento di regioni all'interno di immagini. 
    %Fu proposta da Matas et al. per trovare corrispondenze tra elementi di immagini da due 
    %immagini con due differenti punti di vista. Questo metodo di estrarre un numero comprensivo
    %di elementi di immagini corrispondenti ha condotto a un migliore matching e migliori 
    %algoritmi di riconoscimento di oggetti.
    %
    %In computer vision, blob detection methods are aimed at detecting regions in a digital 
    %image that differ in properties, such as brightness or color, compared to surrounding regions. 
    %Informally, a blob is a region of an image in which some properties are constant or 
    %approximately constant; all the points in a blob can be considered in some sense to be 
    %similar to each other. The most common method for blob detection is convolution.
    %Multi-scale serve per avere diversi livelli di dettaglio
    [Regions, conComp] = detectMSERFeatures(grayimg, 'RegionAreaRange', round([20, 8000]*scale), 'ThresholdDelta', 1);
    
    %disp('TEXT SALIENCY->Regions')
    %2510×1 MSERRegions array with properties:
    %      Count: 2510
    %   Location: [2510×2 single]
    %       Axes: [2510×2 single]
    %Orientation: [2510×1 single]
    %  PixelList: {2510×1 cell}
    %Regions 
    
    %disp('TEXT SALIENCY->conComp')
    %struct with fields:
    %Connectivity: 8
    %   ImageSize: [252 288]
    %  NumObjects: 2510
    %PixelIdxList: {1×2510 cell}
    %conComp
    %plot(Regions)
    
    %regionprops(CC,properties) measures a set of properties for each connected component (object) in CC
    %e mette il risultato in una struct.
    %Per il BoundingBox -> The first elements are the coordinates of the minimum corner of the box. 
    %The second Q elements are the size of the box along each dimension.
    %Per la Image -> the same size as the bounding box of the region, returned as a binary (logical) array. 
    %The on pixels correspond to the region, and all other pixels are off.
    mserStats = regionprops(conComp, 'BoundingBox', 'Eccentricity', 'Solidity', 'Extent', 'Euler', 'Image');
    
    %disp('TEXT SALIENCY->mserStats')
    %2510×1 struct array with fields:
    %BoundingBox -> contiene double a righe di 4
    %Eccentricity -> contiene double a righe di 1
    %Image -> contiene degli array booleani
    %EulerNumber->
    %Solidity->
    %Extent->
    %mserStats
   
    %pause
    
    %vertcat -> Concatenate arrays vertically
    %ci creiamo quindi un unico array che contenga tutti i box insieme,
    %cioe' un' unica grande matrice che abbia tutti i box salvati al suo
    %interno, uno per riga
    bbox = vertcat(mserStats.BoundingBox);
    %disp('TEXT SALIENCY->bbox')
    %    1.5000    1.5000    3.0000    3.0000
    %10.5000    5.5000    3.0000    4.0000
    %21.5000    1.5000    5.0000    6.0000
    %49.5000    1.5000    6.0000    2.0000
    %35.5000    1.5000   21.0000   13.0000
    %bbox %e' un matricione con 4 colonne
    %size(bbox) %2510           4
    %pause
    
    if isempty(bbox)
        disp('TEXT SALIENCY->bbox empty')
        continue;
    end
    
    %disp('TEXT SALIENCY->bbox not empty')
    
    %estraggo informazioni relative ad altezza e larghezza di ogni boundary
    %box
    w = bbox(:,3);
    h = bbox(:,4);
    
    %rapporto tra le dimensioni dei boundary box
    aspectRatio = w./h;
    %size(aspectRatio) %2510           1 -> vettore perche' ho un rapporto
    %per ogni box
    
    filterIdx = [];
    %filterIdx diventa un vettore di zeri e uni in cui 1 se aspectRatio in
    %quella posizione e' piu' grande di 3, altrimenti diventa zero
    filterIdx = aspectRatio' > 3;
    
    %size(filterIdx) %1        2510 perche' ho avuto la trasposizione
    
    %condizioni di or logiche in cui mi serve per avere le posizioni degli
    %indici in cui devo andare a filtrare
    filterIdx = filterIdx | [mserStats.Eccentricity] > .995 ;
    filterIdx = filterIdx | [mserStats.Solidity] < .3;
    filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
    filterIdx = filterIdx | [mserStats.EulerNumber] < -4;
    
    %size(filterIdx) %%1        2510
    
    mserStats(filterIdx) = []; %solo dove filterIdx e' 1 metto il vuoto perche' sono le parti da escludere
    %e non solo vengono messi a vuoti, ma sono proprio indici che vengono
    %eliminati dalla struttura.
    %mserStats qui sopra era struct di dimensione 2510×1 with fields:
    %BoundingBox -> contiene double a righe di 4
    %Eccentricity -> contiene double a righe di 1
    %Image -> contiene degli array booleani che costituiscono l'immagine
    %EulerNumber
    %Solidity
    %Extent
    %a cui in pratica tolgo quelli filtrati
    
    Regions(filterIdx) = [];
    %Regions era anche lui una struct
    
    %sum(filterIdx==1) %256 sono gli uni
    %sinceramente mi sarei aspettato che sarebbero state conservate solo le
    %posizioni con gli uni e non quelle con gli zeri, praticamente quelli
    %che hanno filterIdx 1  sono quelli che vengono esclusi. Oppure forse
    %prende correttamente quelle ad 1 e le mette a vettori vuoti
    %escludendoli quindi -> fa esattamente come l'ultima frase che ho
    %detto.
    
    %size(mserStats) %2254(=2510-256)           1
    %size(Regions) %2254           1
    
    strokeWidthThreshold = 0.3;
    strokeWidthFilterIdx = [];
    
    %i commenti sono relativi al primo ciclo. In cicli dopo, le dimensioni
    %potrebbero anche variare
    for j = 1:numel(mserStats)
        %estraiamo la parte di immagine relativa alla regione che stiamo
        %scorrendo adesso in questo ciclo
        regionImage = mserStats(j).Image;
        
        %size(regionImage) %3     3 (la dimensione e' quella del bounding
        %box relativo)
        
        %padarray(A,padsize) pads array A with an amount of padding in each dimension 
        %specified by padsize. The padarray function pads numeric or logical images 
        %with the value 0 and categorical images with the category <undefined>. 
        %By default, paddarray adds padding before the first element and after 
        %the last element of each dimension.
        %padarray(A,padsize,padval) pads array A where padval specifies a constant
        %value to use for padded elements or a method to replicate array elements
        regionImage = padarray(regionImage, [1 1], 0);
        
        %regionImage %5×5 logical array
        %size(regionImage) %5     5 in quanto abbiamo fatto un padding all'inizio e alla fine 
        %in ognuna delle due dimensioni. Il padding che e' stato fatto e' stata
        %l'aggiunta di zeri.
        
        %pause

        %bwdist(BW) computes the Euclidean distance transform of the binary image BW. 
        %For each pixel in BW, the distance transform assigns a number that is the 
        %distance between that pixel and the nearest nonzero pixel of BW
        distanceImage = bwdist(~regionImage);
        
        %distanceImage %5×5 single matrix
        
        %questo comando sotto fa parte delle Morphological operations on binary
        %images.
        %
        %bwmorph(BW,operation) applies a specific morphological operation to the 
        %binary image BW. 
        %bwmorph(BW,operation,n) applies the operation n times. 
        %n can be Inf, in which case the operation is repeated until the image no longer changes.
        %
        %L'opzione 'thin' con with n = Inf, thins (assottiglia) objects to lines. It removes pixels so that an object 
        %without holes shrinks to a minimally connected stroke (tratto), and an object with 
        %holes shrinks(restringersi) to a connected ring halfway between each hole and the outer 
        %boundary. This option preserves the Euler number.
        skeletonImage = bwmorph(regionImage, 'thin', inf);
        %skeletonImage %5×5 logical array

        %con il comando qui sotto conserviamo della matrice distanceImage solo
        %le posizioni corrispondenti ad un 1 in skeletonImage e mettiamo i
        %valori in un vettore colonna
        strokeWidthValues = distanceImage(skeletonImage);
        %strokeWidthValues %2×1 single column vector

        %std->standard deviation 
        strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);

        %tengo solo se sono sopra la soglia fissata, cioe' ho un vettore di
        %booleani rispetto al valore calcolato qui sopra e la soglia che ho
        %fissato invece fuori dal ciclo
        strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;

        %pause
    end
    
    %strokeWidthFilterIdx %e' un array normale di interi
    %logical(A) converts A into an array of logical values. Any nonzero element of A is
    %converted to logical 1 (true) and zeros are converted to logical 0 (false)
    strokeWidthFilterIdx = logical(strokeWidthFilterIdx);
    %strokeWidthFilterIdx %1×2254 logical array
    
    %pause
    
    % Remove regions based on the stroke width variation
    if ~isempty(strokeWidthFilterIdx)
        %se non e' vuoto entro
        
        %ricordiamo che Regions era:
        %disp('TEXT SALIENCY->Regions')
        %2510×1 MSERRegions array with properties:
        %      Count: 2510
        %   Location: [2510×2 single]
        %       Axes: [2510×2 single]
        %Orientation: [2510×1 single]
        %  PixelList: {2510×1 cell}
        %Regions
        %dovrebbe entrare quando in pratica non ho un vettore, ma un
        %singolo valore, cosa che non dovrebbe mai capitare credo
        
        %size(Regions) %2254           1
        if (size(Regions,1)==1 && size(Regions,2)==1 && strokeWidthFilterIdx == 1)
            disp('TEXT SALIENCY->Regions to Remove')
            Regions = [];
            mserStats = [];
            continue;
        else
            Regions(strokeWidthFilterIdx) = [];
            mserStats(strokeWidthFilterIdx) = [];
        end
        %sum(strokeWidthFilterIdx) %813
        %abbiamo tolto quelle in cui strokeWidthFilterIdx e' 1
        %size(Regions) %1441=2254-813           1
    end
    
    %pause
    
    %disp('TEXT SALIENCY->show MSER')
    % show MSER
     %handle = figure;
     %imshow(grayimg)
     %hold on
     %plot(Regions, 'showPixelList', true,'showEllipses',false)
    
    % write MSER
     %outfilename = ['MSER_'];
     %print(outfilename,'-dpng');
    
    %disp('TEXT SALIENCY -> Press to continue')
    %pause
    
     %close(handle); %non necessario se chiudo manualmente la figura che si
     %viene a disegnare
     
    
    % use the filtered MSER bounding boxes to create mask for edge maps 
    %BoundingBox -> contiene double a righe di 4 e dovrebbero essere i
    %contorni dei rettangoli che creano le varie aree che si visualizzano
    %sulla mappa. Concatena array verticalmente.
    %BoundingBox -> guardare sopra che cosa avevo scritto per capire meglio
    %che cosa fossero più nel dettaglio
    bboxes = vertcat(mserStats.BoundingBox);
    %size(bboxes) %1441           4
    
    if isempty(bboxes)
        disp('TEXT SALIENCY->bboxes empty')
        continue;
    end
    
    %disp('TEXT SALIENCY->bboxes not empty')
    %pause
    
    ymin = bboxes(:,2)*0.98-2;
    xmin = bboxes(:,1)*0.98-2;
    xmax = xmin + round(bboxes(:,3)*1.02) + 1;
    ymax = ymin + round(bboxes(:,4)*1.02) + 1;
    
    %qui sotto abbiamo le coordinate di un rettangolo quindi, cioe' sono
    %vari rettangoli perche' ogni riga di bboxes e' un rettangolo
    
    %floor(X) rounds each element of X to the nearest integer less than or equal to that element.
    xmin = floor(xmin);
    ymin = floor(ymin);
    %arrotonda per eccesso
    xmax = ceil(xmax);
    ymax = ceil(ymax);
    
    %valore logico
    idx = xmin<1;
    %idx %1441×1 logical array
    %dove idx e' 1 e quindi dove xmin era piu' piccolo di 1, vado a mettere
    %xmin=1, cioe' lo incremento in modo che sotto ad 1 non possa mai
    %andare. Penso che questa cosa si faccia per non fare uscire dalla
    %figura quello che stiamo costruendo.
    xmin(idx)=1;
    %stessa cosa la facciamo per la y minima
    idx = ymin<1;
    ymin(idx)=1;
    %Ricordiamo
    %H = dim_img(1);
    %W = dim_img(2);
    idx = xmax>W;
    xmax(idx) = W;  % x is the column subscript
    idx = ymax>H;
    ymax(idx) = H;  % y in the row subscript
    
    %ecco quindi tutti i box che abbiamo, uno per riga
    boxes = [ymin ymax xmin xmax];
    %     1     4     1     4
    % 3     9     8    13
    % 1     7    19    26
    %11    16    37    42
    %12    25     4    19
    %..     ..      ..  ..
    %boxes
    %size(boxes) %1441           4
    %pause
    
    %disp('TEXT SALIENCY->mask')
    %size(grayimg) %252   288
    mask = zeros(size(grayimg));  
    for k = 1:length(xmin)  % loop through all bounding boxes
        %metto ad 1 tutti i pixel nel limite del box indicato dall'indice
        %che sto scorrrendo
        mask(xmin(k):xmax(k), ymin(k):ymax(k)) = 1;
    end
     
    % write mask
    %outfilename = ['Mask_.jpg'];
    %imwrite(A,filename) writes image data A to the file specified by filename, 
    %inferring the file format from the extension. imwrite creates the new file in your current folder
    %imwrite(mask, outfilename);
    
    %disp('text saliency->SHOW MASK')
    %imshow(mask)
    
    %imsave
    
    %ImageCurrent = getframe(gcf);
    %int2str(N) converte un intero in un carattere per concatenare le
    %stringhe e fare il nome dell'immagine giusta.
    %strcat(s1,...,sN) concatena le stringhe orizzontalmente per poter dare
    %il nome corretto all'immagine che voglio in uscita senza sovrascrivere
    %'samplepics/economist_daily_chart_5.png'-> grafico a barre
    %orrizzontali
    %imwrite(ImageCurrent.cdata,strcat('mask_economist_daily_chart_5_scale_',int2str(floor(scale*10)),'.jpg'));
    
    %disp('text saliency->PRESS TO CONTITNUE and compute three features')
    %pause
    
    % compute three features
    if isempty(boxes)
        disp('TEXT SALIENCY->boxes empty')
        continue;
    end
    
    %disp('TEXT SALIENCY->boxes not empty')
    
    %script textF1.m
    F1 = textF1(grayimg, boxes);  % gradient contrast feature
    %moltiplico ancora per un fattore di scala che nel paper era presente
    %come P
    F1 = F1*2.5;
    
    %size(F1) %252   288 -> stessa dimensione dell'immagine riscalata nel
    %primo ciclo
    
    %ragiona su due caratteristiche e le combina un po' aggiornandole man
    %mano scorrendo tutti i box come presentato nel paper 3 della tesi
    [F2, F3] = textF2F3(scaledimg, boxes);
    %size(F2) %252   288
    %size(F3) %252   288
    
    %tutte e 3 le caratteristiche sono delle matrici di double che sono
    %molto sparse
    
    %pause
    
%     F1 = imgaussfilt(F1, sqrt(H*W)/52);
%     F2 = imgaussfilt(F2, sqrt(H*W)/52);
%     F3 = imgaussfilt(F3, sqrt(H*W)/52);

%     indx = F1>0;
%     F1nz = F1(indx);
%     F2nz = F2(F2>0);
%     F3nz = F3(F3>0);
%     
%     hist(F1nz,50);
%     figure;
%     hist(F2nz,50);
%     figure;
%     hist(F3nz,50);
%     

    %pause
    
    %non so perche' facccia questa modifica ai valori che ha cacolato prima
    %Non so se sia giusto, ma sinceramente ne' prima ne' dopo le modifiche
    %riscontro differenze tra queste caratteristiche che in effetti sono
    %matrici molto sparse e quindi le differenze potrebbero essere
    %impercettibili e quindi magari quella e' la spiegazione, ma ci si
    %potrebbe soffermare su questo aspetto.
    %disp('TEXT SALIENCY->F1-1')
    %imshow(F1)
    %pause
    F1 = F1*10;
    %disp('TEXT SALIENCY->F1-2')
    %imshow(F1)
    %pause
    %disp('TEXT SALIENCY->F2-1')
    %imshow(F2)
    %pause
    F2 = F2*10;
    %disp('TEXT SALIENCY->F2-2')
    %imshow(F2)
    %pause
    %disp('TEXT SALIENCY->F3-1')
    %imshow(F3)
    %pause
    F3 = F3*10;
    %disp('TEXT SALIENCY->F3-2')
    %imshow(F3)
    %pause
    
%     f1 = normalize01(F1);
%     imshow(f1);
%     f2 = normalize01(F2);
%     imshow(f2);
%     f3 = normalize01(F3);
%     imshow(f3);

    %pause
    
    S0 = F1+F2+F3;
    %disp('TEXT SALIENCY->S01')
    %e' un immagine con sfondo nero e vari puntini bianchi
    %imshow(S0)
    
    %imgaussfilt->2-D Gaussian filtering of images
    %imgaussfilt(A,sigma) filters image A with a 2-D Gaussian smoothing kernel 
    %with standard deviation specified by sigma
    S0 = imgaussfilt(S0, sqrt(H*W)/52);
    
    %pause
    
    %e' un immagine che rispetto a quella di prima evidenzia delle chiazze
    %bianche dove prima c'era la pletora di puntini bianchi sullo sfondo
    %nero
    %imshow(S0)
    
    %disp('TEXT SALIENCY->S02')
%     imshow(mat2gray(S0));
%     S0 = F1.*F2.*F3;
    %pause
    
    %continua ad aggiornare il suo valore riscalando quella calcolata
    %precedentemente
    S = S + imresize(S0, size(S));
    
    %disp('TEXT SALIENCY->S1')
    %imshow(S)
    
    %ImageCurrent = getframe(gcf);
    %imwrite(ImageCurrent.cdata,strcat('S_economist_daily_chart_5_scale_',int2str(floor(scale*10)),'.jpg'));
    
    %disp('text saliency->PRESS TO CONTITNUE and pass to the next scale')
    %pause
    
end

%disp('TEXT SALIENCY->S2')
%immagine molto grossolana e luminosa con sfondo nero e tratti bianchi
%molto marcati
%imshow(S)
%pause

S = S/length(scales);
%disp('TEXT SALIENCY->S3')
%immagine piu' sfocata in cui i tratti bianchi sono notevolmente piu'
%sottili
%imshow(S)
%pause

S(S<=0) = eps;   % fix negative values con epsilon di macchina
%disp('TEXT SALIENCY->S4')
%cambiamenti impercettibili dalla precedente
%imshow(S)
%pause

S = mat2gray(S); % normalize to a range of 0 to 1 
%disp('TEXT SALIENCY->S5')
%diventa ancora un po' meno chiara e un po' piu' scura rispetto alle ultime
%2
%imshow(S)
%pause

