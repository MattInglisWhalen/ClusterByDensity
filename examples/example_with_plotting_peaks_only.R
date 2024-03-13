
library('plotrix')
library('ClusterByDensity')

example_workflow <- function(){

  datapoints <- read.csv("sample_point.csv")

  # Choose the options for our grid. Extents and smear_size are chosen automatically
  opts <- make_opts(x_positions = datapoints$x,
                    y_positions = datapoints$y,
                    resolution = 0.1)

  # uncomment to save image to a file -- "turn on the png device"
  # png(filename=sprintf("%s/images/%s.png",getwd(),overtitle))

  # find the clusters in the distribution of points
  peaks <- find_peaks(opts, prop_cutoff = 0.5)

  # open a new image and plot the clusters as ellipsoids
  plot_peaks(peaks = peaks, opts = opts, new_plot = TRUE, show_frame = TRUE)

  # human-readable format of where the peaks are and how they're shaped
  print_peaks(peaks=peaks, opts=opts)

  # uncomment to finish saving to the file -- "turn off the png device"
  # dev.off()

}

example_workflow()


