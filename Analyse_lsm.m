function [time,AP_percentage,AP_properties_all]=Analyse_lsm(output_dir_main,image_name_current,pixel_time,number_of_pixels)

%% This function is designed to extract detailed actio potential properties 
%% Author: Dr Vicky Wang
%% Last date of modification: 26/05/2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Read in the data                        %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in the raw lsm image, data are in unit8 format
lsm_image=imread(image_name_current);
% Tranpose the data
lsm_image=lsm_image';
% Plot the raw lsm image
%figure(1)
%imshow(lsm_image,[]);
% Extract the size of the image
number_rows=size(lsm_image,1);
number_columns=size(lsm_image,2);
% To extract the action potential, average the signal at each of the
% scanned line
lsm_image_average=zeros(number_columns,1);
for j=1:number_columns
    lsm_current_line=lsm_image(:,j);
    lsm_current_line_average=mean(lsm_current_line);
    lsm_image_average(j)=1/lsm_current_line_average;
end

% Plot the extracted action potentials
screensize = get( groot, 'Screensize' );
current_figure=figure('units','normalized','outerposition',[0 0 1 1]);
image_title=image_name_current(strfind(image_name_current,'Image'):end);
space_index=strfind(image_title,'lsm');
% Remove the white space in the file name
image_title(space_index+3:end)=[];
title_name=[image_title,' Action Potential Properties'];
title(title_name,'FontSize',16);
hold on;
lsm_current_line_average_column=linspace(1,number_columns,number_columns);
% Convert the horizontal axis to time
time=lsm_current_line_average_column'.*pixel_time.*number_of_pixels;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Smooth the data before further analysis %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'sgolay' — Savitzky-Golay filter, which smooths according to a quadratic polynomial that is fitted over each window of A. This method can be more effective than other methods when the data varies rapidly.
lsm_image_average_smooth=smoothdata(lsm_image_average,'sgolay',6);
subplot(2,1,1),plot(time,lsm_image_average_smooth','go','MarkerFace','g','MarkerEdge','b','MarkerSize',6);
hold on;
subplot(2,1,1),plot(time,lsm_image_average','k*-');
hold on;
subplot(2,1,2),plot(time,lsm_image_average_smooth','go','MarkerFace','g','MarkerEdge','b','MarkerSize',6);
hold on;
AP=lsm_image_average_smooth;
% Calculate gradient of the signal
AP_gradient=gradient(AP);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Extract properties of the action potential %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 0) Finding out the frequency of AP signals
[AP_period,dt]=finding_freq(time,AP);
number_of_cycle=floor(time(end)/AP_period);
number_of_points_per_cycle=floor(size(AP,1)/number_of_cycle);
% Calculate number of beats per minute
number_of_cycle_BPM=number_of_cycle/time(end)*(60*1000);
%% 1) Detect the peaks from the action potential, assuming neighbouring peaks
%% can't be within 2/3 of the AP cycles (note, cycle here is defined by number of points
[AP_peaks,AP_peaks_locations]=findpeaks(AP,'MinPeakDistance',number_of_points_per_cycle/2);
number_of_peaks=size(AP_peaks_locations,1);
% This is to eliminate the extra peaks detected towards the end of the
% recording. 
% Check the magnitude of the last peak because sometimes it could
% detect a peak during the diastolic phase
if AP_peaks(end)<(AP_peaks(end-1)*0.8)
    AP_peaks_locations(end)=[];
    AP_peaks(end)=[];
end
% Revaluate number of peaks after removing the extra unneccesary peaks
number_of_peaks=size(AP_peaks_locations,1);
subplot(2,1,2),plot(time(AP_peaks_locations),AP_peaks,'ro','MarkerFace','r','MarkerEdge','y','MarkerSize',8);
hold on;
grid minor;

%% 2) Detect the troughs from the action potential by finding the minimum
% between peaks
% Note: the following algorithm assumes that the trough lies approximately
% within n points from the peak, 
% Initialise range_trough, but will be calculated later based on individual
% cycles
range_trough=AP_period/3;
AP_troughs_locations=zeros(number_of_peaks,1);
AP_troughs=zeros(number_of_peaks,1);
for p=1:number_of_peaks
    % Isolate the AP signals before the peak locations
    if time(AP_peaks_locations(p))>range_trough
        % The following conditions are checked because the first cycle
        % needs to be treated differently from the rest of the cycles
        if p<number_of_peaks & p==1 
            range_trough_to_peak=Calculate_range_from_trough_to_peak(time,AP,AP_gradient,...
                                                                1,AP_peaks_locations(p));
        % This deals with the rest of the cycles    
        elseif p<=number_of_peaks
            range_trough_to_peak=Calculate_range_from_trough_to_peak(time,AP,AP_gradient,...
                AP_peaks_locations(p-1),AP_peaks_locations(p));
        % This deals with the last cycle which can potentially be
        % incomplete. 
        else
            range_trough_to_peak=range_trough_to_peak;
        end
        time_before_peaks=time((AP_peaks_locations(p)-range_trough_to_peak):AP_peaks_locations(p));
        AP_before_peaks=AP((AP_peaks_locations(p)-range_trough_to_peak):AP_peaks_locations(p));
        % Find the minimum
        [AP_before_peaks_min,AP_before_peaks_min_location]=min(AP_before_peaks);
        % Plot the trough locations
        AP_troughs_locations(p)=AP_peaks_locations(p)-range_trough_to_peak+AP_before_peaks_min_location-1;
        AP_troughs(p)=AP_before_peaks_min;
        subplot(2,1,2),plot(time(AP_troughs_locations(p)),AP_troughs(p),'mo','MarkerFace','m','MarkerEdge','m','MarkerSize',8);
    end
end

% If the first peak occurs earlier than 1/6 of the AP duration (number of points), then this suggests that the first cycle is not useful
% therefore, the first peak and trough should be removed from the analysis as well
upstroke_period=floor(number_of_points_per_cycle/6);
if AP_peaks_locations(1)<upstroke_period
    % Remove the first peak
    AP_peaks_locations(1)=[];
    AP_peaks(1)=[];
    AP_troughs_locations(1)=[];
    AP_troughs(1)=[];
end
% Update the number of peaks and troughs in case first peaks and troughs have been removed
number_of_peaks=size(AP_peaks,1);
number_of_troughs=size(AP_troughs,1);
        
%% 3) Calculate the amplitude of the AP (start of the upstroke to peak)
AP_amplitudes=zeros(number_of_peaks,1);
for a=1:number_of_peaks
    AP_amplitudes(a)=AP_peaks(a)-AP_troughs(a);
end

%% 4) Detect the end of repolarisation
AP_endRepos_locations=zeros(size(number_of_troughs,1)-1,1);
AP_endRepos=zeros(size(number_of_troughs,1)-1,1);
for r=1:(number_of_troughs-1)
    % Extract action potential between peak and next trough
    AP_peak_to_trough=AP(AP_peaks_locations(r):AP_troughs_locations(r+1)-1);
    %% Calculate the number of signals 
    range_trough_to_peak_from_peak=floor(size(AP_peak_to_trough,1)/3);
    time_after_peaks=time(AP_peaks_locations(r):(AP_peaks_locations(r)+range_trough_to_peak_from_peak));
    AP_after_peaks=AP(AP_peaks_locations(r):(AP_peaks_locations(r)+range_trough_to_peak_from_peak));
    % Find the minimum
    [AP_after_peaks_min,AP_after_peaks_min_location]=min(AP_after_peaks);
    % Plot the peak locations
    AP_endRepos_locations(r)=AP_peaks_locations(r)+AP_after_peaks_min_location-1;
    AP_endRepos(r)=AP_after_peaks_min;
    subplot(2,1,2),plot(time(AP_endRepos_locations(r)),AP_endRepos(r),'mo','MarkerFace','m','MarkerEdge','m','MarkerSize',8);
end

%% 5) Calculate the amplitude of the AP (peak to end of repolarisation)
number_of_troughs=size(AP_troughs,1);
AP_amplitudes_peak_to_endRepos=zeros(number_of_troughs-1,1);
for a_rp=1:(number_of_troughs-1)
    AP_amplitudes_peak_to_endRepos(a_rp)=AP_peaks(a_rp)-AP_endRepos(a_rp);
end

%
%% 6) Convert the amplitude of the AP to percentage after offsetting to the average
%% of the troughs
AP_troughs_mean=mean(AP_troughs);
AP_percentage=(AP-AP_troughs_mean)/AP_troughs_mean*100;
yyaxis left
subplot(2,1,1),plot(time,AP,'go','MarkerFace','g','MarkerEdge','b','MarkerSize',6);
ylabel('AP raw signal','Color','g','FontSize',16);
yyaxis right
subplot(2,1,1),plot(time,AP_percentage,'co','MarkerFace','c','MarkerEdge','b','MarkerSize',4);
ylabel('AP percentage','Color','c','FontSize',16);
hold on;
grid minor;

%% 6b) Calculate the amplitude of the AP (start of the upstroke to peak)
number_of_troughs=size(AP_troughs,1);
AP_amplitudes_percentage=zeros(number_of_peaks,1);
for a=1:number_of_peaks
    AP_amplitudes_percentage(a)=AP_percentage(AP_peaks_locations(a))-AP_percentage(AP_troughs_locations(a));
end


%% 7) Calculate AP duration at various percentages of the amplitudes
x={'20','30','40','50','60','70','80','90'};

% 7a) Initialise a vector to store the results
for x_index=1:size(x,2)
    eval(['APDx_',x{x_index},'_duration=zeros(number_of_peaks-1,1);']);
end

% 7b) Loop through each cycle to calculate the APDx for each cycle
for d=1:(number_of_peaks-1)
    time_DS=time(AP_troughs_locations(d));
    %% Extract AP between trough and peak within a cycle
    time_trough_to_peak=time(AP_troughs_locations(d):AP_peaks_locations(d));
    AP_trough_to_peak=AP(AP_troughs_locations(d):AP_peaks_locations(d));
    %
    %% Calculate the instateneous change in AP (dF/dt_max)
    AP_trough_to_peak_diff=diff(AP_trough_to_peak);
    AP_trough_to_peak_dv_dt_max(d)=max(AP_trough_to_peak_diff);
   
    %% 50% between the initiation and maximal height of an up-stroke 
    APDx_50_amplitude(d)=AP_troughs(d)+AP_amplitudes(d)*0.5;
    AP_diff_wrt_50=abs(AP_trough_to_peak-APDx_50_amplitude(d));
    AP_50_index=find(AP_diff_wrt_50==min(AP_diff_wrt_50));
    APDx_50_time_upstroke(d)=time_trough_to_peak(AP_50_index);
    % Plot the 50% amplitude
    subplot(2,1,2),plot(APDx_50_time_upstroke(d),APDx_50_amplitude(d),'ys','MarkerEdge','k','MarkerFace','y','MarkerSize',12);
    
    %% Calculate the time required to return to x% of the return to diastolic baseline
    for x_index=1:size(x,2)
        y_offset=0.01*x_index;
        [APDx_duration]=Evaluate_APDx(time,AP,APDx_50_time_upstroke(d),AP_peaks_locations(d),AP_endRepos_locations(d),...
            AP_peaks(d), AP_amplitudes_peak_to_endRepos(d),...
            str2num(x{x_index})/100,AP_troughs(d),y_offset);
        eval(['APDx_',x{x_index},'_duration(d)=APDx_duration;']);
    end
end

%% 8) Collate all results and calculate mean and std for all parameters
% 8a) Amplitude: mean +/- std, exclude result from the first cycle
AP_amplitudes_percentage(1)=[];
AP_amplitudes_percentage_mean=mean(AP_amplitudes_percentage);
AP_amplitudes_percentage_std=std(AP_amplitudes_percentage);

% 8b) Maximum rate change of voltage: mean +/- std, exclude result from the
% first cycle and calculate the mean of 3 cycles only
AP_trough_to_peak_dv_dt_max(1)=[];
AP_trough_to_peak_dv_dt_max_mean=mean(AP_trough_to_peak_dv_dt_max(1:3));
AP_trough_to_peak_dv_dt_max_std=std(AP_trough_to_peak_dv_dt_max(1:3));

% 8c) APDx: exclude the result from the first cycle and calculate the mean and
% std of each APDx
for x_index=1:size(x,2);
    eval(['APDx_',x{x_index},'_duration(1)=[];']);
end

for x_index=1:size(x,2);
    eval(['APDx_',x{x_index},'_duration_mean=mean(APDx_',x{x_index},'_duration);']);
    eval(['APDx_',x{x_index},'_duration_std=std(APDx_',x{x_index},'_duration);']);
end

% 8d) APDx ratio=(APDx_30-APDx_40)/(APDx_70,APDx_80): mean +/- std, exclude
% result from the first cycle
for p=1:size(APDx_30_duration,1)
    APDx_ratio(p)=(APDx_30_duration(p)-APDx_40_duration(p))/(APDx_70_duration(p)-APDx_80_duration(p));
end
APDx_ratio_mean=mean(APDx_ratio);
APDx_ratio_std=std(APDx_ratio);
if APDx_ratio_mean>1.5
    Ventricle_cells='Y';
else
    Ventricle_cells='N';
end

%% 9) Export the figure
output_dir=image_name_current;
output_dir=strrep(output_dir,'Input_data',output_dir_main);
space_index=strfind(output_dir,'lsm');
% Remove the white space in the file name
output_dir(space_index+3:end)=[];
% Assemble the output quantities
AP_properties_all=[{image_name_current},{number_of_cycle_BPM},{AP_amplitudes_percentage_mean},{AP_amplitudes_percentage_std},...
                    {AP_trough_to_peak_dv_dt_max_mean},{AP_trough_to_peak_dv_dt_max_std},...
                    {APDx_50_duration_mean},{APDx_50_duration_std},...
                    {APDx_70_duration_mean},{APDx_70_duration_std},...
                    {APDx_90_duration_mean},{APDx_90_duration_std},...
                    {APDx_ratio_mean},{APDx_ratio_std},...
                    {Ventricle_cells}];

% Output the final figure
figure_name=[output_dir,'_AP_Properties.jpeg'];
%Export the figure
print(current_figure,figure_name,'-djpeg');

return