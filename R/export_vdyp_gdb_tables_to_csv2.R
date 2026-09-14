#' Export non-spatial tables from a geodatabase to CSV
#'
#' This function exports specified non-spatial tables from a geodatabase to CSV files
#' (typically, the VDYP7 geodatabase found on the BC data catalogue).
#' It allows the user to select specific tables to export, avoiding the need to
#' iterate through all layers.
#'
#' @param vdyp_gdb_path A character string specifying the file path to the geodatabase.
#' @param output_folder A character string specifying the folder where the CSV
#'   files will be saved. Defaults to "vdyp7_veg_comp_csv_files".
#' @param layers_to_export An optional character vector of table names to export.
#'   If `NULL` (the default), the function will attempt to export all non-spatial
#'   layers from the geodatabase.
#'
#' @return Returns `invisible(NULL)`. The function's main effect is the creation
#'   of CSV files in the specified output folder.
#'
#' @examples
#' \dontrun{
#' # First, get a list of all layers in the geodatabase to see what's available
#' # Replace "path/to/your/geodatabase.gdb" with the actual path
#' vdyp_gdb_path <- "path/to/your/geodatabase.gdb"
#' layer_names <- sf::st_layers(vdyp_gdb_path)$name
#' print(layer_names)
#'
#' # Now, use the names of the desired layers in the function call
#' # Example usage to export only two specific tables
#' export_gdb_tables_to_csv2(
#'   vdyp_gdb_path = "path/to/your/geodatabase.gdb",
#'   layers_to_export = c("VDYP7_INPUT_POLY_FD", "VDYP7_INPUT_LAYER_FD")
#' )
#' }
#' @export
#' @importFrom sf st_layers st_read st_drop_geometry
#' @importFrom utils write.csv
export_gdb_tables_to_csv2 <- function(vdyp_gdb_path,
                                     output_folder = "vdyp7_veg_comp_csv_files",
                                     layers_to_export = NULL) {

  # Check if the gdb path exists
  if (!dir.exists(vdyp_gdb_path)) {
    stop(paste("Geodatabase path not found:", vdyp_gdb_path))
  }

  # Create the output folder if it doesn't exist
  if (!dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
  }

  # Determine which layers to process
  if (is.null(layers_to_export)) {
    message("No specific layers provided. Reading all geodatabase layers...")
    layers_to_process <- sf::st_layers(vdyp_gdb_path)$name
  } else {
    message("Processing specified layers: ", paste(layers_to_export, collapse = ", "))
    all_layers <- sf::st_layers(vdyp_gdb_path)$name
    missing_layers <- setdiff(layers_to_export, all_layers)
    if (length(missing_layers) > 0) {
      stop("Specified layers not found in geodatabase: ", paste(missing_layers, collapse = ", "))
    }
    layers_to_process <- layers_to_export
  }

  # Initialize counters
  tables_exported <- 0
  spatial_layers_skipped <- 0
  errors <- 0

  # Iterate through each layer
  for (layer_name in layers_to_process) {
    tryCatch({
      # Read the current layer
      layer_data <- sf::st_read(dsn = vdyp_gdb_path, layer = layer_name, quiet = TRUE)

      # Check if it's a non-spatial table
      if (inherits(layer_data, "data.frame") && !inherits(layer_data, "sf")) {
        # Regular data frame - export directly
        output_filename <- file.path(output_folder, paste0(layer_name, ".csv"))
        utils::write.csv(layer_data, file = output_filename, row.names = FALSE, na = "")
        message("Table '", layer_name, "' exported to: ", output_filename)
        tables_exported <- tables_exported + 1
      } else if (inherits(layer_data, "sf") && is.null(sf::st_geometry(layer_data))) {
        # sf object with NULL geometry - also non-spatial
        output_filename <- file.path(output_folder, paste0(layer_name, ".csv"))
        utils::write.csv(sf::st_drop_geometry(layer_data), file = output_filename,
                         row.names = FALSE, na = "")
        message("Table '", layer_name, "' exported to: ", output_filename)
        tables_exported <- tables_exported + 1
      } else if (inherits(layer_data, "sf") && !is.null(sf::st_geometry(layer_data))) {
        # Spatial layer - skip
        message("Layer '", layer_name, "' is spatial. Skipping CSV export.")
        spatial_layers_skipped <- spatial_layers_skipped + 1
      } else {
        message("Layer '", layer_name, "' could not be processed as table or spatial layer.")
        errors <- errors + 1
      }

    }, error = function(e) {
      message("Error processing layer '", layer_name, "': ", e$message)
      errors <- errors + 1
    })
  }

  # Summary message
  message("\nProcessing complete:")
  message("- Tables exported: ", tables_exported)
  message("- Spatial layers skipped: ", spatial_layers_skipped)
  message("- Errors encountered: ", errors)

  return(invisible(NULL))
}
