
<!-- README.md is generated from README.Rmd. Please edit that file -->

# IPA: Image Processing & Analysis pipeline <img src="https://raw.githubusercontent.com/villegar/IPA/master/inst/images/logo.png" alt="logo" align="right" height=200px/>

<!-- badges: start -->

<!-- [![](https://img.shields.io/badge/devel%20version-0.0.1-blue.svg)](https://github.com/villegar/IPA) -->

<!-- [![](https://img.shields.io/github/languages/code-size/villegar/IPA.svg)](https://github.com/villegar/IPA) -->

[![R build
status](https://github.com/villegar/IPA/workflows/R-CMD-check/badge.svg)](https://github.com/villegar/IPA/actions)
[![](https://img.shields.io/badge/devel%20version-0.0.1-blue.svg)](https://github.com/villegar/MetaPipe)
[![](https://codecov.io/gh/villegar/IPA/branch/master/graph/badge.svg)](https://codecov.io/gh/villegar/IPA)
<!-- badges: end -->

## Overview

The goal of IPA is to provide a set of functions for image processing
and
analysis.

## Installation

<!-- You can install the released version of IPA from [CRAN](https://CRAN.R-project.org) with: -->

<!-- ``` r -->

<!-- install.packages("IPA") -->

<!-- ``` -->

<!-- And the development version from [GitHub](https://github.com/) with: -->

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages(c("hexSticker", "remotes")
remotes::install_github("villegar/IPA")
```

## Example

<!-- This is a basic example which shows you how to solve a common problem: -->

You should start by loading `IPA` on your session.

``` r
library(IPA)
```

### RGB decomposition (`rgb_decomposition`)

This function extracts each layer from an image as a matrix, for further
processing.

1.  Start by creating an example image, in this case a simple barplot

<!-- end list -->

``` r
test_data <- data.frame(name = c("R", "G", "B"), values = c(2, 2, 2))
RGB <- c("red", "green", "blue")
png("inst/figures/test_plot.png")
  barplot(height = test_data$values, names = test_data$name, col = RGB)
dev.off()
```

This code generates the following barplot
(`inst/figures/test_plot.png`)

<img src="inst/figures/test_plot.png" alt="logo" align="center" height=300px/>

Which we want to decompose into 3 images:

<table>

<thead>

<tr>

<th>

Red layer

</th>

<th>

Green layer

</th>

<th>

Blue
layer

</th>

</tr>

</thead>

<tbody>

<tr>

<td>

<img src="inst/figures/test_plot_R.png" alt="logo" align="center" height=220px/>

</td>

<td>

<img src="inst/figures/test_plot_G.png" alt="logo" align="center" height=220px/>

</td>

<td>

<img src="inst/figures/test_plot_B.png" alt="logo" align="center" height=220px/>

</td>

</tr>

</tbody>

</table>

For this purpouse we can use the function `rgb_decomposition`, which can
be called as follows

``` r
rgb_decomposition(subdirectory, 
                  # optional
                  extension = "jpg", 
                  Rdata = TRUE, 
                  recursive = TRUE)
```

where `subdirectory` is the name of a directory where to search for the
images. The other arguments are optional; `extension` is the file format
of the images, `Rdata` is a boolean flag to indicate whether or not the
layers should be stored as Rdata format or CSV, the latter requires more
disk space. Finally, `recursive` is a boolean flag on whether or not
explore the `subdirectory` recursively for more images.

2.  Call the `rgb_decomposition` function to extract the layers of the
    example image previously created:

<!-- end list -->

``` r
rgb_decomposition("inst/figures/", "png", recursive = FALSE)
```

After running this, three new files (per image) will be on disk, called
`IMAGE-NAME-red.Rdata`, `IMAGE-NAME-green.Rdata`, and
`IMAGE-NAME-blue.Rdata`.
