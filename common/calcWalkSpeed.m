function [avgWalkSpeed] = calcWalkSpeed(toexpos,HSTO,samprate_m)
%function [avgWalkSpeed] = untitled(toexvel,HSTO)
%   This function takes in the vector of x-positions for the toe marker,
%   HSTO matrix, and the sample rate for the markers and calculates the 
%   average walking speed

% Differentiate the positions and make positive
vel = -diff(toexpos)*samprate_m;
low = floor(mean(HSTO(:,2) - HSTO(:,1))/10*3);
high = floor(mean(HSTO(:,2) - HSTO(:,1))/10*6);

for i = 1:length(HSTO)
    avgWalkSpeed(i) = mean(vel(HSTO(i,1)+low:(HSTO(i,1)+high)));
end

avgWalkSpeed = mean(avgWalkSpeed);