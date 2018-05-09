ENCODE Motif Validation pipeline
====
Three types of motif enrichment scores are computed by overlapping the motif instances with the given ChIP-seq peak locations, which includes global enrichment z-score (compare the actual motif with the shuffled-version motif), positional bias z-score (compare peak center to the peak flanking region, +/-100bp), and peak rank bias z-score (compare the high signal value regions to the low signal value regions). Then, a combined enrichment score can be derived from taking average of three enrichment scores listed above.  Forth, the known motifs are grouped as 282 clusters by their PWM similarities and each motif cluster is ranked by the highest combined enrichment score of that motif cluster. Therefore, each known motif is assigned to the ranking of the motif cluster it belong to.

We developed a Bayesian approach assuming the enrichment ranking distribution of the known motif following a mixture of two negative-binomial distributions, which corresponding to two cases: 1. antibody targeting corresponding TF of that motif, and  2. Antibody is targeting other TFs. If these two negative-binomial distributions for the tested motif is known, we can derived the accept/reject probability of the tested antibody given the enrichment ranking of that motif. 

The parameters of two negative-binomial distribution is estimated from the previous ChIP-seq data of that TF and all other TFs (stored in pipeline_script/cistrome_model.pickle). This accepted probability calculation also assumes the prior probability of passing validation is 50% and takes into account the fact that different TFs may share the same motif or one TF may use multiple motifs. 

Software Requirement
----
- add "bin" folder to your enviroment PATH. This folder consists of utility scripts created by Pouya Kheradpour
- Python 2.7, Numpy, Scipy, sklearn, matplotlib
- Bedtools
- R-3.1

Input
-----
- BED format peak file with at least 5 columns. The pipeline assumes that the 5th column is the peak score, which usually corresponds to the 7th column in the ENCODE NarrowPeak format.
- reference genome, default is hg19
- motif instances, which are defined and can be downloaded in http://compbio.mit.edu/encode-motifs/  

### Getting started:
- Add the "bin" folder to your enviroment PATH. This folder consists of utility scripts created by Pouya Kheradpour

### Using:
reuse UGER
reuse BEDTools
reuse Anaconda # (or install miniconda - this may be better)

### Create the following environment:
conda create --name mv_env python=2.7 r-essentials r-base scipy scikit-learn numpy matplotlib

Author
---
Pouya Kheradpour

Maintained by Carles Boix

MIT Kellis Lab 
=======
