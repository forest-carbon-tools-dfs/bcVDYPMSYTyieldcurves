#' Process VDYP7 Output and Calculate Softwood/Hardwood Volume
#'
#' This function takes the raw output from a VDYP7 run, joins it with the input
#' polygon and layer data, and calculates the conifer and deciduous volume components
#' based on species codes. It also saves the final, processed data table.
#'
#' @param output_file The full path to the VDYP7 output CSV file
#'   (e.g., "VDYP7_OUTPUT_YLDTBL_parms_aoi.csv").
#' @param input_poly_file The full path to the VDYP7 input polygon CSV file.
#' @param output_dir The directory where the final processed data
#'   will be saved.
#' @param vdyp_postpro_file File name given to csv containing post-processed vdyp output.
#'
#' @return A data.table containing the processed VDYP output, with new columns
#'   for conifer and deciduous volumes. The function also saves the
#'   final data table as a CSV file.
#' @export
#' @importFrom data.table as.data.table fifelse
#' @importFrom stats setNames
#' @importFrom dplyr left_join select
#' @importFrom fs path
#' @importFrom readr read_csv cols col_character col_double col_logical
#'
#' @examples
#' \dontrun{
#' # Assuming the required files are available
#' # output_file <- "C:/VDYP7/Output/VDYP7_OUTPUT_YLDTBL_parms_aoi.csv"
#' # input_poly_file <- "C:/VDYP7/Input/poly_csv_file_name.csv"
#' # output_dir <- "C:/VDYP7/Output"
#' # vdyp_postpro_file <- "vdyp_postpro_file.csv"
#'
#' # processed_data <- process_vdyp_output(
#' #   output_file = output_file,
#' #   input_poly_file = input_poly_file,
#' #   output_dir = output_dir
#' # )
#'
#' # head(processed_data)
#' }
process_vdyp_output <- function(output_file, input_poly_file, output_dir, vdyp_postpro_file) {

  # Note: This function assumes lookup_species2() is available in the package.
  species_data <- lookup_species2()

  # --- Manual column types for vdyp_output_aoi based on spec() ---
  output_col_types <- readr::cols(
    TABLE_NUM = readr::col_double(),
    FEATURE_ID = readr::col_double(),
    DISTRICT = readr::col_character(),
    MAP_ID = readr::col_character(),
    POLYGON_ID = readr::col_double(),
    LAYER_ID = readr::col_character(),
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
  vdyp_output_aoi <- readr::read_csv(output_file, col_types = output_col_types)

  # --- Manual column types for vdyp_poly_input_aoi ---
  poly_col_types <- readr::cols(
    FEATURE_ID = readr::col_double(),
    MAP_ID = readr::col_character(),
    POLYGON_NUMBER = readr::col_double(),
    ORG_UNIT = readr::col_character(),
    TSA_NAME = readr::col_character(),
    TFL_NAME = readr::col_character(),
    INVENTORY_STANDARD_CODE = readr::col_character(),
    TSA_NUMBER = readr::col_character(),
    SHRUB_HEIGHT = readr::col_double(),
    SHRUB_CROWN_CLOSURE = readr::col_double(),
    SHRUB_COVER_PATTERN = readr::col_double(),
    HERB_COVER_TYPE_CODE = readr::col_character(),
    HERB_COVER_PCT = readr::col_double(),
    HERB_COVER_PATTERN_CODE = readr::col_double(),
    BRYOID_COVER_PCT = readr::col_double(),
    BEC_ZONE_CODE = readr::col_character(),
    CFS_ECOZONE = readr::col_double(),
    PRE_DISTURBANCE_STOCKABILITY = readr::col_double(),
    YIELD_FACTOR = readr::col_double(),
    NON_PRODUCTIVE_DESCRIPTOR_CD = readr::col_logical(),
    BCLCS_LEVEL1_CODE = readr::col_character(),
    BCLCS_LEVEL2_CODE = readr::col_character(),
    BCLCS_LEVEL3_CODE = readr::col_character(),
    BCLCS_LEVEL4_CODE = readr::col_character(),
    BCLCS_LEVEL5_CODE = readr::col_character(),
    PHOTO_ESTIMATION_BASE_YEAR = readr::col_double(),
    REFERENCE_YEAR = readr::col_double(),
    PCT_DEAD = readr::col_double(),
    NON_VEG_COVER_TYPE_1 = readr::col_character(),
    NON_VEG_COVER_PCT_1 = readr::col_double(),
    NON_VEG_COVER_PATTERN_1 = readr::col_double(),
    NON_VEG_COVER_TYPE_2 = readr::col_character(),
    NON_VEG_COVER_PCT_2 = readr::col_double(),
    NON_VEG_COVER_PATTERN_2 = readr::col_double(),
    NON_VEG_COVER_TYPE_3 = readr::col_character(),
    NON_VEG_COVER_PCT_3 = readr::col_double(),
    NON_VEG_COVER_PATTERN_3 = readr::col_double(),
    LAND_COVER_CLASS_CD_1 = readr::col_character(),
    LAND_COVER_PCT_1 = readr::col_double(),
    LAND_COVER_CLASS_CD_2 = readr::col_character(),
    LAND_COVER_PCT_2 = readr::col_double(),
    LAND_COVER_CLASS_CD_3 = readr::col_character(),
    LAND_COVER_PCT_3 = readr::col_double(),
    ENTRY_USERID = readr::col_character(),
    UPDATE_USERID = readr::col_character()
  )
  vdyp_poly_input_aoi <- readr::read_csv(input_poly_file, col_types = poly_col_types)


  # Join with poly input to get BEC zone
  vdyp_output_aoi <- dplyr::left_join(vdyp_output_aoi,
                                           vdyp_poly_input_aoi %>% dplyr::select(FEATURE_ID, BEC_ZONE_CODE),
                                           by = "FEATURE_ID")

  # Convert to data.table for efficient processing
  vdyp_output_aoi_B <- data.table::as.data.table(vdyp_output_aoi)

  # Join to classify species
  for (i in 1:6) {
    species_col <- paste0("SPECIES_", i, "_CODE")
    type_col <- paste0("Spp", i, "Type")

    if (species_col %in% names(vdyp_output_aoi_B)) {
      data.table::setkeyv(species_data, "SPECIES")
      vdyp_output_aoi_B[species_data, on = stats::setNames("SPECIES", species_col),
                             (type_col) := i.SP_TYPE]
    }
  }

  # Initialize the new columns
  vdyp_output_aoi_B[, ConiferBA_Pct := 0]
  vdyp_output_aoi_B[, DecidBA_Pct := 0]

  # Column names for species type and percentage
  spp_type_cols <- paste0("Spp", 1:6, "Type")
  spp_pcnt_cols <- paste0("SPECIES_", 1:6, "_PCNT")

  # Loop through each species column to calculate conifer and deciduous volume
  for (j in 1:6) {
    spp_type_col <- spp_type_cols[j]
    spp_pcnt_col <- spp_pcnt_cols[j]

    vdyp_output_aoi_B[!is.na(get(spp_type_col)) & get(spp_type_col) == 'C',
                           ConiferBA_Pct := ConiferBA_Pct + data.table::fifelse(is.na(get(spp_pcnt_col)), 0, get(spp_pcnt_col))]

    vdyp_output_aoi_B[!is.na(get(spp_type_col)) & get(spp_type_col) == 'D',
                           DecidBA_Pct := DecidBA_Pct + data.table::fifelse(is.na(get(spp_pcnt_col)), 0, get(spp_pcnt_col))]
  }

  # Calculate Conifer_Vol_CU and Decid_Vol_CU
  vdyp_output_aoi_B[, Conifer_Vol_CU := (ConiferBA_Pct/100) * PRJ_VOL_CU]
  vdyp_output_aoi_B[, Decid_Vol_CU := (DecidBA_Pct/100) * PRJ_VOL_CU]

  # Drop unnecessary variables and save to file
  vdyp_output_aoi_C <- vdyp_output_aoi_B[, c("MAP_ID",
                                                       "LAYER_ID",
                                                       "Spp1Type", "Spp2Type", "Spp3Type",
                                                       "Spp4Type", "Spp5Type",
                                                       "Spp6Type") := NULL]

  data.table::fwrite(vdyp_output_aoi_C, fs::path(output_dir, vdyp_postpro_file), na = "")

  return(vdyp_output_aoi_C)
}
