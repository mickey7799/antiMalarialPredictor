# ********************************************************
# *               University of Melborune                *
# *   ----------------------------------------------     *
# * Mi-Chi Lee - michil@student.unimelb.edu.au        *
# * Last modification :: 25/09/2019                      *
# *   ----------------------------------------------     *
# ********************************************************
import pandas as pd 
import sys
import os
import glob
from sklearn.model_selection import train_test_split 

def main():
    src = '/home/localhpc/Desktop/PlasmoCSM/pdcsm_ML_file'
    file_list = glob.glob( src +'/potency_output_all.pdCSM_pharm_*_*_combined_activity_*_*.csv')
    print(len(file_list))
    
    for file in file_list:
        print(file)
        graph_csv = pd.read_csv(file)
        graph_csv.dropna(inplace=True)
        output_name = file[:-4]+"_"+ "dropna" + ".csv" 
        train.to_csv(output_name, index=False)
    
if __name__ == '__main__':
    main() 
