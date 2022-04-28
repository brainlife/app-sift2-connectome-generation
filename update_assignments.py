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
    unique_edges = list(map(list,set(map(frozenset,unique_edges_unclean))))
    unique_edges = [ f for f in unique_edges if len(f) == 2 and f[0] != 0 and f[1] != 0 ]

    # loop through unique edges and create "classification" structure essentially. REALLY SLOW. NEED TO FIGURE OUT HOW TO SPEED UP.
    indices = pd.Series([ 0 for f in range(len(assignments)) ])
    names = pd.Series([ "not-classified" for f in range(len(assignments)) ])

    for i in range(len(unique_edges)):
        tmp_edges = unique_edges[i]

        tmp = assignments.loc[(assignments['pair1'] == tmp_edges[0]) & (assignments['pair2'] == tmp_edges[1])]

        indices[tmp.index.values.tolist()] = i+1
        names[tmp.index.values.tolist()] = "ROI_"+str(tmp_edges[0])+"_ROI_"+str(tmp_edges[1])

    # set up output csvs
    out_index = pd.DataFrame(indices)
    out_names = pd.DataFrame(names)

    # output csv files
    out_index.to_csv(outpath+'/index.csv',index=False)
    out_names.to_csv(outpath+'/names.csv',index=False)


def main():

    with open('config.json','r') as config_f:
        config = json.load(config_f)

    assignments = './connectomes/assignments.csv'

    outdir = './assignments'

    if not os.path.isdir(outdir):
        os.mkdir(outdir)

    update_assignments_csv(assignments,outdir)

if __name__ == '__main__':
    main()
