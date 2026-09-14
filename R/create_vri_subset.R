#' Create VRI Subset from Polygon or Bounding Box
#'
#' This function reads a specified layer from a geodatabase (e.g., VRI) and clips it to a
#' defined area of interest (AOI). The AOI can be provided as either a bounding box
#' or an existing `sf` polygon object.
#'
#' @param vri_gdb_path The full path to the geodatabase file.
#' @param layer The name of the layer to read from the geodatabase,
#'   defaulting to "VEG_COMP_LYR_R1_POLY".
#' @param aoi The Area of Interest to clip the VRI data. This can be either:
#'   \itemize{
#'     \item a numeric vector of length 4 for a bounding box: `c(xmin, ymin, xmax, ymax)`
#'     \item an `sf` polygon object representing the clipping area.
#'   }
#' @param output_crs The EPSG code of the desired output CRS. The default
#'   is 3005 (BC Albers).
#'
#' @return An `sf` tibble containing the VRI subset, clipped to the AOI.
#'   Returns an empty `sf` object if no features are found.
#' @export
#' @importFrom sf st_read st_layers st_polygon st_sfc st_transform st_as_text st_geometry
#' @importFrom fs file_exists
#'
#' @examples
#' \dontrun{
#' # Assuming you have a geodatabase at 'data/vri.gdb'
#' vri_gdb_path <- "data/vri.gdb"
#'
#' # EXAMPLE 1: Using a bounding box
#' # Define a bounding box for a small area
#' bbox_coords <- c(xmin = -123.5, ymin = 50.0, xmax = -123.0, ymax = 50.5)
#' vri_subset_bbox <- create_vri_subset(
#'   vri_gdb_path = vri_gdb_path,
#'   aoi = bbox_coords
#' )
#'
#' # EXAMPLE 2: Using an existing polygon
#' # Assuming you have a pre-defined sf polygon object named 'my_aoi_polygon'
#' # This can be created from a shapefile, for example:
#' # my_aoi_polygon <- sf::st_read("data/my_aoi_polygon.shp")
#'
#' # Example polygon for demonstration
#' poly_coords <- matrix(c(-123.5, 50.0,
#'                         -123.0, 50.0,
#'                         -123.2, 50.5,
#'                         -123.5, 50.0), ncol = 2, byrow = TRUE)
#' my_aoi_polygon <- sf::st_sfc(sf::st_polygon(list(poly_coords)), crs = 4326)
#'
#' # Create the subset using the polygon
#' vri_subset_poly <- create_vri_subset(
#'   vri_gdb_path = vri_gdb_path,
#'   aoi = my_aoi_polygon
#' )
#' }
create_vri_subset <- function(vri_gdb_path,
                              layer = "VEG_COMP_LYR_R1_POLY",
                              aoi,
                              output_crs = 3005) {
  # Validate geodatabase path
  if (!file.exists(vri_gdb_path)) {
    stop("Geodatabase path not found: ", vri_gdb_path)
  }

  # Check if layer exists in geodatabase
  available_layers <- sf::st_layers(vri_gdb_path)$name
  if (!layer %in% available_layers) {
    stop("Layer '", layer, "' not found in geodatabase. Available layers: ",
         paste(available_layers, collapse = ", "))
  }

  # Handle the different types of AOI input
  if (is.numeric(aoi) && length(aoi) == 4) {
    message("AOI provided as a bounding box. Converting to polygon.")
    aoi_polygon <- sf::st_polygon(list(matrix(c(aoi[1], aoi[2],   # xmin, ymin
                                                aoi[3], aoi[2],   # xmax, ymin
                                                aoi[3], aoi[4],   # xmax, ymax
                                                aoi[1], aoi[4],   # xmin, ymax
                                                aoi[1], aoi[2]),  # close polygon
                                              ncol = 2, byrow = TRUE)))
    aoi_sf <- sf::st_sfc(aoi_polygon, crs = 4326)
  } else if (inherits(aoi, "sf")) {
    # Check if aoi is a polygon or a multipolygon
    if (!all(sf::st_is(sf::st_geometry(aoi), c("POLYGON", "MULTIPOLYGON")))) {
      stop("The provided sf object is not a polygon or multipolygon.")
    }
    message("AOI provided as a polygon object.")
    aoi_sf <- sf::st_geometry(aoi)
  } else {
    stop("Invalid 'aoi' argument. Please provide a numeric vector of length 4 (bbox) ",
         "or an sf polygon object.")
  }

  # Reproject AOI to match the output CRS before clipping
  aoi_transformed <- sf::st_transform(aoi_sf, crs = output_crs)

  # Read VRI data with spatial filter
  message("Reading VRI data with spatial filter...")
  vri_subset <- sf::st_read(vri_gdb_path,
                            layer = layer,
                            wkt_filter = sf::st_as_text(aoi_transformed),
                            quiet = TRUE)

  message("VRI subset created with ", nrow(vri_subset), " features")

  return(vri_subset)
}
