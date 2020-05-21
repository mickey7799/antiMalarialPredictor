# ********************************************************
# *               University of Melborune                *
# *   ----------------------------------------------     *
# * Mi-Chi Lee - michil@student.unimelb.edu.au        *
# * Last modification :: 11/09/2019                      *
# *   ----------------------------------------------     *
# ********************************************************
import pandas as pd 
import sys
import os
import glob

def main():
    src = r'/home/localhpc/Desktop/PlasmoCSM/pdcsm/ML'
    regression_file_list = glob.glob( src +'/*_*_potency_output_all.pdCSM_pharm_*_*_combined_activity_train_regression_dropna.csv_*_BestFit_10folds_result.csv')
    print(len(regression_file_list))

    regression_csv = pd.read_csv(regression_file_list[0])
    for regression_file in regression_file_list[1:]:
        next_csv = pd.read_csv(regression_file)
        regression_csv = pd.concat([regression_csv, next_csv], axis=0) 
    regression_csv.to_csv('regression_result.pdCSM_pharm.csv', index=False)

if __name__ == '__main__':
         main() 


