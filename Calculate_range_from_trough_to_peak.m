function range_trough_to_peak=Calculate_range_from_trough_to_peak(time,AP,AP_gradient,AP_peaks_locations_current,AP_peaks_locations_next)

% This function is designed to calculate the range to look for the troughs
% from peak automatically by examining the gradient of the AP and detect
% the point beyond which the upstroke occured. 

%AP_gradient=gradient(AP);
%yyaxis right
%plot(time,AP_gradient,'mo','MarkerFace','m','MarkerEdge','b','MarkerSize',6);
AP_peak_to_peak=AP(AP_peaks_locations_current:AP_peaks_locations_next);
number_of_points_peak_to_peak=floor(size(AP_peak_to_peak,1));
time_mid_to_peak=time((AP_peaks_locations_next-floor(number_of_points_peak_to_peak/2)):AP_peaks_locations_next);
AP_gradient_mid_to_peak=AP_gradient((AP_peaks_locations_next-floor(number_of_points_peak_to_peak/2)):AP_peaks_locations_next);
%plot(time_mid_to_peak,abs(AP_gradient_mid_to_peak),'mo','MarkerFace','m','MarkerEdge','b','MarkerSize',8);

% Find the maximum gradient
AP_gradient_mid_to_peak_max_index=find(AP_gradient_mid_to_peak==max(AP_gradient_mid_to_peak));
% If the maximum index is less than the total number of points, then it
% suggests that the gradient already started to decrease, for the purpose
% of calculating the outliers, these points need to be eliminated.
if AP_gradient_mid_to_peak_max_index<size(AP_gradient_mid_to_peak,1)
    AP_gradient_mid_to_peak_tmp=AP_gradient_mid_to_peak(1:AP_gradient_mid_to_peak_max_index);
end
AP_gradient_mid_to_peak_all=AP_gradient_mid_to_peak;
AP_gradient_mid_to_peak=AP_gradient_mid_to_peak_tmp;

% Extract the outlier in the boxplot
fig_boxplot=figure(100);
hb=boxplot(abs(AP_gradient_mid_to_peak));
hOutliers = findobj(hb,'Tag','Outliers');
AP_gradient_outliers = get(hOutliers,'YData');
hUpperAdjacent_tag=findobj(hb,'Tag','Upper Adjacent Value');
hUpperAdjacent=get(hUpperAdjacent_tag,'YData');

% Initialise the varialble to store the critical index
AP_gradient_critical_point_index=1;
o=1;
% If the critical point index is too up front, then it has not picked up
% then the outlier is too small, move on to the next outlier
while AP_gradient_critical_point_index<floor(size(AP_gradient_mid_to_peak,1)*0.9)
    % This is to check whether the upper adjacent value is too close to the
    % first outlier, if yes, then it suggested that the outlier is still too
    % small to become a critical point.
    if (AP_gradient_outliers(o)-hUpperAdjacent(1))<mean(diff(AP_gradient_outliers))*0.1
        AP_gradient_critical_point_index=(find(abs(AP_gradient_mid_to_peak)==AP_gradient_outliers(o+1))-1);
    else
        AP_gradient_critical_point_index=(find(abs(AP_gradient_mid_to_peak)==AP_gradient_outliers(o))-1);
    end
    o=o+1;
end
range_trough_to_peak=size(AP_gradient_mid_to_peak_all,1)-AP_gradient_critical_point_index;
plot(time_mid_to_peak(AP_gradient_critical_point_index),AP_gradient_mid_to_peak(AP_gradient_critical_point_index),'rs','MarkerFace','r','MarkerEdge','b','MarkerSize',10);
close(fig_boxplot);

%{
%% Calculate 95% percentile of the data
%AP_gradient_95_percentile=prctile(abs(AP_gradient_mid_to_peak),95);
% Smooth the gradient data before calculating the difference between
% gradient and 95% percentile
% Very heavy smoothing in order to put more emphasis on the data prior
% initiation of the upstroke
AP_gradient_mid_to_peak_smooth=smoothdata(abs(AP_gradient_mid_to_peak),'sgolay',10);
AP_gradient_diff=abs(AP_gradient_mid_to_peak_smooth-AP_gradient_95_percentile);
AP_gradient_critical_point_index=find(AP_gradient_diff==min(AP_gradient_diff));
%}
%plot(time_mid_to_peak(AP_gradient_critical_point_index),AP_gradient_mid_to_peak(AP_gradient_critical_point_index),'rs','MarkerFace','r','MarkerEdge','b','MarkerSize',10);
% note -5 is also arbitary
%range_trough_to_peak=size(AP_gradient_mid_to_peak,1)-AP_gradient_critical_point_index+10;

return