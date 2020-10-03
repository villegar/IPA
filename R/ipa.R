#' Generate an RGB decomposition for a group of images inside a directory
#'
#' @importFrom graphics barplot
#' @importFrom grDevices dev.off
#' @importFrom grDevices png
#' @importFrom utils write.csv
#' @param subdirectory main directory to search for images
#' @param extension images format or extension [default: \code{jpg}]
#' @param RData boolean flag on whether to store the layers as \code{RData} or
#'     \code{CSV}
#' @param recursive boolean flag on whether to recursively search for images
#'
#' @export
#'
#' @examples
#' \dontrun{
#'     test_data <- data.frame(name = c("R", "G", "B"), values = c(2, 2, 2))
#'     RGB <- c("red", "green", "blue")
#'     png("test_plot.png")
#'     barplot(height = test_data$values, names = test_data$name, col = RGB)
#'     dev.off()
#'     rgb_decomposition(".", "png", recursive = FALSE)
#' }
rgb_decomposition <- function(subdirectory,
                              extension = "jpg",
                              RData = TRUE,
                              recursive = TRUE) {
  extension <- paste0("*", extension, "$") # Adding regex pattern
  images <- list.files(subdirectory,
                       pattern = extension,
                       full.names = FALSE,
                       recursive = recursive)
  for (i in images) {
    message(paste0("Processing: ", file.path(subdirectory, i)))
    tmp <- imager::load.image(file.path(subdirectory, i)) # Load image
    red <- imager::R(tmp) # Extract red layer
    green <- imager::G(tmp) # Extract green layer
    blue <- imager::B(tmp) # Extract blue layer
    # Extract filename without extension
    j <- file.path(subdirectory, gsub(".$", "", gsub(extension, "", i)))
    if (RData) {
      # Save each layer as a separate RData file (smaller)
      save(red, file = paste0(j, '-red.RData'))
      save(green, file = paste0(j, '-green.RData'))
      save(blue, file = paste0(j, '-blue.RData'))
    }
    else {
      # Save each layer as a separate CSV file (larger)
      write.csv(matrix(red, nrow = nrow(red)), paste0(j, '-red.csv'))
      write.csv(matrix(green, nrow = nrow(green)), paste0(j, '-green.csv'))
      write.csv(matrix(blue, nrow = nrow(blue)), paste0(j, '-blue.csv'))
    }
  }
}

#' Remove image background
#'
#' @importFrom graphics hist
#'
#' @param image_path filename w/o the full path
#' @param bkg_thr background threshold, any pixel below this value will be set
#'     to zero (black) and one (white) in the alpha layer, to create a
#'     transparency effect.
#' @param plot boolean flag on whether or not to generate a histogram of the
#'     pixel values. This can be used to determine an optimal \code{bkg_thr}
#' @param ... extra parameters for \code{hist}
#'
#' @export
#'
#' @examples
#' \dontrun{
#'     test_data <- data.frame(name = c("R", "G"), values = c(2, 2))
#'     RG <- c("red", "green")
#'     png("test_plot.png")
#'     par(bg = 'black')
#'     barplot(height = test_data$values, names = test_data$name, col = RG)
#'     dev.off()
#'     rm_background("test_plot.png", 0.1)
#'     rm_background("test_plot.png", 0.1, TRUE)
#'     rm_background("test_plot.png", 0.1, TRUE, breaks = 10)
#' }
rm_background <- function(image_path, bkg_thr = 0.4, plot = FALSE, ...) {
  # Load image
  img <- imager::load.image(image_path)
  # Remove transparency layer
  img <- imager::rm.alpha(img)
  # Extract image dimensions
  img_rows <- dim(img)[1]
  img_cols <- dim(img)[2]

  if (plot){
    out <- hist(img, ...)
  }

  # Find indices for values below the background threshold (bkg_thr)
  idx <- img < bkg_thr
  # Create a new transparency layer
  alpha <- matrix(0, img_rows, img_cols)
  alpha[!as.array(idx)] <- 1
  alpha <- matrix(alpha, img_rows, img_cols)
  alpha <- imager::as.cimg(alpha, img_rows, img_cols)
  # plot(alpha)
  # Set to zero all the pixels detected as background
  img[idx] <- 0
  # Combine the original image with the transparency layer
  img2 <- imager::as.cimg(abind::abind(img, alpha, along = 4))
  # Save image to disk (adds the _wb.png suffix)
  image_path2 <- IPA::drop_extension(image_path)
  imager::save.image(img2, paste0(image_path2, "_wb.png"))
  # imager::save.image(img2, "new3.png")
  # plot(img)
  # img.g <- imager::grayscale(img)
  # gr <- imager::imgradient(img.g, "xy")
  # plot(gr, layout = "row")
  # dx <- imager::imgradient(img.g, "x")
  # dy <- imager::imgradient(img.g, "y")
  # grad.mag <- sqrt(dx^2 + dy^2)
  # plot(grad.mag, main = "Gradient magnitude")
}

#' Add transparency (set pixels to zero) area to image
#'
#' @param img image object (\code{cimg} class)
#' @param area area to modify: \code{c(x0, width, y0, height)}
#'     where: \code{x0} is the starting pixel on the x-axis,
#'            \code{width} is the number of pixels along x,
#'            \code{y0} is the starting pixel on the y-axis, and
#'            \code{height} is the number of pixels along y
#' @param quiet boolean flag to show message of work area
#'
#' @return modified image object (\code{cimg} class)
#' @export
#'
#' @examples
#' \dontrun{
#'     # Create test image
#'     red <- matrix(0, 50, 50)
#'     red[1:25, 1:25] <- 1
#'     blue <- matrix(0, 50, 50)
#'     blue[26:50, 1:25] <- 1
#'     green <- matrix(0, 50, 50)
#'     green[1:25, 26:50] <- 1
#'     alpha <- matrix(1, 50, 50)
#'     alpha[26:50, 26:50] <- 0
#'     img <- imager::as.cimg(abind::abind(imager::as.cimg(red),
#'                                         imager::as.cimg(blue),
#'                                         imager::as.cimg(green),
#'                                         imager::as.cimg(alpha),
#'                                         along = 4))
#'     # Remove red portion of the image
#'     img2 <- add_alpha(img, c(1, 25, 1, 25))
#' }
add_alpha <- function(img, area, quiet = TRUE) {
  # Check for cimg class
  if (!("cimg" %in% class(img))){
    stop(paste0("image is expected to be of class 'cimg'"))
  }
  # Check for number of elements passed to area
  if (length(area) != 4) {
    stop(paste0("area must contain 4 elements (x0, width, y0, height)"))
  }

  # Extract image dimensions
  img_rows <- dim(img)[1]
  img_cols <- dim(img)[2]

  # Check if the area is out of bounds
  if (area[1] > img_cols || area[3] > img_rows) {
    stop(paste0("The given area is out of bounds. Select an area within ",
                "(1, 1) and (", img_rows, ", ", img_cols, ")"))
  }

  # Create indices
  idx_x <- area[1]:ifelse(sum(area[1:2]) > img_cols, img_cols, sum(area[1:2]))
  idx_y <- area[3]:ifelse(sum(area[3:4]) > img_rows, img_rows, sum(area[3:4]))
  # Create matrix of zeros
  tmp <- matrix(0, img_rows, img_cols)
  tmp[idx_x, idx_y] <- 1
  tmp <- imager::as.cimg(tmp, img_rows, img_cols)
  # Display vertices of working area
  if (!quiet) {
    # Creat vertices
    v1 <- paste0("(", min(idx_x), ", ", min(idx_y), ")")
    v2 <- paste0("(", max(idx_x), ", ", min(idx_y), ") \n")
    v3 <- paste0("(", min(idx_x), ", ", max(idx_y), ")")
    v4 <- paste0("(", max(idx_x), ", ", max(idx_y), ")")

    # Verify that both left-most vertices have the same length, if not pad with
    # blank spaces
    if (nchar(v1) > nchar(v3)) {
      v3 <- paste0(v3,
                   paste0(rep(" ", times = nchar(v1) - nchar(v3)),
                          collapse = ""))
    }
    else if (nchar(v3) > nchar(v1)) {
      v1 <- paste0(v1,
                   paste0(rep(" ", times = nchar(v3) - nchar(v1)),
                          collapse = ""))
    }
    # Width = Height
    len_x <- 3
    len_y <- 3
    if (area[2] > area[4]) { # Width > Height
      len_x <- 6
    } else if (area[2] < area[4]) { # Width < Height
      len_y <- 6
    }
    # Create template for box sides
    box_sides <- paste0(paste0(rep(" ", nchar(v1)), collapse = ""),
                          " |",
                          paste0(rep(" ", len_x * 3), collapse = ""),
                          "|\n")
    top_side <- paste0(rep("_", len_x * 3), collapse = "")
    # Display message
    message(paste0("Adding transparency to the area bounded by: \n",
                   v1, "  ", top_side, "  ", v2,
                   paste0(rep(box_sides, len_y), collapse = ""),
                   v3, " |", top_side, "| ", v4))
  }
  # Set to zero the selected area
  img[tmp == 1] <- 0

  # Update transparency layer
  if (dim(img)[4] == 4) {
    alpha <- imager::channel(img, 4)
    alpha[tmp == 1] <- 0
    img <- imager::rm.alpha(img)
  } else {
    alpha <- matrix(1, img_rows, img_cols)
    alpha[idx_x, idx_y] <- 0
    alpha <- imager::as.cimg(alpha, img_rows, img_cols)
  }
  img <- imager::as.cimg(abind::abind(img, alpha, along = 4))
  # Return new image
  return(img)
}

#' Find continuous group of pixels with a tolerance of \code{px_tol} pixels
#'
#' @param img image object (\code{cimg} class)
#' @param start starting point: \code{c(x0, y0)}
#' @param px_tol number of non-continuous pixels to accept
#'
#' @return blobs containing adjacent groups of non-zero pixels
# @export
#'
# @examples
find_area <- function(img, start = c(1, 1), px_tol = 20) {
  # Extract image dimensions
  img_rows <- dim(img)[1]
  img_cols <- dim(img)[2]
  # Initialise variables
  area_start <- NULL
  area_end <- NULL
  i <- 1
  j <- start[2]
  blobs <- list()
  bins <- seq(start[1], img_rows, px_tol)

  # Loop through the image in chunks of (px_tol * px_tols)
  while (i < length(bins)) {
    idx_x <- bins[i]:ifelse(bins[i] + px_tol > img_cols,
                            img_cols,
                            bins[i] + px_tol)
    idx_y <- j:ifelse(j + px_tol > img_rows, img_rows, j + px_tol)
    print(paste0("(i, j) = (", bins[i], ", ", j, ") to ",
                 "(", max(idx_x), ", ", max(idx_y), ")"))
    if (any(as.matrix(img[idx_x, idx_y] > 0))) {
      if (is.null(area_start)) {
        area_start <- c(bins[i], min(idx_y))
      }
      else {
        area_end <- c(bins[i], max(idx_y))
        blobs[[length(blobs) + 1]] <- list(start = area_start, end = area_end)
        # area_start <- c(bins[i], min(idx_y))
        # area_end <- NULL
      }
    } else if(!is.null(area_start)) {
        area_end <- c(bins[i], max(idx_y))
        blobs[[length(blobs) + 1]] <- list(start = area_start, end = area_end)
        area_start <- NULL
        area_end <- NULL
        j <- j + px_tol
        if (j > img_rows) {
          break
        }
        i <- 0
        print("HERE")
    } else {
      area_end <- c(bins[i], max(idx_y))
      blobs[[length(blobs) + 1]] <- list(start = area_start, end = area_end)
      break
    }
    i <- i + 1
    # if(i == length(bins)) {
    #   i <- 1
    #   j <- j + px_tol
    #   area_start <- NULL
    #   area_end <- NULL
    #   if (j > img_rows) {
    #     break
    #   }
    # }
  }
  print(blobs)
  blobs <- matrix(unlist(blobs), ncol = 4, byrow = TRUE)
  # blobs_sum <- list()
  # i <- 2
  # while (i < nrow(blobs)) {
  #   if (blobs[i, 1] == blobs[i - 1, 3]) {
  #     blobs_sum[[length(blobs_sum) + 1]] <- c(blobs[i-1, 1:2], blobs[i, c(1, 3)])
  #
  #   }
  # }
  return(blobs)
}

# alpha_mat <- as.matrix(alpha)
# for (i in 1:nrow(d)) {
#   print(i)
#   alpha <- add_alpha(alpha, c(d[i, 1], 100, d[i, 2], 100))
# }
# plot(alpha)
