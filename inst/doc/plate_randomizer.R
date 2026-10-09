## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(warning = FALSE,
                      fig.height = 6,
                      fig.width = 6,
                      message = FALSE)

## ----manifest, echo = FALSE, message = FALSE----------------------------------
OlinkAnalyze::manifest |>
  dplyr::slice_head(
    n = 10L
  ) |>
  knitr::kable(
    format = "html",
    booktabs = TRUE,
    linesep = "",
    digits = 4L,
    longtable = TRUE,
    row.names = FALSE,
    caption = "Table 1. Example of Sample manifest",
    label = "manifest"
  )

## ----complete_randomization, message = FALSE, warning = FALSE, results = 'hide'----
randomized_manifest <- OlinkAnalyze::olink_plate_randomizer(
  Manifest = OlinkAnalyze::manifest,
  seed = 123456
)

## ----randomize_subject, message = FALSE, eval = TRUE, echo = TRUE-------------
# Example longitudinal randomization with subjects kept on the same plate.
randomized_manifest_subject <- OlinkAnalyze::olink_plate_randomizer(
  Manifest = OlinkAnalyze::manifest,
  Product = "Explore HT",
  SubjectColumn = "SubjectID",
  num_ctrl = 10L
)

## ----randomize_controls, message = FALSE, eval = FALSE, echo = TRUE-----------
# # Randomize Olink external control samples.
# randomized_manifest_random <- OlinkAnalyze::olink_plate_randomizer(
#   Manifest = OlinkAnalyze::manifest,
#   Product = "Explore HT",
#   SubjectColumn = "SubjectID",
#   num_ctrl = 10L,
#   rand_ctrl = TRUE
# )

## ----randomized_controls_table, echo = FALSE, message = FALSE, warning = FALSE----
randomized_manifest_subject |>
  dplyr::slice_head(
    n = 10L
  ) |>
  knitr::kable(
    format = "html",
    booktabs = TRUE,
    linesep = "",
    digits = 4L,
    longtable = TRUE,
    row.names = FALSE,
    caption = paste0(
      "Table 2. Example of Randomized Sample manifest ",
      "with subjects kept on the same plate."
    ),
    label = "manifest"
  )

## ----subjects_randomization, message = FALSE, results = 'hide'----------------
randomized_manifest_num <- OlinkAnalyze::olink_plate_randomizer(
  Manifest = OlinkAnalyze::manifest,
  SubjectColumn = "SubjectID",
  available.spots = c(48L, 48L, 42L),
  iterations = 500L,
  seed = 123456
)

## -----------------------------------------------------------------------------
randomized_manifest_multi <- OlinkAnalyze::olink_plate_randomizer(
  Manifest = OlinkAnalyze::manifest,
  study = "Site"
)

## ----figure_captions, message = FALSE, echo = FALSE---------------------------
fcap1 <- paste0(
  "Figure 1. Randomized samples in 96 well plate format, ",
  "colored by Subject ID."
)
fcap2 <- paste0(
  "Figure 2. Randomized samples in 96 well plate format ",
  "with labeled wells."
)
fcap3 <- paste0(
  "Figure 3. Randomized samples in a 96-well plate format, ",
  "with the number of samples per plate pre-defined."
)
fcap4 <- paste0(
  "Figure 4. Randomized samples in 96 well plate format, ",
  "colored by Studies."
)
fcap5 <- "Figure 5. Distribution of Subject ID across randomized plates."
fcap6 <- "Figure 6. Distribution of Site across randomized plates."

## ----fig.height = 6, fig.width = 7.5, fig.align = "center", fig.cap = fcap1----
OlinkAnalyze::olink_displayPlateLayout(
  data = randomized_manifest,
  fill.color = "SubjectID",
  include.label = FALSE
)

## ----fig.height = 6, fig.width = 7.5, fig.align = "center", fig.cap = fcap2----
OlinkAnalyze::olink_displayPlateLayout(
  data = randomized_manifest,
  fill.color = "SubjectID",
  include.label = TRUE
)

## ----fig.height = 6, fig.width = 7.5, fig.align = "center", fig.cap = fcap3----
OlinkAnalyze::olink_displayPlateLayout(
  data = randomized_manifest_num,
  fill.color = "SubjectID",
  include.label = FALSE
)

## ----fig.height = 6, fig.width = 7.5, fig.align = "center", fig.cap = fcap4----
OlinkAnalyze::olink_displayPlateLayout(
  data = randomized_manifest_multi,
  fill.color = "Site"
)

## ----fig.align = "center", fig.cap = fcap5------------------------------------
OlinkAnalyze::olink_displayPlateDistributions(
  data = randomized_manifest,
  fill.color = "SubjectID"
)

## ----fig.align = "center", fig.cap= fcap6-------------------------------------
OlinkAnalyze::olink_displayPlateDistributions(
  data = randomized_manifest,
  fill.color = "Site"
)

## ----eval = FALSE-------------------------------------------------------------
# writexl::write_xlsx(
#   x = randomized_manifest,
#   path = "randomized.manifest.xlsx"
# )

