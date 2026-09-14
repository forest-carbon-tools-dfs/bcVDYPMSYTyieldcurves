#' Match VRI Records to VDYP7 Yield Curves
#'
#' This function takes a VRI sf object and a VDYP7 output CSV file, pivots the
#' VDYP7 data from a long to a wide format, and joins it to the VRI records
#' based on a matching FEATURE_ID. This prepares the data for plotting and
#' further analysis.
#'
#' @param vri_data An sf object. VRI polygon data, typically created by
#'   `create_vri_subset()`.
#' @param vdyp7_curves_path A character string. The full path to the VDYP7
#'   output CSV file (e.g., "vdyp7_output.csv").
#'
#' @return An sf object. The original VRI data frame with new columns appended
#'   for VDYP7 projected volumes (e.g., Conifer_Vol_CU_10, Decid_Vol_CU_20, etc.).
#'
#' @details
#' The VDYP7 output is expected to be in a long format with columns for
#' `FEATURE_ID`, `PRJ_TOTAL_AGE`, `Conifer_Vol_CU`, and `Decid_Vol_CU`. This function
#' reshapes the data into a wide format to allow for direct plotting of
#' volume by age.
#'
#' @examples
#' \dontrun{
#' # Assuming 'vri_subset' is your VRI data
#' # and 'vdyp7_output.csv' is your processed VDYP7 data
#'
#' # Match VRI with VDYP7 curves
#' vri_with_vdyp7 <- match_vri_to_vdyp7_curves(
#'   vri_data = vri_subset,
#'   vdyp7_curves_path = "vdyp7_output.csv"
#' )
#'
#' # Inspect the result, which now contains columns like 'Conifer_Vol_CU_10', etc.
#' print(names(vri_with_vdyp7))
#' }
#'
#' @export
#' @import sf
#' @import dplyr
#' @importFrom tidyr pivot_wider
#' @importFrom readr read_csv
match_vri_to_vdyp7_curves <- function(vri_data, vdyp7_curves_path) {

  # Validate inputs
  if (!inherits(vri_data, "sf")) {
    stop("vri_data must be an sf object.")
  }

  if (!file.exists(vdyp7_curves_path)) {
    stop("VDYP7 curves file not found: ", vdyp7_curves_path)
  }

  if (!"FEATURE_ID" %in% names(vri_data)) {
    stop("vri_data must contain a FEATURE_ID column.")
  }

  # Read VDYP7 output
  message("Reading VDYP7 yield curves...")
  vdyp7_curves <- readr::read_csv(
    vdyp7_curves_path,
    show_col_types = FALSE,
    na = c("", "NA", "D", "-", "NULL")
  )

  # Check required columns
  required_cols <- c("FEATURE_ID", "PRJ_TOTAL_AGE", "Conifer_Vol_CU", "Decid_Vol_CU")
  if (!all(required_cols %in% names(vdyp7_curves))) {
    stop("VDYP7 curves file is missing one of the required columns: ",
         paste(required_cols, collapse = ", "))
  }

  # Pivot VDYP7 data to wide format
  message("Pivoting VDYP7 data to wide format...")
  vdyp7_curves_wide <- vdyp7_curves %>%
    tidyr::pivot_wider(
      id_cols = FEATURE_ID,
      names_from = PRJ_TOTAL_AGE,
      values_from = c(Conifer_Vol_CU, Decid_Vol_CU),
      names_prefix = "Age"
    )

  # Join VRI to VDYP7 curves
  message("Joining VRI data to VDYP7 curves...")
  vri_with_vdyp7 <- vri_data %>%
    dplyr::inner_join(vdyp7_curves_wide, by = "FEATURE_ID")

  message("Found ", nrow(vri_with_vdyp7), " VRI records with VDYP7 curves.")

  return(vri_with_vdyp7)
}
