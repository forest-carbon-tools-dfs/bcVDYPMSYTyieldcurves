#' Execute VDYP7console and Read Output
#'
#' This function executes the external VDYP7console program using specified
#' executable and parameter files, then reads the generated yield table output.
#' VDYP7 and vdyp7console are available on the BC govn't website. When installing
#' VDYP7, it is recommended that it be placed as a sub-folder on the C drive
#' (e.g., C:/VDYP7).
#'
#' @param vdyp_exe The full path to the VDYP7console executable.
#' @param parms_file The full path to the VDYP7 parameter file.
#' @param output_dir The directory where the VDYP7 output file is expected to be saved.
#' @param expected_output_file Character or NULL. Specific output CSV filename to read.
#'   If NULL (default), the function will search for any CSV file in the output directory
#'   and use the first one found (careful!). If specified, the function will look
#'   for this exact filename in the output directory.
#'
#' @return A tibble containing the VDYP7 yield data if the output file is
#'   successfully generated and found. If the file is not found, a message
#'   is printed to the console and NULL is returned.
#'
#' @export
#' @importFrom fs file_exists
#' @importFrom readr read_csv
#'
#' @examples
#' \dontrun{
#' # Assuming you have the VDYP executable and parameter files set up
#' # on your system and have prepared the input files.
#' # vdyp_path <- "C:/VDYP7/vdyp7console.exe"
#' # parms_file <- "C:/VDYP7/Input/my_parms.txt"
#' # output_dir <- "C:/VDYP7/Output"
#'
#' # Run the model and read the output
#' # The function returns the data frame, so we can save it to a variable
#' # for later use.
#' yield_table <- run_vdyp7(
#'   vdyp_exe = vdyp_path,
#'   parms_file = parms_file,
#'   output_dir = output_dir
#' )
#'
#' # If the run was successful, print the head of the output
#' if (!is.null(yield_table)) {
#'   head(yield_table)
#' }
#' }
run_vdyp7 <- function(vdyp_exe, parms_file, output_dir,
                          expected_output_file = NULL) {

  # Input validation
  if (!file.exists(vdyp_exe)) {
    stop("VDYP executable not found: ", vdyp_exe)
  }

  if (!file.exists(parms_file)) {
    stop("Parameter file not found: ", parms_file)
  }

  if (!dir.exists(output_dir)) {
    stop("Output directory not found: ", output_dir)
  }

  # run VDYP7console with error handling
  message("Executing VDYP7console...")
  result <- system2(vdyp_exe, args = c("-p", parms_file),
                    stdout = TRUE, stderr = TRUE)

  # Check if system2 failed
  if (!is.null(attr(result, "status")) && attr(result, "status") != 0) {
    warning("VDYP7console may have failed. Exit status: ", attr(result, "status"))
    message("VDYP7 output: ", paste(result, collapse = "\n"))
  }

  # Determine output file (either specified or search for it)
  if (is.null(expected_output_file)) {
    # Look for CSV files in output directory
    csv_files <- list.files(output_dir, pattern = "\\.csv$", full.names = TRUE)
    if (length(csv_files) == 0) {
      message("No CSV output files found in ", output_dir)
      return(NULL)
    }
    output_csv <- csv_files[1]  # Take the first one found
    if (length(csv_files) > 1) {
      warning("Multiple CSV files found, using: ", basename(output_csv))
    }
  } else {
    output_csv <- file.path(output_dir, expected_output_file)
  }

  # Read output file if it exists
  if (fs::file_exists(output_csv)) {
    output_col_types <- readr::cols(
        TABLE_NUM = readr::col_double(),
        FEATURE_ID = readr::col_double(),
        DISTRICT = readr::col_logical(),
        MAP_ID = readr::col_character(),
        POLYGON_ID = readr::col_double(),
        LAYER_ID = readr::col_double(),
        PROJECTION_YEAR = readr::col_double(),
        PRJ_TOTAL_AGE = readr::col_double(),
        SPECIES_1_CODE = readr::col_character(),
        SPECIES_1_PCNT = readr::col_double(),
        SPECIES_2_CODE = readr::col_character(),
        SPECIES_2_PCNT = readr::col_double(),
        SPECIES_3_CODE = readr::col_character(),
        SPECIES_3_PCNT = readr::col_double(),
        SPECIES_4_CODE = readr::col_character(),
        SPECIES_4_PCNT = readr::col_double(),
        SPECIES_5_CODE = readr::col_character(),
        SPECIES_5_PCNT = readr::col_double(),
        SPECIES_6_CODE = readr::col_character(),
        SPECIES_6_PCNT = readr::col_double(),
        PRJ_PCNT_STOCK = readr::col_double(),
        PRJ_SITE_INDEX = readr::col_double(),
        PRJ_DOM_HT = readr::col_double(),
        PRJ_SCND_HT = readr::col_double(),
        PRJ_LOREY_HT = readr::col_double(),
        PRJ_DIAMETER = readr::col_double(),
        PRJ_TPH = readr::col_double(),
        PRJ_BA = readr::col_double(),
        PRJ_VOL_WS = readr::col_double(),
        PRJ_VOL_CU = readr::col_double(),
        PRJ_VOL_D = readr::col_double(),
        PRJ_VOL_DW = readr::col_double(),
        PRJ_VOL_DWB = readr::col_double(),
        PRJ_MODE = readr::col_character()
      )
    yield_data <- readr::read_csv(output_csv, col_types = output_col_types,
                                  na = c("", "NA", "D", "-", "NULL"))
    message("VDYP7 output loaded: ", basename(output_csv))
    return(yield_data)
  } else {
    message("Expected output file not found: ", basename(output_csv))
    message("Check VDYP7 error messages or parameter file configuration.")
    return(NULL)
  }
}
