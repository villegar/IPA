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

rm_background <- function(subdirectory, extension = "jpg", Rdata = TRUE, recursive = TRUE) {
  tmp <- imager::load.image(leaves)
  tmp <- imager::rm.alpha(tmp)
  idx <- tmp < 0.4
  alpha <- matrix(0, 5104, 7200)
  # alpha <- imager::as.cimg(alpha, 5104, 7200)
  alpha[!idx] <- 1
  plot(alpha)
  alpha <- matrix(alpha, 5104, 7200, byrow = TRUE)
  alpha <- imager::as.cimg(alpha, 5104, 7200)
  plot(alpha)
  tmp[idx] <- 0
  imager::save.image(tmp, "new.png")
  plot(tmp)

  tmp.g <- imager::grayscale(tmp)
  gr <- imager::imgradient(tmp.g, "xy")
  plot(gr, layout = "row")
  dx <- imager::imgradient(tmp.g, "x")
  dy <- imager::imgradient(tmp.g, "y")
  grad.mag <- sqrt(dx^2 + dy^2)
  plot(grad.mag, main = "Gradient magnitude")
}
