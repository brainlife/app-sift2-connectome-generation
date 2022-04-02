[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-brainlife.app.394-blue.svg)](https://doi.org/10.25663/brainlife.app.394)

# Structural connectome MRTrix3 (SCMART).

This app will generate structural connectome adjacency matrices to use in graph theory analyses (Sporns cite). This uses MRTrix3's tck2connectome and SIFT2 functions to generate connectomes of count, length, and the average of diffusion measures (if inputted) (MRTRIX3 CONNECTOME AND SIFT2 CITE). This app will also generate density and density of length matrices. 

# Authors
- [Bradley Caron](bacaron@iu.edu)

# Contributors
- [Franco Pestilli](pestilli@utexas.edu)
- [Soichi Hayashi](hayashis@iu.edu)

# Please cite the following work and funding when using this code.

[Aydogan2019a]	Aydogan DB, Shi Y., “Parallel transport tractography”, In preparation.

[Aydogan2019b]	Aydogan DB, Shi Y., “A novel fiber tracking algorithm using parallel transport frames”, ISMRM 2019, Montreal.

[Avesani et al. (2019) The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. Scientific Data](https://doi.org/10.1038/s41597-019-0073-y)

### Funding 
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)


# How does it work?

This [brainlife.io](brainlife.io/apps) App generates adjacency matrices using [MRTRix3 and SIFT2](mrtrix3 cite). 

To run THORA you need to first run the following Apps: 

  (1) [Generate FOD](https://doi.org/10.25663/bl.app.49) alternatively [FreeSurfer](https://doi.org/10.25663/bl.app.0) 

  (2) [Generate 5tt](https://doi.org/10.25663/brainlife.app.222) 
  
  (3) [DTI or NODDI](https://doi.org/10.25663/bl.app.23)
  
  (4) [Tracking]()

## Running the App 

### On Brainlife.io

You can submit this App online at [https://doi.org/10.25663/brainlife.app.394](https://doi.org/10.25663/brainlife.app.394) via the "Execute" tab.

# Run this App

You can run this App on brainlife.io, or if you'd like to run it locally, you ca do the following.

1) git clone this repo on your machine

2) Stage input file

```
bl dataset download <dataset id for any neuro/dwi data and neuro/anat/t1w and neuro/csd and neuro/rois data from barinlife>
```

3) Create config.json (you can copy from config.json.sample)

```
{
  "parc": "/testdata/parcellation/parc.nii.gz",
  "track":  "/testdata/track/track.tck",
  "lmax2":  "/tesdata/input_csd/lmax2.nii.gz",
  "lmax4":  "/tesdata/input_csd/lmax4.nii.gz",
  "lmax6":  "/tesdata/input_csd/lmax6.nii.gz",
  "lmax8":  "/tesdata/input_csd/lmax8.nii.gz",
  "lmax10":  "/tesdata/input_csd/lmax10.nii.gz",
  "lmax12":  "/tesdata/input_csd/lmax12.nii.gz",
  "lmax14":  "/testdata/input_csd/lmax14.nii.gz",
  "ndi":  "/testdata/noddi/ndi.nii.gz",
  "odi":  "/testdata/noddi/odi.nii.gz",
  "isovf":  "/testdata/noddi/isovf.nii.gz",
  "fa":	"/testdata/tensor/fa.nii.gz",
  "md":	"/testdata/tensor/md.nii.gz",
  "ad":	"/testdata/tensor/ad.nii.gz",
  "rd":	"/testdata/tensor/rd.nii.gz"
}
```

4) run `./main`
