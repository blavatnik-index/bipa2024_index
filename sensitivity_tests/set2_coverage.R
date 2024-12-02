# sensitivity tests
# set 2: vary country coverage

# 2.1: use only the data quality score
sens2_1_countries <- dqc_global$dq_data |>
  dplyr::filter(
    x_a >= dqc_global$threshold_q & 
      !(cc_iso3c %in% dqc_global$excluded_cc) # maintain HKG exclusion
  ) |>
  dplyr::pull(cc_iso3c)

sens2_1_metrics <- calculate_metrics(
  metrics_base,
  countries = sens2_1_countries,
  scope = "global",
  theme_dq = dqc_global$dq_data_themes
)

sens2_1_index <- sens2_1_metrics |>
  calculate_tier("indicator") |>
  calculate_tier("theme") |>
  calculate_tier("domain") |>
  calculate_tier("index") |>
  dplyr::mutate(sens_test = "2_1_dqonly")

# 2.2: use only the percent metrics
sens2_2_countries <- dqc_global$dq_data |>
  dplyr::filter(
    p_m >= dqc_global$threshold_m &
      !(cc_iso3c %in% dqc_global$excluded_cc) # maintain HKG exclusion
  ) |>
  dplyr::pull(cc_iso3c)

sens2_2_metrics <- calculate_metrics(
  metrics_base,
  countries = sens2_2_countries,
  scope = "global",
  theme_dq = dqc_global$dq_data_themes
)

sens2_2_index <- sens2_2_metrics |>
  calculate_tier("indicator") |>
  calculate_tier("theme") |>
  calculate_tier("domain") |>
  calculate_tier("index") |>
  dplyr::mutate(sens_test = "2_2_pmetsonly")

# 2.3: raise dq threshold to 2/3rds
sens2_3_countries <- dqc_global$dq_data |>
  dplyr::filter(
    x_a >= (dqc_global$dq_ref$x_a * 2/3) & p_m >= dqc_global$threshold_m &
      !(cc_iso3c %in% dqc_global$excluded_cc) # maintain HKG exclusion
  ) |>
  dplyr::pull(cc_iso3c)

sens2_3_metrics <- calculate_metrics(
  metrics_base,
  countries = sens2_3_countries,
  scope = "global",
  theme_dq = dqc_global$dq_data_themes
)

sens2_3_index <- sens2_3_metrics |>
  calculate_tier("indicator") |>
  calculate_tier("theme") |>
  calculate_tier("domain") |>
  calculate_tier("index") |>
  dplyr::mutate(sens_test = "2_3_dq23rds")

# 2.4: only countries with dq grade of A/B/C

sens2_4_countries <- dqc_global$dq_data |>
  dplyr::filter(dq_grade == "A" | dq_grade == "B" | dq_grade == "C") |>
  dplyr::filter(!(cc_iso3c %in% dqc_global$excluded_cc)) |>
  dplyr::pull(cc_iso3c)

sens2_4_metrics <- calculate_metrics(
  metrics_base,
  countries = sens2_4_countries,
  scope = "global",
  theme_dq = dqc_global$dq_data_themes
)

sens2_4_index <- sens2_4_metrics |>
  calculate_tier("indicator") |>
  calculate_tier("theme") |>
  calculate_tier("domain") |>
  calculate_tier("index") |>
  dplyr::mutate(sens_test = "2_4_dqABC")
