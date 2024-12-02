# sensitivity tests
# set 1: rescaling base data and aggregations

# 1.1: z-score normalisation
# convert base metrics to normalised scores
metrics_base_z <- metrics_base |>
  dplyr::filter(cc_iso3c %in% dqc_global$countries) |>
  dplyr::mutate(
    raw_value = value,
    value_sd = sd(value, na.rm = TRUE),
    value_mean = mean(value, na.rm = TRUE),
    .by = structure_id
  ) |>
  dplyr::mutate(
    value = (value - value_mean) / value_sd
  )

sens1_1_metrics <- calculate_metrics(
  metrics_base_z |> dplyr::select(-raw_value, -value_sd, -value_mean),
  countries = dqc_global$countries,
  scope = "global",
  theme_dq = dqc_global$dq_data_themes
)

sens1_1_index <- sens1_1_metrics |>
  calculate_tier("indicator") |>
  calculate_tier("theme") |>
  calculate_tier("domain") |>
  calculate_tier("index") |>
  dplyr::mutate(sens_test = "1_1_zscore")

# 1.2: ranked data
# rank metrics (to account for inversion and distance transformations) and
# then convert back to 0-1 scale (adjust for the BTI/SGI scaling)
sens1_2_metrics <- global_metrics |>
  dplyr::mutate(raw_value = value) |>
  dplyr::mutate(
    value = dplyr::case_when(
      transformation == "bti_rescale" ~ scales::rescale(-rank, c(0, 0.8)),
      transformation == "sgi_rescale" ~ scales::rescale(-rank, c(0.3, 1)),
      TRUE ~ scales::rescale(-rank, c(0, 1))
    ),
    .by = structure_id
  ) |>
  dplyr::mutate(value = round(value, 2))

sens1_2_index <- sens1_2_metrics |>
  calculate_tier("indicator") |>
  calculate_tier("theme") |>
  calculate_tier("domain") |>
  calculate_tier("index") |>
  dplyr::mutate(sens_test = "1_2_ranked")

# 1.3: rescale after aggregation
sens1_3_index <- global_metrics |>
  calculate_tier("indicator") |>
  dplyr::mutate(value = scales::rescale(value), .by = structure_id) |>
  calculate_tier("theme") |>
  dplyr::mutate(value = scales::rescale(value), .by = structure_id) |>
  calculate_tier("domain") |>
  dplyr::mutate(value = scales::rescale(value), .by = structure_id) |>
  calculate_tier("index") |>
  dplyr::mutate(
    value = scales::rescale(value),
    value = round(value, 2),
    rank = rank(-value, ties.method = "min")
  ) |>
  dplyr::arrange(-value, cc_iso3c) |>
  dplyr::mutate(sens_test = "1_3_tier01")

# 1.4: geometric mean
sens1_4_index <- global_metrics |>
  # indicators
  dplyr::mutate(
    structure_id = floor(structure_id)
  ) |>
  dplyr::summarise(
    value = round(psych::geometric.mean(value + 1), 2) - 1,
    .by = c(structure_id, cc_iso3c)
  ) |>
  # themes
  dplyr::mutate(
    structure_id = floor(structure_id/100)*100
  ) |>
  dplyr::summarise(
    value = round(psych::geometric.mean(value + 1), 2) - 1,
    .by = c(structure_id, cc_iso3c)
  ) |>
  # domains
  dplyr::mutate(
    structure_id = floor(structure_id/10000)*10000
  ) |>
  dplyr::summarise(
    value = round(psych::geometric.mean(value + 1), 2) - 1,
    .by = c(structure_id, cc_iso3c)
  ) |>
  # index
  dplyr::mutate(
    structure_id = floor(structure_id/100000)*100000
  ) |>
  dplyr::summarise(
    value = round(psych::geometric.mean(value + 1), 2) - 1,
    .by = c(structure_id, cc_iso3c)
  ) |>
  dplyr::mutate(
    rank = rank(-value, ties.method = "min")
  ) |>
  dplyr::arrange(-value, cc_iso3c) |>
  dplyr::mutate(sens_test = "1_4_geomean")
