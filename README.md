# ClusterByDensity

 An R package which implements a clustering algorithm for 2D point-spread datasets. Additional functionality includes data visualization through scatterplots, heatmaps, and superimposed ellipsoidal clusters. 

 !["Heatmap with overlaid cluster ellipses"](/images/_final_product.png "ClusterByDensitySample")

## Installation

Option 1) Use the `devtools` library. 

If you don't have devtools already installed, type

> install('devtools')

into your R console. Then, also on the command line, type

> devtools::install_github("MattInglisWhalen/ClusterByDensity")

The package should now be usable.


Option 2) Use the `remotes` library. 

I've been told that this is preferable to devtools, since `remotes` is smaller and easier to install. If you don't already have `remotes` installed, use R's command line to type

> install('remotes')

Then, also on the command line, type

> remotes::install_github("MattInglisWhalen/ClusterByDensity")

The package should now be usable.

Option 3) Copy/paste the source files.

Simply copy the five .R files in this repository's `R` directory into your working directory. In `cluster_by_density.R`, uncomment all lines. Then at the top of your analysis script, add

```
source('cluster_by_density.R')
```

All functions in the package should now be available for you to use. 
If you have no need for visualization then the
package should be self-contained, but if you want the pretty plots you'll also need to install [plotrix](https://cran.r-project.org/package=plotrix), which can be done using the command
```
install.packages("plotrix")
```

## Usage

There are 3 core functions that are exposed by this package.

1. `make_opts` : This sets up the options for the algorithm and returns a single object to store all the required information.

2. `find_peaks` : This takes as input the `opts` object returned from `make_opts()` and returns a `peaks` object with information about the location of clusters in the data.

3. `print_peaks` : This takes as input the `peaks` object returned from `find_peaks` and prints its contents in a human-readable format

There are a further 2 non-core functions that can help visualize the data and peak-finding results, provided that the `plotrix` package is installed on your machine.

4. `plot_heatmap` : Shows a heatmap of the 2D dataset.

5. `plot_peaks` : Shows the results of the `find_peaks` algorithm as ellipsoids.

For code samples, please see the `examples` directory of this repository. If you have installed ClusterByDensity using either `devtools` or `remotes`, you can also type 

> ?make_opts

into the R command line to get more information about each of the function. There are no vignettes for this package.

## Algorithm Explanation

 !["Algorithm Explanation Gif"](/images/cbd_algo.gif "ClusterByDensityAlgorGif")


## Citing this package

You may cite this package as 

```
@misc{MIW2024,
  author = {Inglis-Whalen, Matthew},
  title = {ClusterByDensity},
  year = {2024},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {\url{https://github.com/MattInglisWhalen/ClusterByDensity}},
  commit = {04985076509bb2fca774b5b96d976c3de6a64454}
}
```

