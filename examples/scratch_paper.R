# read in some data
datapoints <- read.csv("sample_point.csv")

# choose the options for our grid
opts <- make_opts(x_positions = datapoints$x,
                  y_positions = datapoints$y,
                  resolution = 0.1,
                  smear_size = 0.3,
                  x_extent = c(-2,2),
                  y_extent = c( 0,3))

# uncomment to save image to a file -- "turn on the png device"
# png(filename=sprintf("%s/images/%s.png",getwd(),overtitle))

# find the clusters in the distribution of points
peaks <- find_peaks(opts, prop_cutoff = 0.4)

print(peaks[[1]])
print(peaks[[length(peaks)]])
highest_tpeak <- peaks[[length(peaks)]]
print(highest_tpeak$info)
print(highest_tpeak$clusters)
print(highest_tpeak$clusters$ij)
print(highest_tpeak$clusters$xy)
