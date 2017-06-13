function [APDx_duration]=Evaluate_APDx(time,AP,APDx_50_time_upstroke_current,AP_peaks_locations_current,AP_endRepos_locations_current,...
                                   AP_peaks_current, AP_amplitudes_peak_to_endRepos_current,...
                                   x_current,AP_troughs_current,y_offset_current);
                               
%% This function is designed to calculate the APDx 
%% APDx was calculated to be the time interval between when signals reached
%% 50% of the difference in fluorescence between the initiation and maximal
%% height of an upstroke, and x% of the return to diastolic baseline. 
%% Author: Dr Vicky Wang
%% Last date of modification: 23/05/2017


%% Calculate x% of the return to diastolic baseline
time_peak_to_trough=time(AP_peaks_locations_current:AP_endRepos_locations_current);
AP_peak_to_trough=AP(AP_peaks_locations_current:AP_endRepos_locations_current);
% This is equivalent to 
% AP_endRepos_current+AP_amplitudes_peak_to_endRepos_current*(1-x_current)
APDx_amplitude=AP_peaks_current-AP_amplitudes_peak_to_endRepos_current*x_current;
AP_diff=abs(AP_peak_to_trough-APDx_amplitude);
AP_index=find(AP_diff==min(AP_diff));
APDx_time=time_peak_to_trough(AP_index);
APDx_duration=APDx_time-APDx_50_time_upstroke_current;
% Plot the x% return to diastolic baseline
subplot(2,1,2),plot(APDx_time,APDx_amplitude,'ys','MarkerEdge','k','MarkerFace','y','MarkerSize',10);
% Plot the duration
subplot(2,1,2),quiver(APDx_50_time_upstroke_current,(AP_troughs_current-y_offset_current),APDx_duration,0,0,'b-<','LineWidth',2);
subplot(2,1,2),text((APDx_50_time_upstroke_current+APDx_duration/2),(AP_troughs_current-y_offset_current-0.005),sprintf('%.0fms',APDx_duration),'FontSize',10);
hold on;
return