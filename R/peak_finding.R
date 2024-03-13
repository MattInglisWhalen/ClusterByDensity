source("density_map.R")


flood_fill_peaks <- function(weights, threshold, tol=0.01){
  # if a "peak" at val=threshold is adjacent to another higher-valued pixel
  # then it's not a peak. Therefore we flood-fill all pixels with val-threshold
  
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
  
  
  # merge peaks together into a new data structure -- a list of regions
  # and where each region is a dataframe of connected pixels in the peak region
  clusters <- list()
  while(nrow(df)>0){
    
    new_cluster <- df[1,]  # get the seed of a new cluster
    df <- df[-1,]
    
    new_point_added <- TRUE
    while(new_point_added){
      new_point_added <- FALSE
      for(m in 1:nrow(new_cluster)){
        for(n in 1:nrow(df)){
          if(nrow(df)<1){
            break
          }
          constit_i <- new_cluster[m,1]
          constit_j <- new_cluster[m,2]
          
          candidate_i <- df[n,1]
          candidate_j <- df[n,2]
          
          if( abs(constit_i-candidate_i) + abs(constit_j-candidate_j) == 1){
            # if they're adjacent, put them in the same cluster
            new_cluster <- rbind(new_cluster,df[n,])
            df <- df[-n,]
            new_point_added <- TRUE
            break
          }
        }
      }
    }
    # print(new_cluster)
    clusters <- c(clusters, list(new_cluster))
  }
  
  info <- list("threshold"=threshold, "n"=length(clusters))
  ret_list <- list("info"=info,"clusters"=clusters)
  
  return(ret_list)
}

peak_finding_algo <- function(x_positions, y_positions, grid, prop_cutoff=0.7){
  
  # 1. Pixel densities are calculated by smearing a Gaussian kernel over
  #    the distribution of points. These are discretized into discrete heights
  # 2. All points at this height are first assumed to be a peak candidate. 
  #    Candidates are then trimmed from the list by flood-filling each connected
  #    candidate region with higher surrounding values, if they exist
  # 3. Candidates that survive the flood fill are actual peaks for that height

  # Get the density of each pixel
  w_maxW <- density_on_grid(x_positions, y_positions, grid)
  weights <- w_maxW[[1]]
  
  
  thresholds <- seq(from=prop_cutoff, to=1., by=0.1)

  clusters_by_threshold <- list()
  for(thresh in thresholds){
    # find the clusters
    clusters <- flood_fill_peaks(weights, thresh)
    clusters_by_threshold[[length(clusters_by_threshold)+1]] <- clusters
  }
  
  return(clusters_by_threshold)
}


