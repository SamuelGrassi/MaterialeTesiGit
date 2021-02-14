%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%QUESTO CODICE E' PER L'ESPERIMENTO CON L'EYE TRACKER%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc

%load('/Users/samuelgrassi/Documents/MATLAB/dvs_release/targets393_metadata_withuserdata.mat')

dvs_install 

%ELENCO CODICI IN BASE ALL'OPERAZIONE CHE SI VUOLE SVOLGERE
%codice=0 -> viene calcolata la mappa di calore dai punti veri di
%fissazione, le metriche con le rispettive saliency map relative all'algoritmo 
%di Itti, Itti modificato e Matzen
%codice=1 -> viene calcolata la distribuzione dei punti tra orizzontale e
%verticale con la creazione dei rettangoli
codice=1;
%0 si considerano tutte le fissazioni nei 5 secondi
%1 si considerano solo i primi 2,5 s di osservazione
%2 si considera solo il primo secondo di osservazione
preattentive=0; 

string='/Users/samuelgrassi/Documents/MATLAB/dvs_release_EXPERIMENT/dvs_release/visualizationCode/targets/';
string_immagini='/Users/samuelgrassi/Documents/MATLAB/dvs_release_EXPERIMENT/dvs_release/excel/IMMAGINI_ESPERIMENTO/im';
immagine='graph';
numero_immagine=0; %indice da 0 a 29 per scorrere tutte le immagini

whichfix = 'enc'; % or 'rec'
params = struct();
params.thresh = 0.1;
params.sigma = 32;
params.scaleFact = 4; % a larger number speeds up computation
    
immagine_da_leggere=strcat(immagine,num2str(numero_immagine));
stringa_immagine_eye_tracking=strcat(string_immagini,num2str(numero_immagine),'/',immagine_da_leggere,'.png')
%pause
   
img=imread(stringa_immagine_eye_tracking);
image(img)

imsize = [size(img,1),size(img,2)]
maxsize = max(imsize(1),imsize(2));

disp('PRESS TO COMPUTE THE FIXATIONS');
pause
        
%% CARICO LE FISSAZIONI PER L'IMMAGINE
fixations = [];

for osservatore=1:62

    stringa_excel_parte1='/Users/samuelgrassi/Documents/MATLAB/dvs_release_EXPERIMENT/dvs_release/excel/IMMAGINI_ESPERIMENTO/im';
    numero_osservatore=osservatore;
    stringa_excel_parte_finale='/Cartel1.xlsx';

    [num,txt,raw] = xlsread(strcat(stringa_excel_parte1,num2str(numero_immagine),'/oss',num2str(numero_osservatore),stringa_excel_parte_finale));

    campi_struttura_dati=["TimeStamp","GazePointXLeft","GazePointYLeft","ValidityLeft","GazePointXRight","GazePointYRight","ValidityRight","GazePointX","GazePointY","PupilSizeLeft","PupilValidityLeft","PupilSizeRight","PupilValidityRight"];

    struttura_dati=[];
    %carica prima i campi della struttura
    for indice_colonna=1:size(campi_struttura_dati,2) %scorro la prima riga del file scorrendo le colonne
        struttura_dati(1).(campi_struttura_dati(indice_colonna))=0;
    end 
    
    for j=2:size(raw,1) %scorro le righe per caricare i dati degli osservatori
        for indice_colonna=1:size(campi_struttura_dati,2) %scorro la colonna nella riga
            struttura_dati(j-1).(campi_struttura_dati(indice_colonna))=raw{j,indice_colonna};
        end
    end

    %elimino le due righe che delimitano l'immagine
    righe_elimare=[1, size(struttura_dati,2)];
    %nuova struttura dati con quello che rimane
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
    
    if(preattentive>0)
        if(preattentive==2)
            %elimino gli ultimi 4/5
            righe_elimare3=[ceil(size(struttura_dati_senza_testo_zeri,2)/5):size(struttura_dati_senza_testo_zeri,2)];
        else
            %elimino la seconda meta'
            righe_elimare3=[ceil(size(struttura_dati_senza_testo_zeri,2)/2):size(struttura_dati_senza_testo_zeri,2)];
        end
    else
        righe_elimare3=[];
    end
    %struttura dati rimanente in base ad un'analisi globale o preattentive
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

    %tolgo gli zeri nella visualizzazione fallita di almeno uno dei
    %due occhi
    righe_elimare_2=[];
    for i=1:size(struttura_dati_senza_testo_zeri2,2) %scorro le righe 
        if (struttura_dati_senza_testo_zeri2(i).(campi_struttura_dati(4))==0 || struttura_dati_senza_testo_zeri2(i).(campi_struttura_dati(7))==0)
            righe_elimare_2=[righe_elimare_2 i];
        end 
    end
    %struttura dati finale caricata con i punti di osservazione di
    %interesse
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

    osservatore %stampiamo il numero di osservatore a quale siamo per avere indicazione dell'avanzamento del codice
    %escludiamo i primi punti di osservazione che tipicamente sono
    %concentrati nella parte centrale dell'immagine e quindi sono
    %irrilevanti.
    if(preattentive>0)
        punti_da_escludere=29;
    else
        punti_da_escludere=49;
    end
    if(size(struttura_dati_senza_testo_senza_zeri,2)>punti_da_escludere)
        for j = (punti_da_escludere+1):size(struttura_dati_senza_testo_senza_zeri,2)
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

end %fine ciclo osservatori


disp('TOTAL FIXATIONS');
size(fixations) 

disp('PRESS ENTER TO CONTINUE');
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%CORREGGERE FISSAZIONI IN NUMERI INTERI%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%convertiamo i punti di osservazione in interi per poterli rappresentare
%graficamente 
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

end

disp('TOTAL FIXATIONS');
size(fixations)  
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%COSTRUZIONE RETTANGOLI%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%costruisco rettangoli per la dispersione dei punti sull'immagine
if(codice>0)
    %creo il primo rettangolo e poi lo traslo su tutta l'immagine
    punto1=[0 0];
    punto2=[0 28.8];
    punto4=[33.6 0];
    punto3=[33.6 28.8];
    rettangolo{1,1}=[punto1; punto2; punto3; punto4];
    rettangolo{2,1}=0;

    for ret=2:900
        rettangolo{2,ret}=0;
        if(abs(punto4(1,1)-1008)<1e-2) %sono all'estremo orizzontale quindi devo andare a capo
            punto1=punto1+[0 28.8];
            punto2=punto2+[0 28.8];
            punto3=punto3+[0 28.8];
            punto4=punto4+[0 28.8]; 
            punto1(1,1)=0;
            punto2(1,1)=0;
            punto3(1,1)=33.6;
            punto4(1,1)=33.6;
        else
            %sposto tutti i punti orizzontalmente
            punto1=punto1+[33.6 0];
            punto2=punto2+[33.6 0];
            punto3=punto3+[33.6 0];
            punto4=punto4+[33.6 0];
        end
        rettangolo{1,ret}=[punto1; punto2; punto3; punto4];
    end


    %% CALCOLO NUMERI PUNTI DI FISSAZIONE SU OGNI RETTANGOLO
    for nfix=1:size(fixations,1)
        for ret=1:900
            %controllo se sono dentro al rettangolo 'ret' con la
            %fissazione 'nfix' 
            if(rettangolo{1,ret}(1,1)<=fixations(nfix,1)&&rettangolo{1,ret}(3,1)>=fixations(nfix,1)&&rettangolo{1,ret}(1,2)<=fixations(nfix,2)&&rettangolo{1,ret}(3,2)>=fixations(nfix,2))
                rettangolo{2,ret}=rettangolo{2,ret}+1;
                break;
            end   
        end
    end

    %STAMPIAMO IN UN FILE DI TESTO IN USCITA I RETTANGOLI
    fileID=fopen(strcat('FILE_TEXT_900_',immagine_da_leggere),'w');
    fprintf(fileID,'900 RETTANGOLI: 33.6 -> ASSE X, 28.8 -> ASSE Y\n\n');

    for ret=1:900
        fprintf(fileID,'RETTANGOLO ');
        fprintf(fileID,num2str(ret));
        fprintf(fileID,': ');
        fprintf(fileID,num2str(rettangolo{2,ret}));
        fprintf(fileID,' FISSAZIONI \n');
    end
    fclose(fileID);

    %% PLOT RETTANGOLI SU IMMAGINE
    %scrivo il testo sui rettangoli in cui ci sia almeno 1 punto di
    %fissazione
    for j=1:900
        punti_x=[];
        punti_y=[];
        for punti_pol=1:4
            punti_x=[punti_x; rettangolo{1,j}(punti_pol,1)];
            punti_y=[punti_y; rettangolo{1,j}(punti_pol,2)];
        end
        punti_x(size(punti_x,1)+1)=punti_x(1);
        punti_y(size(punti_y,1)+1)=punti_y(1);
        [punti_x punti_y];
        set(gca,'Ydir','reverse')
        plot(punti_x, punti_y);
        valutazione_x=[1; 500; 989; 600; 507; 980];
        valutazione_y=[1;650;620;660;620; 630];
        in=inpolygon(valutazione_x, valutazione_y, punti_x, punti_y);

        if(rettangolo{2,j}>0)
            x_medio=(rettangolo{1,j}(1,1)+rettangolo{1,j}(3,1))/2;
            y_medio=(rettangolo{1,j}(1,2)+rettangolo{1,j}(2,2))/2;
            x_coordinata=x_medio-9.0;
            y_coordinata=y_medio;
            text(x_coordinata,y_coordinata,num2str(rettangolo{2,j}),'FontSize',6);
        end         
        hold on       
    end

    ImageCurrent = getframe(gcf);
    imwrite(ImageCurrent.cdata,strcat(strcat('RETTANGOLO_900_',immagine_da_leggere),'.jpg'));

    disp('PREMI ENTER PER PASSARE ALLA SOGLIA DI 10 PUNTI DI FISSAZIONE')
    pause

    %scrivo il testo sui rettangoli in cui ci sono almeno 10 punti di
    %fissazione
    for j=1:900
        punti_x=[];
        punti_y=[];
        for punti_pol=1:4
            punti_x=[punti_x; rettangolo{1,j}(punti_pol,1)];
            punti_y=[punti_y; rettangolo{1,j}(punti_pol,2)];
        end
        punti_x(size(punti_x,1)+1)=punti_x(1);
        punti_y(size(punti_y,1)+1)=punti_y(1);
        [punti_x punti_y];
        set(gca,'Ydir','reverse')
        plot(punti_x, punti_y);
        valutazione_x=[1; 500; 989; 600; 507; 980];
        valutazione_y=[1;650;620;660;620; 630];
        in=inpolygon(valutazione_x, valutazione_y, punti_x, punti_y);

        if(rettangolo{2,j}>9)
            x_medio=(rettangolo{1,j}(1,1)+rettangolo{1,j}(3,1))/2;
            y_medio=(rettangolo{1,j}(1,2)+rettangolo{1,j}(2,2))/2;
            x_coordinata=x_medio-9.0;
            y_coordinata=y_medio;
            text(x_coordinata,y_coordinata,num2str(rettangolo{2,j}),'FontSize',6);
        end         
        hold on       
    end 

    ImageCurrent = getframe(gcf);
    imwrite(ImageCurrent.cdata,strcat(strcat('RETTANGOLO_900_10_',immagine_da_leggere),'.jpg'));

    disp('PREMI ENTER PER PASSARE ALLA SOGLIA DI 20 PUNTI DI FISSAZIONE')
    pause

    for j=1:900
        punti_x=[];
        punti_y=[];
        for punti_pol=1:4
            punti_x=[punti_x; rettangolo{1,j}(punti_pol,1)];
            punti_y=[punti_y; rettangolo{1,j}(punti_pol,2)];
        end
        punti_x(size(punti_x,1)+1)=punti_x(1);
        punti_y(size(punti_y,1)+1)=punti_y(1);
        [punti_x punti_y];
        set(gca,'Ydir','reverse')
        plot(punti_x, punti_y);
        valutazione_x=[1; 500; 989; 600; 507; 980];
        valutazione_y=[1;650;620;660;620; 630];
        in=inpolygon(valutazione_x, valutazione_y, punti_x, punti_y);

        if(rettangolo{2,j}>19)
            x_medio=(rettangolo{1,j}(1,1)+rettangolo{1,j}(3,1))/2;
            y_medio=(rettangolo{1,j}(1,2)+rettangolo{1,j}(2,2))/2;
            x_coordinata=x_medio-9.0;
            y_coordinata=y_medio;
            text(x_coordinata,y_coordinata,num2str(rettangolo{2,j}),'FontSize',6);
        end         
        hold on       
    end

    ImageCurrent = getframe(gcf);
    imwrite(ImageCurrent.cdata,strcat(strcat('RETTANGOLO_900_20_',immagine_da_leggere),'.jpg'));


    disp('PREMI ENTER PER PASSARE ALLA SOGLIA DI 30 PUNTI DI FISSAZIONE')
    pause

    for j=1:900
        punti_x=[];
        punti_y=[];
        for punti_pol=1:4
            punti_x=[punti_x; rettangolo{1,j}(punti_pol,1)];
            punti_y=[punti_y; rettangolo{1,j}(punti_pol,2)];
        end
        punti_x(size(punti_x,1)+1)=punti_x(1);
        punti_y(size(punti_y,1)+1)=punti_y(1);
        [punti_x punti_y];
        set(gca,'Ydir','reverse')
        plot(punti_x, punti_y);
        valutazione_x=[1; 500; 989; 600; 507; 980];
        valutazione_y=[1;650;620;660;620; 630];
        in=inpolygon(valutazione_x, valutazione_y, punti_x, punti_y);

        if(rettangolo{2,j}>29)
            x_medio=(rettangolo{1,j}(1,1)+rettangolo{1,j}(3,1))/2;
            y_medio=(rettangolo{1,j}(1,2)+rettangolo{1,j}(2,2))/2;
            x_coordinata=x_medio-9.0;
            y_coordinata=y_medio;
            text(x_coordinata,y_coordinata,num2str(rettangolo{2,j}),'FontSize',6);
        end         
        hold on       
    end

    ImageCurrent = getframe(gcf);
    imwrite(ImageCurrent.cdata,strcat(strcat('RETTANGOLO_900_30_',immagine_da_leggere),'.jpg'));


    disp('PREMI ENTER PER PASSARE AL CALCOLO CON 400 RETTANGOLI')
    pause
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%NUOVI RETTANGOLI%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%400 RETTANGOLI 
    punto1=[0 0];
    punto2=[0 43.2];
    punto4=[50.4 0];
    punto3=[50.4 43.2];
    rettangolo{1,1}=[punto1; punto2; punto3; punto4];
    rettangolo{2,1}=0;

    for ret=2:400
        rettangolo{2,ret}=0;
        if(abs(punto4(1,1)-1008)<1e-2) %sono all'estremo orizzontale quindi devo andare a capo
            punto1=punto1+[0 43.2];
            punto2=punto2+[0 43.2];
            punto3=punto3+[0 43.2];
            punto4=punto4+[0 43.2]; 
            punto1(1,1)=0;
            punto2(1,1)=0;
            punto3(1,1)=50.4;
            punto4(1,1)=50.4;
        else
            %posso spostare tutti i punti orizzontalmente
            punto1=punto1+[50.4 0];
            punto2=punto2+[50.4 0];
            punto3=punto3+[50.4 0];
            punto4=punto4+[50.4 0];
        end
        rettangolo{1,ret}=[punto1; punto2; punto3; punto4];
    end


    %% NUMERI PUNTI DI FISSAZIONE SU OGNI RETTANGOLO
    for nfix=1:size(fixations,1)
        for ret=1:400
            %controllo se sono dentro al rettangolo 'ret' con la
            %fissazione 'nfix' 
            if(rettangolo{1,ret}(1,1)<=fixations(nfix,1)&&rettangolo{1,ret}(3,1)>fixations(nfix,1)&&rettangolo{1,ret}(1,2)<fixations(nfix,2)&&rettangolo{1,ret}(3,2)>=fixations(nfix,2))
                rettangolo{2,ret}=rettangolo{2,ret}+1;
                break;
            end   
        end
    end

    %STAMPIAMO IN UN FILE DI TESTO IN USCITA I RETTANGOLI
    fileID=fopen(strcat('FILE_TEXT_400_',immagine_da_leggere),'w');
    fprintf(fileID,'400 RETTANGOLI: 50.4 -> ASSE X, 43.2 -> ASSE Y\n\n');

    for ret=1:400
        fprintf(fileID,'RETTANGOLO ');
        fprintf(fileID,num2str(ret));
        fprintf(fileID,': ');
        fprintf(fileID,num2str(rettangolo{2,ret}));
        fprintf(fileID,' FISSAZIONI \n');
    end
    fclose(fileID);

    %% PLOT RETTANGOLI SU IMMAGINE
    %soglia dei 30 punti di fissazione
    for j=1:400
        punti_x=[];
        punti_y=[];
        for punti_pol=1:4
            punti_x=[punti_x; rettangolo{1,j}(punti_pol,1)];
            punti_y=[punti_y; rettangolo{1,j}(punti_pol,2)];
        end
        punti_x(size(punti_x,1)+1)=punti_x(1);
        punti_y(size(punti_y,1)+1)=punti_y(1);
        [punti_x punti_y];
        set(gca,'Ydir','reverse')
        plot(punti_x, punti_y);
        valutazione_x=[1; 500; 989; 600; 507; 980];
        valutazione_y=[1;650;620;660;620; 630];
        in=inpolygon(valutazione_x, valutazione_y, punti_x, punti_y);

        if(rettangolo{2,j}>29)
            x_medio=(rettangolo{1,j}(1,1)+rettangolo{1,j}(3,1))/2;
            y_medio=(rettangolo{1,j}(1,2)+rettangolo{1,j}(2,2))/2;
            x_coordinata=x_medio-9.0;
            y_coordinata=y_medio;
            text(x_coordinata,y_coordinata,num2str(rettangolo{2,j}),'FontSize',6);
        end         
        hold on       
    end

    ImageCurrent = getframe(gcf);
    imwrite(ImageCurrent.cdata,strcat(strcat('RETTANGOLO_400_30_',immagine_da_leggere),'.jpg'));

    disp('PREMI ENTER PER PASSARE ALLA SOGLIA DI 40 PUNTI DI FISSAZIONE')
    pause

    for j=1:400
        punti_x=[];
        punti_y=[];
        for punti_pol=1:4
            punti_x=[punti_x; rettangolo{1,j}(punti_pol,1)];
            punti_y=[punti_y; rettangolo{1,j}(punti_pol,2)];
        end
        punti_x(size(punti_x,1)+1)=punti_x(1);
        punti_y(size(punti_y,1)+1)=punti_y(1);
        [punti_x punti_y];
        set(gca,'Ydir','reverse')
        plot(punti_x, punti_y);
        valutazione_x=[1; 500; 989; 600; 507; 980];
        valutazione_y=[1;650;620;660;620; 630];
        in=inpolygon(valutazione_x, valutazione_y, punti_x, punti_y);

        if(rettangolo{2,j}>39)
            x_medio=(rettangolo{1,j}(1,1)+rettangolo{1,j}(3,1))/2;
            y_medio=(rettangolo{1,j}(1,2)+rettangolo{1,j}(2,2))/2;
            x_coordinata=x_medio-9.0;
            y_coordinata=y_medio;
            text(x_coordinata,y_coordinata,num2str(rettangolo{2,j}),'FontSize',6);
        end         
        hold on       
    end

    ImageCurrent = getframe(gcf);
    imwrite(ImageCurrent.cdata,strcat(strcat('RETTANGOLO_400_40_',immagine_da_leggere),'.jpg'));

end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%FINE RETTANGOLI%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%% plot fixations and fixation heatmap

if(codice==0)
    
    image(img)  
    hold on
    for j=1:size(fixations,1)
        hold on
        plot(fixations(j,1),fixations(j,2),'r+')
    end
    ImageCurrent = getframe(gcf);
    imwrite(ImageCurrent.cdata,strcat(strcat('IMAGE_FIXATIONS_',immagine_da_leggere),'.png'));

    disp('press enter to continue and compute heatmap');
    pause
    
    plotFixationHeatmap(img, fixations, params);
    ImageCurrent = getframe(gcf);
    imwrite(ImageCurrent.cdata,strcat(strcat('IMAGE_HEAT_MAP_62_',immagine_da_leggere),'.png'));

    params.scaleFact = 1;
    
    disp('PRESS ENTER AND COMPUTE ITTI, ITTI MOD AND MATZEN')
    pause
    
    heatFixationsMap=extractHeatMapFromFixations(img,fixations,params);

    map = dvs(img,fixations,whichfix,heatFixationsMap,strcat(immagine_da_leggere,'.png'));

    disp('PRESS ENTER TO PRODUCE MATZEN HEATMAP')
    pause

    show_imgnmap( img , map ); 
    ImageCurrent = getframe(gcf);
    imwrite(ImageCurrent.cdata,strcat(strcat('Final_',immagine_da_leggere),'.png'));
end