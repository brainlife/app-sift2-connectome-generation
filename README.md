<h1 align="center">Structural Connectome MRtrix3 (SCMRT)</h1>

<p align="center">
  Structural connectivity matrices (count, density, length and mean microstructure) from a whole-brain tractogram and a volumetric parcellation, built with MRtrix3.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.395"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.395-blue.svg" alt="Run on brainlife.io"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT license"></a>
</p>

> **This branch, `nosift2_v1.2_centers_netneuro`, is the brainlife.io App Structural Connectome MRTrix3 (SCMRT) - No labels or weights** ([doi:10.25663/brainlife.app.395](https://doi.org/10.25663/brainlife.app.395)). The other Apps in this repository are listed under **Versions on brainlife.io** below.

## At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Builds structural connectivity matrices (count, density, length and mean diffusion measures) from a tractogram and volumetric parcellation with MRtrix3 tck2connectome, without SIFT2 weighting, and outputs conmat and networkneuro datatypes.**

Assigns streamlines to parcel pairs with tck2connectome and builds symmetric count, density (inverse node volume), length and density-of-length matrices, plus mean-microstructure matrices when tensor, NODDI or spherical-mean maps are given. It also builds a networkneuro datatype with parcel surfaces for visualisation. Streamlines are not weighted; use the SIFT2 variant to correct streamline density biases.

| | |
|---|---|
| **Inputs** | `neuro/track/tck` · `neuro/parcellation/volume` · `neuro/tensor` (optional) · `neuro/noddi` (optional) · `neuro/spherical-mean` (optional) |
| **Outputs** | `raw` · `neuro/conmat` ×4 · `neuro/networkneuro` |
| **Container** | `brainlife/mrtrix3:3.0.3` |
| **Resources** | 8 CPUs · 20 GB memory · 6.5 h walltime |
| **Run it** | [doi.org/10.25663/brainlife.app.395](https://doi.org/10.25663/brainlife.app.395) |

#### Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `track` | `neuro/track/tck` | yes | Whole-brain tractogram (.tck). |
| `parc` | `neuro/parcellation/volume` | yes | Volumetric parcellation with label.json; each label becomes a network node. Must be in the same space as the tractogram. |
| `tensor` | `neuro/tensor` | no | Optional DTI/DKI maps (FA, MD, RD, AD and kurtosis maps if present); used to build mean-microstructure matrices. |
| `noddi` | `neuro/noddi` | no | Optional NODDI maps (NDI, ODI, ISOVF); used to build mean-microstructure matrices. |
| `sm` | `neuro/spherical-mean` | no | Optional spherical-mean map; used to build a mean-microstructure matrix. |

#### Outputs

| Output | Datatype | Description |
|---|---|---|
| `output` | `raw` | All connectivity matrices as CSV files (count, density, length, density-of-length and per-measure mean matrices). |
| `count_out` | `neuro/conmat` | Connectivity matrix datatype (csv/correlation.csv with label.json) of streamline counts between node pairs. |
| `length_out` | `neuro/conmat` | Connectivity matrix datatype (csv/correlation.csv with label.json) of mean streamline length between node pairs. |
| `density_out` | `neuro/conmat` | Connectivity matrix datatype (csv/correlation.csv with label.json) of streamline counts scaled by inverse node volume. |
| `denlen_out` | `neuro/conmat` | Connectivity matrix datatype (csv/correlation.csv with label.json) of length-scaled counts normalised by inverse node volume. |
| `netneuro` | `neuro/networkneuro` | networkneuro datatype for brainlife visualisation: matrices, per-edge streamline lists and parcel surfaces. |

<!-- brainlife-app:end -->

## Versions on brainlife.io

Each version is a separate App on brainlife.io, built from its own branch of this repository.

| Version | MRtrix3 | Branch | Run it | Status |
|---|---|---|---|---|
| Structural Connectome MRTrix3 (SCMRT) | 3.0.3 | [`nosift-input-labels-weights-v1.1`](https://github.com/brainlife/app-sift2-connectome-generation/tree/nosift-input-labels-weights-v1.1) | [doi:10.25663/brainlife.app.765](https://doi.org/10.25663/brainlife.app.765) | current |
| Structural Connectome MRTrix3 (SCMRT) (SIFT2) | 3.0.3 | [`sift2_v1.2_centers_netneuro`](https://github.com/brainlife/app-sift2-connectome-generation/tree/sift2_v1.2_centers_netneuro) | [doi:10.25663/brainlife.app.580](https://doi.org/10.25663/brainlife.app.580) | available |
| **Structural Connectome MRTrix3 (SCMRT) - No labels or weights** (this branch) | 3.0.3 | [`nosift2_v1.2_centers_netneuro`](https://github.com/brainlife/app-sift2-connectome-generation/tree/nosift2_v1.2_centers_netneuro) | [doi:10.25663/brainlife.app.395](https://doi.org/10.25663/brainlife.app.395) | available |
| Structural Connectome MRTrix3 (SCMRT) - deprecated | 3.0.3 | [`nosift-input-labels-weights-v1.0`](https://github.com/brainlife/app-sift2-connectome-generation/tree/nosift-input-labels-weights-v1.0) | [doi:10.25663/brainlife.app.617](https://doi.org/10.25663/brainlife.app.617) | deprecated |
| Structural Connectome MRTrix3 (SCMRT) (SIFT2) - Deprecated | 3.0.3 | [`sift2_v1.1_centers`](https://github.com/brainlife/app-sift2-connectome-generation/tree/sift2_v1.1_centers) | [doi:10.25663/brainlife.app.394](https://doi.org/10.25663/brainlife.app.394) | deprecated |

The current App takes optional streamline labels and precomputed streamline weights (for example SIFT2 weights). The SIFT2 App computes the SIFT2 weights itself from CSD FODs and a five-tissue-type (5TT) image, and the SIFT2 and "No labels or weights" Apps also output a `neuro/networkneuro` datatype for visualisation on brainlife.io.

## Running the App

### On brainlife.io

Open the App at [doi.org/10.25663/brainlife.app.765](https://doi.org/10.25663/brainlife.app.765), choose a whole-brain tractogram (`neuro/track/tck`) and a volumetric parcellation in the same space, add any optional maps (tensor, NODDI, quantitative MRI, myelin map, spherical mean) and optional streamline labels or weights, and press **Execute**. The App archives the matrices to your project as a raw `networkmatrices` dataset, four `neuro/conmat` datasets (count, density, length, density-of-length) and a `neuro/labels` dataset with the streamline assignments.

### Locally

You need [Singularity/Apptainer](https://apptainer.org/) and [`jq`](https://jqlang.github.io/jq/). `main` runs MRtrix3 3.0.3 (`brainlife/mrtrix3:3.0.3`) and Python with DIPY 1.4.0 (`brainlife/dipy:1.4.0`) from containers.

1. Clone this repository and check out the version you want (for example `git checkout nosift-input-labels-weights-v1.1`).
2. Create `config.json` with the paths to your inputs and the options you want. Leave out the optional maps you do not have:

   ```json
   {
       "track": "/input/track/track.tck",
       "parc": "/input/parc/parc.nii.gz",
       "key": "/input/parc/key.txt",
       "label": "/input/parc/label.json",
       "fa": "/input/tensor/fa.nii.gz",
       "md": "/input/tensor/md.nii.gz",
       "rd": "/input/tensor/rd.nii.gz",
       "ad": "/input/tensor/ad.nii.gz",
       "ndi": "/input/noddi/ndi.nii.gz",
       "isovf": "/input/noddi/isovf.nii.gz",
       "odi": "/input/noddi/odi.nii.gz",
       "labels": "/input/labels/labels.csv",
       "weights": "/input/weights/weights.csv",
       "assignment_radial_search": 4,
       "assignment_reverse_search": "",
       "assignment_forward_search": "",
       "inverse_length": true
   }
   ```

3. Run the App:

   ```bash
   ./main
   ```

### Sample data

Download sample datasets from brainlife.io with the [brainlife CLI](https://github.com/brainlife/cli):

```bash
npm install -g brainlife
bl login
mkdir input
bl dataset download <dataset-id>
```

## Outputs

```text
output/output/     all matrices as CSV: count, density, length, denlen,
                   <measure>_mean[_density|_length|_denlen].csv for each map given,
                   centers.csv (node centres) and assignments.csv
count_out/         neuro/conmat: csv/correlation.csv, label.json, index.json
density_out/       neuro/conmat (streamline count scaled by inverse node volume)
length_out/        neuro/conmat (streamline length)
denlen_out/        neuro/conmat (length-scaled density)
assignments/       neuro/labels: streamline-to-node-pair assignments
```

`inverse_length` chooses whether the length and density-of-length matrices are scaled by inverse length (`true`) or by length (`false`); the choice is recorded as a tag in `product.json`.

## Troubleshooting

- **`something failed. check derivatives`**: `density.csv` was not written. Check that the tractogram and parcellation are in the same space; streamlines that end outside every parcel are not assigned to any node (increase `assignment_radial_search`, or set the reverse or forward search, to assign more endpoints).
- **Labels and weights together**: when both are given, the weights are subset to the streamlines labelled 1, so the weights file must have one value per streamline of the input tractogram.

## Citing

> [!TIP]
> If you use this App in your work, please cite the App, the software it builds on and brainlife.io (below). GitHub's **Cite this repository** button gives the App citation in APA and BibTeX.

- Tournier J-D, Smith RE, Raffelt D, Tabbara R, Dhollander T, Pietsch M, Christiaens D, Jeurissen B, Yeh C-H, Connelly A. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. *NeuroImage* 202:116137 (2019). [doi:10.1016/j.neuroimage.2019.116137](https://doi.org/10.1016/j.neuroimage.2019.116137)
- Hagmann P, Cammoun L, Gigandet X, Meuli R, Honey C, Wedeen V, Sporns O. Mapping the structural core of human cerebral cortex. *PLoS Biology* 6(7):e159.
- Smith RE, Tournier J-D, Calamante F, Connelly A. The effects of SIFT on the reproducibility and biological accuracy of the structural connectome. *NeuroImage* 104:253–265 (2015).
- Structural Connectome MRTrix3 (SCMRT) - No labels or weights. brainlife.io App. [doi:10.25663/brainlife.app.395](https://doi.org/10.25663/brainlife.app.395)
- Garyfallidis et al. Dipy, a library for the analysis of diffusion MRI data. *Frontiers in Neuroinformatics* 8 (2014). [doi:10.3389/fninf.2014.00008](https://doi.org/10.3389/fninf.2014.00008)
- Zhang et al. NODDI: Practical in vivo neurite orientation dispersion and density imaging of the human brain. *NeuroImage* 61:1000-1016 (2012). [doi:10.1016/j.neuroimage.2012.03.072](https://doi.org/10.1016/j.neuroimage.2012.03.072)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## Authors

- Brad Caron

**Contributors:** Soichi Hayashi, Franco Pestilli

## Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## License

[MIT](LICENSE). MRtrix3 is distributed under its own [license](https://www.mrtrix.org/).
