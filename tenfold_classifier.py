import pandas as pd
import numpy as np
import scipy as sp
import time
import sys
import os
import argparse
from math import sqrt
from scipy import stats

from sklearn.model_selection import cross_validate
from sklearn.metrics import recall_score
from sklearn.ensemble import AdaBoostClassifier, ExtraTreesClassifier, RandomForestClassifier, GradientBoostingClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.neural_network import MLPClassifier

from sklearn.model_selection import KFold, RepeatedKFold
from sklearn.metrics import mean_squared_error
from sklearn import preprocessing

from sklearn.metrics import roc_auc_score, f1_score, matthews_corrcoef, accuracy_score, balanced_accuracy_score, confusion_matrix, classification_report

def classify(algorithm, fname, input_data, label_name, n_cores, random_state):
    train_y = np.array(input_data[label_name])
    input_data = input_data.drop('ID', axis=1)
    training_x = input_data.drop(label_name, axis=1)

    le = preprocessing.LabelEncoder()
    le.fit(train_y)
    train_y = le.transform(train_y)

    cv_metrics = pd.DataFrame()

    # 10-fold cross validation
    predicted_n_actual_pd = pd.DataFrame(columns=['ID', 'predicted', 'actual', 'fold'])
   
    kf = KFold(n_splits=10, shuffle=True, random_state=random_state)
    fold = 1 

    for train, test in kf.split(training_x):
        # number of train and test instances is based on training_x.

        train_cv_features, test_cv_features, train_cv_label, test_cv_label = training_x.iloc[train], training_x.iloc[test], train_y[train], train_y[test]

        if algorithm == 'GB':
            temp_classifier = GradientBoostingClassifier(n_estimators=300, random_state=1)

        elif (algorithm == 'RF'):
            temp_classifier = RandomForestClassifier(n_estimators=300, random_state=1, n_jobs=n_cores)

        elif (algorithm == 'M5P'):
            temp_classifier = ExtraTreesClassifier(n_estimators=300, random_state=1, n_jobs=n_cores)

        elif (algorithm == 'KNN'):
            temp_classifier = KNeighborsClassifier(n_neighbors=3, n_jobs=n_cores)

        elif (algorithm == 'NEURAL'):
            temp_classifier = MLPClassifier(random_state=1)


        temp_classifier.fit(train_cv_features, train_cv_label)
        temp_prediction = temp_classifier.predict(test_cv_features)

        predicted_n_actual_pd = predicted_n_actual_pd.append(pd.DataFrame({'ID':test, 'actual':test_cv_label, 'predicted' : temp_prediction, 'fold':fold}),ignore_index=True, sort=True)

        fold += 1

    try : 
        roc_auc = round(roc_auc_score(predicted_n_actual_pd['actual'].to_list(),predicted_n_actual_pd['predicted'].to_list()),3)
    
    except ValueError:
        roc_auc = 0.0

    matthews = round(matthews_corrcoef(predicted_n_actual_pd['actual'].to_list(),predicted_n_actual_pd['predicted'].to_list()),3)
    balanced_accuracy = round(balanced_accuracy_score(predicted_n_actual_pd['actual'].to_list(),predicted_n_actual_pd['predicted'].to_list()),3)
    f1 = round(f1_score(predicted_n_actual_pd['actual'].to_list(),predicted_n_actual_pd['predicted'].to_list()),3)

    try:
        tn, fp, fn, tp = confusion_matrix(predicted_n_actual_pd['actual'].to_list(), predicted_n_actual_pd['predicted'].to_list()).ravel()

    except:
        tn, fp, fn, tp = 0,0,0,0

    cv_metrics = cv_metrics.append(pd.DataFrame(np.column_stack(['cv',roc_auc, matthews,\
        balanced_accuracy, f1, tn, fp, fn, tp]),\
        columns=['type','roc_auc','matthew','bacc','f1','TN','FP','FN','TP']), ignore_index=True, sort=True)
    
    cv_metrics = cv_metrics.round(3)
    cv_metrics = cv_metrics.astype({'TP':'int64','TN':'int64','FP':'int64','FN':'int64'})
    cv_metrics = cv_metrics[['type','matthew','f1','bacc','roc_auc','TP','TN','FP','FN']]
    
    predicted_n_actual_pd['predicted'] = le.inverse_transform(predicted_n_actual_pd['predicted'].to_list())
    predicted_n_actual_pd['actual'] = le.inverse_transform(predicted_n_actual_pd['actual'].to_list())
    fname_predicted_n_actual_pd = os.path.join(output_result_dir,'cv_{}_predited_data.csv'.format(algorithm))
    predicted_n_actual_pd['ID'] = predicted_n_actual_pd['ID'] + 1
    predicted_n_actual_pd = predicted_n_actual_pd.sort_values(by=['ID'])
    predicted_n_actual_pd.to_csv(fname_predicted_n_actual_pd,index=False)

    return cv_metrics
    

def main(algorithm, input_csv, label_name, n_cores, num_shuffle):
    fname = os.path.split(input_csv.name)[1]
    original_dataset = pd.read_csv(input_csv, sep=',', quotechar='\"', header=0)

    result_ML = pd.DataFrame()
    
    if original_dataset.columns[0] != 'ID':
        print("'ID' column should be given as 1st column.")
        sys.exit()

    for each in range(1, int(num_shuffle) + 1):

        each_result_ML = classify(algorithm, fname, original_dataset, label_name, n_cores, each)
        
        result_ML = result_ML.append([each_result_ML], ignore_index=False)

    result_ML = result_ML.reset_index(drop=True)
    result_ML.index += 1

    fname_result_ML = os.path.join(output_result_dir,'10CV_{}_result.csv'.format(algorithm))
    result_ML.to_csv(fname_result_ML,index=False)
 
    return result_ML


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='ex) python tenfold_classifier.py M5P input.csv . dG 16 10')
    parser.add_argument("algorithm", help="Choose algorithm between RF,GB,XGBOOST and M5P")
    parser.add_argument("input_csv", help="Choose input CSV(comma-separated values) format file", type=argparse.FileType('rt'))
    parser.add_argument("output_result_dir", help="Choose folder to save result(CSV)")
    parser.add_argument("label_name", help="Type the name of label")
    parser.add_argument("n_cores", help="Choose the number of cores to use", type=int)
    parser.add_argument("num_shuffle", help="Choose the number of shuffling", type=int)
    
    args = parser.parse_args()
    # required args
    algorithm = args.algorithm
    input_csv = args.input_csv
    output_result_dir = args.output_result_dir
    label_name = args.label_name
    n_cores = args.n_cores
    num_shuffle = args.num_shuffle

    if not os.path.exists(output_result_dir):
        os.makedirs(output_result_dir)
