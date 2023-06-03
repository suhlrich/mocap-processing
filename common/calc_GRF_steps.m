function [Fx Fy Fz Fmag COPx COPy] = calc_F_steps(forces,step_frames,leg) ;

Fx_raw = forces(:,1) ;
Fy_raw = forces(:,2) ;
Fz_raw = forces(:,3) ;
COPx_raw = forces(:,4) ;
COPy_raw = forces(:,5) ;

if leg == 'l'
    Fy_raw = -Fy_raw ;
end

recframes = step_frames ;
    Fx = zeros(size(recframes)) ; Fy = Fx ; Fz = Fx; Fmag = Fx ; COPx = Fx; COPy = Fx ;
    
    if max(max(recframes)) > length(Fx_raw) % more frames in matlab than cortex
        lastrecframe = max(find(max(recframes')>length(Fx_raw),1)) - 1 ;  % Find last frame that is fully captured by cortex (if stopped cortex first :/ )
    else % more frames in cortex (how it should be)
        lastrecframe = size(recframes,1) ;
    end
    
    for ii = 1:lastrecframe
        if recframes(ii,1) ~= 0
        n = length(find(recframes(ii,:))) ;
        n_frames = range(recframes(ii,1):recframes(ii,n))+1 ;
        Fx(ii,1:n_frames) = Fx_raw(recframes(ii,1):recframes(ii,n))' ;
        Fy(ii,1:n_frames) = Fy_raw(recframes(ii,1):recframes(ii,n))' ;
        Fz(ii,1:n_frames) = Fz_raw(recframes(ii,1):recframes(ii,n))' ;
        COPx(ii,1:n_frames) = COPx_raw(recframes(ii,1):recframes(ii,n))' ;
        COPy(ii,1:n_frames) = COPy_raw(recframes(ii,1):recframes(ii,n))' ;
        end
    end    
    
    Fmag = sqrt(Fx.^2+Fy.^2+Fz.^2) ;
    