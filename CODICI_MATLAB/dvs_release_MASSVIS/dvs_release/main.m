%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%QUESTO CODICE E' SOLO PER LE ANALISI SU MASSVIS%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc

load('/Users/samuelgrassi/Documents/MATLAB/dvs_release_MASSVIS/dvs_release/targets393_metadata_withuserdata.mat')

dvs_install 
%dettagli sulla variabile codice:
%0 -> produzione mappa di calore vera, calcolo di metriche e produzione delle mappe di salienza per ITTI,
%ITTI modificato e MATZEN
%1 -> analisi semantica dei poligoni sull'immagine
codice=0;
%dettagli sulla variabile preattentive:
%0 -> vengono considerati tutti i punti di fissazione
%1 -> vengono presi in considerazione solo i primi 250 ms
%2 -> vengono presi in considerazione solo i primi 500 ms
%3 -> vengono esclusi i primi 250 ms e poi presi in considerazione i 250 ms
%successivi
preattentive=0;

string='/Users/samuelgrassi/Documents/MATLAB/dvs_release_MASSVIS/dvs_release/visualizationCode/targets/';

whichfix = 'enc'; % or 'rec'
params = struct();
params.thresh = 0.1;
params.sigma = 32;
params.scaleFact = 4; % a larger number speeds up computation

%gli indici vanno da 1 a 393 per scorrere tutte le immagini di MASSVIS, ma
%solo 110 immagini noi abbiamo conservato. Per cui con indici crescenti
%scorriamo tutta la struttura dati caricata prima con 'load' e se sono tra
%le immagini che abbiamo conservato di MASSVIS allora il programma viene
%eseguito, altrimenti non succede nulla e si va direttamente alla fine.
indice=1;

stringa=strcat(string,allImages(indice).filename)
stringa_nome=split(allImages(indice).filename,'.');
stringa_poligoni=strcat('dvs_release_MASSVIS/dvs_release/elementLabels/', char(stringa_nome(1)))
    
if isfile(stringa)
    if(codice>0)
        fileID=fopen(stringa_poligoni,'r');
        formatSpec = '%s\n';
        tline = fgetl(fileID);
        conta_poligoni=0;
        analisi_semantica=[];
        poligono=0;
        punti_poligono=0;
        while ischar(tline)
            punti_poligono=punti_poligono+1;
            tline_div=split(tline,",",4);

            a=str2num(char(tline_div(1)));
            b=char(tline_div(2));
            c=str2num(char(tline_div(3)));
            d=str2num(char(tline_div(4)));
            
            if(poligono~=a)
                conta_poligoni=conta_poligoni+1;
                poligono=a;
                analisi_semantica(conta_poligoni).poligono=poligono;
                punti_poligono=1;
                analisi_semantica(conta_poligoni).osservazioni=0;
            end
            
            %poligono
            analisi_semantica(conta_poligoni).tipo=b;
            analisi_semantica(conta_poligoni).punti(punti_poligono).x=c;
            analisi_semantica(conta_poligoni).punti(punti_poligono).y=d;
            tline = fgetl(fileID);
        end
        disp('poligoni caricati')
        size(analisi_semantica,2)

        fclose(fileID);
    end

    whichusers = 1:length(allImages(indice).userdata);

    img = imread(allImages(indice).impath);

    image(img)

    size(img)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(codice>0)
        %% PLOT POLIGONI SU IMMAGINE
        disp('PRESS ENTER TO CONTINUE (POLY)')
        pause 
        
        image(img)
        hold on
        
        for j=1:size(analisi_semantica,2)
            punti_x=[];
            punti_y=[];
            for punti_pol=1:size(analisi_semantica(j).punti,2)
                punti_x=[punti_x; analisi_semantica(j).punti(punti_pol).x];
                punti_y=[punti_y; analisi_semantica(j).punti(punti_pol).y];
            end
            punti_x(size(punti_x,1)+1)=punti_x(1);
            punti_y(size(punti_y,1)+1)=punti_y(1);
            [punti_x punti_y];
            plot(punti_x, punti_y);
            valutazione_x=[1; 500; 989; 600; 507; 980];
            valutazione_y=[1;650;620;660;620; 630];
            in=inpolygon(valutazione_x, valutazione_y, punti_x, punti_y);

            hold on

        end

        set(gca,'Ydir','reverse')
    
        ImageCurrent = getframe(gcf);
        imwrite(ImageCurrent.cdata,strcat(strcat('POLY_ON_IMG_',allImages(indice).filename)));
        
        disp('PRESS ENTER TO CONTINUE (POLY 2)')
        pause
        
        %% PLOT POLIGONI SENZA IMMAGINE
        for j=1:size(analisi_semantica,2)
            punti_x=[];
            punti_y=[];
            for punti_pol=1:size(analisi_semantica(j).punti,2)
                punti_x=[punti_x; analisi_semantica(j).punti(punti_pol).x];
                punti_y=[punti_y; analisi_semantica(j).punti(punti_pol).y];
            end
            punti_x(size(punti_x,1)+1)=punti_x(1);
            punti_y(size(punti_y,1)+1)=punti_y(1);
            [punti_x punti_y];
            set(gca,'Ydir','reverse')
            plot(punti_x, punti_y);
            hold on   
        end
        
        fixations = [];

        for j = 1:length(whichusers)
            %con somma tengo conto dei ms totali di un dato osservatore 
            somma=0;
            whichuser = whichusers(j);

            if isempty(allImages(indice).userdata(whichuser).fixations) || ...
                    ~isfield(allImages(indice).userdata(whichuser).fixations,whichfix) || ...
                    isempty(allImages(indice).userdata(whichuser).fixations.(whichfix))
                %disp('CONTINUE');
                continue;
            end
            
            if(preattentive==0)
                fixdata = allImages(indice).userdata(whichuser).fixations.(whichfix);
            else
                if(preattentive==1)
                    limite=250;
                elseif(preattentive==2)
                    limite=500;
                elseif(preattentive==3)
                    limite=500;
                end
                fixdata_or = allImages(indice).userdata(whichuser).fixations.(whichfix);
                fixdata=[];
                %si parte dal 2 perchè altrimenti c'è sempre il punto
                %centrale
                for indice_fix=2:length(fixdata_or)
                    somma=somma+allImages(indice).userdata(whichuser).fix_durations.('enc')(indice_fix);
                    if(preattentive<3 || (preattentive==3 && somma>250))
                        fixdata=[fixdata; fixdata_or(indice_fix,1) fixdata_or(indice_fix,2)];
                    end
                    if (somma>limite)
                        break;
                    end
                end
            end
            fixations = [fixations ; fixdata];
        end 

        hold on

        for j=1:size(fixations,1)
            hold on
            plot(fixations(j,1),fixations(j,2),'r+')
        end

        ImageCurrent = getframe(gcf);
        if(preattentive==0)
            imwrite(ImageCurrent.cdata,strcat(strcat('POLY_AND_POINTS_',allImages(indice).filename)));
        elseif(preattentive==1)
            imwrite(ImageCurrent.cdata,strcat(strcat('POLY_AND_POINTS_MOD250_',allImages(indice).filename)));
        elseif(preattentive==2)
            imwrite(ImageCurrent.cdata,strcat(strcat('POLY_AND_POINTS_MOD500_',allImages(indice).filename)));
        elseif(preattentive==3)
            imwrite(ImageCurrent.cdata,strcat(strcat('POLY_AND_POINTS_MODNOFIRST250_',allImages(indice).filename)));
        end

        disp('press to continue');
        pause

    end

    if(codice==0)
        disp('PRESS ENTER TO CONTINUE AND COMPUTE FIXATIONS')
        pause 

        imsize = [size(img,1),size(img,2)];
        maxsize = max(imsize(1),imsize(2));

        disp('COMPUTE THE FIXATIONS');

        fixations = [];

        for j = 1:length(whichusers)
            %con somma tengo conto dei ms totali di un dato osservatore 
            somma=0;

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

            if isempty(allImages(indice).userdata(whichuser).fixations) || ...
                    ~isfield(allImages(indice).userdata(whichuser).fixations,whichfix) || ...
                    isempty(allImages(indice).userdata(whichuser).fixations.(whichfix))
                %disp('CONTINUE');
                continue;
            end
            
            if(preattentive==0)
                fixdata = allImages(indice).userdata(whichuser).fixations.(whichfix);
            else
                if(preattentive==1)
                    limite=250;
                elseif(preattentive==2)
                    limite=500;
                elseif(preattentive==3)
                    limite=500;
                end
                fixdata_or = allImages(indice).userdata(whichuser).fixations.(whichfix);
                fixdata=[];
                %si parte dal 2 perchè altrimenti c'è sempre il punto
                %centrale
                for indice_fix=2:length(fixdata_or)
                    somma=somma+allImages(indice).userdata(whichuser).fix_durations.('enc')(indice_fix);
                    if(preattentive<3 || (preattentive==3 && somma>250))
                        fixdata=[fixdata; fixdata_or(indice_fix,1) fixdata_or(indice_fix,2)];
                    end
                    if (somma>limite)
                        break;
                    end
                end
            end
          
            fixations = [fixations ; fixdata];
        end


        disp('END USER CICLE');
        disp('Number fixations');
        size(fixations) %righe   colonne
    end
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%VERIFICA IN QUALE POLIGONO I PUNTI%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(codice>0)  
        for punto=1:size(fixations,1)
            for pol=1:size(analisi_semantica,2)
                punti_x=[];
                punti_y=[];
                for punti_pol=1:size(analisi_semantica(pol).punti,2)
                    punti_x=[punti_x; analisi_semantica(pol).punti(punti_pol).x];
                    punti_y=[punti_y; analisi_semantica(pol).punti(punti_pol).y];
                end
                punti_x(size(punti_x,1)+1)=punti_x(1);
                punti_y(size(punti_y,1)+1)=punti_y(1);
                %verifica punto interno al poligono
                in=inpolygon(fixations(punto,1), fixations(punto,2), punti_x, punti_y);
                if(in==1)
                    analisi_semantica(pol).osservazioni=analisi_semantica(pol).osservazioni+1;
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%PRODUZIONE FILE DI TESTO USCITA%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %strcat('elementLabels/', char(stringa_nome(1)))
        if(preattentive==0)
            fileID=fopen(strcat(char(stringa_nome(1)),'.txt'),'w');
        elseif(preattentive==1)
            fileID=fopen(strcat(strcat(char(stringa_nome(1)),'_MOD250'),'.txt'),'w');
        elseif(preattentive==2)
            fileID=fopen(strcat(strcat(char(stringa_nome(1)),'_MOD500'),'.txt'),'w');
        elseif(preattentive==3)
            fileID=fopen(strcat(strcat(char(stringa_nome(1)),'_MODNOFIRST250'),'.txt'),'w');
        end
        
        for j=1:size(analisi_semantica,2)
            fprintf(fileID,'%s','POLIGONO ');
            fprintf(fileID,'%d',analisi_semantica(j).poligono);
            fprintf(fileID,'%s %s\n',': ',analisi_semantica(j).tipo);
            fprintf(fileID,'\t%s %d\n','numero osservazioni: ',analisi_semantica(j).osservazioni);
        end
    end
    
    if(codice==0)
        %% plot fixation heatmap
        plotFixationHeatmap(img, fixations, params);
        ImageCurrent = getframe(gcf);
        if(preattentive==0)
        imwrite(ImageCurrent.cdata,strcat(strcat('EyeTracking_',allImages(indice).filename)));
        elseif(preattentive==1)
            imwrite(ImageCurrent.cdata,strcat(strcat('EyeTracking_MOD250_',allImages(indice).filename)));
        elseif(preattentive==2)
            imwrite(ImageCurrent.cdata,strcat(strcat('EyeTracking_MOD500_',allImages(indice).filename)));
        elseif(preattentive==3)
            imwrite(ImageCurrent.cdata,strcat(strcat('EyeTracking_MODNOFIRST250_',allImages(indice).filename)));
        end

        disp('PRESS ENTER TO PASS TO ITTI, ITTI MOD AND MATZEN')
        pause 
        
        params.scaleFact = 1;
        heatFixationsMap=extractHeatMapFromFixations(img,fixations,params);

        map = dvs(img,fixations,whichfix,heatFixationsMap,allImages(indice).filename);

        %utilizza a sua volta un altro script che richiama la costruzione di una
        %mappa di calore
        disp('Press to continue and show img+map')
        pause 
        show_imgnmap( img, map ); 
        ImageCurrent = getframe(gcf);
        if(preattentive==0)
        imwrite(ImageCurrent.cdata,strcat(strcat('IMAGE_HEAT_MAP_',allImages(indice).filename)));
        elseif(preattentive==1)
            imwrite(ImageCurrent.cdata,strcat(strcat('IMAGE_HEAT_MAP_MOD250_',allImages(indice).filename)));
        elseif(preattentive==2)
            imwrite(ImageCurrent.cdata,strcat(strcat('IMAGE_HEAT_MAP_MOD500_',allImages(indice).filename)));
        elseif(preattentive==3)
            imwrite(ImageCurrent.cdata,strcat(strcat('IMAGE_HEAT_MAP_MODNOFIRST250_',allImages(indice).filename)));
        end
    end
end