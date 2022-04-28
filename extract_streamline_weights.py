#!/usr/bin/env python3

import os, sys
import json
import pandas as pd

def extract_streamline_weights():

    with open('config.json','r') config_f:
        config = json.load(config_f)

    labels = pd.read_csv(config['labels'])
    weights = pd.read_csv(config['weights'])

    out_weights = weights.loc[labels[0] == 1].reset_index(drop=True)

    out_weights.to_csv('./weights.csv',index=False,header=False)

if __name__ == '__main__':
    extract_streamline_weights()
