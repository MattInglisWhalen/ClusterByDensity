
#' Creates an options object with information about the grid, given various parameters
#'
#' Collects together all the relevant parameters for peak-finding and visualization. These are
#' bundled together into an `options` object so these parameters don't need to be passed
#' around individually
#'
#' @param x_positions A list of x-coordinates for all points
#' @param y_positions A list of y-coordinates for all points
#' @param resolution The width of a pixel
#' @param smear_size The standard deviation of the Gaussian kernel that convolves with the datapoints to create a 2D density distribution
#' @param x_extent A length-2 vector of the minimum and maximum x-values of the grid
#' @param y_extent A length-2 vector of the minimum and maximum y-values of the grid
#'
#' @return A list of various properties of the grid. In order, xMin, xMax, yMin, yMax, nX, nY, resolution, smear_size, x_positions, y_positions, n_points, grid. The last, `grid`, is an nY x nX array filled with zeroes.
#'
#' @export
make_opts <- function(x_positions,
                      y_positions,
                      resolution = 0.1,
                      smear_size = -1,
                      x_extent = c(0,0),
                      y_extent = c(0,0)){

  if(length(x_positions) == length(y_positions)){
    n_points <- length(x_positions)
  }
  else {
    message("CBD: make_opts(): x_positions and y_positions must have the same length")
    stop()
  }

  xMin <- x_extent[1]
  xMax <- x_extent[2]
  yMin <- y_extent[1]
  yMax <- y_extent[2]

  # in cases where default version of parameters are used
  if(xMin^2 + xMax^2 < 1e-5){
    diff <- max(x_positions) - min(x_positions)
    xMin <- min(x_positions) - diff / 10
    xMax <- max(x_positions) + diff / 10
  }
  if(yMin^2 + yMax^2 < 1e-5){
    diff <- max(y_positions) - min(y_positions)
    yMin <- min(y_positions) - diff / 10
    yMax <- max(y_positions) + diff / 10
  }
  if(smear_size<0){
    avg_density <- n_points / ( (xMax-xMin)*(yMax-yMin) )

    # if R is the avg distance to the nearest neighbour, and there are N
    # points, then in 2D the area occupied by all points is A = N (pi R^2)
    # i.e. density = N/A = 1/(pi R^2), or R = 1/sqrt(pi density)
    avg_dist_to_neighbour <- 1/sqrt(3.14159 * avg_density)

    smear_size <- avg_dist_to_neighbour
  }

  nX <- (xMax-xMin)/resolution
  nY <- (yMax-yMin)/resolution

  if(nX*nY > 5000){
    message(sprintf("CBD: Careful with the choice of resolution! Currently working with $i pixels, which might take forever to complete!",nX*nY))
  }

  grid_content <- c()
  for(row in 1:nY){
    grid_content <- rbind(grid_content, rep(0,nX))  # pre-initialize the grid of weights
  }

  grid_properties <- list("xMin"=xMin,
                          "xMax"=xMax,
                          "yMin"=yMin,
                          "yMax"=yMax,
                          "nX"=nX,
                          "nY"=nY,
                          "resolution"=resolution,
                          "smear_size"=smear_size,
                          "x_positions"=x_positions,
                          "y_positions"=y_positions,
                          "n_points" = n_points,
                          "grid"=grid_content)

  return(grid_properties)

  # TODO: add find_peaks() to the return of this function. Easier UX
  # ^ no, because someone might want to plot the heatmap without peak-finding

}

x_from_jdx <- function(opts,jdx){

  x0 <- opts$xMin
  xf <- opts$xMax
  t <- (jdx-1) / (opts$nX-1)

  x <- xf*t + x0*(1-t)

  return(x)
}
y_from_idx <- function(opts,idx){

  y0 <- opts$yMin
  yf <- opts$yMax
  t <- (idx-1) / (opts$nY-1)

  y <- yf*t + y0*(1-t)

  return(y)
}
xy_from_ij <- function(opts,df_ij){
  xs <- x_from_jdx(opts,df_ij[,2])
  ys <- y_from_idx(opts,df_ij[,1])
  xys <- data.frame(cbind(xs,ys))
  return(xys)
}
