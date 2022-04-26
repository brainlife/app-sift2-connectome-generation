#!/usr/bin/env python

import vtk
import sys
import os
import json
import pandas as pd
import numpy as np

if not os.path.exists("netneuro/surfaces"):
   os.makedirs("netneuro/surfaces")

with open('config.json','r') as config_f:
    config = json.load(config_f)

with open(config['label']) as f:
    labels = json.load(f)

img_path = config['parc']

# import the binary nifti image
print("loading %s" % img_path)
reader = vtk.vtkNIFTIImageReader()
reader.SetFileName(img_path)
reader.Update()

print("list unique values (super slow!)")
out = reader.GetOutput()
vtk_data=out.GetPointData().GetScalars()
unique = set()
for i in range(0, vtk_data.GetSize()):
    v = vtk_data.GetValue(i)
    unique.add(v)

index=[]

for label in labels:

    label_id=int(label["voxel_value"])

    if not label_id in unique:
        continue

    surf_name=str(label['voxel_value'])+'.'+label['name']+'.vtk'
    label["filename"] = surf_name
    label["color"] = {}
    label["color"]["r"] = np.random.randint(255)
    label["color"]["g"] = np.random.randint(255)
    label["color"]["b"] = np.random.randint(255)
    label['name'] = label['name']
    label['label'] = label['voxel_value']
    print(surf_name)

    index.append(label)

    # do marching cubes to create a surface
    surface = vtk.vtkDiscreteMarchingCubes()
    surface.SetInputConnection(reader.GetOutputPort())

    # GenerateValues(number of surfaces, label range start, label range end)
    surface.GenerateValues(1, label_id, label_id)
    surface.Update()

    smoother = vtk.vtkWindowedSincPolyDataFilter()
    smoother.SetInputConnection(surface.GetOutputPort())
    smoother.SetNumberOfIterations(10)
    smoother.NonManifoldSmoothingOn()
    smoother.NormalizeCoordinatesOn()
    smoother.Update()

    connectivityFilter = vtk.vtkPolyDataConnectivityFilter()
    connectivityFilter.SetInputConnection(smoother.GetOutputPort())
    connectivityFilter.SetExtractionModeToLargestRegion()
    connectivityFilter.Update()

    untransform = vtk.vtkTransform()
    untransform.SetMatrix(reader.GetQFormMatrix())
    untransformFilter=vtk.vtkTransformPolyDataFilter()
    untransformFilter.SetTransform(untransform)
    untransformFilter.SetInputConnection(connectivityFilter.GetOutputPort())
    untransformFilter.Update()

    cleaned = vtk.vtkCleanPolyData()
    cleaned.SetInputConnection(untransformFilter.GetOutputPort())
    cleaned.Update()

    deci = vtk.vtkDecimatePro()
    deci.SetInputConnection(cleaned.GetOutputPort())
    deci.SetTargetReduction(0.5)
    deci.PreserveTopologyOn()

    writer = vtk.vtkPolyDataWriter()
    writer.SetInputConnection(deci.GetOutputPort())
    writer.SetFileName("netneuro/surfaces/"+surf_name)
    writer.Write()

print("writing surfaces/index.json")
with open("netneuro/surfaces/index.json", "w") as outfile:
    json.dump(index, outfile)

print("all done")
