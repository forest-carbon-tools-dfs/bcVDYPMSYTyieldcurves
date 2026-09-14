#' Get VDYP Input Files for Specific VRI Records
#'
#' This function identifies and extracts the VDYP input poly and layer records
#' that correspond to the VRI records within the area of interest (aoi) whose
#' current yield is based on VDYP projections. It performs an intersection of
#' feature IDs from the VRI data, and the raw VDYP poly and layer files.
#'
#' @param vri_file The full path to the VRI subset CSV file containing feature IDs.
#' @param msyt_reference_file The full path to the MSYT VDYP reference CSV file.
#' @param vdyp_input_dir The directory containing the raw VDYP input `poly` and `layer`
#'   CSV files (e.g., `VEG_COMP_VDYP7_INPUT_POLY.csv` and `VEG_COMP_VDYP7_INPUT_LAYER.csv`).
#' @param output_dir The directory where the final, filtered poly and layer files will be saved.
#' @param layer_csv_file_name The name of the csv file to be written with vdyp layer info.
#' @param poly_csv_file_name The name of the csv file to be written with vdyp poly info.
#'
#' @return A list containing two data.tables: `poly_dt_final` and `layer_dt_final`.
#'   These data.tables are saved as CSV files in the specified `output_dir`.
#'
#' @examples
#' # Assuming you have the necessary files in a 'data' folder
#' # vri_file <- "data/vri_subset.csv"
#' # msyt_reference_file <- "data/msyt_2024_reference_VDYP.csv"
#' # vdyp_input_dir <- "data/vdyp_input"
#' # output_dir <- "output"
#' # layer_csv_file_name <- "vdyp_input_layer_aoi.csv"
#' # poly_csv_file_name <- "vdyp_input_poly_aoi.csv"
#'
#' # vdyp_data <- get_vdyp_inputs(
#' #   vri_file = vri_file,
#' #   msyt_reference_file = msyt_reference_file,
#' #   vdyp_input_dir = vdyp_input_dir,
#' #   output_dir = output_dir,
#' #   layer_csv_file_name = layer_csv_file_name,
#' #   poly_csv_file_name = poly_csv_file_name
#' # )
#'
#' # View the head of the filtered poly data
#' # head(vdyp_data$poly_dt_final)
#'
#' @export
#' @importFrom data.table fread
#' @importFrom data.table data.table
#' @importFrom dplyr filter select
get_vri_for_vdyp <- function(vri_file, msyt_reference_file, vdyp_input_dir, output_dir,
                             layer_csv_file_name,
                             poly_csv_file_name) {

  # Load dependencies for the function
  # Note: In a package, you would declare these in the DESCRIPTION file
  # and use package::function() calls

  # 1. Read the input files using data.table::fread for efficiency
  vri_subset <- data.table::fread(vri_file, na = "")
  msyt_2024_reference <- data.table::fread(msyt_reference_file, na = "")
  layer_dt <- data.table::fread(file.path(vdyp_input_dir, "VEG_COMP_VDYP7_INPUT_LAYER.csv"))
  poly_dt <- data.table::fread(file.path(vdyp_input_dir, "VEG_COMP_VDYP7_INPUT_POLY.csv"))

  msyt_2024_reference_VDYP <- msyt_2024_reference %>%
    dplyr::filter(current_yield == "VDYP")

  # 2. Join VRI to MSYT reference to get the master list of VDYP-needed IDs
  vri_msyt_vdyp_joined <- dplyr::inner_join(vri_subset, msyt_2024_reference_VDYP,
                                            by = c("FEATURE_ID" = "feature_id"))

  # 3. Find the intersection of all three sets of IDs
  poly_dt_ids <- unique(poly_dt$FEATURE_ID)
  layer_dt_ids <- unique(layer_dt$FEATURE_ID)
  vri_ids <- unique(vri_msyt_vdyp_joined$FEATURE_ID)
  master_ids <- base::intersect(base::intersect(poly_dt_ids, layer_dt_ids), vri_ids)

  # 4. Convert the master list to a data.table for efficient filtering
  master_dt <- data.table::data.table(FEATURE_ID = master_ids)

  # 5. Filter both data.tables using the master list and remove duplicates
  poly_dt_final <- poly_dt[master_dt, on = "FEATURE_ID", nomatch = 0]
  layer_dt_final <- layer_dt[master_dt, on = "FEATURE_ID", nomatch = 0]
  poly_dt_final <- unique(poly_dt_final, by = "FEATURE_ID")
  layer_dt_final <- unique(layer_dt_final, by = "FEATURE_ID")

  poly_dt_final <- poly_dt_final %>%
    dplyr::arrange(FEATURE_ID)

  layer_dt_final <- layer_dt_final %>%
    dplyr::arrange(FEATURE_ID)

  # 6. Save the final files to the output directory
  data.table::fwrite(layer_dt_final, file.path(output_dir, layer_csv_file_name), na = "")
  data.table::fwrite(poly_dt_final, file.path(output_dir, poly_csv_file_name), na = "")

  # Return the final data tables in a list
  return(list(poly_dt_final = poly_dt_final, layer_dt_final = layer_dt_final))
}
