#' Export Geodatabase Tables to CSV
#'
#' Extracts non-spatial tables from a geodatabase and exports them as CSV files.
#' This function is particularly useful for extracting VDYP7 input files from
#' BC government geodatabase distributions.
#'
#' @param gdb_path Character. Path to the geodatabase (.gdb folder)
#' @param output_folder Character. Name of the output folder to create for CSV files.
#'   Default is "vdyp7_veg_comp_csv_files"
#'
#' @return Invisible NULL. Function is called for side effects (creating CSV files)
#'
#' @details This function reads all layers in a geodatabase, identifies non-spatial
#' tables, and exports them as CSV files. It handles both regular data.frame objects
#' and sf objects with NULL geometry. Spatial layers are skipped.
#'
#' The function is designed to work with BC's VEG_COMP_VDYP7_INPUT_POLY_AND_LAYER
#' geodatabases which contain the input_layer and input_poly tables needed for VDYP7.
#'
#' @examples
#' \dontrun{
#' # Path to downloaded VDYP7 input geodatabase
#' gdb_path <- "VEG_COMP_VDYP7_INPUT_POLY_AND_LAYER_2024.gdb"
#' 
#' # Export tables to CSV files
#' export_gdb_tables_to_csv(gdb_path, "vdyp_input_csv_2024")
#' }
#'
#' @export
#' @import sf
#' @importFrom utils write.csv
export_gdb_tables_to_csv <- function(gdb_path, output_folder = "vdyp7_veg_comp_csv_files") {
  
  # Check if the gdb path exists
  if (!dir.exists(gdb_path)) {
    stop(paste("Geodatabase path not found:", gdb_path))
  }
  
  # Create the output folder if it doesn't exist
  if (!dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
  }
  
  # List all layers within the geodatabase
  message("Reading geodatabase layers...")
  all_layers <- sf::st_layers(gdb_path)$name
  message("Found ", length(all_layers), " layers in geodatabase")
  
  # Initialize counters
  tables_exported <- 0
  spatial_layers_skipped <- 0
  errors <- 0
  
  # Iterate through each layer
  for (layer_name in all_layers) {
    tryCatch({
      # Read the current layer
      layer_data <- sf::st_read(dsn = gdb_path, layer = layer_name, quiet = TRUE)
      
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