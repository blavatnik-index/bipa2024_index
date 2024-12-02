### internals/generics

testthat::test_that("check_vars", {
  
  test_df <- tibble::tibble(
    variable = c("var1", "var1", "var2", "var3"),
    value = 1:4
  )

  # df has all expected variables
  testthat::expect_no_error(.check_vars(test_df, c("var1", "var2", "var3")))
  # df has all expected variables but also others
  testthat::expect_error(.check_vars(test_df, c("var1", "var2")))
  # df has some but not all expected variables
  testthat::expect_error(.check_vars(test_df, c("var1", "var4")))
  # df has none of the expected variables
  testthat::expect_error(.check_vars(test_df, c("varA", "varB", "varC")))
  # all df variables are expected, but does not have all expected variables
  testthat::expect_error(.check_vars(test_df, c("var1", "var2", "var3", "var4")))

})

testthat::test_that(".chk_type", {
  # valid
  testthat::expect_true(.chk_type(1L:10L, "numeric"))
  testthat::expect_true(.chk_type(1:10, "numeric"))
  testthat::expect_true(.chk_type(LETTERS, "character"))
  testthat::expect_true(.chk_type(rep(TRUE, 5), "logical"))
  # not valid
  testthat::expect_false(.chk_type(1L:10L, "character"))
  testthat::expect_false(.chk_type(1:10, "logical"))
  testthat::expect_false(.chk_type(LETTERS, "numeric"))
  testthat::expect_false(.chk_type(rep(TRUE, 5), "datetime"))
})

### user functions

testthat::test_that("check_cc", {
  test_df <- tibble::tibble(
    cc_iso3c = c("GBR", "FRA", "DNK", "GBR", "FRA", "GBR")
  )

  # df has expected codes
  testthat::expect_no_error(check_cc(test_df, c("GBR", "FRA", "DNK")))
  testthat::expect_no_error(check_cc(test_df, c("GBR", "FRA", "DNK", "USA", "CAN")))
  # reference list not a character vector
  testthat::expect_error(check_cc(test_df, 1:10))
  # df does not have cc_iso3c variable
  testthat::expect_error(check_cc(tibble::tibble(a = 1:10), c("GBR", "FRA", "DNK")))
  # df has codes that are not expected
  testthat::expect_error(check_cc(test_df, c("GBR", "FRA")))
  testthat::expect_error(check_cc(test_df, c("GBR", "USA", "CAN")))
  # df has only invalid codes
  testthat::expect_error(check_cc(test_df, c("BRA", "NGA", "CHN")))
})

testthat::test_that("check_df", {
  
  test_df <- tibble::tibble(
    cc_iso3c = c("GBR", "FRA", "GBR", "DNK"),
    variable = c("var1", "var1", "var2", "var3"),
    value = 1:4
  )

  # df has expected columns of expected type
  testthat::expect_no_error(check_df(
    test_df, 
    c("cc_iso3c" = "character", "variable" = "character", "value" = "numeric")
  ))
  # function is noisy
  testthat::expect_message(check_df(
    test_df, 
    c("cc_iso3c" = "character", "variable" = "character", "value" = "numeric"),
    .quiet = FALSE
  ))
  # df has expected columns of expected type and valid country codes
  testthat::expect_no_error(check_df(
    test_df, 
    c("cc_iso3c" = "character", "variable" = "character", "value" = "numeric"),
    chk_cc = c("GBR", "FRA", "DNK")
  ))
  testthat::expect_no_error(check_df(
    test_df, 
    c("cc_iso3c" = "character", "variable" = "character", "value" = "numeric"),
    chk_cc = c("GBR", "FRA", "DNK", "USA")
  ))
  # columns argument is not character
  testthat::expect_error(check_df(test_df, 1:3))
  # columns argument is  not named
  testthat::expect_error(check_df(
    test_df, c("character", "character", "numeric")
  ))
  # columns argument is  not same length as columns in df
  testthat::expect_error(check_df(test_df, c("variable" = "character")))
  # columns argument has missing values
  testthat::expect_error(check_df(
    test_df,
    c("cc_iso3c" = "character", "variable" = "character", "value" = NA_character_)
  ))
  # columns argument names has missing values
  testthat::expect_error(check_df(
    test_df, 
    c("cc_iso3c" = "character", "variable" = "character", "numeric")
  ))
  # columns argument names do not match names in df
  testthat::expect_error(check_df(
    test_df, 
    c("cc_iso3c" = "character", "abc" = "character", "value" = "value")
  ))
  # columns not of expected type
  testthat::expect_error(check_df(
    test_df,
    c("cc_iso3c" = "character", "variable" = "numeric", "value" = "character")
  ))
  # chk_cc not valid
  testthat::expect_error(check_df(
    test_df,
    c("cc_iso3c" = "character", "variable" = "character", "value" = "character"),
    chk_cc = TRUE
  ))
  testthat::expect_error(check_df(
    test_df,
    c("cc_iso3c" = "character", "variable" = "character", "value" = "numeric"),
    chk_cc = 1:3
  ))
  testthat::expect_error(check_df(
    test_df,
    c("cc_iso3c" = "character", "variable" = "character", "value" = "numeric"),
    chk_cc = c("ABC", "DEF", "GHIJ", "abc", "AB1", "de2")
  ))
  # df has invalid country codes
  testthat::expect_error(check_df(
    test_df, 
    c("cc_iso3c" = "character", "variable" = "character", "value" = "numeric"),
    chk_cc = c("GBR", "FRA")
  ))
  testthat::expect_error(check_df(
    test_df, 
    c("cc_iso3c" = "character", "variable" = "character", "value" = "numeric"),
    chk_cc = c("GBR", "FRA", "USA")
  ))

})

testthat::test_that("check_source_data", {
  test_df <- tibble::tibble(
    variable = c("var1", "var1", "var2", "var3"),
    value = 1:4
  )
  test_df2 <- tibble::tibble(
    source_variable = c("var1", "var2", "var3")
  )
  test_df3 <- tibble::tibble(
    variable = c("var1", "var1", "var2"),
    value = 1:3
  )
  test_df4 <- tibble::tibble(
    variable = c("var1", "var1", "var2", "var4"),
    value = 1:4
  )

  # df has all variables listed in metadata df
  testthat::expect_no_error(check_source_data(test_df, test_df2))
  # df does not have variable named "variable"
  testthat::expect_error(check_source_data(test_df2, test_df))
  # metadata df does not have variable named "source_variable"
  testthat::expect_error(check_source_data(test_df, test_df))
  # df does not contain all expected variables
  testthat::expect_error(check_source_data(test_df3, test_df2))
  # df contains variables not included in metadata
  testthat::expect_error(check_source_data(test_df4, test_df2))
})


