#' Create VDYP7 Parameter File
#'
#' Creates a parameter file (.txt) needed to run VDYP7console with specified
#' input files, output files and configuration options.
#'
#' @param vdyp_dir Character. Path to the VDYP7 installation directory
#' @param input_dir Character. Path to directory containing input files
#' @param output_dir Character. Path to directory for output files
#' @param poly_file Character. Name of the polygon input CSV file
#' @param layer_file Character. Name of the layer input CSV file
#' @param output_prefix Character. Prefix for output file names. Default is "VDYP7_OUTPUT"
#' @param param_file_name Character. Name for the parameter file. Default is "parms.txt"
#' @param utilization_cu Numeric. Close utilization diameter in cm. Default is 12.5 (others: 4.0, 7.5, 17.5)
#' @param age_start Numeric. Starting age for projections. Default is 0
#' @param age_end Numeric. Ending age for projections. Default is 250
#' @param age_increment Numeric. Age increment for projections. Default is 10
#'
#' @return Character. Path to the created parameter file
#'
#' @details This function creates a parameter file that VDYP7console uses to
#' determine input files, output locations, and processing options. The parameter
#' file includes settings for:
#' - Input/output file locations
#' - Utilization standards by species group
#' - Age range and increment for projections
#' - Output format options
#'
#' The function automatically creates the input and output directories if they
#' don't exist.
#'
#' For help on VDYP7, go to:
#' https://www2.gov.bc.ca/gov/content/industry/forestry/managing-our-forest-resources/forest-inventory/growth-and-yield-modelling/variable-density-yield-projection-vdyp/publications-and-support
#'
#' @examples
#' \dontrun{
#' # Create parameter file for VDYP7 run
#' param_file <- create_vdyp_parameter_file(
#'   vdyp_dir = "C:/VDYP7",
#'   input_dir = "C:/VDYP7/Input_testarea",
#'   output_dir = "C:/VDYP7/Output_testarea",
#'   poly_file = "vdyp_input_poly_test_area.csv",
#'   layer_file = "vdyp_input_layer_test_area.csv",
#'   param_file_name = "parms_testarea.txt"
#' )
#' }
#'
#' @export
#' @importFrom fs dir_create
#' @importFrom readr write_lines
create_vdyp_parameter_file <- function(vdyp_dir,
                                       input_dir,
                                       output_dir,
                                       poly_file,
                                       layer_file,
                                       output_prefix = "VDYP7_OUTPUT",
                                       param_file_name = "parms.txt",
                                       utilization_cu = 12.5,
                                       age_start = 0,
                                       age_end = 250,
                                       age_increment = 10) {

  # Validate inputs
  if (!dir.exists(vdyp_dir)) {
    stop("VDYP7 directory not found: ", vdyp_dir)
  }

  vdyp_exe <- file.path(vdyp_dir, "vdyp7console.exe")
  if (!file.exists(vdyp_exe)) {
    stop("VDYP7console.exe not found in: ", vdyp_dir)
  }

  # Create directories if they don't exist
  fs::dir_create(input_dir)
  fs::dir_create(output_dir)

  # Check if input files exist
  poly_path <- file.path(input_dir, poly_file)
  layer_path <- file.path(input_dir, layer_file)

  if (!file.exists(poly_path)) {
    warning("Polygon input file not found: ", poly_path)
  }

  if (!file.exists(layer_path)) {
    warning("Layer input file not found: ", layer_path)
  }

  # Create parameter file path
  param_file_path <- file.path(input_dir, param_file_name)

  # Normalize paths for Windows (VDYP7 typically runs on Windows)
  vdyp_ini <- normalizePath(file.path(vdyp_dir, "VDYP.ini"), winslash = "\\", mustWork = FALSE)
  vdyp_cfg <- paste0(normalizePath(file.path(vdyp_dir, "VDYP_CFG"), winslash = "\\", mustWork = FALSE), "\\")
  poly_norm <- normalizePath(poly_path, winslash = "\\", mustWork = FALSE)
  layer_norm <- normalizePath(layer_path, winslash = "\\", mustWork = FALSE)
  output_yield <- normalizePath(file.path(output_dir, paste0(output_prefix, "_YLDTBL_",
                                                             gsub("\\.txt$", "", param_file_name), ".csv")),
                                winslash = "\\", mustWork = FALSE)
  output_error <- normalizePath(file.path(output_dir, paste0(output_prefix, "_ERRMSG_",
                                                             gsub("\\.txt$", "", param_file_name), ".txt")),
                                winslash = "\\", mustWork = FALSE)

  # Species groups for utilization settings
  species_groups <- c("AC", "AT", "B", "C", "D", "E", "F", "H", "L", "MB", "PA", "PL", "PW", "PY", "S", "Y")

  # Create utilization lines
  util_lines <- paste0("-util ", species_groups, "=", utilization_cu)

  # Create parameter file content
  param_content <- c(
    paste("-ini", vdyp_ini),
    paste("-c", vdyp_cfg),
    "-ifmt hcsv",
    "-ofmt csvyieldtable",
    paste("-ip", poly_norm),
    paste("-il", layer_norm),
    paste("-o", output_yield),
    paste("-e", output_error),
    "-back Yes",
    "-forward Yes",
    "-includeprojmode Yes",
    util_lines,
    paste("-agestart", age_start),
    paste("-ageend", age_end),
    paste("-inc", age_increment),
    "-includeagerows Yes",
    "-forceRefYear Yes",
    "-forceCrntYear Yes",
    "-yieldtableincpolyid Yes",
    "-projectedBySpecies No",
    "-projectedVolumes Yes",
    "-projectedCFSBiomass No"
  )

  # Write parameter file
  readr::write_lines(param_content, param_file_path)

  message("Parameter file created: ", param_file_path)
  message("Expected output file: ", output_yield)

  return(param_file_path)
}
