
bipa2024_all <- dplyr::bind_rows(
  bipa2024_index,
  bipa2024_domains,
  bipa2024_themes,
  bipa2024_indicators,
  bipa2024_metrics |>
    dplyr::select(
      cc_iso3c, structure_id, value, rank
    )
) |>
  dplyr::add_count(structure_id, rank, name = "rank_n") |>
  dplyr::mutate(
    rank_label = dplyr::if_else(rank_n > 1, paste0("=", rank), as.character(rank))
  ) |>
  dplyr::select(-rank_n)

readr::write_excel_csv(bipa2024_all, "data_out/bipa2024_all_data.csv", na = "")

bipa2024_structure <- dplyr::bind_rows(
  data_structure,
  metrics_meta |>
    dplyr::select(structure_id, name = metric, label) |>
    dplyr::mutate(level = "metric", .after = structure_id)
) |>
  dplyr::filter(structure_id %in% bipa2024_all$structure_id) |>
  dplyr::arrange(structure_id)

readr::write_excel_csv(bipa2024_structure, "data_out/bipa2024_data_structure.csv")


idx_doms_wide <- bipa2024_index |>
  dplyr::rename(index_value = value, index_rank = rank) |>
  dplyr::left_join(
    bipa2024_domains |>
      dplyr::left_join(data_structure, by = "structure_id") |>
      dplyr::select(cc_iso3c, name, value) |>
      dplyr::mutate(name = paste(name, "value", sep = "_")) |>
      tidyr::pivot_wider(names_from = name, values_from = value),
    by = "cc_iso3c"
  ) |>
  dplyr::left_join(
    bipa2024_domains |>
      dplyr::left_join(data_structure, by = "structure_id") |>
      dplyr::select(cc_iso3c, name, rank) |>
      dplyr::mutate(name = paste(name, "rank", sep = "_")) |>
      tidyr::pivot_wider(names_from = name, values_from = rank),
    by = "cc_iso3c"
  ) |>
  dplyr::left_join(cc_ref, by = "cc_iso3c") |>
  dplyr::left_join(cc_geo, by = "cc_iso3c") |>
  dplyr::left_join(cc_wb, by = "cc_iso3c") |>
  dplyr::select(
    cc_iso3c, cc_name_short, bipa_region, income_group, 
    ends_with("value"), ends_with("rank")
  )

readr::write_excel_csv(idx_doms_wide, "data_out/bipa2024_index_domains_wide.csv")

idx_themes_wide <- bipa2024_index |>
  dplyr::rename(index_value = value, index_rank = rank) |>
  dplyr::left_join(
    bipa2024_themes |>
      dplyr::left_join(data_structure, by = "structure_id") |>
      dplyr::select(cc_iso3c, name, value) |>
      dplyr::mutate(name = paste(name, "value", sep = "_")) |>
      tidyr::pivot_wider(names_from = name, values_from = value),
    by = "cc_iso3c"
  ) |>
  dplyr::left_join(
    bipa2024_themes |>
      dplyr::left_join(data_structure, by = "structure_id") |>
      dplyr::select(cc_iso3c, name, rank) |>
      dplyr::mutate(name = paste(name, "rank", sep = "_")) |>
      tidyr::pivot_wider(names_from = name, values_from = rank),
    by = "cc_iso3c"
  ) |>
  dplyr::left_join(cc_ref, by = "cc_iso3c") |>
  dplyr::left_join(cc_geo, by = "cc_iso3c") |>
  dplyr::left_join(cc_wb, by = "cc_iso3c") |>
  dplyr::select(
    cc_iso3c, cc_name_short, bipa_region, income_group, 
    ends_with("value"), ends_with("rank")
  )

readr::write_excel_csv(idx_themes_wide, "data_out/bipa2024_index_themes_wide.csv")

dq_out <- dqc_bipa2024$dq_data |>
  dplyr::full_join(cc_ref, by = "cc_iso3c") |>
  dplyr::left_join(cc_geo, by = "cc_iso3c") |>
  dplyr::left_join(cc_wb, by = "cc_iso3c") |>
  dplyr::mutate(
    across(c(x_a, p_m), ~tidyr::replace_na(.x, 0)),
    cc_status = dplyr::if_else(
      grepl("^UN member", cc_status), cc_status, "Non UN-member entity"
    ),
    income_group = tidyr::replace_na(as.character(income_group), "Not classified"),
    included = tidyr::replace_na(included, FALSE),
    included = tolower(as.character(included))
  ) |>
  dplyr::select(
    cc_name_short, cc_iso3c, cc_status, bipa_region, income_group,
    dq_grade, x_a, p_m, included
  )

readr::write_excel_csv(dq_out, "data_out/bipa2024_dq_scores.csv")