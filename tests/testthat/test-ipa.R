test_that("RGB decomposition works", {
  test_data <- data.frame(name = c("R", "G", "B"), values = c(2, 2, 2))
  RGB <- c("red", "green", "blue")
  png("test_plot.png")
  barplot(height = test_data$values, names = test_data$name, col = RGB)
  dev.off()
  rgb_decomposition(here::here(), "png", recursive = FALSE)
  # Check for generated histograms
  filenames <- c("test_plot.png",
                 "test_plot-blue.Rdata",
                 "test_plot-green.Rdata",
                 "test_plot-red.Rdata")
  for (f in filenames) {
    expect_true(file.exists(f))
    expect_false(dir.exists(f))
    expect_gt(file.size(f), 0)
    file.remove(f)
    expect_false(file.exists(f))
  }
})