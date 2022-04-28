#!/usr/bin/env python3

import os, sys
import pandas as pd
import numpy as np

def update_assignments_csv(assignments,outpath):

    # grab assignments file and rename columns for easier manipulation
    assignments = pd.read_csv(assignments,header=None)
    assignments.rename(columns={0: 'pair1', 1: 'pair2'},inplace=True)

    # identify unique node pairings from assignments. will exclude any instances where a streamline had a 0 assignment, meaning it did not connect nodes
    unique_edges_unclean = assignments.groupby(['pair1','pair2']).count().index.values
    unique_edges = [ list(f) for f in unique_edges_unclean if f[0] != 0 and f[1] != 0 ]
    unique_names = [ str(f[0]) + "_" + str(f[1]) for f in unique_edges ]
    unique_indexes = [ f+1 for f in range(len(unique_edges))]
    labels_dict = {unique_names[i]: str(unique_indexes[i]) for i in range(len(unique_edges))}

    # create temporary column combining the roi pair names
    assignments["combined_name"] = assignments['pair1'].astype(str) + "_" + assignments['pair2'].astype(str)

    # generate indexes for each streamline
    assignments['index'] = assignments["combined_name"].map(labels_dict)
    assignments['index'] = [ int(f) if f is not np.nan else 0 for f in assignments["index"] ]
    assignments.combined_name = np.where(assignments["index"].eq(0), "not-classified", assignments.combined_name)


    indices = assignments['index'].values.tolist()
    names = assignments['combined_name'].values.tolist()

    # set up output csvs
    out_index = pd.DataFrame(indices)
    out_names = pd.DataFrame(names)

    # output csv files
    out_index.to_csv(outpath+'/index.csv',index=False)
    out_names.to_csv(outpath+'/names.csv',index=False)

def main():

    assignments = './connectomes/assignments.csv'

    outdir = './assignments'

    if not os.path.isdir(outdir):
        os.mkdir(outdir)

    update_assignments_csv(assignments,outdir)

if __name__ == '__main__':
    main()
