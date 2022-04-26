[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-brainlife.app.580-blue.svg)](https://doi.org/10.25663/brainlife.app.580)

# Structural Connectome MRTrix3 (SCMRT) (SIFT2)

This app will "This app will generate a structural connectome from tractography and parcellation data using SIFT2 to clean the tractograms. This app takes in as input a wholebrain tractogram, and volumated parcellation, a csd dataytpe to perform SIFT2, a tissue type mask (5tt), and tensor and noddi datatypes as optional datatypes to generate metric-based connectivity matrices. This app will output many datatypes that are common to the network pipelines available on brainlife.io"

### Authors

- Brad Caron (bacaron@utexas.edu)

### Contributors

- Soichi Hayashi (shayashi@iu.edu)

### Funding Acknowledgement

brainlife.io is publicly funded and for the sustainability of the project it is helpful to Acknowledge the use of the platform. We kindly ask that you acknowledge the funding below in your publications and code reusing this code.

[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)

### Citations

We kindly ask that you cite the following articles when publishing papers and code using this code.

1. Avesani, P., McPherson, B., Hayashi, S. et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. Sci Data 6, 69 (2019). https://doi.org/10.1038/s41597-019-0073-y

2. Tournier, J.-D.; Smith, R. E.; Raffelt, D.; Tabbara, R.; Dhollander, T.; Pietsch, M.; Christiaens, D.; Jeurissen, B.; Yeh, C.-H. & Connelly, A. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. NeuroImage, 2019, 202, 116137

3. Hagmann, P.; Cammoun, L.; Gigandet, X.; Meuli, R.; Honey, C.; Wedeen, V. & Sporns, O. Mapping the Structural Core of Human Cerebral Cortex. PLoS Biology 6(7), e159

4. Smith, R. E.; Tournier, J.-D.; Calamante, F. & Connelly, A. The effects of SIFT on the reproducibility and biological accuracy of the structural connectome. NeuroImage, 2015, 104, 253-265

5. Smith, R. E.; Tournier, J.-D.; Calamante, F. & Connelly, A. SIFT2: Enabling dense quantitative assessment of brain white matter connectivity using streamlines tractography. NeuroImage, 2015, 119, 338-351

6. Smith, RE; Raffelt, D; Tournier, J-D; Connelly, A. Quantitative Streamlines Tractography: Methods and Inter-Subject Normalisation. Open Science Framework, https://doi.org/10.31219/osf.io/c67kn.

#### MIT Copyright (c) 2020 brainlife.io The University of Texas at Austin and Indiana University

## Running the App

### On Brainlife.io

You can submit this App online at [https://doi.org/10.25663/brainlife.app.580](https://doi.org/10.25663/brainlife.app.580) via the 'Execute' tab.

### Running Locally (on your machine)

1. git clone this repo

2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
    "track": "/input/track/track.nii.gz",
    "parc": "/input/parc/parc.nii.gz",
    "key": "/input/parc/key.txt",
    "label": "/input/parc/label.json",
    "lmax2": "/input/csd/lmax2.nii.gz",
    "lmax4": "/input/csd/lmax4.nii.gz",
    "lmax6": "/input/csd/lmax6.nii.gz",
    "lmax8": "/input/csd/lmax8.nii.gz",
    "lmax10": "/input/csd/lmax10.nii.gz",
    "lmax12": "/input/csd/lmax12.nii.gz",
    "lmax14": "/input/csd/lmax14.nii.gz",
    "mask": "/input/mask/mask.nii.gz",
    "fa": "/input/tensor/fa.nii.gz",
    "md": "/input/tensor/md.nii.gz",
    "rd": "/input/tensor/rd.nii.gz",
    "ad": "/input/tensor/ad.nii.gz",
    "ga": "/input/tensor/ga.nii.gz",
    "ak": "/input/tensor/ak.nii.gz",
    "mk": "/input/tensor/mk.nii.gz",
    "rk": "/input/tensor/rk.nii.gz",
    "ndi": "/input/noddi/ndi.nii.gz",
    "isovf": "/input/noddi/isovf.nii.gz",
    "odi": "/input/noddi/odi.nii.gz",
    "lmax": 8
}
```

### Sample Datasets

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli). 

```
npm install -g brainlife
bl login
mkdir input
bl dataset download
```

3. Launch the App by executing 'main'

```bash
./main
```

## Output

The main output of this App is a raw datatype containing all of the matrices generated, individual conmat dataytpes for count, length, density, and denlen, and a networkneuro datatypes for visualization.

#### Product.json

The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing.

### Dependencies

This App only requires [singularity](https://www.sylabs.io/singularity/) to run. If you don't have singularity, you will need to install following dependencies.   

- Python3: https://www.python.org/downloads/
- pandas: https://pandas.pydata.org/
- numpy: https://numpy.org/
- nibabel: https://nipy.org/nibabel/
- dipy: https://dipy.org/
- igraph: https://igraph.org/python/
- jgf: https://pypi.org/project/jgf/
- tqdm: https://tqdm.github.io/
- MRTrix3: https://www.mrtrix.org/

#### MIT Copyright (c) 2020 brainlife.io The University of Texas at Austin and Indiana University
