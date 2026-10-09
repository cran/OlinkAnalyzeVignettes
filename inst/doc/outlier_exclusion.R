## ----setup, include = FALSE, echo = FALSE, eval = TRUE------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  tidy = FALSE,
  tidy.opts = list(width.cutoff = 95),
  fig.width = 6,
  fig.height = 3,
  message = FALSE,
  warning = FALSE,
  time_it = TRUE,
  fig.align = "center"
)
knitr::opts_chunk$set(fig.pos = "H")
knitr::opts_chunk$set(fig.align = "center")
knitr::opts_knit$set(eval.after = "fig.cap")

## ----Outlier_data, include = FALSE, error = TRUE, message = FALSE, warning = FALSE----
try({
# Use provided example dataset (npx_data1)
npx_data1 <- OlinkAnalyze::npx_data1

# NPX file preprocessing

# Generate check log
check_log_npx_data1 <- OlinkAnalyze::check_npx(
  df = npx_data1
)

# Clean NPX
npx_data1_clean <- OlinkAnalyze::clean_npx(
  df = npx_data1,
  check_log = check_log_npx_data1
)

# Generate check log on cleaned data
check_log_npx_data1_clean <- OlinkAnalyze::check_npx(
  df = npx_data1_clean
)

# Create Dataset with outliers
outlier_data <- npx_data1_clean |>
  dplyr::mutate(
    NPX = dplyr::if_else(
      .data[["SampleID"]] == "A25",
      .data[["NPX"]] + 4,
      .data[["NPX"]]
    )
  ) |>
  dplyr::mutate(
    NPX = dplyr::if_else(
      .data[["SampleID"]] == "A52",
      .data[["NPX"]] - 4,
      .data[["NPX"]]
    )
  )

group_data <- npx_data1_clean |>
  dplyr::mutate(
    NPX = dplyr::if_else(
      .data[["Site"]] == "Site_D",
      .data[["NPX"]] + 3,
      .data[["NPX"]]
    )
  )

# Clean up environment
rm(check_log_npx_data1, npx_data1)
})

## ----dataset_generation, eval = FALSE, message = FALSE, warning = FALSE-------
# # Use provided example dataset (npx_data1)
# npx_data1 <- OlinkAnalyze::npx_data1
# 
# # NPX file preprocessing
# 
# # Generate check log
# check_log_npx_data1 <- OlinkAnalyze::check_npx(
#   df = npx_data1
# )
# 
# # Clean NPX
# npx_data1_clean <- OlinkAnalyze::clean_npx(
#   df = npx_data1,
#   check_log = check_log_npx_data1
# )
# 
# # Generate check log on cleaned data
# check_log_npx_data1_clean <- OlinkAnalyze::check_npx(
#   df = npx_data1_clean
# )
# 
# # Create Dataset with outliers
# outlier_data <- npx_data1_clean |>
#   dplyr::mutate(
#     NPX = dplyr::if_else(
#       .data[["SampleID"]] == "A25",
#       .data[["NPX"]] + 4,
#       .data[["NPX"]]
#     )
#   ) |>
#   dplyr::mutate(
#     NPX = dplyr::if_else(
#       .data[["SampleID"]] == "A52",
#       .data[["NPX"]] - 4,
#       .data[["NPX"]]
#     )
#   )
# 
# group_data <- npx_data1_clean |>
#   dplyr::mutate(
#     NPX = dplyr::if_else(
#       .data[["Site"]] == "Site_D",
#       .data[["NPX"]] + 3,
#       .data[["NPX"]]
#     )
#   )

## ----Outlier_example_code, eval = FALSE, fig.show='hide'----------------------
# p1 <- OlinkAnalyze::olink_pca_plot(
#   df = outlier_data,
#   label_samples = TRUE,
#   quiet = TRUE,
#   check_log = check_log_npx_data1_clean
# )
# 
# p2 <- OlinkAnalyze::olink_pca_plot(
#   df = group_data,
#   color_g = "Site",
#   quiet = TRUE,
#   check_log = check_log_npx_data1_clean
# )
# 
# ggpubr::ggarrange(
#   p1[[1L]],
#   p2[[1L]],
#   nrow = 1L,
#   labels = "AUTO"
# )

## ----Outlier_Example, echo = FALSE, fig.cap = fcap----------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/PCA_Outlier_Fig1.png"
  ),
  error = FALSE
)

fcap <- paste("**Figure 1** **A.** PCA can be used to identify individual",
              "outlier samples as shown by samples A25 and A52. **B.** PCA can",
              "be used to identify difference in groups as seen by Site_D",
              "samples. This is not suggesting Site_D is an outlier, but",
              "rather that there may be a global difference between sites.")

## ----PCA_treatment, eval = FALSE----------------------------------------------
# OlinkAnalyze::olink_pca_plot(
#   df = npx_data1_clean,
#   color_g = "Treatment",
#   check_log = check_log_npx_data1_clean
# )

## ----PCA_treatment_fig, echo = FALSE------------------------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/PCA_Treatment.png"
  ),
  error = FALSE
)

## ----PCA_Panel, eval = FALSE--------------------------------------------------
# # Use provided example dataset (npx_data2)
# 
# npx_data2 <- OlinkAnalyze::npx_data2
# 
# # NPX file preprocessing
# 
# # Generate check log
# check_log_npx_data2 <- OlinkAnalyze::check_npx(
#   df = npx_data2
# )
# 
# # Clean NPX
# npx_data2_clean <- OlinkAnalyze::clean_npx(
#   df = npx_data2,
#   check_log = check_log_npx_data2
# )
# 
# # Generate check log on cleaned data
# check_log_npx_data2_clean <- OlinkAnalyze::check_npx(
#   df = npx_data2_clean
# )
# 
# # Specify by panel
# OlinkAnalyze::olink_pca_plot(
#   df = npx_data2_clean,
#   byPanel = TRUE,
#   check_log = check_log_npx_data2_clean
# )

## ----PCA_Panel_fig, echo = FALSE----------------------------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/PCA_Panel.png"
  ),
  error = FALSE
)

## ----PCA_object, eval = FALSE-------------------------------------------------
# # Save the PCA plot to a variable
# # By panel
# # quiet argument suppresses export
# pca_plots <- OlinkAnalyze::olink_pca_plot(
#   df =  npx_data2_clean,
#   byPanel = TRUE,
#   quiet = TRUE,
#   check_log = check_log_npx_data2_clean
# )
# 
# pca_plots[[1L]] # Cardiometabolic PCA
# pca_plots[[2L]] # Inflammation PCA

## ----Outlier_PCA, echo = FALSE------------------------------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/Outlier_PCA.png"
  ),
  error = FALSE
)

## ----eval = FALSE-------------------------------------------------------------
# OlinkAnalyze::olink_pca_plot(
#   df = outlier_data,
#   label_samples = TRUE,
#   check_log = check_log_npx_data1_clean
# )

## ----Label_samples, echo = FALSE----------------------------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/label_samples_pca.png"
  ),
  error = FALSE
)

## ----eval = FALSE-------------------------------------------------------------
# if (requireNamespace(package = "ggrepel", quietly = TRUE)) {
#   OlinkAnalyze::olink_pca_plot(
#     df = outlier_data,
#     outlierDefX = 3L,
#     outlierDefY = 3L,
#     outlierLines = TRUE,
#     label_outliers = TRUE,
#     check_log = check_log_npx_data1_clean
#   )
# }

## ----outlier_line_pca, echo = FALSE-------------------------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/outlier_line_pca.png"
  ),
  error = FALSE
)

## ----eval = FALSE-------------------------------------------------------------
# if (requireNamespace(package = "ggrepel", quietly = TRUE)) {
#   OlinkAnalyze::olink_pca_plot(
#     df = outlier_data,
#     outlierDefX = 3L,
#     outlierDefY = 3L,
#     outlierLines = FALSE,
#     label_outliers = TRUE,
#     check_log = check_log_npx_data1_clean
#   )
# }

## -----------------------------------------------------------------------------
if (requireNamespace(package = "ggrepel", quietly = TRUE)) {
  outliers_pca_labeled <-
    OlinkAnalyze::olink_pca_plot(
      df = outlier_data,
      outlierDefX = 3L,
      outlierDefY = 3L,
      outlierLines = FALSE,
      label_outliers = TRUE,
      quiet = TRUE,
      check_log = check_log_npx_data1_clean
    )

  outliers_pca_labeled[[1L]]$data |>
    dplyr::filter(
      .data[["Outlier"]] == TRUE
    ) |>
    dplyr::select(
      dplyr::all_of("SampleID")
    ) |>
    dplyr::distinct()
}

## ----eval = FALSE-------------------------------------------------------------
# outlier_data_dist <- outlier_data |>
#   dplyr::filter(
#     .data[["SampleID"]] %in% c("A25", "A52", "A1", "A2", "A3", "A5",
#                                "A15", "A16", "A18", "A19", "A20")
#   )
# 
# OlinkAnalyze::olink_dist_plot(
#   df = outlier_data_dist,
#   check_log = check_log_npx_data1_clean
# )

## ----echo = FALSE-------------------------------------------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/dist_boxplot.png"
  ),
  error = FALSE
)

## ----eval = FALSE-------------------------------------------------------------
# group_data_dist <- group_data |>
#   # Only visualizing 2 sites to see all samples
#   dplyr::filter(
#     .data[["Site"]] %in% c("Site_A", "Site_D")
#   )
# 
# OlinkAnalyze::olink_dist_plot(
#   df = group_data_dist,
#   color_g = "Site",
#   check_log = check_log_npx_data1_clean
# )

## ----echo = FALSE-------------------------------------------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/site_boxplot.png"
  ),
  error = FALSE
)

## ----eval = FALSE-------------------------------------------------------------
# # Calculate SampleID Median NPX
# median_npx <- group_data |>
#   dplyr::group_by(
#     .data[["SampleID"]]
#   ) |>
#   dplyr::summarise(
#     Median_NPX = median(.data[["NPX"]])
#   ) |>
#   dplyr::ungroup()
# 
# # Adjust by sample median
# adjusted_data <- group_data |>
#   dplyr::inner_join(
#     median_npx,
#     by = "SampleID"
#   ) |>
#   dplyr::mutate(
#     NPX = .data[["NPX"]] - .data[["Median_NPX"]]
#   )
# 
# adjusted_data_dist <- adjusted_data |>
#   # Only visualizing 2 sites to see all samples
#   dplyr::filter(
#     .data[["Site"]] %in% c("Site_A", "Site_D")
#   )
# 
# OlinkAnalyze::olink_dist_plot(
#   df = adjusted_data_dist,
#   color_g = "Site",
#   check_log = check_log_npx_data1_clean
# )

## ----echo=FALSE---------------------------------------------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/sample_med_boxplot.png"
  ),
  error = FALSE
)

## ----eval = FALSE-------------------------------------------------------------
# if (requireNamespace(package = "ggrepel", quietly = TRUE)) {
#   OlinkAnalyze::olink_qc_plot(
#     df = outlier_data,
#     label_outliers = TRUE,
#     check_log = check_log_npx_data1_clean
#   )
# }

## ----echo=FALSE---------------------------------------------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/qc_plot.png"
  ),
  error = FALSE
)

## ----eval = FALSE-------------------------------------------------------------
# if (requireNamespace(package = "ggrepel", quietly = TRUE)) {
#   OlinkAnalyze::olink_qc_plot(
#     df = group_data,
#     color_g = "Site",
#     label_outliers = TRUE,
#     check_log = check_log_npx_data1_clean
#   )
# }

## ----echo = FALSE-------------------------------------------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/qc_site_plot.png"
  ),
  error = FALSE
)

## ----eval = FALSE-------------------------------------------------------------
# if (requireNamespace(package = "ggrepel", quietly = TRUE)) {
#   OlinkAnalyze::olink_qc_plot(
#     df = outlier_data,
#     median_outlierDef = 2L,
#     IQR_outlierDef = 4L,
#     outlierLines = TRUE,
#     label_outliers = TRUE,
#     check_log = check_log_npx_data1_clean
#   )
# }

## ----echo = FALSE-------------------------------------------------------------
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/qc_label_plot.png"
  ),
  error = FALSE
)

## ----eval = FALSE-------------------------------------------------------------
# if (requireNamespace(package = "ggrepel", quietly = TRUE)) {
#   OlinkAnalyze::olink_qc_plot(
#     df = outlier_data,
#     median_outlierDef = 2L,
#     IQR_outlierDef = 4L,
#     outlierLines = FALSE,
#     label_outliers = TRUE,
#     check_log = check_log_npx_data1_clean
#   )
# }

## -----------------------------------------------------------------------------
if (requireNamespace(package = "ggrepel", quietly = TRUE)) {
  outliers_qc_labeled <- OlinkAnalyze::olink_qc_plot(
    df = outlier_data,
    median_outlierDef = 2L,
    IQR_outlierDef = 4,
    outlierLines = FALSE,
    label_outliers = TRUE,
    check_log = check_log_npx_data1_clean
  )

  outliers_qc_labeled$data |>
    dplyr::filter(
      .data[["Outlier"]] == TRUE
    ) |>
    dplyr::select(
      dplyr::all_of("SampleID")
    ) |>
    dplyr::distinct()
}

