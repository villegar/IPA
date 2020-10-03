#' Create hexagonal logo for the package
#'
#' @param subplot image to use as the main logo
#' @param dpi plot resolution (dots-per-inch)
#' @param h_color colour for hexagon border
#' @param h_fill colour to fill hexagon
#' @param output output file (hexagonal logo)
#' @param package title for logo (package name)
#' @param p_color colour for package name
#' @param url URL for package repository or website
#' @param u_size text size for URL
#'
#' @return hexagonal logo
#' @export
#'
#' @examples
#' \dontrun{
#'     hex_logo()
#'     hex_logo("inst/images/beer.png", output = "inst/images/logo.png")
#' }
hex_logo <- function(subplot = system.file("images/beer.png", package = "IPA"),
                     dpi = 600,
                     h_color = "#000000",
                     h_fill = "#696969",
                     output = system.file("images/logo.png", package = "IPA"),
                     package = "IPA",
                     p_color = "#eeeeee",
                     url = "https://github.com/villegar/IPA",
                     u_size = 1.55) {
  hexSticker::sticker(subplot = subplot, package = package,
                      h_color = h_color,  h_fill = h_fill,
                      dpi = dpi,
                      s_x = 1.0, s_y = .85, s_width = .5,
                      p_x = 1.0, p_y = 1.52, p_size = 6, p_color = p_color,
                      url = url,
                      u_angle = 30, u_color = p_color, u_size = u_size,
                      filename = output)
}

#' Drop the file extension in a string
#'
#' @param filename filename w/o full path
#' @param only_basename boolean flag to indicate if only the base name should
#'     be returned.
#'
#' @return filename without extension
#' @export
#'
#' @examples
#' drop_extension("/path/to/A.txt")
#' drop_extension("/path/to/A.txt", TRUE)
drop_extension <- function(filename, only_basename = FALSE) {
  if (only_basename) {
    filename <- basename(filename)
  }
  return(sub(pattern = "(.*)\\..*$", replacement = "\\1", filename))
}
