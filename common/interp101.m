function [out] = interp101(in,interpNum)
% This function interpolates by rows for in matrix and spits out an nrows x
% 101 out matrix

if ~exist('interpNum') ; interpNum = 101 ; end

out = zeros(size(in,1),interpNum) ;
for i = 1:size(in,1)
    if max([max(in(i,:)) min(in(i,:))] ~= [0 0]) ~=0
    n = length(find(in(i,:))) ;
    out(i,:) = interp1(1:n,in(i,find(in(i,:))),linspace(1,n,interpNum)) ;
    end
end