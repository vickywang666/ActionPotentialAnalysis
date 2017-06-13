function Initial_assessment_AP(Input_dir,output_dir_main,all_folders,...
                                code_path,pixel_time,number_of_pixels,plot_toggle)

%% This function is designed to perform an initial assessment of the raw signals
%% by plotting the raw signals and output all files recorded to an excel file
%% for user to exclude non-useable data
%% Author: Dr Vicky Wang
%% Last date of modification: 23/05/2017

% Define an csv file to store the name of all files recorded
all_files_recorded_name=[output_dir_main,'/','All_files_recorded.xlsx'];
% Initialise a variable to store all files
all_files_recorded=[];

% Loop through all folders
for f=1:size(all_folders,1)
    % Check whether the current file is a directory, if it's a directory,
    % then need to go into the current folder and list all files again
    if all_folders(f).isdir==1
        % Make output directory
        output_dir=[output_dir_main,'/',all_folders(f).name];
        if exist(output_dir)==0
            mkdir(output_dir);
        end
        % Specify input directory
        Input_dir_sub=[Input_dir,'/',all_folders(f).name];
        % List all files under the current directory
        all_files=dir(Input_dir_sub);
        all_files(1:2)=[];
        
        % Loop through all files in the current folder
        for im=1:size(all_files,1)
            % Check whether the current file is a directory, if it's a directory,
            % then need to go into the current folder and list all files again
            if all_files(im).isdir==1
                folder_name_sub=(all_files(im).name);
                % Make output directory
                output_dir=[output_dir_main,'/',all_folders(f).name,'/',folder_name_sub];
                if exist(output_dir)==0
                    mkdir(output_dir);
                end
                % Specify input directory
                Input_dir_sub2=[Input_dir,'/',all_folders(f).name,'/',folder_name_sub];
                all_files_sub=dir(Input_dir_sub2);
                all_files_sub(1:2)=[];
                for im_sub=1:size(all_files_sub,1)
                    image_name=[Input_dir_sub2,'/',all_files_sub(im_sub).name];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%% 2) Plot lsm and save them as JPEG %%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if plot_toggle==1
                        Plot_AP(image_name,pixel_time,number_of_pixels,output_dir);
                        close all;
                    end
                    % Write all filenames to an excel file
                    all_files_recorded=[all_files_recorded;{image_name}];
                end
                % If the input file is not a directory, then proceed the
                % following steps
            else
                output_dir=[output_dir_main,'/',all_folders(f).name];
                folder_name=(all_files(im).name);
                % Specify directory
                image_name=[Input_dir,'/',all_folders(f).name,'/',folder_name];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%% 2) Plot lsm and save them as JPEG %%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if plot_toggle==1
                    Plot_AP(image_name,pixel_time,number_of_pixels,output_dir);
                    close all;
                end
                % Record all filenames to an excel file
                all_files_recorded=[all_files_recorded;{image_name}];
            end
            
        end
        cd(code_path);
    end
end

% Default all files to be yes, hence to be included in stage 2 analysis
all_files_recorded(:,2)={'Y'};
xlswrite(all_files_recorded_name,all_files_recorded);

return