function [data coefficients] = CriticallyDampedFilter(data,n,hp,lp,fs);

% n        number of filter passes
% data     data to be filtered
% Lo       3dB cutoff wavelength 
% fo=1/Lo  3dB cutoff frequency 
% fs       sampling_frequency; 
% lp, hp   lowpass and highpass cutoff frequencies
% polynomial coefficients
g=1; p=2; 

if isempty(lp)==1; lp=1; end
if isempty(hp)==1; hp=1; end

% 3 dB cutoof correction
Clp = (2^(1/(2*n))-1)^-0.5;
Chp = (2^(1/(2*n))-1)^0.5;

% corrected cutoff frequency, f*=c*fo/fs
flp = Clp*(lp/fs);
fhp = 0.5-Chp*(hp/fs);

% warp cutoff frequency from analog to digital domain
wolp = tan(pi*flp);
wohp = tan(pi*fhp);

% filter coefficient calculations, K1 and K2
K1lp = p*wolp;
K1hp = p*wohp;

K2lp = g*wolp^2;
K2hp = g*wohp^2;

% filter coefficient calculations, 
% Low-pass: a0=A0, a1=A1, a2=A2, b1=B1, b2=B2
% Low-pass: a0=A0, a1=-A1, a2=A2, b1=-B1, b2=B2
a0lp = K2lp/(1+K1lp+K2lp) 
a0hp = K2hp/(1+K1hp+K2hp); 

a1lp = 2*a0lp 
a1hp = -2*a0hp;

a2lp=a0lp 
a2hp=a0hp; 

b1lp = 2*a0lp*((1/K2lp)-1) 
b1hp = -2*a0hp*((1/K2hp)-1); 

b2lp = 1-(a0lp+a1lp+a2lp+b1lp)
b2hp = 1-(a0hp-a1hp+a2hp-b1hp); % different because a1=-A1 and b1=-B1
% 
% % You can cancel the overshoot of a Butterworth with the lag of the
% % critically-damped filter to obtain another critically-damped filter that
% % has the positive features of both. 
% % For example, a Butterworth of cutoff frequency 2*fo cascaded with a two
% % critically-damped filters of cutoff fo will result in a critically-damped 
% % filter that has less lag than the original critically-damped filter 
% % cascaded 3 times, yet greater stopband attenuation (steeper falloff). 
% 
% [a b]=size(data) ;
% data_filt = zeros(a,b) ;
% 
% % Low-pass filter
% for order=1:n % Order of filter (i.e. 4th order = forward, backward, forward, backward)
%     for i=1:b
%         for k=3:a
%             data_filt(k,i) = a0lp*data(k,i) + a1lp*data(k-1,i) + a2lp*data(k-2,i) + b1lp*data_filt(k-1,i) + b2lp*data_filt(k-2,i);
%         end
%     end
% %     data_filt(1:2,:) = data(1:2,:) ;
%     data = flipud(data_filt);
% %     data = data_filt ;
%     data_filt=zeros(a,b);
% end

coefficients = [0 b1lp b2lp a0lp a1lp a2lp] ;