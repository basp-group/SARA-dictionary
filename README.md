# SARA dictionary

![language](https://img.shields.io/badge/language-MATLAB-orange.svg)
[![license](https://img.shields.io/badge/license-GPL--3.0-brightgreen.svg)](LICENSE)
[![docs-page](https://img.shields.io/badge/docs-latest-blue)](https://basp-group.github.io/SARA-dictionary/)

<!-- [![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit) -->

## Description

- ``SARA-dictionary`` contains a MATLAB implementation of the SARA wavelet dictionary desribed in [1] using a "segment-wise 2D discrete wavelet transform" [2].
Both a serial and a distributed implementation of the dictionary are proposed

- The ``SARA-dictionary`` library is a core dependency of the
[`Faceted-Hyper-SARA`](https://github.com/basp-group/Faceted-Hyper-SARA) wideband imaging library for radio-interferometry.

- Codes ublished by the author of [2], [available online](https://www.utko.fekt.vut.cz/~rajmic/segwt/index_en.html), have been significantly refactored for use in the MATLAB codes associated with the following paper.

> P.-A. Thouvenin, A. Abdulaziz, M. Jiang, A. Dabbech, A. Repetti, A. Jackson, J.-P. Thiran, Y. Wiaux -
> <strong>Parallel faceted imaging in radio interferometry via proximal splitting (Faceted HyperSARA)</strong>, submitted, <a href="https://researchportal.hw.ac.uk/en/publications/parallel-faceted-imaging-in-radio-interferometry-via-proximal-spl">preprint available online</a>, Jan. 2020.

**Authors/contributors:** P.-A. Thouvenin, A. Dabbech.

**References**

> [1] R. E. Carrillo, J. D. McEwen and Y. Wiaux, [Sparsity Averaging Reweighted Analysis (SARA): a novel algorithm for radio-interferometric imaging]([http://dx.doi.org/10.1093/mnras/stx755](https://academic.oup.com/mnras/article/426/2/1223/974193)), *MNRAS*, 426(2):1223-1234, 2012.
>
> [2] Z. PRŮŠA -- <strong>Segmentwise Discrete Wavelet Transform.</strong>, Dissertation thesis, Brno University of Technology, 2012.

## Installation

Just clone the current repository

```bash
git clone https://github.com/basp-group/SARA-dictionary.git
```

To get started with the library, take a look at the [documentation hosted online on github](https://basp-group.github.io/SARA-dictionary/).

## Contributions

### Building the documentation

To build the documentation, make sure the following Python packages have been installed, and issue the appropriate buid command.

```bash
# setup conda environment to build the documentation
conda env create --name sdwt-doc --file environment.yml

## alternative using conda
# conda create -n sdwt-doc
# conda activate sdwt-doc
# conda install pip
# pip install miss_hit
# pip install -r requirement.txt

# building the documentation in html format
cd docs
make html
```

All the generated `.html` files are contained in the `docs/build` folder.

If needed, you can delete the `conda` environment as follows

```bash
conda env remove -n sdwt-doc
```

### Pushing the documentation online

Add a `worktree` from the `master` branch

```bash
   # make sure the folder html does not exist before running the command
   git worktree add docs/build/html gh-pages
   cd docs/build/html
   git add .
   git commit -m "Build documentation as of $(git log '--format=format:%H' master -1)"
   git push origin gh-pages
   # delete the worktree
   cd ../
   git worktree remove html
```

### Code layout

Make sure any pull request has been properly formatted with the [`miss_hit`](https://pypi.org/project/miss-hit/) package using the provided `miss_hit.cfg` configuration file

```bash
# activate sdwt-doc environment (see previous paragraph)
conda activate sdwt-doc
# run the following command from the root of the package (where the miss_hit.cfg file is)
mh_style --fix .
```
