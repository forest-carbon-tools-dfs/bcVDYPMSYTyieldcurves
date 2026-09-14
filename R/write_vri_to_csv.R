#' Write a VRI (or sf) Data Frame to a CSV File
#'
#' This function writes a spatial data frame (`sf` object) to a CSV file.
#' It automatically removes the geometry column and any other complex
#' list-type columns that are not supported by `data.table::fwrite`. The
#' resulting CSV file is used by the function 'get_vri_for_vdyp'.
#'
#' @param sf_df An `sf` data frame (e.g., VRI data) to be written.
#' @param file_path A character string specifying the file path for the output CSV.
#' @param ... Other arguments passed on to `data.table::fwrite`.
#'
#' @return Returns `invisible(NULL)`. The function's primary effect is creating
#'   a CSV file at the specified file path.
#'
#' @examples
#' \dontrun{
#' # Assuming 'vri_subset' is an sf object created from your
#' # create_vri_subset() function
#'
#' # Write the data frame to a CSV file.
#' # The geometry column will be automatically removed.
#' write_vri_to_csv(vri_subset, file.path(tempdir(), "vri_subset.csv"))
#' }
#' @export
#' @importFrom data.table fwrite
#' @importFrom sf st_drop_geometry
#' @importFrom dplyr select_if
write_vri_to_csv <- function(sf_df, file_path, ...) {

  # Drop the geometry column explicitly
  df_no_geom <- sf::st_drop_geometry(sf_df)

  # Remove any other lingering list-type columns for robustness
  df_clean <- df_no_geom %>%
    dplyr::select_if(~!is.list(.))

  # Write the cleaned data frame to the file
  data.table::fwrite(df_clean, file_path, na = "", ...)

  message("File successfully written to: ", file_path)

  return(invisible(NULL))
}
