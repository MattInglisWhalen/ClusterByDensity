% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cbd_plotting.R
\name{plot_heatmap}
\alias{plot_heatmap}
\title{Plot heatmap of 2D point dataset}
\usage{
plot_heatmap(opts, overtitle = "Point Heatmap", show_frame = FALSE)
}
\arguments{
\item{opts}{An options object created from make_grid()}

\item{overtitle}{The main title of the new plot}

\item{show_frame}{Boolean for whether to show the bounding region and xy axes}
}
\description{
Very inefficient implementation of a heatmap plotting algorithm. A rect is
drawn to the screen for each pixel, where the density of a pixel is calculated
by convolving all points with a Guassian kernel and sampling at the pixel's center.
Pixel resolution and Gaussian smear_size are stored in the \code{opts} object created
by the \code{make_opts()} function, which should be called first.
}
