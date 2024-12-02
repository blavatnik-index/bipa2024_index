testthat::test_that("rescale_simple", {
  # valid
  testthat::expect_equal(.rescale_simple(1:3), c(0, 0.5, 1))
  testthat::expect_equal(.rescale_simple(1:3, c(1, 0)), c(1, 0.5, 0))

  # errors
  testthat::expect_error(.rescale_simple("a"))
  testthat::expect_error(.rescale_simple(TRUE))
  testthat::expect_error(.rescale_simple(1:3, "a"))
  testthat::expect_error(.rescale_simple(1:3, TRUE))
  testthat::expect_error(.rescale_simple(1:3, 1))
  testthat::expect_error(.rescale_simple(1:3, 1:3))
})

testthat::test_that("distance_scaled", {
  # valid
  testthat::expect_equal(.distance_scaled(-2:2), c(1, 0.5, 0, 0.5, 1))
  testthat::expect_equal(
    .distance_scaled(-2:4),
    c(0.5, 0.25, 0, 0.25, 0.5, 0.75, 1)
  )
  testthat::expect_equal(
    .distance_scaled(-2:4, two_sided = TRUE), 
    c(1, 0.5, 0, 0.25, 0.5, 0.75, 1)
  )

  # errors
  testthat::expect_error(.distance_scaled("a"))
  testthat::expect_error(.distance_scaled(TRUE))
  testthat::expect_error(.distance_scaled(1:10, to = "a"))
  testthat::expect_error(.distance_scaled(1:10, to = 1))
  testthat::expect_error(.distance_scaled(1:10, to = 1:3))
  testthat::expect_error(.distance_scaled(1:10, two_sided = 1))
  testthat::expect_error(.distance_scaled(1:10, two_sided = c(TRUE, FALSE)))
})

testthat::test_that("rescale_distance", {
  # valid
  testthat::expect_equal(
    .rescale_distance(1:7, dist_from = 3),
    c(0.5, 0.25, 0, 0.25, 0.5, 0.75, 1)
  )
  testthat::expect_equal(
    .rescale_distance(1:7, dist_from = 3, two_sided = TRUE), 
    c(1, 0.5, 0, 0.25, 0.5, 0.75, 1)
  )
  testthat::expect_equal(
    .rescale_distance(sort(c(1:7, 1:3)), dist_from = "median"), 
    c(0.5, 0.5, 0.25, 0.25, 0, 0, 0.25, 0.5, 0.75, 1)
  )
  testthat::expect_equal(
    .rescale_distance(sort(c(1:7, 1:3)), dist_from = "median", two_sided = TRUE), 
    c(1, 1, 0.5, 0.5, 0, 0, 0.25, 0.5, 0.75, 1)
  )

  # errors
  testthat::expect_error(.rescale_distance(-2:2))
  testthat::expect_error(.rescale_distance(-2:2, dist_from = 1:2))
  testthat::expect_error(.rescale_distance(-2:2, dist_from = "max"))
})

testthat::test_that("transformation_vars", {
  test_df <- tibble::tibble(
    transformation = c("transform1","transform1","transform2", NA_character_),
    source_variable = c("var1", "var2", "var3", "var4")
  )

  # valid
  testthat::expect_equal(
    .transformation_vars("transform1", test_df),
    c("var1", "var2")
  )
  testthat::expect_equal(.transformation_vars(NA_character_, test_df), "var4")

  # errors
  testthat::expect_error(.transformation_vars(1, test_df))
  testthat::expect_error(
    .transformation_vars(c("transform1", "transform2", test_df))
  )
  testthat::expect_error(.transformation_vars("transform1", 1))
  testthat::expect_error(
    .transformation_vars("transform1", test_df["source_variable"])
  )
  testthat::expect_error(
    .transformation_vars("transform1", test_df["transformation"])
  )
  testthat::expect_error(.transformation_vars("transformA", test_df))
})

testthat::test_that("scale_value", {
  # valid
  testthat::expect_equal(scale_value(1:3, NULL), c(0, 0.5, 1))
  testthat::expect_equal(scale_value(1:3, NA_character_), c(0, 0.5, 1))
  testthat::expect_equal(scale_value(1:3, "bti_rescale"), c(0, 0.4, 0.8))
  testthat::expect_equal(
    scale_value(seq(0.3, 0.7, 0.1), "gender_parity"), c(0, 0.5, 1, 0.5, 0)
  )
  testthat::expect_equal(
    scale_value(c(0.5, 0.75, 1, 2, 3), "gender_payratio"), c(0, 0.5, 1, 0.5, 0)
  )
  testthat::expect_equal(scale_value(1:3, "invert"), c(1, 0.5, 0))
  testthat::expect_equal(
    scale_value(sort(c(1:7, 1:3)), "median_distance"), 
    c(0, 0, 0.5, 0.5, 1, 1, 0.75, 0.5, 0.25, 0)
  )
  testthat::expect_equal(scale_value(1:3, "sgi_rescale"), c(0.3, 0.65, 1))

  # errors
  testthat::expect_error(scale_value(1:3, 1))
  testthat::expect_error(scale_value(1:3, c("abc", "def")))
  testthat::expect_error(scale_value(LETTERS, NULL))
})

testthat::test_that("scale_data", {
  test_df <- tibble::tibble(
    cc_iso3c = c("GBR", "FRA", "DNK"),
    ref_year = rep(2023, 3),
    value = 1:3
  )
  expect_df <- tibble::tibble(
    cc_iso3c = c("GBR", "FRA", "DNK"),
    ref_year = rep(2023, 3),
    value = c(0, 0.5, 1)
  )
  # valid
  testthat::expect_equal(scale_data(test_df, NA_character_), expect_df)
  # errors
  testthat::expect_error(scale_data(1, "transform"))
  testthat::expect_error(scale_data(test_df, 1))
  testthat::expect_error(scale_data(test_df, c("transform1", "transform2")))
})

testthat::test_that("gender variables", {
  test_df1 <- tibble::tibble(
    cc_iso3c = c("GBR", "GBR", "FRA", "DNK"),
    ref_year = rep(2023, 4),
    variable = c("ilo_pubad_female", "ilo_pse_female", "ilo_pubad_female", "ilo_pse_female"),
    value = 1:4
  )
  expect_df1 <- tibble::tibble(
    cc_iso3c = c("GBR", "FRA", "DNK"),
    ref_year = rep(2023, 3),
   variable =  rep("zzz_gender_pubadmin", 3),
    value = c(1, 3, 4)
  )
  test_df2 <- tibble::tibble(
    cc_iso3c = c("GBR", "GBR", "FRA", "DNK"),
    ref_year = rep(2023, 4),
    variable = c("eige_senior_women", "ilo_ps_snrmgr_female", 
      "eige_senior_women", "ilo_ps_snrmgr_female"),
    value = 1:4
  )
  expect_df2 <- tibble::tibble(
    cc_iso3c = c("GBR", "FRA", "DNK"),
    ref_year = rep(2023, 3),
   variable =  rep("zzz_gender_senior", 3),
    value = c(1, 3, 4)
  )

  # valid generics
  testthat::expect_equal(.gender_all(test_df1), expect_df1)
  testthat::expect_equal(.gender_senior(test_df2), expect_df2)
  # valid overall
  testthat::expect_equal(gender_vars(test_df1, "zzz_gender_all"), expect_df1)
  testthat::expect_equal(gender_vars(test_df2, "zzz_gender_senior"), expect_df2)
  testthat::expect_equal(gender_vars(test_df1, NULL), test_df1)
  testthat::expect_equal(gender_vars(test_df1, NA_character_), test_df1)
  testthat::expect_equal(gender_vars(test_df1, "transform1"), test_df1)

  # errors
  testthat::expect_error(gender_vars(test_df1, "zzz_gender_senior"))
  testthat::expect_error(gender_vars(test_df2, "zzz_gender_all"))
  testthat::expect_error(gender_vars(1, "zzz_gender_all"))
  testthat::expect_error(gender_vars(test_df1, 1))
  testthat::expect_error(gender_vars(test_df1, c("zzz_gender_all", "zzz_gender_senior")))
})

