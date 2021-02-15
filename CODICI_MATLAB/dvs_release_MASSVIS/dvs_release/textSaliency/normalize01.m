function [ map ] = normalize01( map )
%NORMALIZE Summary of this function goes here
%  a simple function that normalizes an input map to a range of 0 to 1
%  using linear transformation

%   Detailed explanation goes here

map = (map - min(map(:)))/(max(map(:))-min(map(:)));

end

