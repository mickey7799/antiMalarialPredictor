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
    src = r'input_split_ID'
    pdCSM_pharm_file_list = glob.glob( src +'/input_ID.*.csv.pdCSM_pharm.csv')
    pdCSM_no_file_list = glob.glob( src +'/input_ID.*.csv.pdCSM_no.csv')
    print(len(pdCSM_pharm_file_list))
    print(len(pdCSM_no_file_list))

    pdCSM_pharm_graph_csv = pd.read_csv(pdCSM_pharm_file_list[0])
    for pdCSM_pharm_file in pdCSM_pharm_file_list[1:]:
        next_csv = pd.read_csv(pdCSM_pharm_file)
        pdCSM_pharm_graph_csv = pd.concat([pdCSM_pharm_graph_csv, next_csv], axis=0) 
    pdCSM_pharm_graph_csv.to_csv('output_all_test.pdCSM_pharm.csv', index=False)    


    pdCSM_no_graph_csv = pd.read_csv(pdCSM_no_file_list[0])
    for pdCSM_no_file in pdCSM_no_file_list[1:]:
        next_csv = pd.read_csv(pdCSM_no_file)
        pdCSM_no_graph_csv = pd.concat([pdCSM_no_graph_csv, next_csv], axis=0)
    pdCSM_no_graph_csv.to_csv('output_all_test.pdCSM_no.csv', index=False)


if __name__ == '__main__':
         main() 


