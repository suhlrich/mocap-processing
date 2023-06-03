function [interpOut] = interpTrace(mat_in) 
% traces should be along a row, the second trace would be row 2

n = size(mat_in,1) ;
interpOut = zeros(n,101) ;

for i = 1:n
    vec = mat_in(i,find(mat_in(i,:)~=0)) ;
    x = linspace(1,101,length(vec)) ;
    interpOut(i,:) = interp1(x,vec,1:101) ; 
end