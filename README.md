# Mouse Brain fMRI Analysis

**Preprocessing Pipeline**

**Group ICA Analysis on FSL**

Contains commands for the following ...
- Running group ICA on FSL MELODIC, including steps to prepare input files
- Running ICA FIX, automated classification of signals and noise in ICA components
- Visualizing ICA components with colors maps (positive and negative correlations) on FSLEYES
- Creating design matrices and contrast files
- Running dual regression
- Identifying statistically significant corrected p-value t-statistic maps for each component 

**Additional Resampling & Smoothing**
- Using ANTS applytransform command to resample 0.3 by 0.3 by 0.3 mm voxel dimensions in fMRI images to 0.5 by 0.5 by 0.5 mm, which should allow the fMRI image to more closely match the voxel dimensions of the T1 images (1:1.5 ratio).
- Smoothing images by 2 voxels (can be tuned)

**Gaussian Mixture Model Thresholded**
- Using gaussian mixture models to identify z-score thresholds for deactivation, activation, and null distributions in uncorrected p-value t-statistic maps.

**Guassian Mixture Model Shaded**
- Creating improved visualization of gaussian mixture models with shading and updated legend

**Conn Batch File**
- Code to load small batch of subjects (n=42) with APOE4 and non APOE4 genotype, high fat diet, and no HN immunity into CONN toolbox

**Group Average Connectome**
- Averaging connectomes for groups of subjects (ex. APOE4 vs. non-APOE4, high fat diet vs. control diet)


  
