
# How to color a pixel based on its density
#
# @param weight The relative density of a pixel (weights are assumed to be 0<w<1)
# @param tol The tolerance for coloring each threshold
#
# internal
color_by_weight <- function(weight, tol=1e-5){
  top_col <- '#FF0000'
  mid_col <- '#CCCCFF'
  bot_col <- '#FFFFFF'
  upper_ramp <- colorRampPalette(c(mid_col,top_col))
  bot_ramp <- colorRampPalette(c(bot_col,mid_col))

  uramp <- upper_ramp(5)
  bramp <- bot_ramp(5)

  if(weight > 0.9 + tol){return('#FFA500')}
  else if(weight > 0.8 + tol){return(uramp[4])}
  else if(weight > 0.7 + tol){return(uramp[3])}
  else if(weight > 0.6 + tol){return(uramp[2])}
  else if(weight > 0.5 + tol){return(uramp[1])}
  else if(weight > 0.4 + tol){return(bramp[5])}
  else if(weight > 0.3 + tol){return(bramp[4])}
  else if(weight > 0.2 + tol){return(bramp[3])}
  else if(weight > 0.1 + tol){return(bramp[2])}
  return(bramp[1])
}

#' Plot all peaks as ellipsoids
#'
#' Using the `peaks` object that is returned from the `find_peaks()` function,
#' plot each cluster as an ellipsoid based off the constituent pixels of that cluster.
#' The original datapoints are overlaid as an inefficient scatterplot.
#'
#' @param peaks The object that was returned from find_peaks()
#' @param opts The options object that was passed to find_peaks()
#' @param new_plot Boolean for whether a new plot should be created. Use FALSE to continue writing to the current plot.
#' @param overtitle The main title of the new plot
#' @param show_frame Boolean of whether to show the bounding region and xy axes
#'
#' @export
plot_peaks <- function(peaks,
                       opts,
                       new_plot = TRUE,
                       overtitle = "Peak Locations",
                       show_frame = FALSE){

  colorblind_palette  = rep(c('#377eb8', '#ff7f00', '#4daf4a',
                              '#f781bf', '#a65628', '#984ea3',
                              '#999999', '#e41a1c', '#dede00'),100)

  asp_rat <- 1
  if(new_plot){

    resolution <- opts$resolution
    minX <- opts$xMin-resolution/2
    maxX <- opts$xMax+resolution/2
    minY <- opts$yMin-resolution/2
    maxY <- opts$yMax+resolution/2

    aspX <- maxX - minX
    aspY <- maxY - minY
    asp_rat <- aspY/aspX

    if(show_frame){
      par(pin=c(6,6*asp_rat))
      plot(opts$x_positions,
           opts$y_positions,
           xlim=c(minX,maxX),
           ylim=c(minY,maxY),
           xlab="",ylab="")
      rect(minX,minY,maxX,maxY,col = '#FFFFFF',border = '#FFFFFF')
    }
    else{
      plot.new()
      plot.window(xlim=c(minX,maxX),
                  ylim=c(minY,maxY))

    }
    title(main=overtitle)
  }

  count <- 1
  for(tpeak in peaks){

    threshold <- tpeak$info$threshold
    n_peaks <- tpeak$info$n
    clusters_at_threshold <- tpeak$clusters

    for(clust in clusters_at_threshold){

      xy <- clust$xy
      xs <- xy[,1]
      ys <- xy[,2]

      mu_x <- mean(xs)
      mu_y <- mean(ys)

      slope <- 0
      if(nrow(xy)==2){
        dy <- ys[2]-ys[1]
        dx <- xs[2]-xs[1]
        slope <- dy /(dx+1e-5)
      }
      else if(nrow(xy)>2){
        # Thwart zero division error
        slope <- cov(xs,ys) / (cov(xs,xs)+1e-5)
      }
      else{
        # do nothing
      }
      angle <- atan(slope)

      rotated_x <-  cos(angle)*xs + sin(angle)*ys
      rotated_y <- -sin(angle)*xs + cos(angle)*ys
      semi_major = (max(rotated_x) - min(rotated_x) + opts$resolution)/2
      semi_minor = (max(rotated_y) - min(rotated_y) + opts$resolution)/2

      semi_major <- semi_major*(threshold/0.5)
      semi_minor <- semi_minor*(threshold/0.5)

      if(new_plot){
        color <- colorblind_palette[count]
        plotrix::draw.ellipse(x=mu_x,
                              y=mu_y,
                              angle=180*angle/3.14159,
                              a=semi_major,
                              b=semi_minor,
                              col=color,
                              border=color#, asp=5
                             )
        count <- count + 1
      }
      else{
        color <- "#000000"
        plotrix::draw.ellipse(x=mu_x,
                              y=mu_y,
                              angle=180*angle/3.14159,
                              a=semi_major,
                              b=semi_minor,
                              border=color
        )
      }
    }
  }

  for(idx in 1:opts$n_points){
    plotrix::draw.circle(x=opts$x_positions[idx],
                         y=opts$y_positions[idx],
                         radius=opts$resolution/10,
                         col='black')

  }

}

#' Plot heatmap of 2D point dataset
#'
#' Very inefficient implementation of a heatmap plotting algorithm. A rect is
#' drawn to the screen for each pixel, where the density of a pixel is calculated
#' by convolving all points with a Guassian kernel and sampling at the pixel's center.
#' Pixel resolution and Gaussian smear_size are stored in the `opts` object created
#' by the `make_opts()` function, which should be called first.
#'
#' @param opts An options object created from make_grid()
#' @param overtitle The main title of the new plot
#' @param show_frame Boolean for whether to show the bounding region and xy axes
#'
#' @export
plot_heatmap <- function(opts,
                         overtitle = "Point Heatmap",
                         show_frame = FALSE){

  resolution <- opts$resolution
  minX <- opts$xMin-resolution/2
  maxX <- opts$xMax+resolution/2
  minY <- opts$yMin-resolution/2
  maxY <- opts$yMax+resolution/2

  aspX <- maxX - minX
  aspY <- maxY - minY
  asp_rat <- aspY/aspX

  if(show_frame){
    par(pin=c(6,6*asp_rat))
    plot(opts$x_positions,
         opts$y_positions,
         xlim=c(minX,maxX),
         ylim=c(minY,maxY),
         xlab="",ylab="")
  }
  else{
    plot.new()
    plot.window(xlim=c(minX,maxX),
                ylim=c(minY,maxY))

  }
  title(main=overtitle)

  # if the opts grid has non-zero data, then we treat that as the density data
  weights <- opts$grid
  recalculate <- TRUE
  for(idx in 1:opts$nY){
    for(jdx in 1:opts$nX){
      if(weights[idx,jdx] > 0.5){
        recalculate <- FALSE
        break
      }
    }
    if(!recalculate){
      break
    }
  }
  if(recalculate){
    w_maxW <- density_on_grid(opts)
    weights <- w_maxW[[1]]
  }


  for(idx in 1:opts$nY){
    for(jdx in 1:opts$nX){
      w <- weights[idx,jdx]

      new_col <- color_by_weight(w)
      x <- x_from_jdx(opts,jdx)
      y <- y_from_idx(opts,idx)

      rect(xleft  = x - resolution/2,
           xright = x + resolution/2,
           ybottom = y - resolution/2,
           ytop    = y + resolution/2,
           col = new_col, border = new_col )
    }
  }

}
