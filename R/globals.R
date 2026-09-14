# Silence R CMD check "no visible binding for global variable" NOTEs raised by
# non-standard evaluation in dplyr/data.table/ggplot2 pipelines.
utils::globalVariables(c(
  ":=", "i.SP_TYPE",
  "FEATURE_ID", "feature_id", "current_yield", "area", "bec_zone",
  "BEC_ZONE_CODE", "PRJ_TOTAL_AGE", "PRJ_VOL_CU",
  "Conifer_Vol_CU", "Decid_Vol_CU", "ConiferBA_Pct", "DecidBA_Pct",
  "SPECIES", "SP0", "DESCRIPTION", "SP_SINDEX", "SP_TYPE", "SP_COST",
  "LONG_SPECIES", "SPECIES_CD_1", "SPECIES_CD_2", "SPECIES_CD_3",
  "MVcon_80", "MVdec_80", "age", "volume", "volume_type"
))
