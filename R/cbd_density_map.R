
# Finds the density of a point-spread by convolving with a Gaussian
# filter with some spread parameter sigma
#
# @param x The x-coordinate at which we want to know the density
# @param x The y-coordinate at which we want to know the density
# @param The options object created from make_cbd()
#
# @ return A float representing the density at the point (x,y)
#
# internal
weighting_by_distance <- function(x, y, opts){
  w <- 0
  for (idx in 1:length(opts$x_positions)){
    dsqr <- (x-opts$x_positions[idx])^2 + (y-opts$y_positions[idx])^2
    dw = exp(-0.5*dsqr/opts$smear_size^2)
    w <- w + dw
  }
  return(w)
}

# Finds the density of each pixel on a grid
#
# @param x_positions A list of x-coordinates for all points
# @param y_positions A list of y-coordinates for all points
# @param opts An options object created using make_options()
#
# @return An nY x nX array of relative densities
#
# internal
density_on_grid <- function(opts){

  "
  Fills a grid from the bottom-left, going rightward across a row first,
  then up row by row.
  "

  w_grid <- opts$grid

  for(idx in 1:opts$nY){
    for(jdx in 1:opts$nX){
      x <- x_from_jdx(opts,jdx)
      y <- y_from_idx(opts,idx)
      new_weight <- weighting_by_distance(x,y,opts)
      w_grid[idx,jdx] <- new_weight
    }
  }

  # find densities relative to the max density, and discretize to nearest 0.1
  maxW <- max(w_grid)
  normW <- w_grid / maxW
  normW <- round(10*normW)/10

  w_maxW <- list(normW,maxW)
  return(w_maxW)

}
