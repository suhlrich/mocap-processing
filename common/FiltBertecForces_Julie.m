function forcesfilt_function = FiltBertecForces_Julie(force_raw,indicies,samprate,filt_freq,threshold_high,threshold_low)
% indicies are [start_right end_right fz_right; start_left end_left fz_left]
% force_raw are actually filtered, converted into N and into the motion capture reference frame

% For testing as a script
% filt_freq = 9 ; %Hz
% samprate = 60 ; %Hz
% indicies = [1 7 3;8 14 10] ;
% force_raw = forces_proc ;
% threshold_high = 200 ;
% threshold_low = 40 ;
%

% Default Parameters
if isempty(threshold_high) == 1
    threshold_high = 200 ; %N
end
if isempty(threshold_low) == 1
    threshold_low = 40 ; %N
end
if isempty(filt_freq) == 1
    filt_freq = 15 ; %Hz
end

% Zeroing step with high threshold
forcesfilt_function = zeros(size(force_raw)) ;

for i = 1:2 % Do this for all of the right, then all of the left data
    f_raw = force_raw(:,indicies(i,1):indicies(i,2)) ; % All columns, indicy row 1 then row 2
    fz = force_raw(:,indicies(i,3)) ; % Only vertical forces
    force_firstzero = zeros(size(fz)) ;
    force_secondzero = zeros(size(f_raw)) ;
    
    % Find all vertical forces above the high threshold, and zero the rest
    ind = find(fz>threshold_high) ;
    force_firstzero(ind) = fz(ind) ;
    
    % Filter the z trace with Critically Damped
%     filteredz = CriticallyDampedFilter(force_firstzero,2,[],filt_freq,samprate);
    
    % Critically damped filter from Robertson and Dowling 2003 paper (might
    % be same as CriticallyDampedFilter above?)
    [B_f,A_f] = critCoeff(samprate, filt_freq, 2);
    filteredz= filtfilt(B_f,A_f,force_firstzero);
    
    %%%%%%%%%%%%%%%%This was when we were using 4th order Butterworth
%     [B_f,A_f] = butter(4,filt_freq/(samprate/2)) ;
%     filteredz = filtfilt(B_f,A_f,force_firstzero) ; % this is just the z trace
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    filteredforces = f_raw;
    filteredforces(:,3) = filteredz ; % Replace the vertical forces with your new vertical forces
        
    % Find all vertical forces above the low threshold, and zero the rest
    ind = find(filteredz>threshold_low) ;
    force_secondzero(ind,:) = filteredforces(ind,:) ; 
    
    % Replace all forces and moments with zerod data
    forcesfilt_function(:,indicies(i,1):indicies(i,2)) = force_secondzero ;
end



