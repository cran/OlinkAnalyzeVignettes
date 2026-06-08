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

## ----echo = FALSE-------------------------------------------------------------
set.seed(1234)

# Load example dataset (npx_data1)
npx_data1 <- OlinkAnalyze::npx_data1

# NPX file preprocessing
## Generate check log
check_log_npx_data1 <- OlinkAnalyze::check_npx(
  df = npx_data1
)

## Clean NPX
npx_data1_clean <- OlinkAnalyze::clean_npx(
  df = npx_data1,
  check_log = check_log_npx_data1
)

## Generate check log on cleaned data
check_log_npx_data1_clean <- OlinkAnalyze::check_npx(
  df = npx_data1_clean
)

table1 <- npx_data1_clean |>
  dplyr::slice_head(
    n = 6L
  ) |>
  dplyr::select(
    -dplyr::all_of(
      c("Index", "MissingFreq", "Panel_Version", "QC_Warning", "Subject",
        "Treatment", "Site", "Time", "Project", "Panel", "PlateID")
    )
  ) |>
  dplyr::mutate(
    Count = round(
      x = .data[["NPX"]] * (100L + sample(x = seq(from = -5L, to = 15L),
                                          size = 1L))
    )
  ) |>
  dplyr::mutate(
    SampleType = "SAMPLE"
  ) |>
  dplyr::mutate(
    Normalization = "Plate control"
  ) |>
  dplyr::mutate(
    NPX = round(x = .data[["NPX"]], digits = 2L)
  ) |>
  dplyr::mutate(
    LOD = round(x = .data[["LOD"]], digits = 2L)
  ) |>
  dplyr::mutate(
    PCNormalizedNPX = .data[["NPX"]]
  ) |>
  dplyr::mutate(
    PCNormalizedLOD = .data[["LOD"]]
  ) |>
  dplyr::select(
    dplyr::all_of(
      c("SampleID", "SampleType", "OlinkID", "UniProt", "Assay", "Count", "NPX",
        "PCNormalizedNPX", "Normalization", "LOD", "PCNormalizedLOD")
    )
  )

table1 |>
  knitr::kable(
    caption = "Example results from Plate Control Normalized Project"
  ) |>
  kableExtra::kable_styling(
    font_size = 10L
  )

table1 |>
  dplyr::mutate(
    Normalization = "Intensity"
  ) |>
  dplyr::mutate(
    NPX = round(x = .data[["NPX"]] + 4.16, digits = 2L)
  ) |>
  dplyr::mutate(
    LOD = round(x = .data[["LOD"]] + 4.16, digits = 2L)
  ) |>
  dplyr::select(
    dplyr::all_of(
      c("SampleID", "SampleType", "OlinkID", "UniProt", "Assay", "Count", "NPX",
        "PCNormalizedNPX", "Normalization", "LOD", "PCNormalizedLOD")
    )
  ) |>
  knitr::kable(
    caption = "Example results from Intensity Normalized Project"
  ) |>
  kableExtra::kable_styling(
    font_size = 10
  )

## ----npx_data_for_lod, eval = FALSE, message = FALSE, warning = FALSE---------
# # Preprocessing steps for both fixed LOD and Negative Control LOD integration
# 
# ## Load NPX file
# df_npx <- OlinkAnalyze::read_NPX(
#   filename = "Path_to/Explore_NPX_file.parquet"
# )
# 
# ## Check NPX data
# check_log_df_npx <- OlinkAnalyze::check_npx(
#   df = df_npx
# )
# 
# ## Clean NPX data
# df_npx_clean <- OlinkAnalyze::clean_npx(
#   df = df_npx,
#   check_log = check_log_df_npx,
#   # do not remove controls or warnings to ensure LOD can be calculated correctly
#   remove_control_assay = FALSE,
#   remove_control_sample = FALSE,
#   remove_assay_warning = FALSE,
#   remove_qc_warning = FALSE
# )
# 
# ## Generate check log on cleaned data
# check_log_df_npx_clean <- OlinkAnalyze::check_npx(
#   df = df_npx_clean
# )
# 
# # Cleanup intermediate objects
# rm(
#   df_npx,
#   check_log_df_npx
# )

## ----NCLOD_example, eval = FALSE, message = FALSE, warning = FALSE------------
# # Calculate LOD from negative controls
# 
# ## Calculate LOD
# df_npx_nc_lod <- OlinkAnalyze::olink_lod(
#   data = df_npx_clean,
#   lod_method = "NCLOD",
#   check_log = check_log_df_npx_clean
# )
# 
# ## Generate check log on data with LOD
# check_log_df_npx_nc_lod <- OlinkAnalyze::check_npx(
#   df = df_npx_nc_lod
# )
# 
# ## Clean NPX data with LOD
# df_npx_nc_lod_clean <- OlinkAnalyze::clean_npx(
#   df = df_npx_nc_lod,
#   check_log = check_log_df_npx_nc_lod
# )
# 
# ## Generate check log on cleaned data with LOD
# check_log_df_npx_nc_lod_clean <- OlinkAnalyze::check_npx(
#   df = df_npx_nc_lod_clean
# )
# 
# # Cleanup intermediate objects
# rm(
#   df_npx_nc_lod,
#   check_log_df_npx_nc_lod
# )
# 
# # Rename final cleaned data with LOD for clarity
# df_npx_nc_lod <- df_npx_nc_lod_clean
# check_log_df_npx_nc_lod <- check_log_df_npx_nc_lod_clean
# rm(
#   df_npx_nc_lod_clean,
#   check_log_df_npx_nc_lod_clean
# )

## ----FixedLOD, eval = FALSE, message = FALSE, warning = FALSE-----------------
# # Integrating fixed LOD
# 
# ## Fixed LOD file path
# fixedlod_filepath <- "Path_to/ExploreHT_fixedLOD.csv"
# 
# ## Calculate LOD
# df_npx_fixed_lod <- OlinkAnalyze::olink_lod(
#   data = df_npx_clean,
#   lod_method = "FixedLOD",
#   lod_file_path = fixedlod_filepath,
#   check_log = check_log_df_npx_clean
# )
# 
# ## Generate check log on data with LOD
# check_log_df_npx_fixed_lod <- OlinkAnalyze::check_npx(
#   df = df_npx_fixed_lod
# )
# 
# ## Clean NPX data with LOD
# df_npx_fixed_lod_clean <- OlinkAnalyze::clean_npx(
#   df = df_npx_fixed_lod,
#   check_log = check_log_df_npx_fixed_lod
# )
# 
# ## Generate check log on cleaned data with LOD
# check_log_npx_fixed_lod_clean <- OlinkAnalyze::check_npx(
#   df = df_npx_fixed_lod_clean
# )
# 
# # Cleanup intermediate objects
# rm(
#   df_npx_fixed_lod,
#   check_log_df_npx_fixed_lod
# )
# 
# # Rename final cleaned data with LOD for clarity
# df_npx_fixed_lod <- df_npx_fixed_lod_clean
# check_log_df_npx_fixed_lod <- check_log_npx_fixed_lod_clean
# rm(
#   df_npx_fixed_lod_clean,
#   check_log_npx_fixed_lod_clean
# )

## ----echo = FALSE-------------------------------------------------------------
table1 |>
  dplyr::mutate(
    Normalization = "Intensity"
  ) |>
  dplyr::mutate(
    PCNormalizedNPX = round(x = .data[["NPX"]], digits = 2L)
  ) |>
  dplyr::mutate(
    PCNormalizedLOD = round(x = .data[["LOD"]], digits = 2L)
  ) |>
  dplyr::mutate(
    NPX = round(.data[["NPX"]] + 4.16, digits = 2L)
  ) |>
  dplyr::mutate(
    LOD = round(.data[["LOD"]] + 4.16, digits = 2L)
  ) |>
  dplyr::rename(
    "FixedLOD" = "LOD",
    "FixedPCNormalizedLOD" = "PCNormalizedLOD"
  ) |>
  dplyr::mutate(
    NCLOD = .data[["FixedLOD"]] - 2.34,
    NCPCNormalizedLOD = .data[["FixedPCNormalizedLOD"]] - 2.34
  ) |>
  dplyr::select(
    dplyr::all_of(
      c("SampleID", "SampleType", "OlinkID", "UniProt", "Assay", "Count", "NPX",
        "Normalization", "PCNormalizedNPX", "FixedLOD", "FixedPCNormalizedLOD",
        "NCLOD", "NCPCNormalizedLOD")
    )
  ) |>
  knitr::kable(
    caption = "Example results using both LOD calculation methods"
  ) |>
  kableExtra::kable_styling(
    font_size = 10L
  )

## ----explore_npx_export, eval = FALSE, message = FALSE, warning = FALSE-------
# # Exporting Olink NGS data with LOD information as a parquet file
# 
# ## Integrate both Negative Control LOD and fixed LOD before NPX preprocessing
# df_npx_both_lod <- OlinkAnalyze::olink_lod(
#   data = df_npx_clean,
#   lod_file_path = fixedlod_filepath,
#   lod_method = "Both",
#   check_log = check_log_df_npx_clean
# )
# 
# ## Generate check log
# check_log_df_npx_both_lod <- OlinkAnalyze::check_npx(
#   df = df_npx_both_lod
# )
# 
# ## Clean NPX
# df_npx_both_lod_clean <- OlinkAnalyze::clean_npx(
#   df = df_npx_both_lod,
#   check_log = check_log_df_npx_both_lod
# )
# 
# ## Generate check log on cleaned data
# check_log_npx_both_lod_clean <- OlinkAnalyze::check_npx(
#   df = df_npx_both_lod_clean
# )
# 
# # Cleanup intermediate objects
# rm(
#   df_npx_both_lod,
#   check_log_df_npx_both_lod
# )
# 
# # Rename final cleaned data with both LOD for clarity
# df_npx_both_lod <- df_npx_both_lod_clean
# check_log_df_npx_both_lod <- check_log_npx_both_lod_clean
# rm(
#   df_npx_both_lod_clean,
#   check_log_npx_both_lod_clean
# )
# 
# # Add metadata for export
# df_npx_both_lod_arrow <- df_npx_both_lod |>
#   arrow::as_arrow_table()
# 
# df_npx_both_lod_arrow$metadata$FileVersion <- "NA"
# df_npx_both_lod_arrow$metadata$ExploreVersion <- "NA"
# df_npx_both_lod_arrow$metadata$ProjectName <- "NA"
# df_npx_both_lod_arrow$metadata$SampleMatrix <- "NA"
# df_npx_both_lod_arrow$metadata$DataFileType <- "Olink Analyze Export File"
# # One of "ExploreHT", "Explore3072", or "Reveal"
# df_npx_both_lod_arrow$metadata$ProductType <- "ExploreHT"
# # # "ExploreHT", "Explore3072", or "Reveal"
# df_npx_both_lod_arrow$metadata$Product <- "ExploreHT"
# 
# arrow::write_parquet(
#   x = df_npx_both_lod_arrow,
#   sink = "path_to_output.parquet"
# )

