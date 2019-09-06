# ********************************************************
# *               University of Melborune                *
# *   ----------------------------------------------     *
# * Yoochan Myung - ymyung@student.unimelb.edu.au        *
# * Last modification :: 06/09/2019                      *
# *   ----------------------------------------------     *
# ********************************************************
import pandas as pd 
import sys
import os

def main(input_csv):
    inputcsv = pd.read_csv(input_csv,header=0)
    inputcsv.drop(['AcceptorCount','AromaticCount','DonorCount','HydrophobeCount','NegIonizableCount','PosIonizableCount','CLASS'],axis=1,inplace=True)

    column_list = inputcsv.columns.tolist()
    column_dict = dict()

    for each in column_list:
        splitted_string = each.split('-')[-1]
        column_dict.setdefault(splitted_string,[])
        column_dict[splitted_string].append(each)

    # CUTOFF from 5 to 19
    # STEP SIZE: 1 
    for cutoff_dist in range(5,20,1):
        cutoff_step_size = '1'
        filtered_column_list = list()
        for key in column_dict.keys():

            if float(key) <= cutoff_dist:
                filtered_column_list.extend(column_dict[key])

        output_name = os.path.basename(input_csv)[:-4]+"_"+ cutoff_step_size + "_" +str(cutoff_dist)+".csv" 
        inputcsv[filtered_column_list].to_csv(output_name,index=False)
    
    # CUTOFF from 5 to 19
    # STEP SIZE: 2
    for cutoff_dist in range(5,20,1):
        cutoff_step_size = '2'
        filtered_column_list_odd = list()
        filtered_column_list_even = list()

        if cutoff_dist%2 != 0:
            temp_keys = list()
            for each in range(1,cutoff_dist+1,2):
                temp_keys.append(format(float(each),'.2f'))
            for each in temp_keys:
                filtered_column_list_odd.extend(column_dict[each])
            output_name = os.path.basename(input_csv)[:-4]+"_"+ cutoff_step_size + "_" +str(cutoff_dist)+".csv" 
            inputcsv[filtered_column_list_odd[::-1]].to_csv(output_name,index=False)            
        else:
            temp_keys = list()
            for each in range(2,cutoff_dist+1,2):
                temp_keys.append(format(float(each),'.2f'))
            for each in temp_keys:
                filtered_column_list_even.extend(column_dict[each])
            output_name = os.path.basename(input_csv)[:-4]+"_"+ cutoff_step_size + "_" +str(cutoff_dist)+".csv" 
            inputcsv[filtered_column_list_even[::-1]].to_csv(output_name,index=False)   

if __name__ == '__main__':
    input_csv = sys.argv[1]
    main(input_csv) 