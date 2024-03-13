
library('ClusterByDensity')

example_workflow <- function(){

  # Read in some data
  datapoints <- read.csv("sample_point.csv")

  # Choose the options for our grid
  opts <- make_opts(x_positions = datapoints$x,
                    y_positions = datapoints$y,
                    resolution = 0.1,
                    smear_size = 0.3,
                    x_extent = c(-2,2),
                    y_extent = c( 0,3))

  # Find the clusters in the distribution of points
  # Only peaks with a density equal to 60% of the max density are kept
  peaks <- find_peaks(opts, prop_cutoff = 0.6)

  # Human-readable format of where the peaks are and how they're shaped
  print_peaks(peaks=peaks, opts=opts)

  # ... analysis continues ...

  # to use the `peaks` object, here is its structure
  #
  # peaks = list( tpeak_1, tpeak_2, ... )
  #
  #     tpeak_1 = list( info , clusters )
  #         info     = list( threshold, n )
  #             threshold: the relative density of all pixels in the peak
  #             n        : the number of clusters at this threshold
  #         clusters = list( clust_1, ..., clust_n )
  #             clust_1 = list( ij, xy )
  #                 ij: (Nx2) array, i.e. an array containing the (idx,jdx)
  #                                       pair of each of the N pixels in
  #                                       the clusters
  #                 xy: (Nx2) array, i.e. an array containing the (x,y)
  #                                       pair of each of the N pixels in
  #                                       the clusters

  # for example, let's get the mean position of each peak at each threshold

  for(tpeak in peaks){

    # print info of each tpeak
    threshold <- tpeak$info$threshold
    number_at_threshold <- tpeak$info$n
    message(sprintf("There are %i peaks at threshold=%.1f",number_at_threshold,threshold))

    clusters_at_thresh <- tpeak$clusters
    for(clust in clusters_at_thresh){

      xy <- clust$xy
      xs <- xy[,1]
      ys <- xy[,2]

      mean_x <- mean(xs)
      mean_y <- mean(ys)

      message(sprintf("  Peak center at (x,y) = (%.2f, %.2f) from %i pixels",
                      mean_x,mean_y,nrow(xy)))
    }
  }

}

example_workflow()
