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

There are 3 core functions that are exposed by this package.

1. `make_opts` : This sets up the options for the algorithm and returns a single object to store all the required information.

2. `find_peaks` : This takes as input the `opts` object returned from `make_opts()` and returns an object with information about the location of clusters in the data.

3. `print_peaks` : This takes as input the `peaks` object returned from `find_peaks` and prints its contents in a human-readable format

There are a further 2 non-core functions that can help visualize the data and peak-finding results, provided that the `plotrix` package is installed on your machine.

4. `plot_heatmap` : Shows a heatmap of the 2D dataset.

5. `plot_peaks` : Shows the results of the `find_peaks` algorithm as ellipsoids.

You can further examine the examples in the repository


