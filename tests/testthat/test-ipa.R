test_that("RGB decomposition works", {
  test_data <- data.frame(name = c("R", "G", "B"), values = c(2, 2, 2))
  RGB <- c("red", "green", "blue")
  png("./test_plot.png")
    barplot(height = test_data$values, names = test_data$name, col = RGB)
  dev.off()
  rgb_decomposition(".", "png", recursive = FALSE)
  rgb_decomposition(".", "png", Rdata = FALSE, recursive = FALSE)
  # Check for generated layer files
  filenames <- paste(".",
                     c("test_plot.png",
                       paste0(
                         c("test_plot-blue.",
                           "test_plot-green.",
                           "test_plot-red."
                         ),
                         rep(c("Rdata", "csv"), each = 3)
                       )
                      ),
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
