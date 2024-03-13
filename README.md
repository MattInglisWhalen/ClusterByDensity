# ClusterByDensity

 A package which implements a clustering algorithm for 2D point-spread datasets. Additional functionality includes data visualization through scatterplots, heatmaps, and superimposed ellipsoidal clusters. 

## Installation

Option 1) Use the `devtools` library. 

If you don't have devtools already installed, type

> install('remote')

into your R console. Then, also on the command line, type

> devtools::install_github("MattInglisWhalen/ClusterByDensity")

The package should now be usable.


Option 2) Use the `remote` library. 

I've been told that this is preferable to devtools, since `remote` is smaller and easier to install. If you don't already have `remote`, use R's command line to type

> install('remote')

Then, also on the command line, type

> remote::install_github("MattInglisWhalen/ClusterByDensity")

The package should now be usable.

Option 3) Simply copy the four .R files in the `R` directory into your working directory. For clustering only, add

> source('cluster_by_density.R') to the top of your 


## Usage


