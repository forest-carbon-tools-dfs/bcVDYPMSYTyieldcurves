#' @keywords internal
"_PACKAGE"

#' @title bcVDYPMSYTyieldcurves: Process BC Forest Inventory Data and Generate Yield Curves
#'
#' @description
#' This package provides tools for processing British Columbia's Vegetation
#' Resources Inventory (VRI) data, linking the VRI to existing managed stand
#' yield tables (MSYT; TIPSY curves) and generating yield curves for un-managed
#' stands using VDYP7.
#'
#' @section Main workflow:
#' The typical workflow involves these steps (assumes VRI Rank 1 and VDYP gdb
#' folders have already been downloaded from the BC Data Catalogue):
#' \enumerate{
#'   \item Create VRI subset: \code{\link{create_vri_subset}}
#'   \item Extract VDYP input files: \code{\link{export_gdb_tables_to_csv2}}
#'   \item Match records to existing yield curves: \code{\link{match_vri_to_msyt_curves}}
#'   \item Identify records needing VDYP processing: \code{\link{get_vri_for_vdyp}}
#'   \item Create VDYP parameter files: \code{\link{create_vdyp_parameter_file}}
#'   \item Run VDYP7: \code{\link{run_vdyp7}}
#'   \item Process VDYP output: \code{\link{process_vdyp_output}}
#' }
#'
#' @section Key functions:
#' \describe{
#'   \item{\code{\link{create_vri_subset}}}{Subset VRI to area of interest using sf polygon object or bounding box}
#'   \item{\code{\link{export_gdb_tables_to_csv2}}}{Extract csv tables from vdyp7 geodatabase}
#'   \item{\code{\link{write_vri_to_csv}}}{Removes the geometry and exports VRI aoi sf object as a csv}
#'   \item{\code{\link{match_vri_to_msyt_curves}}}{Join VRI to managed stand yield curves on FEATURE_ID}
#'   \item{\code{\link{run_vdyp7}}}{Run VDYP7console and read output}
#'   \item{\code{\link{process_vdyp_output}}}{Calculate hardwood/softwood volumes from VDYP output}
#' }
#'
#' @section Data sources:
#' This package works with data from (all data sources must be from the same year):
#' \itemize{
#'   \item BC VRI geodatabase (Vegetation Resources Inventory R1 Layer from BC data catalogue)
#'   \item MSYT CSV files (Managed Stand Yield Tables provided by BC govn't - protected)
#'   \item VDYP7 geodatabase (VDYP7 gdb from BC data catalogue)
#' }
#'
#' @name bcVDYPMSYTyieldcurves
#' @author Derek Sattler
#' @keywords forest yield curves MSYT VDYP7 British Columbia
#'
#' @examples
#' \dontrun{
#' # Example workflow
#'
#' # 1. Create VRI for aoi and export as df
#' vri_aoi <- create_vri_subset("path/to/vri_R1_layer.gdb", layer = "VEG_COMP_LYR_R1_POLY",
#'                            aoi = c(-124, 59, -123.5, 59.5))
#'
#' write_vri_to_csv(vri_aoi,
#'   file_path = "path/to/working/directory/vri_aoi_df.csv")
#'
#' # 2. Match vri from aoi to existing msyt curves
#' vri_msyt_joined <- match_vri_to_msyt_curves(
#'   vri_data = vri_aoi,
#'   msyt_curves_path = "path/to/MSYT_prov_current_input_output.csv",
#'   msyt_reference_path = "path/to/MSYT_prov_reference.csv",
#'   output_file = "path/to/working/directory/vri_msyt_joined.csv"
#' )
#'
#' # 3. Identify polygons in aoi that need a vydp curve
#' vdyp_data <- get_vri_for_vdyp(vri_file = "path/to/working/directory/vri_aoi_df.csv",
#'   msyt_reference_file = "path/to/MSYT_prov_reference.csv",
#'   vdyp_input_dir = "path/to/vdyp/layer_poly/folder", # folder with vdyp poly and layer csv files
#'   output_dir = "C:/VDYP7/Input", # assumes VDYP7 is installed
#'   layer_csv_file_name = "layer_csv_file_name.csv",
#'   poly_csv_file_name = "poly_csv_file_name.csv")
#'
#' # 4. Create VDYP parameter file
#' param_file <- create_vdyp_parameter_file(
#'   vdyp_dir = "C:/VDYP7",
#'   input_dir = "C:/VDYP7/Input",
#'   output_dir = "C:/VDYP7/Output",
#'   poly_file = "poly_csv_file_name.csv", # assumes file in input_dir
#'   layer_file = "layer_csv_file_name.csv", # assumes file in input_dir
#'   param_file_name = "parms_aoi.txt", # saved to input_dir
#'   utilization_cu = 12.5, # could be 4.0, 7.5, 12.5, 17.5
#'   age_start = 0,
#'   age_end = 250,
#'   age_increment = 10
#' )
#'
#' # 5. Run VDYP7
#' yield_data <- run_vdyp7(vdyp_exe = "C:/VDYP7/vdyp7console.exe",
#'                         parms_file = "path/to/parms_aoi.txt", # typically, C:/VDYP7/Input
#'                         output_dir = "C:/VDYP7/Output",
#'                         expected_output_file = NULL)
#'
#' # 6. Post-processing of VDYP7 output
#' vdyp_processed_data <- process_vdyp_output(
#'   output_file = "path/to/VDYP7_OUTPUT_YLDTBL_parms_aoi.csv", # in output_dir
#'   input_poly_file = "path/to/poly_csv_file_name.csv", # typically in VDYP7 input_dir
#'   output_dir = "C:/VDYP7/Output"
#'   )
#' }
NULL
