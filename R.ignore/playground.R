AB_001_B <- here::here("runs/extdata/AB_001_B.jpg")
trim_areas <- data.frame(x0 = 1, width = 3000, y0 = 1, height = 1500)
trim_areas <- rbind(trim_areas, c(1, -1, -1, 1400))
IPA::rm_background(AB_001_B, bkg_thr = 0.4, quiet = FALSE)


AB_001_B_wb <- here::here("runs/extdata/0AB_001_B_wb.png")
img_wb <- imager::load.image(AB_001_B_wb)
img_wb_alpha <- imager::channel(img_wb, 4)
plot(imager::grayscale(img_wb_alpha))
img_wb_alpha_blobs4 <- find_area(img_wb_alpha, px_tol = 100)
img_wb_alpha_blobs2 <- find_area(img_wb_alpha, start = c(1, 5750), px_tol = 500)
IPA::rm_background(AB_001_B, bkg_thr = 0.4, trim_areas = img_wb_alpha_blobs2, quiet = TRUE)

# img <- imager::load.image(AB_001_B)
# tictoc::tic()
# IPA::rm_background(AB_001_B)
# tictoc::toc()
# img.g <- imager::grayscale(imager::rm.alpha(img_wb))
# gr <- imager::imgradient(img.g, "xy")
# plot(gr, layout = "row")
# dx <- imager::imgradient(img.g, "x")
# dy <- imager::imgradient(img.g, "y")
# grad.mag <- sqrt(dx ^ 2 + dy ^ 2)
# plot(grad.mag, main = "Gradient magnitude")


img.g <- imager::grayscale(imager::rm.alpha(img_wb))
img.g[img.g > 0.3] <- 0
img_wb[img.g > 0] <- 0


# Example runs
tictoc::tic()
RA_001_2_B <- here::here("runs/extdata/GH127_07_27/RA_001_2_B.jpg")
trim_areas <- data.frame(x0 = 1, width = -1, y0 = 1, height = 1500)
trim_areas <- rbind(trim_areas, c(1, -1, -1, 1500))
IPA::rm_background(RA_001_2_B, bkg_thr = 0.3, trim_areas = trim_areas, quiet = FALSE)

RA_001_2_F <- here::here("runs/extdata/GH127_07_27/RA_001_2_F.jpg")
trim_areas <- data.frame(x0 = 1, width = -1, y0 = 1, height = 1500)
trim_areas <- rbind(trim_areas, c(1, -1, -1, 1500))
IPA::rm_background(RA_001_2_F, bkg_thr = 0.3, trim_areas = trim_areas, quiet = FALSE)

RA_002_2_B <- here::here("runs/extdata/GH127_07_27/RA_002_2_B.jpg")
trim_areas <- data.frame(x0 = 1, width = -1, y0 = 1, height = 2000)
trim_areas <- rbind(trim_areas, c(1, -1, -1, 1500))
IPA::rm_background(RA_002_2_B, trim_areas = trim_areas, quiet = FALSE)
tictoc::toc()
