function [ rHSTO, lHSTO ] = StepIndexing( rFz, lFz )
% This function  uses the vertical ground reaction forces to determine the
% frame indexes when heel strike and toe off occur.  It then finds the
% median step length and removes the steps longer than 1.2 x's the median
% length (when there is crossover) and the corresponding steps on the other
% leg.

rii = 1;  % Toe off indeces
rjj = 1;  % heel strike indeces
i=1;
k=1; % counter
while i < length(rFz)
     if isempty(find(rFz(i:length(rFz)) > 0,1)) == 1 % This will happen if there are no more instances of toe on
         break
     end
     rii(k) = find(rFz(i:length(rFz)) > 0,1) + i - 1; % Find first zero element from last toe on
     if rii(k) == 1 % If data collection started in the middle of a step
        jj_temp = find(rFz(i:length(rFz)) == 0,1) + i - 1; % Find the first toe off
        rii(k) = find(rFz(jj_temp:length(rFz)) > 0,1) + jj_temp - 1; % Find the first toe on
     end
     if isempty(find(rFz(rii(k):length(rFz)) == 0,1)) == 1
         break
     end
     rjj(k) = find(rFz(rii(k):length(rFz)) == 0,1) + rii(k) - 1; % Find first non zero element from last toe off
     if length(rii) == length(rjj)
        i = rjj(k);
     else
        i = i;
        rii(k)=[];
     end
     k = k+1;
end
    
% For left leg
 lii = 1;  % Toe off indeces
 ljj = 1;  % heel strike indeces
 i=1;
 k=1; % counter
while i < length(lFz)
     if isempty(find(lFz(i:length(lFz)) > 0,1)) == 1 % This will happen if there are no more instances of toe on
         break
     end
     lii(k) = find(lFz(i:length(lFz)) > 0,1) + i - 1; % Find first zero element from last heel strike
     if lii(k) == 1 % If data collection started in the middle of a step
        jj_temp = find(lFz(i:length(lFz)) == 0,1) + i - 1; % Find the first toe off
        lii(k) = find(lFz(jj_temp:length(lFz)) > 0,1) + jj_temp - 1; % Find the first heel strike
     end
     if isempty(find(lFz(lii(k):length(lFz)) == 0,1)) == 1
         break
     end
     ljj(k) = find(lFz(lii(k):length(lFz)) == 0,1) + lii(k) - 1; % Find first non zero element from last toe off
     if length(lii) == length(ljj)
        i = ljj(k);
     else
        i = i;
        lii(k)=[];
     end
     k = k+1;
end

% End with toe off
if length(rii) > length(rjj)
    rii(length(rii)) = [];
end
if length(lii) > length(ljj)
    lii(length(lii)) = [];
end

% Create heel strike toe off index matrices for left and right
rHSTO(:,1) = rii;
rHSTO(:,2) = rjj;
lHSTO(:,1) = lii;
lHSTO(:,2) = ljj;

% Start with right foot
if rHSTO(1,1) > lHSTO(1,1)
    lHSTO(1,:) = [];
end

% Make same length
if length(rHSTO) > length(lHSTO)
    rHSTO(end,:)=[];
end