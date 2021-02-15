%compute the union for random fixation map for the metric AUC_shuffled
%clear all; close all; clc
%randomFixationsMaps(645,1000,'enc');
function unionFixations= randomFixationsMaps(size1,size2,whichfix)
%clear all
%close all
%clc

load('/Users/samuelgrassi/Documents/MATLAB/dvs_release_MASSVIS/dvs_release/targets393_metadata_withuserdata.mat')
unionFixations=zeros(size1,size2); 
%size(unionFixations)%645        1000

%prendiamo l'unione di 10 altre fixationsMap
seed=3;
%rng(seed); %->per generare sempre gli stessi numeri causali
global vet
vet=rand(1,10)*393;

for f=1:10 
    if abs(floor(vet(f))-vet(f))>abs(ceil(vet(f))-vet(f))
        vet(f)=ceil(vet(f));
        if(vet(f)==0)
            vet(f)=1;
        end
    else
        vet(f)=floor(vet(f));
        if(vet(f)==0)
            vet(f)=1;
        end
    end    
end
%disp('vet')
%vet

for indice=1:10 
    
    %disp('INDICE')
    %indice
    
    %pause
    
    string='/Users/samuelgrassi/Documents/MATLAB/dvs_release_MASSVIS/dvs_release/visualizationCode/targets/';
    stringa=strcat(string,allImages(vet(indice)).filename);
    new=0;
    booleano=0;
    
    %disp('indice in all images')
    %vet(indice)
    
    while (~isfile(stringa)||ismember(new,vet))
        booleano=1;
        %disp('vet indice not file or member of vet')
        seed=seed+1;
        rng(seed);
        new=rand*393;
        %new
        if abs(floor(new)-new)>abs(ceil(new)-new)
            new=ceil(new);
            if(new==0)
                new=1;
            end
        else
            new=floor(new);
        end
        %disp('new number')
        if(new==0)
            new=1;
        end
        stringa=strcat(string,allImages(new).filename);
    end
    
    if(booleano==1)
        vet(indice)=new;
    end
    
    %vet(indice)
    
    whichusers = 1:length(allImages(vet(indice)).userdata);
    fixations = [];
    for j = 1:length(whichusers)
        whichuser = whichusers(j);
        if isempty(allImages(vet(indice)).userdata(whichuser).fixations) || ...
                ~isfield(allImages(vet(indice)).userdata(whichuser).fixations,whichfix) || ...
                isempty(allImages(vet(indice)).userdata(whichuser).fixations.(whichfix))
            %disp('CONTINUE');
            continue;
        end
        fixdata = allImages(vet(indice)).userdata(whichuser).fixations.(whichfix);
        fixations = [fixations ; fixdata];  
    end
    
    %disp('SIZE FIXATIONS')
    %size(fixations)
    %disp('X')
    %fixations(:,1)
    %disp('Y')
    %fixations(:,2)
    
    %disp('SIZE IMAGE')
    %size(imread(allImages(vet(indice)).impath))
    scale_x=size2/(size(imread(allImages(vet(indice)).impath),2));
    %scale_x
    scale_y=size1/(size(imread(allImages(vet(indice)).impath),1));
    %scale_y
    
    fixations(:,1)=fixations(:,1)*scale_x;
    fixations(:,2)=fixations(:,2)*scale_y;
    %disp('SIZE FIXATIONS')
    %size(fixations)
    %disp('X')
    %fixations(:,1)
    %disp('Y')
    %fixations(:,2)
    
    
    
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

end











