
source("grid.R")

"
Finds the density of a point-spread by convolving with a Gaussian 
filter with some spread parameter sigma
"
KERNEL_SIZE <- 0.3
NUM_INTERVALS <- 10

weighting_by_distance <- function(x,y,x_positions,y_positions, sigma=0.3){
  w <- 0
  for (idx in 1:length(x_positions)){
    dsqr <- (x-x_positions[idx])^2 + (y-y_positions[idx])^2
    dw = exp(-0.5*dsqr/sigma^2/(2*3.14159*sigma^2))
    w <- w + dw
  }
  return(w)
}


density_on_grid <- function(x_positions, y_positions, grid){

  "
  Builds a grid from the bottom-left, going rightward across a row first, 
  then up row by row. 
  "
  
  w_grid <- grid$grid

  for(idx in 1:grid$nY){  
    for(jdx in 1:grid$nX){  
      x <- x_from_jdx(grid,jdx)
      y <- y_from_idx(grid,idx)
      new_weight <- weighting_by_distance(x,y,
                                          x_positions,y_positions,
                                          sigma=KERNEL_SIZE)
      w_grid[idx,jdx] <- new_weight
    }
  }

  maxW <- max(w_grid)
  normW <- w_grid / maxW
  
  if(NUM_INTERVALS>0){
    normW <- ceiling(NUM_INTERVALS*(normW-0.5/NUM_INTERVALS)) / NUM_INTERVALS
  }
  
  w_maxW <- list(normW,maxW)
  
  return(w_maxW)
  
}