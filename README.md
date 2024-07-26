# Sleep Oscillations Analysis Pipeline

This pipeline is designed to analyse electrophysiological data during sleep, with two main aims: oscillatory event extraction and sleep stage classification. This work is built on [Hay et al., 2021](https://doi.org/10.1016/j.neuron.2021.06.030), [Donoghue et al., 2020](https://doi.org/10.1038/s41593-020-00744-x), and [Jarzebowski et al., 2021](https://doi.org/10.7554/eLife.65998).

Example electrophysiological data can be found in [Hay et al., 2021](https://doi.org/10.1016/j.neuron.2021.06.030).

## Software Requirement
- MATLAB 2023a

## Main Experiments

Experiments are run using scripts in the main scripts folder. Scripts should be run in the following order:

1. **Preprocessing** (`preprocessing.m`)
   - Load binary data into numerical array
   - Assign channels and down-sampling
   - Data cleaning – Remove non-sleep signals
   - Generate local signal

2. **Simple Classification** (`SimpleClassification.m`)
   - Generate sleep epochs
   - Calculate delta:theta ratio in each epoch
   - Use K-means clustering to segregate NREM sleep from REM sleep

3. **PSD and Parameterising PSD** (`PSDandFOOOF.m`)
   - Remove REM sleep epochs and non-sleep blocks
   - Welch’s power spectral density estimate
   - Use FOOOF functions ([Donoghue et al., 2020](https://doi.org/10.1038/s41593-020-00744-x)) to parameterise PSD 

4. **Ripple Detection** (`RippleDetection.m`)
   - Bandpass filter as ripple band frequency (80 – 250 Hz)
   - Ripple detection using threshold method ([Jarzebowski et al., 2021](https://doi.org/10.7554/eLife.65998))
   - Plot ripple detected in original signal

## Function Folders
- `openEPHYS` function (called in preprocessing)
- `fooof` functions (called in PSD and parameterising PSD) ([Donoghue et al., 2020](https://doi.org/10.1038/s41593-020-00744-x))
- `Ripple` functions (called in ripple detection) ([Jarzebowski et al., 2021](https://doi.org/10.7554/eLife.65998))
- Other functions (called in multiple main scripts)

## Citation
```
Li, Y. (2024) Sleep oscillations and their temporal association in neocortices in mice. University of Cambridge Repository. doi:10.17863/CAM.109708.
```
Access [here](https://www.repository.cam.ac.uk/handle/1810/370216)

---

All scripts were written by Dr Yuqi Li unless otherwise stated.  
University of Cambridge  
July 2024
