# The CLL-map study

The project assembled and analyzed genomic, transcriptomic, epigenomic and clinical data from over 1100 chronic lymphocytic leukemia (CLL) patients. Here I provide the code to estimate the epigenetic variables in the CLL-map study, including the CLL epitypes and epiCMIT mitotic clock.


## Abstract
(uploaded soon!)

## Graphical summary
(uploaded soon!)

## Code availability

The parent repository for the whole study can be found [here](https://github.com/getzlab/CLLmap). The code for estimating CLL epitypes and epiCMIT is subsequently presented:

### CLL epitype calculation

Chronic lymphocytic leukemia (CLL) is the most frequent leukemia in the western countries and presents with a broad spectrum of clinical behaviors. This can be partially captured by the presence of two biological subtypes distinguished by the extent of somatic mutations in the heavy chain variable region of immunoglobulin genes (IGHV). These groups are unmutated (U) and mutated (M) CLL, with poorer and better clinical outcome, respectively. Nonetheless, [Kulis et al., 2012](https://www.nature.com/articles/ng.2443) found that CLL can be actually classified in 3 groups or epitypes based on different DNA methylation imprints of pre- and post- germinal center experienced B cells. These epitypes, which add further clinical information beyond IGHV subgroups, were named n-CLL (formed mainly by U-CLL), m-CLL (formed mainly by M-CLL) and i-CLL ( formed by U-CLL and M-CLL). Here, I present all necessary steps to find the CLL epitypes in RRBS data.

[Complete tutorial for CLL epitype prediction using your NGS DNA methyaltion data.](https://duran-ferrerm.github.io/CLLmap-epigenetics/Epitype.RRBS.html)

### epiCMIT mitotic clock calculation. 

In addition to CLL epitypes, from the epigenetic perspective they can be are further delineated by their proliferative histories measured by the [epiCMIT](https://www.nature.com/articles/s43018-020-00131-2) mitotic clock using DNA methylation data. This epiCMIT score represents a strong and continuous independent clinical variable from all the well-established to date.

[Complete tutorial for estimating epiCMIT in your CLL samples.](https://duran-ferrerm.github.io/CLLmap-epigenetics/epiCMIT.RRBS.html)


## LICENSE
LICENSE terms for epitype predictions and epiCMIT can be found [here](https://github.com/Duran-FerrerM/Pan-B-cell-methylome/blob/master/LICENSE)

## Citation
If you use any data or code derived from this study, please cite: *Knisbacher, Lin, Hahn, Nadeu, Duran-Ferrer et al, Nat. Genet, 2022*.

## Contact
If you have any question, comment or suggestions please contact me at: *maduran@clinic.cat* :-)


