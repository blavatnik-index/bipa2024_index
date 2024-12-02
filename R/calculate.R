
calculate_tier <- function(df,
                           tier = c("indicator", "theme", "domain", "index"),
                           r = 2) {

  tier <- rlang::arg_match(tier)

  if (tier == "indicator") {
    check_df(df, c(
      cc_iso3c = "character",
      structure_id = "numeric",
      metric = "character",
      ref_year = "numeric",
      value = "numeric",
      rank = "numeric"
    ))
  } else {
    check_df(df, c(
      cc_iso3c = "character",
      structure_id = "numeric",
      value = "numeric",
      rank = "numeric"
    ))
  }

  .chk_tier_input(df$structure_id, tier)

  tier <- switch(tier,
    "indicator" = 1,
    "theme" = 100,
    "domain" = 10000,
    "index" = 100000
  )

  df <- df |>
    dplyr::mutate(structure_id = floor(structure_id/tier) * tier) |>
    dplyr::summarise(
      value = round(mean(value), r),
      .by = c(cc_iso3c, structure_id)
    ) |>
    dplyr::mutate(
      rank = rank(-value, ties.method = "min"),
      .by = structure_id
    ) |>
    dplyr::arrange(structure_id, rank, cc_iso3c)

  return(df)

}

calculate_metrics <- function(df, countries, theme_dq, r = 2) {

  # check df is as expected
  check_df(
    metrics_base, 
    columns = c(
      structure_id = "numeric",
      metric = "character",
      source_variable = "character",
      scope = "character",
      transformation = "character",
      cc_iso3c = "character",
      ref_year = "numeric",
      value = "numeric"
    )
  )

  # check theme_dq is as expected
  check_df(
    theme_dq, 
    columns = c(
      cc_iso3c = "character",
      structure_id = "numeric",
      m_t = "numeric",
      i_t = "numeric",
      p_t = "numeric",
      i_T = "numeric",
      x_t = "numeric",
      include = "logical"
    )
  )

  df |>
    dq_exclude_lowdata(theme_dq) |>
    dplyr::filter(cc_iso3c %in% countries) |>
    dplyr::filter(scope == "global") |>
    tidyr::nest(
      data = c(cc_iso3c, ref_year, value),
      .by = c(structure_id, metric, transformation)
    )|>
    dplyr::mutate(
      new_data = purrr::map2(
        .x = data,
        .y = transformation,
        .f = ~scale_data(.x, .y)
      )
    ) |>
    dplyr::select(-data) |>
    tidyr::unnest(new_data) |>
    dplyr::mutate(
      value = round(value, r)
    ) |>
    dplyr::mutate(
      rank = rank(-value, ties.method = "min"),
      .by = structure_id
    ) |>
    dplyr::arrange(
      structure_id, rank, cc_iso3c
    ) |>
    dplyr::select(cc_iso3c, structure_id, metric, ref_year, value, rank)

}
