
# source data
source_files <- dir(
  "../bipa2024-sourcedata/data_out", pattern = "\\.csv", full.names = TRUE
)
source_data <- vroom::vroom(source_files)

check_df(
  source_data, 
  c("cc_iso3c" = "character", "ref_year" = "numeric", "variable" = "character",
  "value" = "numeric"),
  chk_cc = cc_ref$cc_iso3c
)
check_source_data(source_data, metrics_meta)

# gender pre-processing
data_preproc <- source_data |>
  dplyr::left_join(
    metrics_meta |> dplyr::select(source_variable, transformation),
    by = dplyr::join_by(variable == source_variable)
    ) |>
  tidyr::nest(.by = transformation) |>
  dplyr::mutate(
    new_data = purrr::map2(
      .x = data,
      .y = transformation,
      .f = ~gender_vars(.x, .y)
    )
  ) |>
  dplyr::select(-data) |>
  tidyr::unnest(new_data) |>
  dplyr::select(-transformation)

# create metrics base dataset
metrics_base <- metrics_meta |>
  dplyr::filter(!grepl("zzz_gender", transformation)) |>
  dplyr::select(structure_id, metric, source_variable, scope, transformation) |>
  dplyr::left_join(
    data_preproc, 
    by = dplyr::join_by(source_variable == variable)
  ) |>
  dplyr::filter(ref_year >= 2019)

check_df(
  metrics_base,
  c(
    "structure_id" = "numeric",
    "metric" = "character",
    "source_variable" = "character",
    "scope" = "character",
    "transformation" = "character",
    "cc_iso3c" = "character",
    "ref_year" = "numeric",
    "value" = "numeric"
  ),
  chk_cc = cc_ref$cc_iso3c
)
