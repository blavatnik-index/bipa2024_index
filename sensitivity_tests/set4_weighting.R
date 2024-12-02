# sensitivity tests
# set 4: weighting

# 4.1: simple mean
# ignore implicit weighting structure

sens4_1_index <- global_metrics |>
  dplyr::summarise(
    structure_id = 0,
    value = round(mean(value), 2),
    .by = c(cc_iso3c)
  ) |>
  dplyr::mutate(
    rank = rank(-value, ties.method = "min"), .by = structure_id
  ) |>
  dplyr::arrange(-value, cc_iso3c) |>
  dplyr::mutate(sens_test = "4_1_nowgt")

# 4.2: capped weighting

metric_weights <- metrics_meta |>
  dplyr::filter(scope == "global" & !is.na(metric)) |>
  dplyr::select(structure_id) |>
  dplyr::mutate(
    metric_id = structure_id,
    structure_id = floor(structure_id)
  ) |>
  dplyr::mutate(
    rwgt_ind = dplyr::n(),
    .by = structure_id
  ) |>
  tidyr::nest(.by = structure_id) |>
  dplyr::mutate(
    indicator_id = structure_id,
    structure_id = floor(structure_id/100) * 100
  ) |>
  dplyr::mutate(
    rwgt_thm = dplyr::n(),
    .by = structure_id
  ) |>
  tidyr::nest(.by = structure_id) |>
  dplyr::mutate(
    theme_id = structure_id,
    structure_id = floor(structure_id/10000) * 10000
  ) |>
  dplyr::mutate(
    rwgt_dom = dplyr::n(),
    .by = structure_id
  ) |>
  tidyr::nest(.by = structure_id) |>
  dplyr::mutate(
    domain_id = structure_id,
    rwgt_idx = dplyr::n()
  ) |>
  tidyr::unnest(data) |>
  tidyr::unnest(data) |>
  tidyr::unnest(data) |>
  dplyr::mutate(
    rwgt_total = 1 / (rwgt_ind * rwgt_thm * rwgt_dom * rwgt_idx),
    cwgt_total = dplyr::if_else(rwgt_total >= 0.02, 0.02, rwgt_total),
    nwgt_idx = dplyr::if_else(
      rwgt_total >= 0.02, 0.02,
      rwgt_total + ((1 - sum(cwgt_total))/sum(rwgt_total < 0.02))
    )
  ) |>
  dplyr::select(structure_id = metric_id, contains("wgt"))

indicator_weights <- metric_weights |>
  dplyr::mutate(
    structure_id = floor(structure_id)
  ) |>
  dplyr::summarise(
    nwgt_idx = sum(nwgt_idx),
    .by = structure_id
  ) |>
  dplyr::select(structure_id, contains("wgt"))

sens4_2_index <- sens3_3_indicators |>
  dplyr::left_join(indicator_weights, by = "structure_id") |>
  dplyr::summarise(
    structure_id = 0,
    value = round(sum(value * nwgt_idx), 2),
    .by = c(cc_iso3c)
  ) |>
  dplyr::mutate(rank = rank(-value, ties.method = "min"), .by = structure_id) |>
  dplyr::arrange(-value, cc_iso3c) |>
  dplyr::mutate(sens_test = "4_2_capwgt")
