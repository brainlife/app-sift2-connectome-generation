#!/usr/bin/env python3

import os,sys
import pandas as pd
import numpy as np
import scipy.io as sio

def create_wmc_classification_networks(assignments_path):

    # load assignments.csv file
    assignments = pd.read_csv(assignments_path,index=False)

    # identify unique pairs in the assignments
    unique_pairs = np.unique([assignments[0],assignments[1]],axis=1)

    pair_name = []
    streamline_index = np.zeros(len(assignments[0]))

    # loop through unique pairs to generate "tracts"
    for i in range(np.shape(unique_pairs)[1]):

        # set pairing name
        pair_name = pair_name + ['roipairs_'+str(unique_pairs[0][i])+'_'+str(unique_pairs[1][i])]

        # locate streamline indices for endpoint pairs i
        streamline_indices = assignments.loc[(assignments[0] == unique_pairs[0][i]) & (assignments[1] == unique_pairs[1][i])].index.tolist()

        # update streamline_index to have numerical value for pairing
        streamline_index[streamline_indices] = i+1

    # save classification structure
    print("saving classification.mat")
    sio.savemat('wmc/classification.mat', { "classification": {"names": pair_name, "index": streamline_index }})

def main():

    # set file path to assignments
    assignments_path = './connectomes/assignments.csv'

    # generate connectome wmc classification
    create_wmc_classification_networks(assignments_path)

if __name__ == '__main__':
    main()
