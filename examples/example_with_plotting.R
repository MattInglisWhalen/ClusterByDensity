
library('ClusterByDensity')

example_workflow <- function(){

  # read in some data
  datapoints <- read.csv("sample_point.csv")

  # print(datapoints$x)
  # plot(datapoints$x,datapoints$y)

  # choose the options for our grid
  opts <- make_opts(x_positions = datapoints$x,
                    y_positions = datapoints$y,
                    resolution = 0.1,
                    smear_size = 0.205,
                    x_extent = c(-2,2),
                    y_extent = c( 0,3))

  # uncomment to save image to a file -- "turn on the png device"
  # png(filename=sprintf("%s/images/%s.png",getwd(),overtitle))

  # find the clusters in the distribution of points
  peaks <- find_peaks(opts, prop_cutoff = 0.75)

  # open a new image and write the heatmap to the image
  plot_heatmap(opts,overtitle="My First Clustering by Density", show_frame=TRUE)

  # on the same image, plot the clusters as ellipsoids
  plot_peaks(peaks = peaks, opts = opts, new_plot = FALSE)

  # human-readable format of where the peaks are and how they're shaped
  print_peaks(peaks=peaks, opts=opts)

  # uncomment to finish saving to the file -- "turn off the png device"
  # dev.off()

}

example_workflow()
