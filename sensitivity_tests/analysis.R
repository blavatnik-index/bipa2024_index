# run this only after you've run each set of sensitivity tests

sensitivity_tests <- dplyr::bind_rows(
  sens1_1_index,
  sens1_2_index,
  sens1_3_index,
  sens1_4_index,
  sens2_1_index,
  sens2_2_index,
  sens2_3_index,
  sens2_4_index,
  sens3_1_index,
  sens3_2_index,
  sens3_3_index,
  sens3_4_index,
  sens3_5_index,
  sens4_1_index,
  sens4_2_index
)

sensitivity_analysis_base <- sensitivity_tests |>
  dplyr::left_join(
    global_index, 
    by = c("cc_iso3c", "structure_id"), suffix = c("_sens", "_final")
  ) |>
  dplyr::mutate(
    # need to rescale value_final for test 1.3 (data re-scaled at each tier)
    value_final_raw = value_final,
    value_final = dplyr::if_else(
      sens_test == "1_3_tier01",
      scales::rescale(value_final, c(0, 1)),
      value_final
    ),
    # need to re-calc rank_sens for tests 2.1 and 2.2 (increased country_coverage)
    rank_sens_raw = rank_sens,
    value_sens_x = dplyr::if_else(is.na(value_final), NA_real_, value_sens),
    rank_sens = dplyr::if_else(
      sens_test == "2_1_dqonly" | sens_test == "2_2_pmetsonly",
      rank(-value_sens_x, ties.method = "min"),
      rank_sens
    ),
    # need to rescale rank_final for tests 2.3 and 2.4 (reduced_country_coverage)
    rank_final_raw = rank_final,
    rank_final = dplyr::if_else(
      sens_test == "2_3_dq23rds" | sens_test == "2_4_dqABC",
      rank(-value_final, ties.method = "min"),
      rank_final
    ),
    .by = sens_test
  ) |>
  dplyr::mutate(
    value_diff = value_final - value_sens,
    value_diff_abs = abs(value_diff),
    rank_diff = rank_final - rank_sens,
    rank_diff_abs = abs(rank_diff)
  )

sensitivity_analysis <- sensitivity_analysis_base |>
  tidyr::nest(.by = sens_test) |>
  dplyr::mutate(
    n_countries = purrr::map_dbl(
      .x = data, .f = ~sum(!is.na(.x$value_sens))
    ),
    n_value_diff = purrr::map_dbl(
      .x = data, .f = ~sum(.x$value_diff != 0, na.rm = TRUE)
    ),
    n_value_diff5 = purrr::map_dbl(
      .x = data, .f = ~sum(.x$value_diff_abs >= 0.05, na.rm = TRUE)
    ),
    value_diff = purrr::map_dbl(
      .x = data, .f = ~mean(.x$value_diff, na.rm = TRUE)
    ),
    value_diff_abs = purrr::map_dbl(
      .x = data, .f = ~mean(.x$value_diff_abs, na.rm = TRUE)
    ),
    n_rank_diff = purrr::map_dbl(
      .x = data, .f = ~sum(.x$rank_diff != 0, na.rm = TRUE)
    ),
    n_rank_diff5 = purrr::map_dbl(
      .x = data, .f = ~sum(.x$rank_diff >= 5, na.rm = TRUE)
    ),
    rank_diff = purrr::map_dbl(
      .x = data, .f = ~mean(.x$rank_diff, na.rm = TRUE)
    ),
    rank_diff_abs = purrr::map_dbl(
      .x = data, .f = ~mean(.x$rank_diff_abs, na.rm = TRUE)
    ),
    corr_pearson = purrr::map(
      .x = data, .f = ~cor.test(.x$value_sens, .x$value_final)
    ),
    corr_kendall = purrr::map(
      .x = data,
      .f = ~cor.test(.x$value_sens, .x$value_final, method = "kendall")
    ),
    r_pearson = purrr::map_dbl(.x = corr_pearson, .f = ~.x$estimate),
    p_pearson = purrr::map_dbl(.x = corr_pearson, .f = ~.x$p.value),
    sig_pearson = dplyr::case_when(
      p_pearson <= 0.001 ~ "***",
      p_pearson <= 0.01 ~ "**",
      p_pearson <= 0.05 ~ "*"
    ),
    r_kendall = purrr::map_dbl(.x = corr_kendall, .f = ~.x$estimate),
    p_kendall = purrr::map_dbl(.x = corr_kendall, .f = ~.x$p.value),
    sig_kendall = dplyr::case_when(
      p_kendall <= 0.001 ~ "***",
      p_kendall <= 0.01 ~ "**",
      p_kendall <= 0.05 ~ "*"
    )
  )

sens_labels <- c(
  "1_1_zscore" = "1.1 Z-score data",
  "1_2_ranked" = "1.2 Ranked data",
  "1_3_tier01" = "1.3 Tier rescale",
  "1_4_geomean" = "1.4 Geometric mean",
  "2_1_dqonly" = "2.1 DQ score",
  "2_2_pmetsonly" = "2.2 Percent metrics",
  "2_3_dq23rds" = "2.3 DQ at 2/3rds",
  "2_4_dqABC" = "2.4 DQ grade A-C",
  "3_1_impsimple" = "3.1 Simple imputation",
  "3_2_imppmm" = "3.2 PMM imputation",
  "3_3_impcart" = "3.3 CART imputation",
  "3_4_complmets" = "3.4 Complete metrics",
  "3_5_complinds" = "3.5 Complete indicators",
  "4_1_nowgt" = "4.1 No weighting",
  "4_2_capwgt" = "4.2 Capped weighting"
)

sensitivity_analysis_results <- sensitivity_analysis |> 
  dplyr::mutate(
    sens_test_label = sens_labels[sens_test],
    n_countries = n_countries - nrow(global_index),
    n_countries = dplyr::case_when(
      n_countries > 0 ~ paste0("+", n_countries),
      n_countries == 0 ~ "",
      TRUE ~ as.character(n_countries)
    ),
    across(
      c(value_diff, value_diff_abs), 
      ~scales::number(.x, 0.01)
    ), 
    across(
      c(rank_diff, rank_diff_abs), 
      ~scales::number(.x, 0.1)
    ), 
    out_pearson = paste(scales::number(r_pearson, 0.001)), 
    out_kendall = paste(scales::number(r_kendall, 0.001))) |>
  dplyr::select(
    sens_test, sens_test_label, n_countries,
    n_value_diff, n_value_diff5, value_diff, value_diff_abs,
    n_rank_diff, n_rank_diff5, rank_diff, rank_diff_abs,
    out_pearson, p_pearson, out_kendall, p_kendall
  )

readr::write_excel_csv(sensitivity_analysis_results, "data_out/bipa2024_sensitivity_results.csv")


ggplot(
  sensitivity_analysis_base |> 
    tidyr::drop_na() |>
    dplyr::mutate(sens_set = substr(sens_test, 1, 1))
) + 
  geom_vline(xintercept = 0, colour = "#999999") +
  geom_density(
    aes(x = value_diff),
    adjust = 2, colour = "#00629B", fill = "#00629B", alpha = 0.25
  ) +
  scale_x_continuous(breaks = c(-0.1, 0, 0.1)) +
  facet_wrap(
    vars(sens_test), scales = "fixed",
    labeller = as_labeller(sens_labels)
  ) +
  labs(
    x = "Difference in value",
    y = "Density"
  ) +
  theme_minimal(base_size = 10, base_family = "Open Sans") +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    strip.text = element_text(face = "bold", hjust = 0),
    panel.background = element_rect(fill = NA, colour = "#e3e3e3")
  )

ggplot(
  sensitivity_analysis_base |> 
    tidyr::drop_na() |>
    dplyr::mutate(sens_set = substr(sens_test, 1, 1))
) + 
  geom_vline(xintercept = 0, colour = "#999999") +
  geom_density(
    aes(x = rank_diff),
    adjust = 2, colour = "#00629B", fill = "#00629B", alpha = 0.25
  ) +
  facet_wrap(
    vars(sens_test), scales = "fixed",
    labeller = as_labeller(sens_labels)
  ) +
  labs(
    x = "Difference in rank",
    y = "Density"
  ) +
  theme_minimal(base_size = 10, base_family = "Open Sans") +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    strip.text = element_text(face = "bold", hjust = 0),
    panel.background = element_rect(fill = NA, colour = "#e3e3e3")
  )

ggplot(
  sensitivity_analysis_base |> tidyr::drop_na(),
  aes(x = value_sens, y = value_final_raw)
) + 
  geom_count(alpha = 0.25, colour = "#00629B") +
  scale_x_continuous(limits = c(0, 1), breaks = c(0, 1)) +
  scale_y_continuous(limits = c(0, 1), breaks = c(0, 1)) +
  coord_fixed() +
  facet_wrap(
    vars(sens_test), scales = "fixed",
    labeller = as_labeller(sens_labels)
  ) +
  labs(x = "Index score in sensitivity test", y = "Index score in final model") +
  theme_minimal(base_size = 10, base_family = "Open Sans") +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    strip.text = element_text(face = "bold", hjust = 0),
    panel.background = element_rect(fill = NA, colour = "#e3e3e3"),
    legend.position = "none"
  )