test_that("lookup_species2 returns the expected schema", {
  tbl <- lookup_species2()

  expect_s3_class(tbl, "data.table")
  expect_setequal(
    names(tbl),
    c("SPECIES", "SP0", "DESCRIPTION", "SP_SINDEX", "SP_TYPE", "SP_COST", "LONG_SPECIES")
  )
  expect_gt(nrow(tbl), 0)
  # SP_TYPE classifies each species as conifer (C) or deciduous (D)
  expect_true(all(tbl$SP_TYPE %in% c("C", "D")))
})
