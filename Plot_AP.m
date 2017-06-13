function Plot_AP(image_name_current,pixel_time,number_of_pixels,output_dir_current)

%% This functio is designed to plot the lsm
%% Author: Dr Vicky Wang
%% Last date of modification: 23/05/2017

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
lsm_current_line_average_column=linspace(1,number_columns,number_columns);
% Convert the horizontal axis to time
time=lsm_current_line_average_column'.*pixel_time.*number_of_pixels;
plot(time,lsm_image_average','k*-');
hold on;
image_title=image_name_current(strfind(image_name_current,'Image'):end);
title_name=[image_title,' raw signals'];
title(title_name,'FontSize',16);
grid minor;
% 
figure_name=[output_dir_current,'/',image_title,'.jpeg'];
%Export the figure
print(current_figure,figure_name,'-djpeg');

return