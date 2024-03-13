
# Finds all peaks in an array of densities at a given threshold
#
# @param opts An options object created by make_opts()
# @param weights An nY x nX array of relative densities
# @param threshold A float. The height of the peaks to be found
# @param tol The tolerance for how far a density can be from threshold to be considered at threshold.
#
# @return A list of clusters, where each cluster is itself a list of points that are othogonally connected to form a true peak
#
# internal
flood_fill_peaks <- function(opts, weights, threshold, tol=0.01){
  "
  If a 'peak' at val=threshold is adjacent to another higher-valued pixel
  then it's not a peak. Therefore we flood-fill all pixels with weight=threshold
  with the value of a higher-weighted adjacent pixel, if it exists
  "
  nX <- ncol(weights)
  nY <- nrow(weights)

  updated <- TRUE
  queue <- c() # pixels to check
  for(idx in 1:nY){
    for(jdx in 1:nX){
      queue <- rbind(queue, c(idx,jdx))
    }
  }
  queue <- data.frame(queue)
  # queue now contains all pixels

  while(nrow(queue)>0){

    idx <- queue[1,1]
    jdx <- queue[1,2]

    val <- weights[idx,jdx]
    if( abs(val-threshold)>tol ){
      # we don't care about pixels in the queue that aren't at threshold
      queue <- queue[-1,] # remove current (idx,jdx) from the queue
      next
    }

    if(idx<nY){
      # check the top-adjacency for a higher value
      top <- weights[idx+1,jdx]
      if(top>threshold+tol){
        # when a higher value is found next to a pixel at threshold, set the
        # pixel to the higher height. Then remove the current pixel from the
        # queue, and queue up the 3 other adjacent cells
        weights[idx,jdx] <- top
        queue <- queue[-1,]
        # if(idx < nY) queue <- rbind(c(idx+1,jdx),queue)
        if(idx > 1) queue <- rbind(c(idx-1,jdx),queue)
        if(jdx < nX) queue <- rbind(c(idx,jdx+1),queue)
        if(jdx > 1) queue <- rbind(c(idx,jdx-1),queue)
        next
      }
    }

    if(idx>1){
      # check the bottom
      bot <- weights[idx-1,jdx]
      if(bot>threshold+tol){
        weights[idx,jdx] <- bot
        queue <- queue[-1,]
        if(idx < nY) queue <- rbind(c(idx+1,jdx),queue)
        # if(idx > 1) queue <- rbind(c(idx-1,jdx),queue)
        if(jdx < nX) queue <- rbind(c(idx,jdx+1),queue)
        if(jdx > 1) queue <- rbind(c(idx,jdx-1),queue)
        next
      }
    }

    if(jdx<nX){
      # check the right
      right <- weights[idx,jdx+1]
      if(right>threshold+tol){
        weights[idx,jdx] <- right
        queue <- queue[-1,]
        if(idx < nY) queue <- rbind(c(idx+1,jdx),queue)
        if(idx > 1) queue <- rbind(c(idx-1,jdx),queue)
        # if(jdx < nX) queue <- rbind(c(idx,jdx+1),queue)
        if(jdx > 1) queue <- rbind(c(idx,jdx-1),queue)
        next
      }
    }

    if(jdx>1){
      # check the left
      left <- weights[idx,jdx-1]
      if(left>threshold+tol){
        weights[idx,jdx] <- left
        queue <- queue[-1,]
        if(idx < nY) queue <- rbind(c(idx+1,jdx),queue)
        if(idx > 1) queue <- rbind(c(idx-1,jdx),queue)
        if(jdx < nX) queue <- rbind(c(idx,jdx+1),queue)
        # if(jdx > 1) queue <- rbind(c(idx,jdx-1),queue)
        next
      }
    }

    queue <- queue[-1,]

  }  # end while

  # all points at threshold should now be true peaks
  # we now just need to collect them into contiguous clusters

  # collect pixel constituents for the peaks
  pixels_at_thresh <- c()
  for(idx in 1:nY){
    for(jdx in 1:nX){
      val <- weights[idx,jdx]
      if ( abs(val-threshold)<tol ){
        pixels_at_thresh <- rbind(pixels_at_thresh,c(idx,jdx))
      }
    }
  }
  df <- data.frame(pixels_at_thresh)


  # Merge peaked pixels together into a new data structure -- a list of regions
  # where each region is set of connected pixels in the peak region.
  # We store both the indices $ij and the positions $xy of these regions
  clusters <- list()
  while(nrow(df)>0){

    new_cluster_ij <- df[1,]  # get the seed of a new cluster
    df <- df[-1,]

    new_point_added <- TRUE
    while(new_point_added){
      new_point_added <- FALSE
      for(m in 1:nrow(new_cluster_ij)){
        for(n in 1:nrow(df)){
          if(nrow(df)<1){
            break
          }
          constit_i <- new_cluster_ij[m,1]
          constit_j <- new_cluster_ij[m,2]

          candidate_i <- df[n,1]
          candidate_j <- df[n,2]

          if( abs(constit_i-candidate_i) + abs(constit_j-candidate_j) == 1){
            # if they're adjacent, put them in the same cluster
            new_cluster_ij <- rbind(new_cluster_ij,df[n,])
            df <- df[-n,]
            new_point_added <- TRUE
            break
          }
        }
      }
    }
    # from cluster_ij get _xy and put both into a list
    new_cluster_xy <- xy_from_ij(opts,new_cluster_ij)
    new_cluster <- list("ij"=new_cluster_ij,"xy"=new_cluster_xy)

    # append the new cluster to the clusters list
    clusters[[length(clusters)+1]] <- new_cluster

  }

  info <- list("threshold"=threshold, "n"=length(clusters))
  ret_list <- list("info"=info,"clusters"=clusters)

  return(ret_list)
}

#' Find the location of clusters of points from a set of 2D points
#'
#' A continuous density distribution is generated by convolving the spread of points
#' with a Gaussian kernel. This distribution is sampled on a grid (like pixels),
#' and the pixel heights are normalized to have a min/max of 0 and 1. The heights
#' are discretized to multiples of 0.1, and at each of these thresholds a flood-fill
#' algorithm finds the location of pixels corresponding to a peak at that threshold.
#' Orthogonally-connected pixels are clustered together.
#'
#' @param opts An options object created using make_options()
#' @param prop_cutoff The lowest relative density, 0<cut<1 which is considered to be a peak. Should be a multiple of 0.1
#'
#' @return A list of TPeaks. Each TPeak is a list of clusters at some threshold T. Each cluster has `$ij` and `$xy` attributes, which are the index and position information of all points that are othogonally connected to form a true peak at threshold T.
#'
#' @export
find_peaks <- function(opts, prop_cutoff=0.7){

  # 1. Pixel densities are calculated by smearing a Gaussian kernel over
  #    the distribution of points. These are discretized into discrete heights
  # 2. All points at this height are first assumed to be a peak candidate.
  #    Candidates are then trimmed from the list by flood-filling each connected
  #    candidate region with higher surrounding values, if they exist
  # 3. Candidates that survive the flood fill are actual peaks for that height

  # Get the density of each pixel
  w_maxW <- density_on_grid(opts)
  weights <- w_maxW[[1]]

  if(prop_cutoff < 0 || prop_cutoff>1){
    message(sprintf("CBD: find_peaks(): prop_cutoff=%.1f should be between 0 and 1",prop_cutoff))
    prop_cutoff <- 0.0
  }
  rounded_prop_cutoff <- ceiling(prop_cutoff*10)/10
  thresholds <- seq(from=rounded_prop_cutoff, to=1., by=0.1)

  clusters_by_threshold <- list()
  for(thresh in thresholds){
    # find the clusters
    clusters <- flood_fill_peaks(opts, weights, thresh)
    clusters_by_threshold[[length(clusters_by_threshold)+1]] <- clusters
  }

  return(clusters_by_threshold)
}

#' Prints the results of find_peaks() in a nice way
#'
#' @param peaks The output of find_peaks()
#' @param opts The output of make_opts()
#'
#' @export
print_peaks <- function(peaks, opts){

  for(tpeak in peaks){

    threshold <- tpeak$info$threshold
    n_peaks <- tpeak$info$n
    clusters <- tpeak$clusters

    message(sprintf("At threshold=%.1f, there are %i peaks:", threshold, n_peaks))

    count <- 1
    for(clust in clusters){

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

      message(sprintf(" (%i) (x,y) = (%.2f,%.2f), length x width = %.2f x %.2f, angle=%.1f°",
                      count, mu_x, mu_y, semi_major, semi_minor, 180*angle/3.14159))
      count <- count + 1
    }
  }
}
