%compute the union for random fixation map for the metric AUC_shuffled
%clear all; close all; clc
%randomFixationsMaps(645,1000,'enc');
function unionFixations= randomFixationsMaps(size1,size2,whichfix)
%clear all
%close all
%clc

%load('/Users/samuelgrassi/Documents/MATLAB/dvs_release/targets393_metadata_withuserdata.mat')

unionFixations=zeros(size1,size2); 
%size(unionFixations)%645        1000

%prendiamo l'unione di 10 altre fixationsMap
seed=3;
%rng(seed); %->per generare sempre gli stessi numeri causali
global vet
vet=rand(1,10)*30;

for f=1:10 
    if abs(floor(vet(f))-vet(f))>abs(ceil(vet(f))-vet(f))
        vet(f)=ceil(vet(f));
        if(vet(f)==30)
            vet(f)=29;
        end
    else
        vet(f)=floor(vet(f));
        if(vet(f)==30)
            vet(f)=29;
        end
    end    
end
%disp('vet')
%vet

for indice=1:10 
    
    disp('IMMAGINE')
    indice
    
    %pause
    
    %string='/Users/samuel/Documents/MATLAB/dvs_release/visualizationCode/targets/';
    string='/Users/samuelgrassi/Documents/MATLAB/dvs_release_EXPERIMENT/dvs_release/excel/IMMAGINI_ESPERIMENTO/im';
    immagine='graph';
    numero_immagine=vet(indice);
    immagine_da_leggere=strcat(immagine,num2str(numero_immagine));

    %stringa=strcat(string,allImages(vet(indice)).filename);
    stringa=strcat(string,num2str(numero_immagine),'/',immagine_da_leggere,'.png');
    
    new=30;
    booleano=0;
    
    %disp('indice in all images')
    %vet(indice)
    
    while (~isfile(stringa)||ismember(new,vet))
        %disp('PROBLEMA CARICAMENTO VETTORE')
        booleano=1;
        %disp('vet indice not file or member of vet')
        seed=seed+1;
        rng(seed);
        new=rand*30;
        %new
        if abs(floor(new)-new)>abs(ceil(new)-new)
            new=ceil(new);
            if(new==30)
                new=29;
            end
        else
            new=floor(new);
        end
        %disp('new number')
        %new
        %stringa=strcat(string,allImages(new).filename);
        numero_immagine=new;
        immagine_da_leggere=strcat(immagine,num2str(numero_immagine));
        %stringa=strcat(string,allImages(vet(indice)).filename);
        stringa=strcat(string,num2str(numero_immagine),'/',immagine_da_leggere,'.png');    
    end
    if(booleano==1)
        vet(indice)=new;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% CARICO LE FISSAZIONI PER L'IMMAGINE
        % accumulate fixations from multiple users (nel for sotto andiamo a 
        fixations = [];
        
        for osservatore=1:62
        
            stringa_excel_parte1='/Users/samuelgrassi/Documents/MATLAB/dvs_release_EXPERIMENT/dvs_release/excel/IMMAGINI_ESPERIMENTO/im';
            numero_osservatore=osservatore;
            stringa_excel_parte_finale='/Cartel1.xlsx';

            %[num,txt,raw] = xlsread('/Users/samuelgrassi/Documents/MATLAB/dvs_release/excel_prova/0/Cartel1.xlsx');
            [num,txt,raw] = xlsread(strcat(stringa_excel_parte1,num2str(numero_immagine),'/oss',num2str(numero_osservatore),stringa_excel_parte_finale));

            campi_struttura_dati=["TimeStamp","GazePointXLeft","GazePointYLeft","ValidityLeft","GazePointXRight","GazePointYRight","ValidityRight","GazePointX","GazePointY","PupilSizeLeft","PupilValidityLeft","PupilSizeRight","PupilValidityRight"];

            struttura_dati=[];
            %mi carica prima i campi della struttura
            for indice_colonna=1:size(campi_struttura_dati,2) %scorro prima riga scorrendo le colonne
                struttura_dati(1).(campi_struttura_dati(indice_colonna))=0;
            end 
            for j=2:size(raw,1) %scorro righe
                for indice_colonna=1:size(campi_struttura_dati,2) %scorro la colonna nella riga
                    struttura_dati(j-1).(campi_struttura_dati(indice_colonna))=raw{j,indice_colonna};
                end
            end
            
            %disp('PAUSA')
            %pause

            righe_elimare=[1, size(struttura_dati,2)];
            %size(struttura_dati) %1 x 4 -> gli oggetti sono il secondo dato
            struttura_dati_senza_testo_zeri=[];
            indice_caricamento=0;
            for i=1:size(struttura_dati,2) %scorro le righe
                if ismember(i,righe_elimare)==0
                    indice_caricamento=indice_caricamento+1;
                    for indice_colonna=1:size(campi_struttura_dati,2) %scorro le colonne nella riga  
                       struttura_dati_senza_testo_zeri(indice_caricamento).(campi_struttura_dati(indice_colonna))=struttura_dati(i).(campi_struttura_dati(indice_colonna));
                    end

                end
            end
            
            %disp('PAUSA')
            %pause
            
            %elimino la seconda metà delle osservazioni per avere le
            %fissazioni solo nei primi 2 secondi e mezzo
            righe_elimare3=[];
            %size(struttura_dati) %1 x 4 -> gli oggetti sono il secondo dato
            struttura_dati_senza_testo_zeri2=[];
            indice_caricamento=0;
            for i=1:size(struttura_dati_senza_testo_zeri,2) %scorro le righe
                if ismember(i,righe_elimare3)==0
                    indice_caricamento=indice_caricamento+1;
                    for indice_colonna=1:size(campi_struttura_dati,2) %scorro le colonne nella riga  
                       struttura_dati_senza_testo_zeri2(indice_caricamento).(campi_struttura_dati(indice_colonna))=struttura_dati_senza_testo_zeri(i).(campi_struttura_dati(indice_colonna));
                    end

                end
            end
            
            %disp('PAUSA')
            %pause
            
              
            %%tolgo gli zeri nella visualizzazione mancata di almeno uno dei
            %%due occhi
            righe_elimare_2=[];
            %for i=1:size(struttura_dati_senza_testo_zeri2,2) %scorro le righe 
            for i=1:size(struttura_dati_senza_testo_zeri2,2) %scorro le righe 
                if (struttura_dati_senza_testo_zeri2(i).(campi_struttura_dati(4))==0 || struttura_dati_senza_testo_zeri2(i).(campi_struttura_dati(7))==0)
                    righe_elimare_2=[righe_elimare_2 i];
                end 
            end

            %pause
            struttura_dati_senza_testo_senza_zeri=[];
            indice_caricamento=0;
            for i=1:size(struttura_dati_senza_testo_zeri2,2) %scorro le righe
                if ismember(i,righe_elimare_2)==0
                    indice_caricamento=indice_caricamento+1;
                    %indice_caricamento
                    %pause
                    for indice_colonna=1:size(campi_struttura_dati,2) %scorro le colonne nella riga  
                       struttura_dati_senza_testo_senza_zeri(indice_caricamento).(campi_struttura_dati(indice_colonna))=struttura_dati_senza_testo_zeri2(i).(campi_struttura_dati(indice_colonna));
                    end

                end
            end
            
            %disp('PAUSA')
            %pause
            
            %disp('LAST FOR');
            %osservatore
            %if(size(struttura_dati_senza_testo_senza_zeri,2)>39)
            if(size(struttura_dati_senza_testo_senza_zeri,2)>49)
                %for j = 40:size(struttura_dati_senza_testo_senza_zeri,2)
                for j = 50:size(struttura_dati_senza_testo_senza_zeri,2)
                    if(struttura_dati_senza_testo_senza_zeri(j).GazePointX<0)
                        struttura_dati_senza_testo_senza_zeri(j).GazePointX=5;
                    end
                    if(struttura_dati_senza_testo_senza_zeri(j).GazePointX>1008)
                        struttura_dati_senza_testo_senza_zeri(j).GazePointX=1000;
                    end
                    if(struttura_dati_senza_testo_senza_zeri(j).GazePointY<0)
                        struttura_dati_senza_testo_senza_zeri(j).GazePointY=5;
                    end
                    if(struttura_dati_senza_testo_senza_zeri(j).GazePointY>864)
                        struttura_dati_senza_testo_senza_zeri(j).GazePointY=860;
                    end
                    fixations = [fixations ; struttura_dati_senza_testo_senza_zeri(j).GazePointX struttura_dati_senza_testo_senza_zeri(j).GazePointY];
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %disp('SIZE IMAGE')
    %size(imread(allImages(vet(indice)).impath))
    scale_x=size2/(1008);
    %scale_x
    scale_y=size1/(864);
    %scale_y
    
    fixations(:,1)=fixations(:,1)*scale_x;
    fixations(:,2)=fixations(:,2)*scale_y;
     
    fixationMap=zeros(size1,size2);
    %size(fixationMap) %645        1000
    nfix=length(fixations(:,1));
    
    for f=1:nfix
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
        
        if(fixations(f,1)==0)
           fixations(f,1)=1;
        end
        if(fixations(f,2)==0)
           fixations(f,2)=1;
        end
        
        %la prima componente e' la y perche' ragiona come una matrice
        fixationMap(fixations(f,2),fixations(f,1))=1;
    
    end

    %disp('PRESS TO ANALIZE THE NEXT IMAGE')
    %pause
    
    unionFixations=unionFixations+fixationMap;
    
end

%size(unionFixations) %645        1000
%sum(sum(unionFixations)) %6681
end











