import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os
import shutil

#extract time series files from directory
original_path = "/Users/bass/Desktop/time_ser/"
csv_dataframe = pd.read_csv("/Users/bass/Desktop/new_conn_data/coon_for_subjects_346.csv")

#create directory of sedentary animals with no high fat diet
os.mkdir("/Users/bass/Desktop/non_HFD_connectomes/")
for file in os.listdir(original_path):
    subjectid_withext = file.split("_")[1]
    subject_id = subjectid_withext.split(".")[0]
    for index, row in csv_dataframe.iterrows():
        if(row["ID"]==subject_id) and (row["HFD"]==0) and (row["Excercise"]==0):
            shutil.copy(original_path+file, "/Users/bass/Desktop/non_HFD_connectomes/")


original_path = "/Users/bass/Desktop/non_HFD_connectomes/"
#using this to reformat header of csv file 
zero_arr = [""]*324
zero_df = pd.DataFrame(zero_arr)
arrs = []
#loop through all the subjects
for file in os.listdir(original_path):
    #extract subject id
    subjectid_withext = file.split("_")[1]
    subject_id = subjectid_withext.split(".")[0]
    #ignoring DS.Store file 
    if not (subject_id=="Store"):
        csv_df = pd.read_csv(original_path+file)
        current_header = csv_df.columns
        #taking current header and adding it to the dataframe 
        header_row = pd.DataFrame([current_header], columns = csv_df.columns)
        csv_df = pd.concat([header_row, csv_df]).reset_index(drop=True)
        #making a new header
        csv_df.columns = zero_df
        #converting the dataframe to an matrix of values
        arr1 = csv_df.values.tolist()
        #adding the matrix to an array 
        arrs.append(arr1)
#convert the matrix to a numpy array
numpy_arr = np.array(arrs)
numpy_arr = numpy_arr.astype(np.float64)

average_np = np.mean(numpy_arr, axis=0)
np.savetxt("average_NON_HFD_connectome.csv", average_np, delimiter=',')



