function F = textF1(grayimg, boxes)
%Find gradient magnitude and direction of 2-D image
%il primo argomento che ritorna e' quello che ci interessa perche' e' il
%gradient magnitude
%Gradient magnitude, returned as a numeric matrix of the same size as image I. 
%Gmag is of class double, unless the input image or directional gradients are 
%of class single, in which case it is of class single.
%link che spiega il gradiente nelle immagini
%https://stackoverflow.com/questions/19815732/what-is-the-gradient-orientation-and-gradient-magnitude
[gmag, ~] = imgradient(grayimg);

F = zeros(size(grayimg));

for i=1:size(boxes,1)

    xmin = boxes(i,1);
    xmax = boxes(i,2);
    ymin = boxes(i,3);
    ymax = boxes(i,4);
    
    %baricentro del box che stiamo scorrendo
    xcent = round((xmin+xmax)/2);
    ycent = round((ymin+ymax)/2);
    
    %mi soffermo solo su quello che c'e' nel box
    patch = gmag(xmin:xmax, ymin:ymax);
    
    F(xcent, ycent) = (mean(patch(:)))/(std(patch(:))+eps);

end

end