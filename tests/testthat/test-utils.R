test_that("hexagonal logo works", {
  hex_logo(output = "hex_logo.png")
  expect_true(file.exists("hex_logo.png"))
  expect_false(dir.exists("hex_logo.png"))
  expect_gt(file.size("hex_logo.png"), 0)
  file.remove("hex_logo.png")
  expect_false(file.exists("hex_logo.png"))
})

test_that("drop file extension works", {
  with_path <- drop_extension("/path/to/A.txt")
  without_path <- drop_extension("/path/to/A.txt", TRUE)
  expect_equal(with_path, "/path/to/A")
  expect_equal(without_path, "A")
})
