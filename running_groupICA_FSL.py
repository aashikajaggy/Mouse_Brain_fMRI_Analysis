#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul 25 15:46:54 2024

@author: bass
"""
import os
import csv
import pandas as pd

csv_dataframe = pd.read_csv("conn_for_subjects_346.csv")



#FIRST STEP - set up a text file including the paths of subject data to input into group ICA on FSL MELODIC

#Using fMRI images (upsampled twice and smoothed)

filepath="/Volumes/newJetStor/newJetStor/paros/paros_WORK/aashika/resample_mouse_fmri/output2/SLURM_RESAMPLED_smoothed_images/"
directory="/Volumes/newJetStor/newJetStor/paros/paros_WORK/aashika/resample_mouse_fmri/output2/SLURM_RESAMPLED_smoothed_images"

with open("RESAMPLED_SMOOTHED_trimmed_errts.txt", "w") as errts_filepaths_txt:
    for value in range(1, 346):
        row_df = csv_dataframe.iloc[value]
        for file in os.listdir(directory):
            file_split = file.split("_")
            #included sedentary animals for now - but planning on testing for exercise effect later
            if(row_df["ID"]==file_split[0] and row_df["Excercise"]==0):
                file = row_df["ID"]+"_4D.nii.gz"
                subject_dir = os.path.join(filepath, file)
                errts_filepaths_txt.write(subject_dir+" \n")
                
#SECOND STEP - run group ICA analysis on FSL MELODIC
os.system("melodic -i /Users/bass/Desktop/new_conn_data/RESAMPLED_smoothed_trimmed_errts.txt -a concat -o SMOOTHED_RESAMPLED_ICA_analysis_346 --nobet --nomask -d 20 --mmthresh=0.5 --tr=2.252 --report")


#THIRD STEP - visualize components on FSLEYES
os.system("fsleyes -ad -s melodic /Users/bass/Desktop/new_conn_data/RESAMPLED_SMOOTHED_ICA_analysis_346/melodic_IC.nii.gz")

#FOURTH STEP - run an ICA fix classifier or do manual classification of ICA components (distinguish signal and noise)
#for FIX - need to set up a directory (.ica)
#this can be an optional step
os.system("fix melodic.ica /Users/bass/Downloads/Fix_base_ic40_v2.RData 20")

#FIFTH STEP - set up dual regression contrast 

#PART 1 - create a design matrix text file
with open("design_matrix_HFD_CTRL.txt", "w") as design_matrix_file:
    # Iterate over each row in the DataFrame
    for file in os.listdir(directory):
        subject_id = file.split("_")
        for index, row_df in csv_dataframe.iterrows():
            if(row_df["ID"]==subject_id[0]):
                if(row_df["Excercise"]==0):
                    if row_df["HFD"] == 1:
                        design_matrix_file.write("1 ")
                    else:
                        design_matrix_file.write("0 ")
                    if row_df["HFD"] == 0:
                        design_matrix_file.write("1 ")
                    else:
                        design_matrix_file.write("0 ")
                        
                    design_matrix_file.write("\n")

#PART 2 - create a contrast [1 -1; -1 1]
with open("design_contrast_HFD_CTRL.txt", "w") as design_contrast_file:
    design_contrast_file.write("1 -1")
    design_contrast_file.write("\n")
    design_contrast_file.write("-1 1")

#PART 3 - convert text files to matrices

#covert design matrix text file to matrix

os.system("Text2Vest /Users/bass/Desktop/new_conn_data/design_matrix_HFD_CTRL.txt design.mat")

#convert contrast text file into a matrix
os.system("Text2Vest /Users/bass/Desktop/new_conn_data/design_contrast_HFD_CTRL.txt design.con")

#make sure line numbers of text file in step 1 and the design matrix match exactly!!
#its a good idea to create a directory with all the design matrix and contrast file

#SIXTH STEP - run dual regression
os.system("export FSLSUB_PARALLEL=1")
os.system("dual_regression /Users/bass/Desktop/new_conn_data/RESAMPLED_SMOOTHED_ICA_analysis_346/melodic_IC.nii.gz 1 /Users/bass/Desktop/newcontrasts/RESAMPLED_SMOOTHED_HFD_gt_CTRL/design.mat /Users/bass/Desktop/newcontrasts/RESAMPLED_SMOOTHED_HFD_gt_CTRL/design.con 5000 /Users/bass/Desktop/newcontrasts/RESAMPLED_SMOOTHED_newcontrast_HFD_CTRL_5000p.dr `cat /Users/bass/Desktop/new_conn_data/RESAMPLED_smoothed_trimmed_errts.txt`")

#SEVENTH STEP - visualize components and threshold to 0.05 p-value
#run this command to see what components passed thresholding
command = """
for subj in dr_stage3_ic00??_tfce_corrp_tstat?.nii.gz; do
    echo $subj $(fslstats $subj -R)
done
"""

os.system(f"bash -c '{command}'")



