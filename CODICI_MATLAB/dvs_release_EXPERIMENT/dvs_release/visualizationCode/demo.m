% Zoya Bylinskii, October 19, 2015
clear all
close all
clc

% https://github.com/massvis
% massvis.mit.edu

% Depends on code from: https://github.com/cvzoya/fixation-visualization

%prima di lanciare il programma caricare il file di dati .mat cliccandoci 2
%volte sopra

%allImages a quel punto e' una struttura che contiene tutte le informazioni
%per tutte le 393 immagini che abbiamo nel file .mat, una per ogni riga.


load('/Users/samuel/Documents/MATLAB/dvs_release/targets393_metadata_withuserdata.mat')
%% set parameters for visualization purposes

params = struct();
params.thresh = 0.1;
params.sigma = 32;
params.scaleFact = 4; % a larger number speeds up computation

%% if you want to accumulate fixations from the massvis dataset:
% if you want to input your own images or fixations, skip to the code below

%load('allImages.mat');

%pause

%whichfix fa riferimento al campo all'interno della struct fixations in
%userdata e in particolare dentro fixations (che e' una struct solo se l'utente 
%ha effettivamente osservato qualcosa) abbiamo due campi:
%-enc contiene i punti (x,y) di fixations durante la fase di encoding
%-rec contiene i punti (x,y) di fixations durante la fase di recognition
whichfix = 'enc'; % or 'rec'

%quale immagine scelgo tra le 393 che abbiamo salvato nel file .mat
%whichim = 41;

%isfile('eyetracking-master/matlab_files/visualizationCode/targets/economist_daily_chart_5.png')
%-> la risposta e' un booleano 1
%size(allImages) -> 1 393
string='eyetracking-master/matlab_files/visualizationCode/targets/';
conta=0;
indice=1; %'economist_daily_chart_103
%for indice=1:size(allImages,2)
    stringa=strcat(string,allImages(indice).filename);
    %questo if mi permette di beccare solo le immagini di grafici di dati
    %che mi interessano effettivamente
    if isfile(stringa)
        conta=conta+1;
        %conta
        %allImages(indice).filename
        
        %se voglio scegliere solo alcuni utenti che hanno osservato un'immagine li
        %seleziono in questa maniera, però devo sapere che abbiano effettivamente
        %osservato l'immagine altrimenti il tutto è abbastanza inutile
        % whichusers = [3,4,5]; 

        % to use all users: -> associati a quell'immagine
        %per oggi immagine abbiamo i dati di 33 osservatori associati (non tutti
        %hanno effettivamente osservato).
        %Una riga di allImages contiene le informazioni legate ad un'immagine. 
        %Abbiamo ad esempio il percorso per importala che useremo in seguito ed e'
        %nel campo impath.
        %Nel campo userdata abbiamo le informazioni di tutte le osservazioni legate
        %a quell'immagine, per tutti gli utenti osservatori (che sono 33, ma che
        %non tutti hanno necessariamente ossevato questa immagine)
        
        %whichusers = 1:length(allImages(whichim).userdata);
        whichusers = 1:length(allImages(indice).userdata);
        
        %il discorso e' che per questo dataset abbiamo in tutto 33 osservatori e in
        %media 16 osservatori per ogni immagine e quindi per questo nel for di
        %sotto controlliamo se abbiamo o meno una fixation map

        %dati del singolo utente che ha guardato quell'immagine
        
        %allImages(whichim).userdata
        allImages(indice).userdata
        
        %whichusers %vettore da 1 a 33

        %pause


        %importiamo l'immagine che vogliamo studiare
        %im = imread(allImages(whichim).impath);
        im = imread(allImages(indice).impath);
        %image(im)
        %size(im) %645        1000           3

        %disp('Presso to continue');
        %pause

        imsize = [size(im,1),size(im,2)];
        %imsize %645        1000
        maxsize = max(imsize(1),imsize(2));

        % accumulate fixations from multiple users (nel for sotto andiamo a 
        fixations = [];

        %scorro ad uno ad uno tutti gli osservatori dell'immagine fissata e
        %faccio in modo che al primo utente che ha fissato qualcosa esco per avere
        %il grafico solo del primo che osserva effettivamente.
        for j = 1:length(whichusers)
            whichuser = whichusers(j);
            % check if fixations exist for this user and include them if they do
            %whichfix e' stato fissato all'inizio.
            %Se l'utente ha osservato effettivamente, abbiamo una struct nel campo
            %fixations, altrimenti il campo e' vuoto ed e' la prima cosa che
            %andiamo a controllare. Se fixations contiene effettivamente una struct
            %andiamo a controllare pero' che il campo che stiamo ricercando sia
            %stato effettivamente costruito al suo interno e che quindi ci sia. Se
            %il campo che abbiamo fissato in whichfix c'e', controlliamo che non
            %sia vuoto.
            
            %isempty(allImages(indice).userdata(whichuser).fixations)
            %size(allImages(indice).userdata(whichuser).fixations)
            %allImages(indice).userdata(whichuser).fixations
            %~isfield(allImages(indice).userdata(whichuser),'fixations')
            %~isfield(allImages(indice).userdata(whichuser).fixations,whichfix)
            %isempty(allImages(indice).userdata(whichuser).fixations.(whichfix))
            
            if isempty(allImages(indice).userdata(whichuser).fixations) || ...
                    ~isfield(allImages(indice).userdata(whichuser).fixations,whichfix) || ...
                    isempty(allImages(indice).userdata(whichuser).fixations.(whichfix))
                %disp('CONTINUE');
                continue;
            end
            
            %allImages(indice).filename
            %disp('USER');
            %j

            %fixdata = allImages(whichim).userdata(whichuser).fixations.(whichfix);
            fixdata = allImages(indice).userdata(whichuser).fixations.(whichfix);
            %fixdata
            
            %man mano che troviamo osservatori che hanno osservato effettivamente
            %l'immagine che abbiamo fissato, andiamo ad aggiungere in fixations i
            %suoi dati espandendo man mano la dimensione di questo vettore di
            %fixations
            fixations = [fixations ; fixdata];
            %fixations
            
            %disp('Size fixations');
            %size(fixations) %36     2

            %break
            
            %pause

        end
        disp('END USER CICLE');
        %size(fixations) %431     2
        pause

        %% plot fixation heatmap

        %plotFixationHeatmap(im, fixations, params);
        disp('FixationHeatmap');
        disp('PRESS TO EXTRAPOLATE PLOT');
        pause
        %ImageCurrent = getframe(gcf);
        %imwrite(ImageCurrent.cdata,strcat('EyeTracking_economist_daily_chart_5.jpg'));
        %imwrite(ImageCurrent.cdata,strcat(strcat('EyeTracking_',allImages(indice).filename)));
        %pause

   end
%end



%% plot coverage map

%plotCoverageMap(im, fixations, params); 
%disp('CoverageMap');
%pause
   
%% plot coverage at different thresholds

%for i = 1:2:10
%    disp('CoverageMap thresholds ');
%    params.thresh
%    params.thresh = i/10;
%    plotCoverageMap(im, fixations, params); 
%    pause
%end

%% plot the ordered sequence of fixations for a particular observer
% on a particular visualization
disp('plot the ordered sequence of fixations for a particular observer on a particular visualization');
%whichuser = 5;
whichuser = 1;
%whichuser
%pause

fix = allImages(indice).userdata(whichuser).fixations.(whichfix);
nfix = size(fix,1);
%numero di punti di fissazione in base al campo whichfix che abbiamo scelto
%e prendiamo la dimensione 1 perche' sono coordinate (x,y) quindi ci basta
%prendere la dimensione delle prime coordinate
%disp('nfix');
%nfix %46

%siamo sempre sull'immagine 1 e prendiamo tutte le osservazioni che ci sono
%relative a quest'immagine per l'osservatore 5 che abbiamo selezionato
im = imread(allImages(indice).impath);
%size(im) %645        1000           3

im_cur = rgb2gray(im);
im_cur = im;

%pause

% plot fixations in a sequence with numbers indicating order of fixations, 
% and lines connecting consecutive fixations
figure; 
%colormap(map) sets the colormap for the current figure to the colormap specified by map.
%autumn->Autumn colormap array che sono colori sul giallo arancio
%ci salviamo la color map in pratica nella variabile cols perche' magari la
%dobbiamo usare da qualche altra parte dopo
cols = colormap(autumn(nfix));
%mostriamo l'immagine
%imshow(im_cur);
image(im_cur)
hold on;
for f = 1:(nfix-1)
     %x
     fix(f:(f+1),1)
     %y
     fix(f:(f+1),2)
    plot(fix(f:(f+1),1),fix(f:(f+1),2),'LineWidth',5,'color',cols(f,:))
    pause
end

disp('END FIRST FOR')
pause

for f=1:(nfix-1)
    disp('original')
    fix(f,1)
    fix(f,2)
    
    disp('modified')
    if abs(floor(fix(f,1))-fix(f,1))>abs(ceil(fix(f,1))-fix(f,1))
        fix(f,1)=ceil(fix(f,1));
    else
        fix(f,1)=floor(fix(f,1));
    end
    
    if abs(floor(fix(f,2))-fix(f,2))>abs(ceil(fix(f,2))-fix(f,2))
        fix(f,2)=ceil(fix(f,2));
    else
        fix(f,2)=floor(fix(f,2));
    end
    fix(f,1)
    fix(f,2)
    pause
end


for f = 1:(nfix-1)
     
    plot(fix(f:(f+1),1),fix(f:(f+1),2),'LineWidth',5,'color',cols(f,:))
    pause
end

disp('END FIRST FIRST FOR')
pause



%for f = 1:nfix
%    text(fix(f,1),fix(f,2),['{\color{black}\bf', num2str(f), '}'],...
%        'FontSize', 16, 'BackgroundColor', cols(f,:));
%end

%% plot the fixations of a single observer on current visualization

%disp('LAST PLOTS 1')

%if strcmp(whichfix,'enc')
%    plotFixationsOnIm(whichim,allImages,1,0,whichuser,1)
%else
%    plotFixationsOnIm(whichim,allImages,2,0,whichuser,1)
%end


%% plot the fixations of a group of observers on current visualization, 
% pausing between observers

%disp('LAST PLOTS 2')

%if strcmp(whichfix,'enc')
%    plotFixationsOnIm(whichim,allImages,1,1,whichusers,1)
%else
%    plotFixationsOnIm(whichim,allImages,2,1,whichusers,1)
%end

     