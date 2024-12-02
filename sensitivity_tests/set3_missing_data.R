# sensitivity tests
# set 3: missing data

# 3.1: simple imputation
# indicators without a score are replaced by a score that is derived from
# 50% of their regional mean and 50% of the income group mean

sens3_1_indicators <- global_indicators |>
  tidyr::complete(cc_iso3c, structure_id) |>
  dplyr::left_join(cc_geo, by = "cc_iso3c") |>
  dplyr::left_join(cc_wb, by = "cc_iso3c") |>
  dplyr::mutate(
    geo_mean = mean(value, na.rm = TRUE), 
    .by = c(bipa_region, structure_id)
  ) |>
  dplyr::mutate(
    inc_mean = mean(value, na.rm = TRUE), 
    .by = c(income_group, structure_id)
  ) |>
  dplyr::mutate(
    impute = is.na(value),
    impute_value = round((0.5 * geo_mean) + (0.5 * inc_mean), 2),
    value = dplyr::if_else(impute, impute_value, value)
  ) |>
  dplyr::mutate(rank = rank(-value, ties.method = "min"), .by = structure_id) |>
  dplyr::select(cc_iso3c, structure_id, value, rank, geo_mean, inc_mean, impute)

sens3_1_index <- sens3_1_indicators |>
  dplyr::select(-geo_mean, -inc_mean, -impute) |>
  calculate_tier("theme") |>
  calculate_tier("domain") |>
  calculate_tier("index") |>
  dplyr::mutate(sens_test = "3_1_impsimple")

# 3.2 / 3.3 preparation

impute_base <- global_indicators |>
  dplyr::left_join(data_structure, by = "structure_id") |>
  dplyr::select(cc_iso3c, name, value) |>
  tidyr::pivot_wider(names_from = name, values_from = value)

# 3.2: PMM imputation
# predictive mean matching was used in InCiSE 2019 to handle missing data

impute_pmm_mids <- impute_base |> 
  mice::mice(method = "pmm")

sens3_2_indicators <- impute_pmm_mids |>
  mice::complete(action = "stacked") |>
  tidyr::pivot_longer(
    cols = -cc_iso3c, names_to = "name", values_to = "value"
  ) |>
  dplyr::summarise(
    value = round(mean(value, na.rm = TRUE), 2),
    .by = c(cc_iso3c, name)
  ) |>
  dplyr::left_join(data_structure, by = "name") |>
  dplyr::select(cc_iso3c, structure_id, value) |>
  dplyr::mutate(rank = rank(-value, ties.method = "min"), .by = structure_id)

sens3_2_index <- sens3_2_indicators |>
  calculate_tier("theme") |>
  calculate_tier("domain") |>
  calculate_tier("index") |>
  dplyr::mutate(sens_test = "3_2_imppmm")

# 3.3: CART imputation
# imputation using classification and regression trees

impute_cart_mids <- impute_base |> 
  mice::mice(method = "cart")

sens3_3_indicators <- impute_cart_mids |>
  mice::complete(action = "stacked") |>
  tidyr::pivot_longer(
    cols = -cc_iso3c, names_to = "name", values_to = "value"
  ) |>
  dplyr::summarise(
    value = round(mean(value, na.rm = TRUE), 2),
    .by = c(cc_iso3c, name)
  ) |>
  dplyr::left_join(data_structure, by = "name") |>
  dplyr::select(cc_iso3c, structure_id, value) |>
  dplyr::mutate(rank = rank(-value, ties.method = "min"), .by = structure_id)

sens3_3_index <- sens3_3_indicators |>
  calculate_tier("theme") |>
  calculate_tier("domain") |>
  calculate_tier("index") |>
  dplyr::mutate(sens_test = "3_3_impcart")

# 3.4: near-complete data only (metrics)

sens3_4_metrics <- global_metrics |>
  dplyr::add_count(structure_id) |>
  dplyr::filter(n == 120 | n == 119)

sens3_4_index <- sens3_4_metrics |>
  dplyr::summarise(
    structure_id = 0,
    value = round(mean(value), 2),
    .by = c(cc_iso3c)
  ) |>
  dplyr::mutate(rank = rank(-value, ties.method = "min")) |>
  dplyr::arrange(-value, cc_iso3c) |>
  dplyr::mutate(sens_test = "3_4_complmets")

# 3.5: near-complete data only (indicators)

sens3_5_indicators <- global_indicators |>
  dplyr::add_count(structure_id) |>
  dplyr::filter(n == 120 | n == 119)

sens3_5_index <- sens3_5_indicators |>
  dplyr::summarise(
    structure_id = 0,
    value = round(mean(value), 2),
    .by = c(cc_iso3c)
  ) |>
  dplyr::mutate(rank = rank(-value, ties.method = "min")) |>
  dplyr::arrange(-value, cc_iso3c) |>
  dplyr::mutate(sens_test = "3_5_complinds")
