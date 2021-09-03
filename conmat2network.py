#!/usr/bin/env python

## CODE PORTED FROM https://github.com/filipinascimento/bl-conmat2network/blob/0.2/main.py WRITTEN BY FILIPI SILVA.
## ADAPTED BY BRAD CARON

import sys
import os.path
from os.path import join as PJ
from collections import OrderedDict
import re
import json
import numpy as np
from tqdm import tqdm
import igraph as ig
import jgf


def loadCSVMatrix(filename):
	return np.loadtxt(filename,delimiter=",")

conmeasures = ['count','density','length','denlen']

for i in conmeasures:

	outputDirectory = "network_"+i+"_out"
	outputFile = PJ(outputDirectory,"network.json.gz")

	if(not os.path.exists(outputDirectory)):
			os.makedirs(outputDirectory)

	indexFilename = i+'_out/index.json'
	labelFilename = i+'_out/label.json'
	CSVDirectory = i+'_out/csv'

	with open(indexFilename, "r") as fd:
		indexData = json.load(fd)

	with open(labelFilename, "r") as fd:
		labelData = json.load(fd)
		labelDataHasHeader = False

	matrices = []
	networkProperties = []
	labels = []
	for entry in indexData:
		entryFilename = entry["filename"]
		networkPropertiesDictionary = entry.copy()
		
		label = ""
		if("name" in entry):
			label = entry["name"]
			del networkPropertiesDictionary["name"]
		del networkPropertiesDictionary["filename"]

		adjacencyMatrix = loadCSVMatrix(os.path.join(CSVDirectory, entryFilename))
		matrices.append(adjacencyMatrix)


		if(len(labelData)>len(adjacencyMatrix)):
			for key,value in labelData[0].items():
				networkPropertiesDictionary["extra_"+key] = value
			labelDataHasHeader = True
		
		networkProperties.append(networkPropertiesDictionary)
		labels.append(label)

	if(labelDataHasHeader):
		labelData = labelData[1:]

	nodesProperties = OrderedDict()
	if(len(labelData)>0):
			for nodeIndex,labelInformation in enumerate(labelData):
				for key,value in labelInformation.items():
					if(key not in nodesProperties):
						nodesProperties[key] = OrderedDict()
					nodesProperties[key][nodeIndex] = value

	jgf.conmat.save(matrices,outputFile, compressed=True,
		label=labels,
		networkProperties=networkProperties,
		nodeProperties=nodesProperties)