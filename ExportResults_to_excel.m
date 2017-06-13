function ExportResults_to_excel(output_dir_main,filenames,time,AP_percentage_all_all_studies,AP_properties_all_all_studies)

%% This function is designed to export results to excel files

% Determine the total number of files
number_files_analyse=size(filenames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Write out AP converted to percentage %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the output filename
filenamew=[output_dir_main,'/AP_Percentage_all_studies.xlsx'];
% Assemble the output
header_percentage={'Time'};
for n=1:number_files_analyse
	header_percentage=[header_percentage,filenames(n,:)];
end
AP_Percentage_all_studies_output=[time,AP_percentage_all_all_studies];
Output_percentage=[cellstr(header_percentage);num2cell(AP_Percentage_all_studies_output)];
xlswrite(filenamew,Output_percentage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Write out AP all properties          %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the output filename
filenamew=[output_dir_main,'/AP_Properties_all_studies.xlsx'];
header={'Study_name','BPM','Amplitude_mean','Amplitude_std',...
    'df_max_mean','df_max_std',...
    'APDx_50_mean','APDx_50_std',...
    'APDx_70_mean','APDx_70_std',...
    'APDx_90_mean','APDx_90_std',...
    'ratio_30_40_70_80_mean','ratio_30_40_70_80_std',...
    'Ventricle Cells'};
Output_quantities=[cellstr(header);AP_properties_all_all_studies];
xlswrite(filenamew,Output_quantities);

return