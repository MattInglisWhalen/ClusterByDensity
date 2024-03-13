library('plotrix')

source("density_map.R")
source("grid.R")

plot_data_only <- function(){
  
}
  
# count_by_energy <- function(energies,E){
#   # for plot_clusters_by_cut
#   count <- 0
#   for(en in energies){
#     if(E<en){
#       count <- count + 1
#     }
#   }
#   return(count)
# }

# plot_clusters_by_cut <- function(df){
#   energies = df[,3]
#   xs <- c(0,0.005,0.01,0.025,0.04,0.06,0.07,0.08,0.09,0.1,0.15,0.2,0.25,0.3,0.4,0.5)
#   ys <- c()
#   for(x in xs){
#     ys = c(ys, count_by_energy(energies,x))
#   }
#   plot(xs,ys)
#   abline(h=1)
# }

# plot_clusters <- function(x_points, y_points, clusters, clust_radius, 
#                           new_plot=TRUE, overtitle="Picture Locations"){
#   
#   n_points = 0
#   if(length(x_points) == length(y_points)){
#     n_points <- length(x_points)
#   } else {
#     print("plot_clusters(): x_points and y_points must have the same length")
#   }
#   
#   colorblind_palette  = rep(c('#377eb8', '#ff7f00', '#4daf4a',
#                               '#f781bf', '#a65628', '#984ea3',
#                               '#999999', '#e41a1c', '#dede00'),100)
#   
#   if(new_plot){
#     plot.new()
#     plot.window(xlim=c(-3,3),ylim=c(-3,3), asp=1)
#     title(main=overtitle)
#   }
#   
#   clusters <- data.frame(clusters)
#   dims <- dim(clusters)
#   if (dims[2] != 3){
#     clusters <- t(clusters)
#   }
#   
#   if (dims[1]>0 && dims[2]>0){
#     for(idx in 1:nrow(clusters)){
#       cluster <- data.matrix(clusters[idx,])
#       print(cluster)
#       
#       xloc <- cluster[1]
#       yloc <- cluster[2]
#       energy <- cluster[3]
#       
#       if (new_plot){
#         draw.circle(x=xloc,y=yloc,radius=clust_radius,
#                     col = colorblind_palette[idx], 
#                     border=colorblind_palette[idx])    
#       } else {
#         draw.circle(x=xloc,y=yloc,radius=clust_radius,
#                     border=colorblind_palette[idx]#, lwd=40*energy
#                     )  
#       }
#       
#     }
#     
#   }
#   
#   for(idx in 1:n_points ){
#     draw.circle(x=x_points[idx], y=y_points[idx], radius=0.01, col='black')
#     
#   }
#   xw <- 2.2  # distance from centre to left or right wall
#   yw <- 2.2  # distance from centre to top or bottom wall
#   dw <- 0.3  # width of the elevator door
#   eL <- 1    # distance from elevator centre to its left/right/top/bottom wall
#   # room
#   lines(x=c(-xw,-xw),y=c(-yw, yw))  # left
#   lines(x=c( xw, xw),y=c(-yw, yw))  # right
#   lines(x=c(-xw, xw),y=c( yw, yw))  # top
#   lines(x=c(-xw, -dw),y=c(-yw,-yw))  # bot_l
#   lines(x=c(dw, xw),y=c(-yw,-yw))  # bot_l
#   # elevator
#   lines(x=c(-eL/2,-eL/2),y=c(-yw,-yw-eL))  # left
#   lines(x=c( eL/2, eL/2),y=c(-yw,-yw-eL))  # right
#   lines(x=c(-eL/2, eL/2),y=c(-yw-eL,-yw-eL))  # bot
#   
# }



plot_peaks <- function(x_points, y_points, peaks, grid, 
                       new_plot=TRUE, overtitle="Picture Locations"){
  
  n_points = 0
  if(length(x_points) == length(y_points)){
    n_points <- length(x_points)
  } else {
    print("plot_clusters(): x_points and y_points must have the same length")
  }
  
  colorblind_palette  = rep(c('#377eb8', '#ff7f00', '#4daf4a',
                              '#f781bf', '#a65628', '#984ea3',
                              '#999999', '#e41a1c', '#dede00'),100)
  
  if(new_plot){
    png(filename=sprintf("%s/_%s.png",getwd(),overtitle))
    plot.new()
    plot.window(xlim=c(-3,3),ylim=c(-3,3), asp=1)
    title(main=overtitle)
  }
  
  for(clust_by_thresh in peaks){
    
    threshold <- clust_by_thresh$info$threshold
    n_peaks <- clust_by_thresh$info$n
    clusters <- clust_by_thresh$clusters
    
    for(peak in clusters){
      
      xs <- x_from_jdx(grid,peak[,2])
      ys <- y_from_idx(grid,peak[,1])
      
      mu_x <- mean(xs)
      mu_y <- mean(ys)

      slope <- 0
      if(nrow(peak)==2){
        dy <- ys[2]-ys[1]
        dx <- xs[2]-xs[1]
        slope <- dy /(dx+1e-5)
      }
      else if(nrow(peak)>2){  # Next: you have a 3-in a row problem, then cov(xs,xs) is zero
        # So you have to check for NA in the slope
        # Then also broaden the semimajor/minor by the height of the peak
        slope <- cov(xs,ys) / (cov(xs,xs)+1e-5)
      }
      else{
        # do nothing
      }
      angle <- atan(slope)
      
      rotated_x <-  cos(angle)*xs + sin(angle)*ys
      rotated_y <- -sin(angle)*xs + cos(angle)*ys
      semi_major = (max(rotated_x) - min(rotated_x) + grid$resolution)/2
      semi_minor = (max(rotated_y) - min(rotated_y) + grid$resolution)/2
      
      semi_major <- semi_major*(threshold/0.5)
      semi_minor <- semi_minor*(threshold/0.5)
      
      print(sprintf("Drawing ellipse at thresh=%f, angle=%f, x=%f, y=%f, a=%f, b=%f",
                    threshold,angle,mu_x,mu_y,semi_major,semi_minor))
      draw.ellipse(x=mu_x,y=mu_y,angle=180*angle/3.14159,
                   a=semi_major,b=semi_minor,
                   #border=color_by_weight(threshold),
                   border="#000000"
                   )
      
    }
  }
  
  for(idx in 1:n_points ){
    draw.circle(x=x_points[idx], y=y_points[idx], radius=0.01, col='black')
    
  }
  xw <- 2.2  # distance from centre to left or right wall
  yw <- 2.2  # distance from centre to top or bottom wall
  dw <- 0.3  # width of the elevator door
  eL <- 1    # distance from elevator centre to its left/right/top/bottom wall
  # room
  lines(x=c(-xw,-xw),y=c(-yw, yw))  # left
  lines(x=c( xw, xw),y=c(-yw, yw))  # right
  lines(x=c(-xw, xw),y=c( yw, yw))  # top
  lines(x=c(-xw, -dw),y=c(-yw,-yw))  # bot_l
  lines(x=c(dw, xw),y=c(-yw,-yw))  # bot_l
  # elevator
  lines(x=c(-eL/2,-eL/2),y=c(-yw,-yw-eL))  # left
  lines(x=c( eL/2, eL/2),y=c(-yw,-yw-eL))  # right
  lines(x=c(-eL/2, eL/2),y=c(-yw-eL,-yw-eL))  # bot
  
}


color_by_weight <- function(weight){
  top_col <- '#FF0000'
  mid_col <- '#CCCCFF'
  bot_col <- '#FFFFFF'
  upper_ramp <- colorRampPalette(c(mid_col,top_col))
  bot_ramp <- colorRampPalette(c(bot_col,mid_col))
  
  uramp <- upper_ramp(5)
  bramp <- bot_ramp(5)
  
  if(weight > 0.91){return('#FFA500')}
  else if(weight > 0.81){return(uramp[4])}
  else if(weight > 0.71){return(uramp[3])}
  else if(weight > 0.61){return(uramp[2])}
  else if(weight > 0.51){return(uramp[1])}
  else if(weight > 0.41){return(bramp[5])}
  else if(weight > 0.31){return(bramp[4])}
  else if(weight > 0.21){return(bramp[3])}
  else if(weight > 0.11){return(bramp[2])}
  return(bramp[1])
}

plot_heatmap <- function(x_positions, y_positions, 
                         grid, new_plot=TRUE, 
                         overtitle="Photo Heatmap"){
  
  minX <- grid$xMin
  maxX <- grid$xMax
  minY <- grid$yMin
  maxY <- grid$yMax
  resolution <- grid$resolution
  
  if(new_plot){
    png(filename=sprintf("%s/_%s.png",getwd(),overtitle))
    plot.new()
    plot.window(xlim=c(minX,maxX),ylim=c(minY,maxY), asp=1)
    title(main=overtitle)
  }
  
  w_maxW <- density_on_grid(x_positions,y_positions,grid)

  weights <- w_maxW[[1]]

  
  for(idx in 1:grid$nY){
    for(jdx in 1:grid$nX){
      w <- weights[idx,jdx]

      new_col <- color_by_weight(w)
      x <- x_from_jdx(grid,jdx)
      y <- y_from_idx(grid,idx)
      
      rect(xleft  = x - resolution/2,
           xright = x + resolution/2,
           ybottom = y - resolution/2,
           ytop    = y + resolution/2,
           col = new_col, border = new_col )
    }
  }
  
}
