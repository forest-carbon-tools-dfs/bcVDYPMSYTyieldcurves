# bcVDYPMSYTyieldcurves

<!-- badges: start -->
[![R-CMD-check](https://github.com/forest-carbon-tools-dfs/bcVDYPMSYTyieldcurves/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/forest-carbon-tools-dfs/bcVDYPMSYTyieldcurves/actions/workflows/R-CMD-check.yaml)
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Tools for processing British Columbia's Vegetation Resources Inventory (VRI)
data and generating forest yield curves. The package subsets VRI data, matches
polygons to existing **managed stand yield tables (MSYT)**, identifies records
that still require a natural-stand curve, and runs the complete **VDYP7**
workflow (parameter-file creation, execution, and post-processing).

## Requirements

- **R** (>= 4.0.0)
- **VDYP7console** — install separately from the
  [BC Government VDYP page](https://www2.gov.bc.ca/gov/content/industry/forestry/managing-our-forest-resources/forest-inventory/growth-and-yield-modelling/variable-density-yield-projection-vdyp).
  The examples assume it is installed at `C:/VDYP7` with `C:/VDYP7/Input` and
  `C:/VDYP7/Output` sub-folders.

## Data access

This package ships **no data**. You must supply, for a common inventory year:

- **BC VRI geodatabase** — Vegetation Resources Inventory R1 layer, from the
  [BC Data Catalogue](https://catalogue.data.gov.bc.ca/) (public).
- **VDYP7 geodatabase** — VDYP7 input gdb, from the BC Data Catalogue (public).
- **MSYT CSV files** — Managed Stand Yield Tables. These are provided by the
  BC Government and may be access-restricted; obtain them through the
  appropriate BC channel.

## Installation

```r
# install.packages("devtools")
devtools::install_github("forest-carbon-tools-dfs/bcVDYPMSYTyieldcurves")
```

## Quick start

```r
library(bcVDYPMSYTyieldcurves)

# 1. Subset VRI to an area of interest and export a flat CSV
vri_aoi <- create_vri_subset(
  "path/to/vri_R1_layer.gdb",
  layer = "VEG_COMP_LYR_R1_POLY",
  aoi   = c(-124, 59, -123.5, 59.5)
)
write_vri_to_csv(vri_aoi, file.path(tempdir(), "vri_aoi_df.csv"))

# 2. Match VRI polygons to existing MSYT (managed-stand) curves
vri_msyt <- match_vri_to_msyt_curves(
  vri_data            = vri_aoi,
  msyt_curves_path    = "path/to/MSYT_prov_current_input_output.csv",
  msyt_reference_path = "path/to/MSYT_prov_reference.csv",
  output_file         = file.path(tempdir(), "vri_msyt_joined.csv")
)

# 3. Identify polygons that still need a VDYP7 natural-stand curve
vdyp_inputs <- get_vri_for_vdyp(
  vri_file            = file.path(tempdir(), "vri_aoi_df.csv"),
  msyt_reference_file = "path/to/MSYT_prov_reference.csv",
  vdyp_input_dir      = "path/to/vdyp/layer_poly/folder",
  output_dir          = "C:/VDYP7/Input",
  layer_csv_file_name = "layer_csv_file_name.csv",
  poly_csv_file_name  = "poly_csv_file_name.csv"
)

# 4. Create the VDYP7 parameter file
param_file <- create_vdyp_parameter_file(
  vdyp_dir       = "C:/VDYP7",
  input_dir      = "C:/VDYP7/Input",
  output_dir     = "C:/VDYP7/Output",
  poly_file      = "poly_csv_file_name.csv",
  layer_file     = "layer_csv_file_name.csv",
  param_file_name = "parms_aoi.txt",
  utilization_cu = 12.5,
  age_start      = 0,
  age_end        = 250,
  age_increment  = 10
)

# 5. Run VDYP7
yield_data <- run_vdyp7(
  vdyp_exe   = "C:/VDYP7/vdyp7console.exe",
  parms_file = "C:/VDYP7/Input/parms_aoi.txt",
  output_dir = "C:/VDYP7/Output"
)

# 6. Post-process: softwood / hardwood volumes over age
vdyp_processed <- process_vdyp_output(
  output_file     = "C:/VDYP7/Output/VDYP7_OUTPUT_YLDTBL_parms_aoi.csv",
  input_poly_file = "C:/VDYP7/Input/poly_csv_file_name.csv",
  output_dir      = "C:/VDYP7/Output"
)
```

## License

MIT © Derek Sattler
