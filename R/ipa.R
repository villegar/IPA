#' Generate an RGB decomposition for a group of images inside a directory
#'
#' @importFrom graphics barplot
#' @importFrom grDevices dev.off
#' @importFrom grDevices png
#' @importFrom utils write.csv
#' @param subdirectory main directory to search for images
#' @param extension images format or extension [default: jpg]
#' @param Rdata boolean flag on whether to store the layers as Rdata or CSV
#' @param recursive boolean flag on whether to recursively search for images
#'
#' @export
#'
#' @examples
#' \dontrun{
#' test_data <- data.frame(name = c("R", "G", "B"), values = c(2, 2, 2))
#' RGB <- c("red", "green", "blue")
#' png("test_plot.png")
#' barplot(height = test_data$values, names = test_data$name, col = RGB)
#' dev.off()
#' rgb_decomposition(".", "png", recursive = FALSE)
#' }
rgb_decomposition <- function(subdirectory, extension = "jpg", Rdata = TRUE, recursive = TRUE) {
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
    if (Rdata) {
      # Save each layer as a separate Rdata file (smaller)
      save(red, file = paste0(j, '-red.Rdata'))
      save(green, file = paste0(j, '-green.Rdata'))
      save(blue, file = paste0(j, '-blue.Rdata'))
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
#' test_data <- data.frame(name = c("R", "G"), values = c(2, 2))
#' RG <- c("red", "green")
#' png("test_plot.png")
#' par(bg = 'black')
#' barplot(height = test_data$values, names = test_data$name, col = RG)
#' dev.off()
#' rm_background("test_plot.png", 0.1)
#' rm_background("test_plot.png", 0.1, TRUE)
#' rm_background("test_plot.png", 0.1, TRUE, breaks = 10)
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
#' @param img image (cimg class)
#' @param area area to modify: c(x, width, y, height)
#'
#' @return modified image (cimg class)
#' @export
#'
#' @examples
#' \dontrun{
#' # Create test image
#' red <- matrix(0, 50, 50)
#' red[1:25, 1:25] <- 1
#' blue <- matrix(0, 50, 50)
#' blue[26:50, 1:25] <- 1
#' green <- matrix(0, 50, 50)
#' green[1:25, 26:50] <- 1
#' alpha <- matrix(1, 50, 50)
#' alpha[26:50, 26:50] <- 0
#' img <- imager::as.cimg(abind::abind(imager::as.cimg(red),
#'                                     imager::as.cimg(blue),
#'                                     imager::as.cimg(green),
#'                                     imager::as.cimg(alpha),
#'                                     along = 4))
#' # Remove red portion of the image
#' img2 <- add_alpha(img, c(1, 25, 1, 25))
#' }
add_alpha <- function(img, area) {
  # Create indices
  idx_x <- area[1]:sum(area[1:2])
  idx_y <- area[3]:sum(area[3:4])
  # Extract image dimensions
  img_rows <- dim(img)[1]
  img_cols <- dim(img)[2]
  # Create matrix of zeros
  tmp <- matrix(0, img_rows, img_cols)
  tmp[idx_x, idx_y] <- 1
  tmp <- imager::as.cimg(tmp, img_rows, img_cols)
  # Set to zero the selected area
  img[tmp == 1] <- 0
  # Return new image
  return(img)
}
