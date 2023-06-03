function [b a] = notchFilter(notchFreq,samprate,notchWidth)

fs = samprate;             %#sampling rate
f0 = notchFreq;                %#notch frequency
fn = fs/2;              %#Nyquist frequency
freqRatio = f0/fn;      %#ratio of notch freq. to Nyquist freq.

if nargin<3
    notchWidth = 0.01;       %#width of the notch (0.01 has ~10hz width)
end

%Compute zeros
notchZeros = [exp( sqrt(-1)*pi*freqRatio ), exp( -sqrt(-1)*pi*freqRatio )];

%#Compute poles
notchPoles = (1-notchWidth) * notchZeros;

figure;
zplane(notchZeros.', notchPoles.');

b = poly( notchZeros ); %# Get moving average filter coefficients
a = poly( notchPoles ); %# Get autoregressive filter coefficients

% figure;
% freqz(b,a,32000,fs)

%#filter signal x
% y = filter(b,a,x);