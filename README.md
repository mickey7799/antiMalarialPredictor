# anti-Malarial Predictor

Use computational approaches to predict the anti- malarial pharmacodynamic property of compounds

## Data Curation
- 28 sources (Harvard, GSK, GNF, Novartis, ...)
- Major: ChEMBL-NTD, PubChem
- data: 196,199 instances

## Features Engineering
- Open-source cheminformatics software RDKit
- Auxiliary features: 196
- Graph-based signature: 425

## Machine Learning
Used different graph-based signature combinations to generate our features and select the one that can best describing molecule pattern for anti-malarial drugs

Random Forest with cut-off 10 and cut-off step 1 graph- based signature combination yielded the best performance for both the performance for 10-fold cross validation and blind test.
