test_that("RGB decomposition works", {
  test_data <- data.frame(name = c("R", "G", "B"), values = c(2, 2, 2))
  RGB <- c("red", "green", "blue")
  png("./test_plot.png")
    barplot(height = test_data$values, names = test_data$name, col = RGB)
  dev.off()
  rgb_decomposition(".", "png", recursive = FALSE)
  rgb_decomposition(".", "png", RData = FALSE, recursive = FALSE)
  # Check for generated layer files
  filenames <- paste(".",
                     c("test_plot.png",
                       paste0(c("test_plot-blue.",
                                "test_plot-green.",
                                "test_plot-red."),
                              rep(c("RData", "csv"), each = 3))),
                     sep = "/")
  for (f in filenames) {
    message(paste0("Testing: ", f))
    expect_true(file.exists(f))
    expect_false(dir.exists(f))
    expect_gt(file.size(f), 0)
    file.remove(f)
    expect_false(file.exists(f))
  }
})

test_that("Remove image background works", {
  test_data <- data.frame(name = c("R", "G"), values = c(2, 2))
  RG <- c("red", "green")
  png("./test_plot.png")
  par(bg = 'black')
  barplot(height = test_data$values, names = test_data$name, col = RG)
  dev.off()
  rm_background("./test_plot.png", 0.1)
  rm_background("./test_plot.png", 0.1, TRUE, breaks = 10)

  filenames <- c("./test_plot.png", "./test_plot_wb.png")
  for (f in filenames) {
    message(paste0("Testing: ", f))
    expect_true(file.exists(f))
    expect_false(dir.exists(f))
    expect_gt(file.size(f), 0)
    file.remove(f)
    expect_false(file.exists(f))
  }
})

test_that("Add transparency (alpha) works", {
  # Create test image
  red <- matrix(0, 50, 50)
  red[1:25, 1:25] <- 1
  blue <- matrix(0, 50, 50)
  blue[26:50, 1:25] <- 1
  green <- matrix(0, 50, 50)
  green[1:25, 26:50] <- 1
  alpha <- matrix(1, 50, 50)
  alpha[26:50, 26:50] <- 0
  img <- imager::as.cimg(abind::abind(imager::as.cimg(red),
                                      imager::as.cimg(blue),
                                      imager::as.cimg(green),
                                      imager::as.cimg(alpha),
                                      along = 4))
  # Remove red portion of the image
  img2 <- add_alpha(img, c(1, 25, 1, 25))
  expect_equal(sum(as.matrix(imager::R(img2)) > 0), 0) # Zero red pixels
  # Remove red and green portions
  img3 <- plot(add_alpha(img, c(1, -1, 1, 25)))
  expect_equal(sum(as.matrix(imager::R(img3)) > 0) +
                 sum(as.matrix(imager::G(img3)) > 0), 0)
  # Remove red and blue portions
  img4 <- add_alpha(img, c(1, 25, 1, -1))
  expect_equal(sum(as.matrix(imager::R(img4)) > 0) +
                 sum(as.matrix(imager::B(img4)) > 0), 0)
  # Remove green and alpha portions
  img5 <- plot(add_alpha(img, c(-1, 25, 1, -1)))
  expect_equal(sum(as.matrix(imager::G(img5)) > 0), 0) # Zero green pixels
  expect_error(add_alpha(img, c(1, 25, 1))) # wrong length for the area param.
  expect_error(add_alpha(as.array(img), c(1, 25, 1, 25))) # wrong class
  expect_error(add_alpha(as.array(img), c(100, 25, 1, 25))) # out of bounds
  expect_message(img3 <- add_alpha(img, c(1, 25, 1, 25), quiet = FALSE))
})
