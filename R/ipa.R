rgb_decomposition <- function(subdirectory, extension = "jpg") {
  extension <- paste0("*", extension, "$") # Adding regex pattern
  images <- list.files(here::here(subdirectory), pattern = extension)
}
