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
    file_list = glob.glob( src +'/potency_output_all.pdCSM_pharm_*_*_combined_activity.csv')
    print(len(file_list))
    # for file in file_list:
    #     print(file)
    #     graph_csv = pd.read_csv(file)
    #     x_train, x_test, y_train, y_test = train_test_split(graph_csv.iloc[:,:-4], graph_csv.iloc[:,-1], test_size=0.1, random_state=42)
    #     frames = [x_train,y_train]
    #     train = pd.concat(frames,axis=1)
    #     output_name = file[:-4]+"_"+ "train_classification" + ".csv" 
    #     train.to_csv(output_name, index=False)

    #     frames = [x_test,y_test]
    #     test = pd.concat(frames,axis=1)
    #     output_name = file[:-4]+"_"+ "test_classification" + ".csv" 
    #     test.to_csv(output_name, index=False)

    for file in file_list:
        print(file)
        graph_csv = pd.read_csv(file)
        x_train, x_test, y_train, y_test = train_test_split(graph_csv.iloc[:,:-4], graph_csv.iloc[:,-2], test_size=0.1, random_state=42)
        frames = [x_train,y_train]
        train = pd.concat(frames,axis=1)
        output_name = file[:-4]+"_"+ "train_regression" + ".csv" 
        train.to_csv(output_name, index=False)

        frames = [x_test,y_test]
        test = pd.concat(frames,axis=1)
        output_name = file[:-4]+"_"+ "test_regression" + ".csv" 
        test.to_csv(output_name, index=False)
    
if __name__ == '__main__':
    main() 
