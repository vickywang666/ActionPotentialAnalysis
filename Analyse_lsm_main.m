function Analyse_lsm_main(output_dir_main,pixel_time,number_of_pixels)

%% This function is the main function for performing analysis on the lsm images
%% Author: Dr Vicky Wang
%% Last date of modification: 26/05/2017

% Read the csv file and perform analysis only on the file picked by user
all_files_recorded_name=[output_dir_main,'/','All_files_recorded.xlsx'];
% Note: even the input file is an excel file, however, xlsread seemed to
% struggle with excel file containing strings only, therefore, importdata
% is used here. 
files_to_be_analysed_all=importdata(all_files_recorded_name);
% Calculate the total number of files
[number_files,number_of_columns]=size(files_to_be_analysed_all);
% Convert structure to characters for easy manipulation
filenames=char(files_to_be_analysed_all{:,1});
file_inclusion_toggle=char(files_to_be_analysed_all{:,2});
% Find the files which the user wants to exclude from further analysis
% These files will have "N" in the second column. 
files_to_be_excluded_index=find(file_inclusion_toggle=='N');
filenames(files_to_be_excluded_index,:)=[];
% Calculate the total number of files to be included in the analysis
number_files_analyse=size(filenames);

% Initialise variables to store final results
AP_percentage_all_all_studies=[];
AP_properties_all_all_studies=[];
% Call Analyse_lsm to extract parameters for action potential
for n=1:number_files_analyse
    [time_axis,AP_percentage_current_study,AP_properties_all_current_study]=Analyse_lsm(output_dir_main,filenames(n,:),pixel_time,number_of_pixels);
	% Assemble results from all studies
	AP_percentage_all_all_studies=[AP_percentage_all_all_studies,AP_percentage_current_study];
	AP_properties_all_all_studies=[AP_properties_all_all_studies;AP_properties_all_current_study];
    close all;
    fprintf('============================================================================\n');
    fprintf('          %s has been analysed                     \n',filenames(n,:));
    fprintf('============================================================================\n');
end

% Write out the output files
ExportResults_to_excel(output_dir_main,filenames,time_axis,AP_percentage_all_all_studies,AP_properties_all_all_studies);

return