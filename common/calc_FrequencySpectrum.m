function [frequency power] = calc_FrequencySpectrum(signal,sampFreq) ;

n = length(signal);
y = fft(signal);               % fft of signal
y0 = fftshift(y);           % shift y values
fhalf = (0:n/2-1)*(sampFreq/n);    % positive frequency range
p0 = abs(y0).^2/n;          % 0-centered power
p0half = p0(n/2+1:n) ;        % second half of 0 centered power

frequency = fhalf ;
power = p0half ;