#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 19 13:03:58 2024

@author: bass
"""
import nibabel as nib
import numpy as np
from scipy.ndimage import morphology
from nibabel import load, save, Nifti1Image, squeeze_image
import os
import sys, string, os
import pandas as pd
import shutil

#use this path when accessing cluster computer nodes or SLURM:
#path = "/mnt/newStor/paros/paros_WORK/aashika/resample_mouse_fmri/"
path = "/Volumes/newJetStor/newJetStor/paros/paros_WORK/aashika/resample_mouse_fmri/"
input_path = path + "errts_trim/"

outpath=path+"output2/"

#looping through all subjects - note that this script does not work for parallel processing
for file in os.listdir(input_path):
    subj = file.split("_")[0]
    if not (subj.find('.')!=-1):
        subject_dir = outpath+subj+"_smoothed_resampled_temp/"
        fmri_file_path = input_path + subj + "_errts.nii.gz"
        bold=nib.load(fmri_file_path) # read the data of this functional file as nib object
        bold_data=bold.get_fdata() #read data as array 
        if not os.path.isdir(subject_dir):
            os.mkdir(subject_dir)
        #looping through all the volumes in the fmri data 
        for i in range(0,int(bold_data.shape[3])):
           
            bold_data_3d=bold_data[:,:,:,(i)]
          
            squuezed=squeeze_image(nib.Nifti1Image(bold_data_3d,bold.affine)) #squeeze the last dimension
        
           
            nib.save(squuezed, subject_dir + subj + '_'+str(i)+'.nii.gz')
            squuezed_path=subject_dir + subj + '_'+str(i)+'.nii.gz'  #to read and use the squeezed ith volume save its path
            squuezed_path_1=subject_dir + subj + '_'+str(0)+'.nii.gz'  #to read and use the squeezed 1st volume save its path
            squuezed_path_res =subject_dir + subj + '_'+str(i)+'_res.nii.gz'   # squuezed path of volume i after applied resampling 
            
            #This ANTS command creates voxels of 0.5 mm by 0.5 mm by 0.5 mm
            #we are applying linear interpolation - this might need to be changed
            os.system("/Users/bass/Applications/ANTS/ResampleImageBySpacing  3 " +squuezed_path+" " +squuezed_path_res+" 0.5 0.5 0.5 0 0 0")
            #This command is smoothing by 2 voxels - this might need to be changed to 1.5 or 1 voxel
            os.system("/Users/bass/Applications/ANTS/SmoothImage 3 " + squuezed_path +" 2x2x2 " +squuezed_path_res +" 1 1" )
            #This command is setting spacing within the NifTi header - so voxels actually become bigger and there are no changes in the number of voxels.
            #Remove this command if only doing resampling
            os.system("/Users/bass/Applications/ANTS/SetSpacing 3 " + squuezed_path_res   + " " + squuezed_path_res  + " 1 1 1 ")
                      
        
        resampled_image_dir = outpath + "RESAMPLED_smoothed_images/"
        if not os.path.isdir(resampled_image_dir):
            os.mkdir(resampled_image_dir)
        #remove the temporary directories to save space!
        #shutil.rmtree(subject_dir)
        out4D = resampled_image_dir + subj + "_4D.nii.gz"
        out_vol_atlas_reg = subject_dir + subj+'_'
        os.system(f"/Users/bass/Applications/ANTS/ImageMath 4 {out4D} TimeSeriesAssemble 1 0 {out_vol_atlas_reg}*_res.nii.gz") # concatenate volumes of fmri
