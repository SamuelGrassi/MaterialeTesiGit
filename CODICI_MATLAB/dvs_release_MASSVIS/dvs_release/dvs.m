%%dvs() takes an image and outputs the Data Vis Saliency Model map
%%structure

%Calculates both the Itti saliency (modified from the original version 
%implemented in Harel's GBVS to use CIE LAB colorspace) and text saliency. 
%Creates and outputs a linear combination of the two (with 2x the weight 
%for text), giving the Data Vis Saliency map. -> quel 2 dato al peso nel
%papaer e' stato detto che nel materiale aggiuntivo e' stato calcolato come
%limite quello che dava le performance migliori

%For more information see Matzen, Haass, Divis, Wang & Wilson. (under
%review). Data Visualization Saliency Model: A tool for evaluating abstract
%data visualizations.

%Created 11.21.16 - K. Divis

%imread(filename) reads the image from the file specified by filename, inferring 
%the format of the file from its contents. If filename is a multi-image file, 
%then imread reads the first image in the file.
%imread returns a 650-by-600-by-3 array (in the example on the
%documentation)

%con img=imread('samplepics/1.jpg');
%size(img)
%ans = 630   720     3
%image(img) or imshow(img) show the image in a figure
%[A,map] = imread(___) reads the indexed image in filename into A and reads 
%its associated colormap into map. Colormap values in the image file are 
%automatically rescaled into the range [0,1].

%la colormap dovrebbe tipo essere la mappa dei colori che viene utilizzata
%o comunque qualcosa del genere perche' cambiandola, cambiano i colori che
%vengono rappresentati

%con img = imread('samplepics/economist_daily_chart_5.png');
%size(img) -> 950        1000           3
%anche lei dovrebbe quindi essere una immagine RGB perche' ha 3 canali
%finali di dimensione che corrispondono a rosso, verde e blu

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Double-precision (64-bit) floating-point numbers are the default MATLAB® 
%representation for numeric data. 

%However, to reduce memory requirements for 
%working with images, you can store images as 8-bit or 16-bit unsigned integers 
%using the numeric classes uint8 or uint16, respectively. 

%An image whose 
%data matrix has class uint8 is called an 8-bit image; an image whose data 
%matrix has class uint16 is called a 16-bit image.

%The image function can display 8- or 16-bit images directly without converting 
%them to double precision. However, image interprets matrix values slightly 
%differently when the image matrix is uint8 or uint16. The specific interpretation 
%depends on the image type.
%If the class of X is uint8 or uint16, its values are offset by 1 before being
%used as colormap indices. The value 0 points to the first row of the colormap, 
%the value 1 points to the second row, and so on. The image command automatically 
%supplies the proper offset, so the display method is the same whether X is 
%double, uint8, or uint16:

%image(X); 
%colormap(map);

%The colormap index offset for uint8 and uint16 data is intended to support 
%standard graphics file formats, which typically store image data in indexed 
%form with a 256-entry colormap. The offset allows you to manipulate and display 
%images of this form using the more memory-efficient uint8 and uint16 arrays.

%filename = uigetfile('*.*');
%[X, map] = imread(filename);
%info = imfinfo(filename)

%imfinfo('samplepics/1.jpg')
%ans =  struct with fields:
%           Filename: '/Users/samuel/Documents/MATLAB/dvs_release/gbvs/samplepics/1.jpg'
%        FileModDate: '30-Sep-2017 01:39:36'
%           FileSize: 88169
%             Format: 'jpg'
%      FormatVersion: ''
%              Width: 720
%             Height: 630
%           BitDepth: 24
%          ColorType: 'truecolor'
%    FormatSignature: ''
%    NumberOfSamples: 3
%       CodingMethod: 'Huffman'
%      CodingProcess: 'Sequential'
%            Comment: {}

%The metadata associated with your image is indicating that your data is already 
%an RGB image with separate RGB planes:
%ColorType: 'truecolor', NumberOfSamples: 3
%for that the command 'ind2rgb' is failing because you are providing input that is already an RGB
%image (and is not an indexed image). 

%imfinfo('samplepics/economist_daily_chart_5.png');
% struct with fields:
%                  Filename: '/Users/samuel/Documents/MATLAB/dvs_release/gbvs/samplepics/economist_daily_chart_5.png'
%               FileModDate: '22-Jul-2015 00:49:19'
%                  FileSize: 227343
%                    Format: 'png'
%             FormatVersion: []
%                     Width: 1000
%                    Height: 950
%                  BitDepth: 24
%                 ColorType: 'truecolor'
%           FormatSignature: [137 80 78 71 13 10 26 10]
%                  Colormap: []
%                 Histogram: []
%             InterlaceType: 'none'
%              Transparency: 'alpha'
%    SimpleTransparencyData: []
%           BackgroundColor: [1 1 1]
%           RenderingIntent: []
%            Chromaticities: [0.3127 0.3290 0.6400 0.3300 0.3000 0.6000 0.1500 0.0600]
%                     Gamma: 0.4546
%               XResolution: []
%               YResolution: []
%            ResolutionUnit: []
%                   XOffset: []
%                   YOffset: []
%                OffsetUnit: []
%           SignificantBits: []
%              ImageModTime: []
%                     Title: []
%                    Author: []
%               Description: []
%                 Copyright: []
%              CreationTime: []
%                  Software: []
%                Disclaimer: []
%                   Warning: []
%                    Source: []
%                   Comment: []
%                 OtherText: {2×2 cell}

%RGB = ind2rgb(X,map) converts the indexed image X and corresponding colormap map to RGB (truecolor) format.  

%If you want the RGB components:
%R = X(:,:,1);
%G = X(:,:,2);
%B = X(:,:,3);

%[X,cmap] = rgb2ind(RGB,Q) converts the RGB image to an indexed image X with 
%associated colormap cmap using minimum variance quantization with Q quantized colors and dithering.

%RGB images are r x c x 3 with an empty map
%CMYK images (tiff only) are r x c x 4 with an empty map
%RGBA images are sometimes r x c x 4 with an empty map, but are sometimes r x c x 3 
%with a third output that can indicate alpha
%Grayscale images are r x c with an empty map. These have an implicit grayscale map.
%Gray+alpha images are uncommon but are r x c x 2 with an empty map
%Pseudocolor images are r x c with a nonempty map and can be converted to rgb with ind2rgb()

%The color components of an 8-bit RGB image are integers in the range [0, 255] 
%rather than floating-point values in the range [0, 1]. A pixel whose color 
%components are (255,255,255) is displayed as white. The image command displays 
%an RGB image correctly whether its class is double, uint8, or uint16:
%image(RGB);

%To convert an RGB image from double to uint8, first multiply by 255:
%RGB8 = uint8(round(RGB64*255)); %round for passing in integers

%Conversely, divide by 255 after converting a uint8 RGB image to double:
%RGB64 = double(RGB8)/255

function out = dvs(img,fixations,whichfix,heatFixationsMap,nome)
%ischar(A) returns logical 1 (true) if A is a character array and logical 0 (false) otherwise
if ( ischar(img) == 1 ) 
    %no with img=imread('samplepics/1.jpg');
    %ans =
    % logical
    %0
    
    %anche con ('samplepics/economist_daily_chart_5.png'); restituisce il
    %valore logico zero
    
    disp('Image char');
    img = imread(img); 
end

%class(img)
%ans = 'uint8' sia per ('samplepics/1.jpg') che per ('samplepics/economist_daily_chart_5.png');

%strcmp compare strings
if ( strcmp(class(img),'uint8') == 1 ) 
    disp('Image uint8');
    %The range of double image arrays is usually [0, 1], but the range of
    %8-bit intensity images is usually [0, 255] and the range of 16-bit intensity
    %images is usually [0, 65535]. 
    
    %Use the following command to display an 8-bit 
    %intensity image with a grayscale colormap: 
    %imagesc(I,[0 255]); 
    %colormap(gray);
    
    %convertiamo l'immagine da 'uint8' a double
    img = double(img)/255; 
end

%class(img) %doube
%size(img)

%weight for the text part of the global saliency map
w = 2;  %scale factor applied to text saliency map before adding to IttiKoch map

disp('press to continue and pass to ITTI')
pause

% compute Itti-Koch saliency map
disp('DVS -> compute ITTI saliency map')
ikout = ittikochmap(img);
%with samplepics/1
%ikout   %struct with fields:
        %master_map: [79×90 double]
        %master_map_resized: [630×720 double]
        %top_level_feat_maps: {[79×90 double]  [79×90 double]  [79×90 double]}
        %map_types: {'intensity'  'labcolor'  'orientation'}
        %intermed_maps: [1×1 struct]
        %rawfeatmaps: [1×1 struct]
        %paramsUsed: [1×1 struct]
%quelle che ci serve da andare a risovrapporre con l'immagine
ikmap = ikout.master_map_resized;
disp('DVS -> ikmap')
imshow(ikmap)
ImageCurrent = getframe(gcf);
%imwrite(ImageCurrent.cdata,strcat('ITTI_economist_daily_chart_5.jpg'));
imwrite(ImageCurrent.cdata,strcat(strcat('ITTI_',nome)));

disp('press to continue and compute the metrics')
pause 

%creo la matrice dei punti di fissazione 
%size(ikmap) %645        1000
%size estrae le dimensioni come quelle di una matrice e dunque prima la
%componente verticale e poi quella orizzontale
fixationMap=zeros(size(ikmap,1),size(ikmap,2));
%size(fixationMap) %645        1000
%fixations
nfix=size(fixations,1);
%nfix %431
for f=1:nfix
    %disp('original')
    %fix(f,1)
    %fix(f,2)
    
    %disp('modified')
    if abs(floor(fixations(f,1))-fixations(f,1))>abs(ceil(fixations(f,1))-fixations(f,1))
        fixations(f,1)=ceil(fixations(f,1));
    else
        fixations(f,1)=floor(fixations(f,1));
    end
    
    if abs(floor(fixations(f,2))-fixations(f,2))>abs(ceil(fixations(f,2))-fixations(f,2))
        fixations(f,2)=ceil(fixations(f,2));
    else
        fixations(f,2)=floor(fixations(f,2));
    end
    %f
    %fixations(f,1)
    %fixations(f,2)
    %pause
    if(fixations(f,1)==0)
       fixations(f,1)=1;
    end
    if(fixations(f,2)==0)
       fixations(f,2)=1;
    end
    %la prima componente e' la y perche' ragiona come una matrice
    fixationMap(fixations(f,2),fixations(f,1))=1;
    
end

%sum(sum(fixationMap)) %431

%size(img) %645        1000           3
%size(fixationMap) %645        1000
%fixationMap

[score,tp,fp] = AUC_Borji(ikmap, fixationMap);
disp('AUC_Borji')
score %0.7253

%pause 

[score,tp,fp,allthreshes] = AUC_Judd(ikmap, fixationMap);
disp('AUC_Judd')
score %0.7386

%pause

otherMap=randomFixationsMaps(size(img,1),size(img,2),whichfix);
[score,tp,fp] = AUC_shuffled(ikmap, fixationMap, otherMap);
disp('AUC_shuffled')
score %0.7618

%pause

score = CC(ikmap, heatFixationsMap); %?
disp('CC')
score %0.0217 -> 0.5819

%pause



score = KLdiv(ikmap, fixationMap);
disp('KLdiv')
score %6.9440

%pause

score = NSS(ikmap, fixationMap);
disp('NSS')
score %0.8391

%pause

score = SIM(ikmap, heatFixationsMap);
disp('SIM')
score %0.0012 -> 0.6796

%pause

[score,D,flowMat] = EMD(ikmap, fixationMap);
disp('EMD')
score %3.8827

%pause

beep

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp('press to continue and pass to TEXT SALIENCY')
pause  

% compute text saliency
S = textSaliency(img);
disp('DVS -> textSaliency')
imshow(S)
ImageCurrent = getframe(gcf);
%imwrite(ImageCurrent.cdata,strcat('TextSaliency_economist_daily_chart_5.jpg'));
imwrite(ImageCurrent.cdata,strcat(strcat('TextSaliency_',nome)));


%sulla parte di testo non dobbiamo andare a calcolare le metriche



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp('press to continue and pass to the combination map')
pause

% make linear combinations (with text saliency given twice the weight)
comb = (S*w+ikmap) ./ (w + 1); % weighted average to keep scaling from 0 to 1
disp('DVS -> comb')
imshow(comb)
ImageCurrent = getframe(gcf);
%imwrite(ImageCurrent.cdata,strcat('Combination_economist_daily_chart_5.jpg'));
imwrite(ImageCurrent.cdata,strcat(strcat('Combination_',nome)));

disp('press to continue and compute the metrics')
pause 

%size estrae le dimensioni come quelle di una matrice e dunque prima la
%componente verticale e poi quella orizzontale
size(comb) %645        1000
%sum(sum(fixationMap)) %431
%size(img) %645        1000           3
%size(fixationMap) %645        1000
%fixationMap

[score,tp,fp] = AUC_Borji(comb, fixationMap);
disp('AUC_Borji')
score %0.7735

%pause 

[score,tp,fp,allthreshes] = AUC_Judd(comb, fixationMap);
disp('AUC_Judd')
score %

%pause

otherMap=randomFixationsMaps(size(img,1),size(img,2),whichfix);
[score,tp,fp] = AUC_shuffled(comb, fixationMap, otherMap);
disp('AUC_shuffled')
score %

%pause

score = CC(comb, heatFixationsMap); %?
disp('CC')
score %

%pause



score = KLdiv(comb, fixationMap);
disp('KLdiv')
score %

%pause

score = NSS(comb, fixationMap);
disp('NSS')
score %

%pause

score = SIM(comb, heatFixationsMap);
disp('SIM')
score %

%pause

[score,D,flowMat] = EMD(comb, fixationMap);
disp('EMD')
score %

%pause

beep

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('press to continue and pass to the final part')
pause
    
% out = comb;
%inizializzo l'output alla mappa che ritornava da Itti indietro
out = ikout;
out.master_map_resized = comb;  % put the visSal map in master_map_resized
out.map_types{end+1} = 'text';  % update may type cell arrary
out.top_level_feat_maps{end+1} = S; % put text saliency map into top_level_feat_maps



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp('press to continue and pass to ORIGINAL ITTI')
pause   

disp('DVS -> compute ORIGINAL ITTI saliency map')
ikoutOR = ittikochmapOR(img);
ikmapOR = ikoutOR.master_map_resized;
disp('DVS -> ikmapOR')
imshow(ikmapOR)
ImageCurrent = getframe(gcf);
%imwrite(ImageCurrent.cdata,strcat('ITTI_OR_economist_daily_chart_5.jpg'));
imwrite(ImageCurrent.cdata,strcat(strcat('ITTI_OR_',nome)));

disp('press to continue and compute the metrics')
pause 

[score,tp,fp] = AUC_Borji(ikmapOR, fixationMap);
disp('AUC_Borji')
score %0.7735

%pause 

[score,tp,fp,allthreshes] = AUC_Judd(ikmapOR, fixationMap);
disp('AUC_Judd')
score %

%pause

otherMap=randomFixationsMaps(size(img,1),size(img,2),whichfix);
[score,tp,fp] = AUC_shuffled(ikmapOR, fixationMap, otherMap);
disp('AUC_shuffled')
score %

%pause

score = CC(ikmapOR, heatFixationsMap); %?
disp('CC')
score %

%pause



score = KLdiv(ikmapOR, fixationMap);
disp('KLdiv')
score %

%pause

score = NSS(ikmapOR, fixationMap);
disp('NSS')
score %

%pause

score = SIM(ikmapOR, heatFixationsMap);
disp('SIM')
score %

[score,D,flowMat] = EMD(ikmapOR, fixationMap);
disp('EMD')
score %

%pause

beep

%pause
disp('press to quit')
pause




