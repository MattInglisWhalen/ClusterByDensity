
make_grid <- function(resolution=0.1,
                      x_extent = c(-3,3), 
                      y_extent = c(-3,3)){
  
  xMin <- x_extent[1]
  xMax <- x_extent[2]
  yMin <- y_extent[1]
  yMax <- y_extent[2]
  
  nX <- (xMax-xMin)/resolution
  nY <- (yMax-yMin)/resolution
  
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
                          "grid"=grid_content)
  
  return(grid_properties)
  
}

x_from_jdx <- function(grid,jdx){
  
  x0 <- grid$xMin
  xf <- grid$xMax
  t <- (jdx-1) / (grid$nX-1)

  x <- xf*t + x0*(1-t)
  
  return(x)
}
y_from_idx <- function(grid,idx){
  
  y0 <- grid$yMin
  yf <- grid$yMax
  t <- (idx-1) / (grid$nY-1)
  
  y <- yf*t + y0*(1-t)

  return(y)
}

test_grids <- function(){
  
  new_grid <- make_grid(resolution = 0.1, x_extent=c(-5,5),y_extent=c(-1,1) )
  
  print(new_grid$nX)
  print(x_from_jdx(new_grid,1))
  print(x_from_jdx(new_grid,102))
  print(x_from_jdx(new_grid,0))
  
  print(new_grid$nY)
  print(y_from_idx(new_grid,1))
  print(y_from_idx(new_grid,102))
  print(y_from_idx(new_grid,0))
  
  print(new_grid$grid)
  
}

