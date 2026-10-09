## ----include = FALSE----------------------------------------------------------
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

## ----brnrtab, eval = TRUE, message = FALSE, echo = FALSE----------------------
dplyr::tibble(
  "Olink Product" = c(
    "'Olink Explore 3072' to 'Olink Explore HT'",
    "'Olink Explore 3072' to 'Olink Reveal'",
    "'Olink Explore HT' to 'Olink Reveal'",
    "'Olink Reveal' to 'Olink Explore HT'"
  ),
  "Number of Bridge Samples" = c(
    "40-64",
    "32-48",
    "24-40",
    "24-40"
  )
) |>
  kableExtra::kbl(
    booktabs = TRUE,
    digits = 2L,
    caption = paste("Recommended number of bridge samples for normalizing",
                    "between Olink products.")
  ) |>
  kableExtra::kable_styling(
    bootstrap_options = "striped",
    full_width = FALSE,
    position = "center",
    latex_options = "HOLD_position"
  )

## ----fig.cap = fcap, eval = TRUE, echo = FALSE, out.width = "50%"-------------
knitr::include_graphics(
  normalizePath(
    path = "../man/figures/Bridging_schematic.png"
  ),
  error = FALSE
)

fcap <- "Schematic of Between-Product Bridging Workflow"

## ----message = FALSE, eval = FALSE, echo = TRUE-------------------------------
# ### Use provided example dataset
# 
# # Explore 3072: CSV or parquet file
# data_e3072 <- OlinkAnalyze::read_NPX(
#   filename = "~/NPX_Explore3072_location.parquet"
#   )
# 
# # Explore HT: parquet file
# data_eht <- OlinkAnalyze::read_NPX(
#   filename = "~/NPX_ExploreHT_location.parquet"
# )
# 
# # Reveal: CSV or parquet file
# data_reveal <- OlinkAnalyze::read_NPX(
#   filename = "~/NPX_Reveal_location.parquet"
# )

## ----message = FALSE, eval = FALSE, echo = TRUE-------------------------------
# ### NPX file preprocessing
# 
# # Generate check log
# check_log_data_e3072 <- OlinkAnalyze::check_npx(
#   df = data_e3072
# )
# check_log_data_eht <- OlinkAnalyze::check_npx(
#   df = data_eht
# )
# check_log_data_reveal <- OlinkAnalyze::check_npx(
#   df = data_reveal
# )
# 
# # Clean NPX data
# data_e3072_clean <- OlinkAnalyze::clean_npx(
#   df = data_e3072,
#   check_log = check_log_data_e3072,
#   # keep internal and external controls
#   remove_control_sample = FALSE,
#   remove_control_assay = FALSE,
#   # keep datapoints with samples and assays warnings
#   remove_qc_warning = FALSE,
#   remove_assay_warning = FALSE
# )
# data_eht_clean <- OlinkAnalyze::clean_npx(
#   df = data_eht,
#   check_log = check_log_data_eht,
#   # keep internal and external controls
#   remove_control_sample = FALSE,
#   remove_control_assay = FALSE,
#   # keep datapoints with samples and assays warnings
#   remove_qc_warning = FALSE,
#   remove_assay_warning = FALSE
# )
# data_reveal_clean <- OlinkAnalyze::clean_npx(
#   df = data_reveal,
#   check_log = check_log_data_reveal,
#   # keep internal and external controls
#   remove_control_sample = FALSE,
#   remove_control_assay = FALSE,
#   # keep datapoints with samples and assays warnings
#   remove_qc_warning = FALSE,
#   remove_assay_warning = FALSE
# )
# 
# # Generate check log on cleaned data
# check_log_data_e3072_clean <- OlinkAnalyze::check_npx(
#   df = data_e3072_clean
# )
# check_log_data_eht_clean <- OlinkAnalyze::check_npx(
#   df = data_eht_clean
# )
# check_log_data_reveal_clean <- OlinkAnalyze::check_npx(
#   df = data_reveal_clean
# )
# 
# # clean up environment
# rm(
#   data_e3072,
#   data_eht,
#   data_reveal,
#   check_log_data_e3072,
#   check_log_data_eht,
#   check_log_data_reveal
# )

## ----eval = FALSE, echo = TRUE------------------------------------------------
# # Note that if `SampleType` is not is input data:
# # stringr::str_detect can be used to exclude control samples based on SampleID.
# 
# data_e3072_samples <- data_e3072_clean |>
#   dplyr::filter(
#     .data[["SampleType"]] == "SAMPLE"
#   ) |>
#   dplyr::distinct(
#     .data[["SampleID"]]
#   ) |>
#   dplyr::pull()
# 
# data_eht_samples <- data_eht_clean |>
#   dplyr::filter(
#     .data[["SampleType"]] == "SAMPLE"
#   ) |>
#   dplyr::distinct(
#     .data[["SampleID"]]
#   ) |>
#   dplyr::pull()
# 
# overlapping_samples <- dplyr::intersect(
#   x = data_e3072_samples,
#   y = data_eht_samples
# ) |>
#   unique()

## ----echo=FALSE---------------------------------------------------------------
try(
  readRDS(
    file = normalizePath(
      path = "../man/figures/overlapping_samples_table.rds"
    )
  ) |>
    kableExtra::kbl(
      booktabs = TRUE,
      digits = 2L,
      caption = "List of overlapping samples between the two projects."
    ) |>
    kableExtra::kable_styling(
      bootstrap_options = "striped",
      full_width = FALSE,
      position = "center",
      latex_options = "HOLD_position"
    )
)

## ----include = FALSE----------------------------------------------------------
f3 <- paste0(
  "PCA plot prior to bridging for Explore 3072 data and data from the",
  " reference product. Bridge samples are indicated by color. PCA plots can be",
  " helpful in assessing if any bridge samples were outliers in one of the",
  " platforms."
)

## ----eval = FALSE-------------------------------------------------------------
# #### Extract bridging samples
# 
# data_e3072_before_br <- data_e3072_clean |>
#   dplyr::filter(
#     .data[["SampleType"]] == "SAMPLE"
#   ) |>
#   # Note that if column `SampleType` is not in input data, the function
#   # stringr::str_detect can be used to exclude control samples based on naming
#   # convention.
#   dplyr::mutate(
#     Type = dplyr::if_else(
#       .data[["SampleID"]] %in% .env[["overlapping_samples"]],
#       paste0("Explore 3072 Bridge"),
#       paste0("Explore 3072 Sample")
#     )
#   )
# 
# data_eht_before_br <- data_eht_clean |>
#   dplyr::filter(
#     .data[["SampleType"]] == "SAMPLE"
#   ) |>
#   # Note that if column `SampleType` is not in input data, the function
#   # stringr::str_detect can be used to exclude control samples based on naming
#   # convention.
#   dplyr::mutate(
#     Type = dplyr::if_else(
#       .data[["SampleID"]] %in% .env[["overlapping_samples"]],
#       paste0("Explore HT Bridge"),
#       paste0("Explore HT Sample")
#     )
#   )
# 
# ### PCA plot
# pca_e3072 <- OlinkAnalyze::olink_pca_plot(
#   df = data_e3072_before_br,
#   check_log = check_log_data_e3072_clean,
#   color_g = "Type",
#   quiet = TRUE
# )
# pca_eht <- OlinkAnalyze::olink_pca_plot(
#   df = data_eht_before_br,
#   check_log = check_log_data_eht_clean,
#   color_g = "Type",
#   quiet = TRUE
# )

## ----echo = FALSE, fig.cap = f3, fig.height = 8, fig.width = 6----------------
knitr::include_graphics(
  normalizePath(
    path = "../man/figures/PCA_btw_product_before.png"
  ),
  error = FALSE
)

## ----eval = FALSE, echo = TRUE------------------------------------------------
# ### Perform bridge normalization
# 
# # Note:
# # Project name is assigned by `df1_project_nr` and `df2_project_nr` parameters
# # in `olink_normalization` function
# 
# # Perform between-product bridging without formatting for downstream analysis
# npx_br_data <- OlinkAnalyze::olink_normalization(
#   df1 = data_eht_clean,
#   df2 = data_e3072_clean,
#   overlapping_samples_df1 = overlapping_samples,
#   df1_project_nr = "Explore HT",
#   df2_project_nr = "Explore 3072",
#   reference_project = "Explore HT",
#   format = FALSE,
#   df1_check_log = check_log_data_eht_clean,
#   df2_check_log = check_log_data_e3072_clean
# )
# 
# # Perform between-product bridging with formatting for downstream analysis
# npx_br_data <- OlinkAnalyze::olink_normalization(
#   df1 = data_eht_clean,
#   df2 = data_e3072_clean,
#   overlapping_samples_df1 = overlapping_samples,
#   df1_project_nr = "Explore HT",
#   df2_project_nr = "Explore 3072",
#   reference_project = "Explore HT",
#   format = TRUE,
#   df1_check_log = check_log_data_eht_clean,
#   df2_check_log = check_log_data_e3072_clean
# )

## ----message = FALSE, eval = FALSE, echo = TRUE-------------------------------
# # Generate check log
# check_log_br_data <- OlinkAnalyze::check_npx(
#   df = npx_br_data
# )
# 
# # Clean NPX data
# npx_br_data_clean <- OlinkAnalyze::clean_npx(
#   df = npx_br_data,
#   check_log = check_log_br_data,
#   # keep only control samples as we will need them for downstream QC
#   remove_control_sample = FALSE
# )
# 
# # Generate check log on cleaned data
# check_log_br_data_clean <- OlinkAnalyze::check_npx(
#   df = npx_br_data_clean
# )
# 
# # clean up environment
# rm(
#   npx_br_data,
#   check_log_br_data
# )

## ----echo = FALSE, fig.cap = fcap, out.width = "50%"--------------------------
knitr::include_graphics(
  normalizePath(
    path = "../man/figures/assay_bridgeability.jpg"
  ),
  error = FALSE
)
fcap <- paste(
  "Criteria to determine the bridging recommendation for an assay. The",
  "assessment of linearity ensures bridging between signal in both platforms",
  "or noise in both platforms (but not between signal and noise). Similar NPX",
  "ranges and sufficient counts provide additional insight into an assay's",
  "bridgeability. Distribution shape is assessed to determine recommended",
  "bridging method."
)

## ----eval = FALSE, echo = TRUE------------------------------------------------
# ### Generate olink_bridgeability_plot figures
# 
# npx_br_data_bridgeable_plt <- npx_br_data_clean |>
#   dplyr::filter(
#     .data[["SampleType"]] == "SAMPLE"
#   ) |>
#   OlinkAnalyze::olink_bridgeability_plot(
#     check_log = check_log_br_data_clean,
#     # Important to note that setting `olink_id` to NULL will generate plots for
#     # all assays. This can be computationally intensive if there are many
#     # assays!
#     # To generate plots for a subset of assays, set `olink_id` to a vector of
#     # Olink IDs of interest.
#     olink_id = NULL,
#     median_counts_threshold = 150L,
#     min_count = 10L
#   )
# 
# npx_br_data_bridgeable_plt[[1L]]

## ----message = FALSE, echo = FALSE, out.width = "675px", fig.cap = fcap-------
knitr::include_graphics(
  normalizePath(path = "../man/figures/bridgeable_plt_MedianCenter.png"),
  error = FALSE
)

fcap <- paste("Visualization of an assay's bridgeability criteria as generated",
              "by the `olink_bridgeability_plot()` function.")

## ----eval = TRUE, echo = FALSE------------------------------------------------
try(
  readRDS(
    file = normalizePath("../man/figures/bridging_results.rds")
  ) |>
    kableExtra::kbl(
      booktabs = TRUE,
      digits = 1,
      caption = paste("Table 4. First 5 rows of combined datasets after",
                      "bridging with between-product formatting argument set",
                      "to FALSE.")
    ) |>
    kableExtra::kable_styling(
      bootstrap_options = "striped",
      full_width = FALSE,
      font_size = 10,
      position = "center",
      latex_options = "HOLD_position"
    ) |>
    kableExtra::scroll_box(
      width = "100%"
    )
)

## ----eval = TRUE, echo = FALSE------------------------------------------------
try(
  readRDS(
    normalizePath(path = "../man/figures/bridging_results.rds")
  ) |>
    dplyr::mutate(
      NPX = dplyr::case_when(
        .data[["BridgingRecommendation"]] == "MedianCentering" ~
          .data[["MedianCenteredNPX"]],
        .data[["BridgingRecommendation"]] == "QuantileSmoothing" ~
          .data[["QSNormalizedNPX"]],
        .default = .data[["NPX"]]
      )
    ) |>
    dplyr::mutate(
      SampleID = paste(.data[["SampleID"]], .data[["Project"]], sep = "_")
    ) |>
    dplyr::mutate(
      OlinkID = dplyr::if_else(
        .data[["BridgingRecommendation"]] != "NotBridgeable",
        paste(.data[["OlinkID"]], .data[["OlinkID_E3072"]], sep = "_"),
        .data[["OlinkID_E3072"]]
      )
    ) |>
    dplyr::select(
      -dplyr::all_of(
        c("OlinkID_E3072", "MedianCenteredNPX", "QSNormalizedNPX")
      )
    ) |>
    kableExtra::kbl(
      booktabs = TRUE,
      digits = 1L,
      caption = paste("Table 5. First 5 rows of combined datasets after",
                      "bridging with between-product formatting argument set",
                      "to TRUE.")
    ) |>
    kableExtra::kable_styling(
      bootstrap_options = "striped",
      full_width = FALSE,
      font_size = 10,
      position = "center",
      latex_options = "HOLD_position"
    ) |>
    kableExtra::scroll_box(
      width = "100%"
    )
)

## ----include = FALSE----------------------------------------------------------
f8 <- paste("Combined PCA of sample controls from both platforms prior to",
            "normalization.")
f9 <- paste("Combined PCA of bridging samples from both platforms prior to",
            "normalization.")
f10 <- paste("Combined PCA of sample controls from both platforms after",
             "normalization.")
f11 <- paste("Combined PCA of bridging samples from both platforms after",
             "normalization.")

## ----eval = FALSE, echo = TRUE------------------------------------------------
# # Prepare data for PCA plots - pre-bridging
# 
# npx_pre_data <- data_eht_clean |>
#   dplyr::mutate(
#     Project = "Explore HT"
#   ) |>
#   dplyr::bind_rows(
#     data_e3072_clean |>
#       dplyr::mutate(
#         Project = "Explore 3072"
#       )
#   )
# 
# check_log_pre_data <- OlinkAnalyze::check_npx(
#   df = npx_pre_data
# )
# 
# # no need to clean data set `npx_pre_data`
# # ```

## ----pca_pre_sc, eval = FALSE, echo = TRUE------------------------------------
# # Generate pre-bridging PCA using Sample Control samples
# 
# npx_pre_data |>
#   dplyr::filter(.data[["SampleType"]] == "SAMPLE_CONTROL") |>
#   dplyr::mutate(
#     SampleID = paste(.data[["Project"]], .data[["SampleID"]], sep = "_")
#   ) |>
#   OlinkAnalyze::olink_pca_plot(
#     check_log = check_log_pre_data,
#     color_g = "Project",
#   )

## ----pca_pre_sc_fig, eval = TRUE, echo = FALSE, fig.cap = f8, message = FALSE----
# Generate pre-bridging PCA using Sample Control samples
knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/SCs_pre_bridging.png"
  ),
  error = FALSE
)

## ----pca_pre_bridge, eval = FALSE, echo = TRUE--------------------------------
# # Generate pre-bridging PCA using bridging sample
# 
# npx_pre_data |>
#   dplyr::filter(
#     .data[["SampleType"]] == "SAMPLE"
#   ) |>
#   dplyr::filter(
#     .data[["SampleID"]] %in% .env[["overlapping_samples"]]
#   ) |>
#   dplyr::mutate(
#     SampleID = paste(.data[["Project"]], .data[["SampleID"]], sep = "_")
#   ) |>
#   OlinkAnalyze::olink_pca_plot(
#     check_log = check_log_pre_data,
#     color_g = "Project"
#   )

## ----eval = TRUE, echo = FALSE, fig.cap = f9----------------------------------
# Generate pre-bridging PCA using bridging sample

knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/bridges_pre_bridging.png"
  ),
  error = FALSE
)

## ----eval = FALSE, echo = TRUE------------------------------------------------
# ### Format post-bridging data
# 
# ## Keep the data following BridgingRecommendation
# npx_post_br_reco <- npx_br_data_clean |>
#   # Not necessary if olink_normalization() is run with format = TRUE
#   dplyr::filter(
#     .data[["BridgingRecommendation"]] != "NotBridgeable"
#   ) |>
#   dplyr::mutate(
#     NPX = dplyr::case_when(
#       .data[["BridgingRecommendation"]] == "MedianCentering" ~
#         .data[["MedianCenteredNPX"]],
#       .data[["BridgingRecommendation"]] == "QuantileSmoothing" ~
#         .data[["QSNormalizedNPX"]],
#       .default = .data[["NPX"]]
#     )
#   )

## ----pca_post_SC, eval = FALSE, echo = TRUE-----------------------------------
# # Generate PCA plot of post-bridging data from Sample Controls
# 
# npx_post_br_reco |>
#   dplyr::filter(
#     .data[["SampleType"]] == "SAMPLE_CONTROL"
#   ) |>
#   dplyr::mutate(
#     SampleID = paste(.data[["Project"]], .data[["SampleID"]], sep = "_")
#   ) |>
#   OlinkAnalyze::olink_pca_plot(
#     color_g = "Project",
#     check_log = check_log_br_data_clean
#   )

## ----eval = TRUE, echo = FALSE, fig.cap = f10---------------------------------
# Generate PCA plot of post-bridging data from Sample Controls

knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/SCs_post_bridging.png"
  ),
  error = FALSE
)

## ----eval = FALSE, echo = TRUE------------------------------------------------
# # Generate PCA plot of post-bridging data from bridging samples
# 
# npx_post_br_reco |>
#   dplyr::filter(
#     .data[["SampleType"]] == "SAMPLE"
#   ) |>
#   dplyr::filter(
#     .data[["SampleID"]] %in% .env[["overlapping_samples"]]
#   ) |>
#   dplyr::mutate(
#     SampleID = paste0(.data[["Project"]], .data[["SampleID"]])
#   ) |>
#   OlinkAnalyze::olink_pca_plot(
#     color_g = "Project",
#     check_log = check_log_br_data_clean
#   )

## ----echo = FALSE, fig.cap = f11----------------------------------------------
# Generate PCA plot of post-bridging data from bridging samples

knitr::include_graphics(
  path = normalizePath(
    path = "../man/figures/bridges_post_bridging.png"
  ),
  error = FALSE
)

## ----eval = FALSE, echo = TRUE------------------------------------------------
# ### Export normalized data
# 
# # Here we will export the full dataset including internal and external controls
# # to follow Olink Software Export File formatting, but the data can be filtered
# # to include only samples and assays of interest prior to export.
# df <- npx_br_data |>
#   dplyr::filter(
#     .data[["Project"]] == "Explore_3072"
#   ) |>
#   arrow::as_arrow_table()
# 
# df$metadata$FileVersion <- "NA"
# df$metadata$ExploreVersion <- "NA"
# df$metadata$ProjectName <- "NA"
# df$metadata$SampleMatrix <- "NA"
# df$metadata$DataFileType <- "R Package Export File"
# df$metadata$ProductType <- "Explore3072"
# df$metadata$Product <- "Explore3072"
# 
# arrow::write_parquet(
#   x = df,
#   sink = "path_to_output.parquet"
# )

## ----eval = FALSE, echo = TRUE------------------------------------------------
# ### npx_post_br_clean generated by olink_normalization with format = TRUE
# 
# ## Option 1: Exclude non-bridgeable assays from both products
# npx_recommended <- npx_br_data_clean |>
#   dplyr::filter(
#     .data[["BridgingRecommendation"]] != "NotBridgeable"
#   )
# 
# ## Option 2: Analyze non-bridgeable assays separately
# # No further preprocessing needed
# npx_recommended <- npx_br_data_clean

## ----eval = FALSE, echo = TRUE------------------------------------------------
# ### npx_post_br_clean generated by olink_normalization with format = FALSE
# 
# ## Option 1: Exclude non-bridgeable assays from both products
# npx_recommended <- npx_br_data_clean |>
#   dplyr::mutate(
#     NPX_original = .data[["NPX"]]
#   ) |>
#   dplyr::filter(
#     .data[["BridgingRecommendation"]] != "Not Bridgeable"
#   ) |>
#   dplyr::mutate(NPX = dplyr::case_when(
#     .data[["BridgingRecommendation"]] == "MedianCentering" ~
#       .data[["MedianCenteredNPX"]],
#     .data[["BridgingRecommendation"]] == "QuantileSmoothing" ~
#       .data[["QSNormalizedNPX"]],
#     .default = .data[["NPX"]]
#   )
#   ) |>
#   dplyr::mutate(
#     OlinkID_HT = .data[["OlinkID"]]
#   ) |>
#   dplyr::mutate(
#     OlinkID = paste0(.data[["OlinkID"]], "_", .data[["OlinkID_E3072"]])
#   )
# 
# # Option 2: Analyze non bridgeable assays separately
# npx_recommended <- npx_br_data_clean |>
#   dplyr::mutate(
#     NPX_original = .data[["NPX"]]
#   ) |>
#   dplyr::mutate(
#     NPX = dplyr::case_when(
#       .data[["BridgingRecommendation"]] == "MedianCentering" ~
#         .data[["MedianCenteredNPX"]],
#       .data[["BridgingRecommendation"]] == "QuantileSmoothing" ~
#         .data[["QSNormalizedNPX"]],
#       .default = .data[["NPX"]]
#     )
#   ) |>
#   dplyr::mutate(
#     OlinkID_HT = .data[["OlinkID"]]
#   ) |>
#   dplyr::mutate(
#     OlinkID = dplyr::if_else(
#       .data[["BridgingRecommendation"]] != "NotBridgeable",
#       paste0(.data[["OlinkID"]], "_", .data[["OlinkID_E3072"]]),
#       # Concatenated OlinkID for bridgeable Assays
#       dplyr::if_else(.data[["Project"]] == "Explore HT",
#                      # replace with reference project name as set in function
#                      .data[["OlinkID"]],
#                      .data[["OlinkID_E3072"]]
#       )
#     )
#   )

