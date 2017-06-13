function Extract_AP_Properties

%% This function is designed to extract action potential properties
%% from lsm images
%% Author: Dr Vicky Wang
%% Last date of modification: 26/05/2017


clear all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Stage 0: Set up the analysis     %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the path where all analysis codes are stored
code_path=pwd;
% Define the pixel time (change this number if differen microscope setup
% was used)
total_duration=8000; %ms
number_of_pixels=512;
pixel_time=total_duration/(number_of_pixels*2000); %ms
% Old parametrs
%pixel_time=3.15/1000;
%number_of_pixels=512;
% Define the output directory
output_dir_main='Output';
% If the output directory does not exist, then make a directory
if exist(output_dir_main)==0
    mkdir(output_dir_main);
end
% Define the input directory
Input_dir=('Input_data');
% List the folders under the input folder
all_folders=dir(Input_dir);
% Remove the first two elements as they are not useful information
all_folders(1:2)=[];

% Ask the user whether both Step 1 and Step 2 should be executed
dlg_title='Input required';
prompt={'Enter 1 if you want to perform Step 1 analysis, or 2 if you just want to perform Step 2 analysis. '};
steps_to_excute = inputdlg(prompt,dlg_title);

%% Hard code step to excute
%steps_to_excute={'2'};

if steps_to_excute{1}=='1'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% Stage 1: Perform an initial assessmet of the AP and eliminate %%%%
    %%%%%%% file with non-useable signals                     %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ask the user whether they want to plot all raw signals
    dlg_title='Input required';
    prompt={'Enter 1 if all raw signals should be plotted, other enter 0'};
    plot_toggle_prompt = inputdlg(prompt,dlg_title);
    Initial_assessment_AP(Input_dir,output_dir_main,all_folders,code_path,pixel_time,number_of_pixels,str2num(plot_toggle_prompt{1}));
    msg='Open Output/All_files_recorded.xlsx and change ''Y'' to ''N'' for study you want to exclude for final analysis, then rerun the main code to proceed to step 2';
    uiwait(msgbox(msg,'Attention','modal'));
    % Print a dialogue to notify user that Step 1 analysis in completed.
    msg='Step 1 analysis is completed';
    uiwait(msgbox(msg,'Finished','modal'));
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% Stage 2: Extract properies of AP                  %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Analyse_lsm_main(output_dir_main,pixel_time,number_of_pixels);
    % Print a final dialogue to notify user that analysis in completed.
    msg='Analysis is completed';
    uiwait(msgbox(msg,'Finished','modal'));
    
end


return