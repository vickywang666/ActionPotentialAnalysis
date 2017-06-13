function [period,dt]=finding_freq(tvec,Ca)

% This function is designed to calculate the frequency of the calcium
% signal

% assuming t is in s, convert to Fs in Hz
dt = tvec(2)-tvec(1);
Fs = 1/dt;

% use a matlab file exchange FFT function, Ca-mean(Ca) to remove DC offset
[amp, freq] = findFFT(Ca-mean(Ca),'-sampFreq',Fs);

% enable to see the power specturm, the dominant frequency is the peak
%plot(freq,amp);

% find the dominant frequency (in Hz) by finding the max power
[d, ind] = max(amp);

% calculate the approximate period of the signal
period=1/freq(ind);

% x60 to cover to beats per minute
%d_freq = freq(ind)*60;
%disp(['The dominant frequency is: ', num2str(round(d_freq*100)/100), ' bpm'])

return