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

## ----brnrtab, message = FALSE, echo = FALSE-----------------------------------
dplyr::tibble(
  "Olink Product" = c(
    "Target 96",
    "Explore 384: Cardiometabolic, Inflammation, Neurology, and Oncology",
    paste(
      "Explore 384: Cardiometabolic II, Inflammation II, Neurology II,",
          "and Oncology II"
      ),
    "Explore 3072",
    "Explore HT",
    "Reveal",
    "Explore 3072 to Explore HT",
    "Explore 3072 to Reveal"
  ),
  "Number of Bridge Samples" = c(
    "8-16",
    "8-16",
    "16-24",
    "16-24",
    "16-32",
    "16-24",
    "40-64",
    "32-48"
  )
) |>
  kableExtra::kbl(
    booktabs = TRUE,
    digits = 2L,
    caption =
      paste(
        "Table 1. Recommended number of bridge samples for Olink products."
        )
  ) |>
  kableExtra::kable_styling(
    bootstrap_options = "striped",
    full_width = FALSE,
    position = "center",
    latex_options = "HOLD_position"
  )

## ----preprocessing, eval = TRUE-----------------------------------------------
# Load example dataset (npx_data1)
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

## ----bridge_sample_selection_example, echo = TRUE, eval = TRUE----------------
# Using the already cleaned data from `clean_npx()`
bridge_samples <- OlinkAnalyze::olink_bridge_selector(
  df = npx_data1_clean,
  sample_missing_freq = 0.1,
  n = 16L,
  check_log = check_log_npx_data1_clean
)

# Excluding control samples manually. Naming convention may differ.
bridge_samples_manual <- npx_data1 |>
  dplyr::filter(
    stringr::str_detect(
      string = .data[["SampleID"]],
      pattern = "CONTROL",
      negate = TRUE
    )
  ) |>
  # In this case we skip the argument `check_log`. When `check_log` is not
  # provided, the function will run it internally to check for other
  # inconsistencies in the data such as duplicate sample IDs.
  OlinkAnalyze::olink_bridge_selector(
    sample_missing_freq = 0.1,
    n = 16L
  )

## ----bridge_sample_selection, echo = FALSE------------------------------------
bridge_samples |>
  kableExtra::kbl(
    booktabs = TRUE,
    digits = 2L,
    caption = "Table 2. Selected bridge samples."
  ) |>
  kableExtra::kable_styling(
    bootstrap_options = "striped",
    full_width = FALSE,
    position = "center",
    latex_options = "HOLD_position"
  )

## ----captions, echo = FALSE---------------------------------------------------
f1 <- paste("Figure 1. PCA plot of bridge samples and other samples in",
            "dataset `npx_data1` (control samples excluded).")

f2 <- paste("Figure 2. Density plot of NPX distribution in both datasets",
            "before bridging.")

f3 <- paste("Figure 3. PCA plot of both datasets before bridging.")

f4 <- paste("Figure 4. Density plot of NPX distribution in both datasets after",
            "bridging.")

f5 <- paste("Figure 5. Histogram of adjustment factors in normalized data from",
             "dataset `npx_data2`.")

f6 <- paste("Figure 6. Violin plot of CHL1 in both datasets prior to bridging.",
            "Bridge samples are indicated by black points.")

f7 <- paste("Figure 7. Density plot of inter-project CV before and after",
            "bridging.")

f8 <- paste("Figure 8. PCA plot of both datasets after bridging.")

## ----bridge_sample_selection_example_pca, echo = TRUE, eval = TRUE, fig.cap = f1----
npx_data1_clean |>
  dplyr::mutate(
    Bridge = dplyr::if_else(
      .data[["SampleID"]] %in% bridge_samples[["SampleID"]],
      "Bridge",
      "Sample"
    )
  ) |>
  OlinkAnalyze::olink_pca_plot(
    color_g = "Bridge",
    check_log = check_log_npx_data1_clean
  )

## ----message = FALSE, eval = FALSE, echo = TRUE-------------------------------
# npx_data1 <- OlinkAnalyze::read_NPX(
#   filename = "~/NPX_file1_location.xlsx"
# )
# npx_data2 <- OlinkAnalyze::read_NPX(
#   filename = "~/NPX_file2_location.xlsx"
# )

## ----data_uniq_sid, eval = TRUE, echo = TRUE----------------------------------
# Load example dataset (npx_data1)
npx_data1 <- npx_data1 |>
  # create unique extension as suffix for control samples
  dplyr::mutate(
    sid_ext = stringr::str_remove(
      string = .data[["PlateID"]],
      pattern = ".csv"
    ),
    sid_ext = paste0(
      stringr::str_split_i(.data[["sid_ext"]], "_", 4L),
      stringr::str_split_i(.data[["sid_ext"]], "_", 3L)
    ),
  ) |>
  # rename SampleIDs for control samples
  dplyr::mutate(
    SampleID = dplyr::if_else(
      stringr::str_detect(
        string = .data[["SampleID"]],
        pattern = "CONTROL"
      ),
      paste0(.data[["SampleID"]], "_", .data[["sid_ext"]]),
      .data[["SampleID"]]
    )
  ) |>
  dplyr::select(
    -dplyr::all_of("sid_ext")
  )

# Load example dataset (npx_data2)
npx_data2 <- OlinkAnalyze::npx_data2 |>
  # create unique extension as suffix for control samples
  dplyr::mutate(
    sid_ext = stringr::str_remove(
      string = .data[["PlateID"]],
      pattern = ".csv"
    ),
    sid_ext = paste0(
      stringr::str_split_i(.data[["sid_ext"]], "_", 5L),
      stringr::str_split_i(.data[["sid_ext"]], "_", 4L)
    ),
  ) |>
  # rename SampleIDs for control samples
  dplyr::mutate(
    SampleID = dplyr::if_else(
      stringr::str_detect(
        string = .data[["SampleID"]],
        pattern = "CONTROL"
      ),
      paste0(.data[["SampleID"]], "_", .data[["sid_ext"]]),
      .data[["SampleID"]]
    )
  ) |>
  dplyr::select(
    -dplyr::all_of("sid_ext")
  )

## ----preprocessing2, eval = TRUE----------------------------------------------
# NPX file preprocessing - npx_data1
# Generate check log
check_log_npx_data1 <- OlinkAnalyze::check_npx(
  df = npx_data1
)

# Clean NPX
npx_data1_clean <- OlinkAnalyze::clean_npx(
  df = npx_data1,
  # Retain control samples and assays
  remove_control_assay = FALSE,
  remove_control_sample = FALSE,
  # Retain assay and QC warnings
  remove_assay_warning = FALSE,
  remove_qc_warning = FALSE,
  check_log = check_log_npx_data1
)

# Generate check log on cleaned data
check_log_npx_data1_clean <- OlinkAnalyze::check_npx(
  df = npx_data1_clean
)

# cleanup intermediate variables
rm(
  npx_data1,
  check_log_npx_data1
)

# NPX file preprocessing - npx_data2
# Generate check log
check_log_npx_data2 <- OlinkAnalyze::check_npx(
  df = npx_data2
)

# Clean NPX
npx_data2_clean <- OlinkAnalyze::clean_npx(
  df = npx_data2,
  # Retain control samples and assays
  remove_control_assay = FALSE,
  remove_control_sample = FALSE,
  # Retain assay and QC warnings
  remove_assay_warning = FALSE,
  remove_qc_warning = FALSE,
  check_log = check_log_npx_data2
)

# Generate check log on cleaned data
check_log_npx_data2_clean <- OlinkAnalyze::check_npx(
  df = npx_data2_clean
)

# cleanup intermediate variables
rm(
  npx_data2,
  check_log_npx_data2
)

## ----eval = TRUE--------------------------------------------------------------
overlapping_samples <- dplyr::tibble(
  SampleID = intersect(
    x = npx_data1_clean[["SampleID"]],
    y = npx_data2_clean[["SampleID"]]
  )
) |>
  dplyr::filter(
    stringr::str_detect(
      string = .data[["SampleID"]],
      pattern = "CONTROL",
      negate = TRUE
    )
  ) |>
  dplyr::pull(
    .data[["SampleID"]]
  )

## ----echo = FALSE-------------------------------------------------------------
overlapping_samples |>
  kableExtra::kbl(
    col.names = "SampleID",
    booktabs = TRUE,
    digits = 2L,
    align = "c",
    caption = "Table 3. Overlapping Bridge Samples."
  ) |>
kableExtra::column_spec(
    1, width = "7cm"
  ) |>
  kableExtra::kable_styling(
    bootstrap_options = "striped",
    full_width = FALSE,
    position = "center",
    latex_options = "HOLD_position"
  )

## ----check, message = FALSE, fig.cap = f2-------------------------------------
# Expand the datasets to contain the Project column
npx_1 <- npx_data1_clean |>
  dplyr::mutate(
    Project = "data1"
  )
npx_2 <- npx_data2_clean |>
  dplyr::mutate(
    Project = "data2"
  )

# Combine the two data sets for visualization
npx_df <- dplyr::bind_rows(
  npx_1,
  npx_2
)

# Filter out control samples to avoid skewing the distribution
# and affecting downstream PCA results.
npx_df_no_ctrl <- npx_df |>
  dplyr::filter(
    stringr::str_detect(
      string = .data[["SampleID"]],
      pattern = "CONTROL_SAMPLE",
      negate = TRUE
    )
  ) |>
  # Mark bridge samples
  dplyr::mutate(
    Type = dplyr::if_else(
      .data[["SampleID"]] %in% .env[["overlapping_samples"]],
      paste(Project, "Bridge"),
      paste(Project, "Sample")
      )
    ) |>
  # Ensure that SampleIDs are unique across projects for downstream functions.
  dplyr::mutate(
    SampleID = paste0(.data[["SampleID"]],
                      .data[["Project"]])
  )

# Generate check log
check_log_npx_df_no_ctrl <- OlinkAnalyze::check_npx(
  df = npx_df_no_ctrl
  )

# Plot NPX density before bridging
npx_df_no_ctrl |>
  ggplot2::ggplot(
    mapping = ggplot2::aes(
      x = .data[["NPX"]],
      fill = .data[["Project"]]
    )
  ) +
  ggplot2::geom_density(
    alpha = 0.4
  ) +
  ggplot2::facet_grid(
    cols = ggplot2::vars(.data[["Panel"]])
  ) +
  OlinkAnalyze::olink_fill_discrete(
    coloroption = c("red", "darkblue")
  ) +
  OlinkAnalyze::set_plot_theme() +
  ggplot2::ggtitle(
    label = "Before bridging: NPX distribution"
  ) +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    strip.text = ggplot2::element_text(size = 16L),
    legend.title = ggplot2::element_blank(),
    legend.position = "top"
  )

## ----pca1, message = FALSE, fig.cap = f3--------------------------------------
if (requireNamespace(package = "ggpubr", quietly = TRUE)) {
  # PCA plot
  OlinkAnalyze::olink_pca_plot(
    df = npx_df_no_ctrl,
    color_g = "Type",
    byPanel = TRUE,
    check_log = check_log_npx_df_no_ctrl
  )
}

## ----bridging, message = FALSE------------------------------------------------
overlapping_samples_list <- list(
  "DF1" = overlapping_samples,
  "DF2" = overlapping_samples
)

# Perform bridging
npx_df_br <- OlinkAnalyze::olink_normalization_bridge(
  project_1_df = npx_data1_clean,
  project_2_df = npx_data2_clean,
  bridge_samples = overlapping_samples_list,
  project_1_name = "data1",
  project_2_name = "data2",
  project_ref_name = "data1",
  project_1_check_log = check_log_npx_data1_clean,
  project_2_check_log = check_log_npx_data2_clean
)

# generate check log on bridged data
check_log_npx_df_br <- OlinkAnalyze::check_npx(
  df = npx_df_br
)

## ----norm_data_table, echo = FALSE--------------------------------------------
npx_df_br |>
  dplyr::slice_head(
    n = 10L
  ) |>
  kableExtra::kbl(
    booktabs = TRUE,
    digits = 1L,
    caption = "Table 4. First 10 rows of the normalized dataset after bridging."
  ) |>
  kableExtra::kable_styling(
    bootstrap_options = "striped",
    full_width = FALSE,
    font_size = 10L,
    position = "center",
    latex_options = "HOLD_position"
  ) |>
  kableExtra::scroll_box(
    width = "100%"
  )

## ----echo = TRUE, eval = FALSE------------------------------------------------
# overlapping_samples_list <- list(
#   "DF1" = c("A1", "A2", "A3", "Sample_1_Aliquot_1"),
#   "DF2" = c("A1", "A2", "A3", "Sample_1_Aliquot_2")
# )

## ----densitybr, message = FALSE, fig.cap = f4---------------------------------
# Filter out control samples to avoid skewing the distribution
# and affecting downstream PCA results.
npx_df_br_no_ctrl <- npx_df_br |>
  # Remove control samples
  dplyr::filter(
    stringr::str_detect(
      string = .data[["SampleID"]],
      pattern = "CONTROL_SAMPLE",
      negate = TRUE
    )
  ) |>
  # Mark bridge samples
  dplyr::mutate(
    Type = dplyr::if_else(
      .data[["SampleID"]] %in% .env[["overlapping_samples"]],
      paste(.data[["Project"]], "Bridge"),
      paste(.data[["Project"]], "Sample")
    )
  ) |>
  dplyr::mutate(
    SampleID = paste0(.data[["SampleID"]],
                      .data[["Project"]])
  )

# Generate check log
check_log_npx_df_br_no_ctrl <- OlinkAnalyze::check_npx(
  df = npx_df_br_no_ctrl
  )

# Plot NPX density after bridging
npx_df_br_no_ctrl |>
  dplyr::mutate(
    Panel = gsub(
      pattern = "Olink ",
      replacement = "", x = .data[["Panel"]]
    )
  ) |>
  ggplot2::ggplot(
    mapping = ggplot2::aes(
      x = .data[["NPX"]],
      fill = .data[["Project"]]
    )
  ) +
  ggplot2::geom_density(
    alpha = 0.4
  ) +
  ggplot2::facet_grid(
    cols = ggplot2::vars(.data[["Panel"]])
  ) +
  OlinkAnalyze::olink_fill_discrete(
    coloroption = c("red", "darkblue")
  ) +
  OlinkAnalyze::set_plot_theme() +
  ggplot2::ggtitle(
    label = "After bridging: NPX distribution"
  ) +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    strip.text = ggplot2::element_text(size = 16L),
    legend.title = ggplot2::element_blank(),
    legend.position = "top"
  )

## ----dist_adj_fct, message = FALSE, echo = FALSE, fig.cap = f5----------------
npx_df_br |>
  # Only looking at Project 2 since project 1 is unadjusted
  dplyr::filter(
    .data[["Project"]] == "data2"
  ) |>
  dplyr::select(
    dplyr::all_of(
      c("OlinkID", "Adj_factor")
    )
  ) |>
  dplyr::distinct() |>
  ggplot2::ggplot(
    mapping = ggplot2::aes(
      x = .data[["Adj_factor"]]
    )
  ) +
  ggplot2::geom_histogram() +
  OlinkAnalyze::set_plot_theme()

## ----violin_plot, fig.cap = f6------------------------------------------------
# Bridge sample data
bridge_samples <- npx_df |>
  dplyr::filter(
    .data[["SampleID"]] %in% .env[["overlapping_samples"]]
  ) |>
  dplyr::filter(
    .data[["Assay"]] == "CHL1"
  ) |>
  dplyr::mutate(
    Assay_OID = paste(.data[["Assay"]], .data[["OlinkID"]], sep = "\n")
  )

# Generate violin plot for CHL1
npx_df_no_ctrl |>
  dplyr::filter(
    .data[["Assay"]] == "CHL1"
  ) |>
  dplyr::mutate(
    Assay_OID = paste(.data[["Assay"]], .data[["OlinkID"]], sep = "\n")
  ) |>
  ggplot2::ggplot(
    mapping = ggplot2::aes(
      x = .data[["Project"]],
      y = .data[["NPX"]]
    )
  ) +
  ggplot2::geom_violin(
    mapping = ggplot2::aes(
      fill = .data[["Project"]]
    )
  ) +
  ggplot2::geom_point(
    data = bridge_samples,
    position = ggplot2::position_jitter(
      width = 0.1
    )
  ) +
  ggplot2::theme(
    legend.position = "none"
  ) +
  OlinkAnalyze::set_plot_theme() +
  ggplot2::facet_wrap(
    facets = ggplot2::vars(.data[["Assay_OID"]]),
    nrow = 1L,
    ncol = 1L
  )

## ----CV_calculation, fig.cap = f7---------------------------------------------
# Olink NGS products CV calculation formula
ngs_cv <- function(npx, na_rm = FALSE) {
  sqrt(exp((log(2) * sd(npx, na.rm = na_rm)) ^ 2) - 1) * 100
}

# Olink qPCR products CV calculation formula
qpcr_cv <- function(npx, na_rm = TRUE) {
  100 * sd(2 ^ npx) / mean(2 ^ npx)
}

tech <- "qPCR"

# Calculate CV for control samples across projects before bridging
cv_before <- npx_df |>
  dplyr::filter(
    stringr::str_detect(
      string = .data[["SampleID"]],
      pattern = "CONTROL*."
    )
  ) |>
  dplyr::filter(
    .data[["NPX"]] > .data[["LOD"]]
  ) |>
  dplyr::group_by(
    .data[["OlinkID"]]
  ) |>
  dplyr::mutate(
    CV = dplyr::if_else(
      .env[["tech"]] == "NGS",
      ngs_cv(npx = .data[["NPX"]]),
      qpcr_cv(npx = .data[["NPX"]])
    )
  ) |>
  dplyr::ungroup() |>
  dplyr::distinct(
    .data[["OlinkID"]], .data[["CV"]]
  )

# Calculate CV for control samples across projects after bridging
cv_after <- npx_df_br |>
  dplyr::filter(
    stringr::str_detect(
      string = .data[["SampleID"]],
      pattern = "CONTROL*."
    )
  ) |>
  dplyr::filter(
    .data[["NPX"]] > .data[["LOD"]]
  ) |>
  dplyr::group_by(
    .data[["OlinkID"]]
  ) |>
  dplyr::mutate(
    CV = dplyr::if_else(
      .env[["tech"]] == "NGS",
      ngs_cv(npx = .data[["NPX"]]),
      qpcr_cv(npx = .data[["NPX"]])
    )
  ) |>
  dplyr::ungroup() |>
  dplyr::distinct(
    .data[["OlinkID"]], .data[["CV"]]
  )

# Plot distribution of CV before and after bridging
cv_before |>
  dplyr::mutate(
    Analysis = "Before"
  ) |>
  dplyr::bind_rows(
    cv_after |>
       dplyr::mutate(
         Analysis = "After"
        )
  ) |>
  ggplot2::ggplot(
    mapping = ggplot2::aes(
      x = .data[["CV"]],
      fill = .data[["Analysis"]]
      )
    ) +
  ggplot2::geom_density(
    alpha = 0.7
    ) +
  OlinkAnalyze::set_plot_theme() +
  OlinkAnalyze::olink_fill_discrete() +
  ggplot2::theme(
    text = ggplot2::element_text(
      size = 20L
      )
  ) +
  ggplot2::xlim(-50L, 400L)

## ----pca2, message = FALSE, fig.cap = f8--------------------------------------
if (requireNamespace(package = "ggpubr", quietly = TRUE)) {
  # PCA plot
  OlinkAnalyze::olink_pca_plot(
    df = npx_df_br_no_ctrl,
    color_g = "Type",
    byPanel = TRUE,
    check_log = check_log_npx_df_br_no_ctrl
  )
}

## ----eval = FALSE-------------------------------------------------------------
# npx_df_br |>
#   dplyr::filter(
#     .data[["Project"]] == "data2"
#   ) |>
#   dplyr::select(
#     -dplyr::all_of(
#       c("Project", "Adj_factor")
#     )
#   ) |>
#   write.table(
#     file = "New_Normalized_NPX_data.csv",
#     sep = ";"
#   )

