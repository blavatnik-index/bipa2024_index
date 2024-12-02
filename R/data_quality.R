
dq_countries <- function(df, scope = c("global", "oecd_eu", "all"), 
                     metrics_df, threshold_q = NULL, threshold_m = NULL,
                     threshold_t = NULL, ignore_cc = NULL) {
  
  scope <- rlang::arg_match(scope)
  
  if (scope == "global") {
    df <- df |>
      dplyr::filter(scope == "global" & !is.na(metric))
    metrics_df <- metrics_df |>
      dplyr::filter(scope == "global" & !is.na(metric))
  }


  exclude_cc <- .get_exclude_cc(df, ignore_cc)
  
  metrics_df <- metrics_df |>
    dplyr::mutate(cc_iso3c = "ZZZ_REF", .before = 1)

  total_metrics <- nrow(metrics_df)
  total_themes <- metrics_df |>
    dplyr::mutate(structure_id = floor(structure_id/100) * 100) |>
    dplyr::distinct(structure_id) |>
    nrow()

  dq_ref_themes <- df |>
    dplyr::mutate(structure_id = floor(structure_id)) |>
    dplyr::distinct(structure_id) |>
    dplyr::mutate(structure_id = floor(structure_id/100)*100) |>
    dplyr::summarise(i_T = dplyr::n(), .by = structure_id)

  dq_ref <- metrics_df |>
    .dqc_indicators() |>
    .dqc_themes(ref_df = dq_ref_themes, threshold_t = NULL) |>
    .dqc_overall(total_metrics, total_themes)

  if (is.null(threshold_q)) {
    threshold_q <- dq_ref$x_a / 2
  }

  if (is.null(threshold_m)) {
    threshold_m <- 2/3
  }

  if (is.null(threshold_t)) {
    threshold_t <- 1/5
  }

  dq_data_themes <- df |>
    .dqc_indicators() |>
    .dqc_themes(ref_df = dq_ref_themes, threshold_t = threshold_t)

  dq_data <- dq_data_themes |>
    dplyr::filter(include) |>
    .dqc_overall(total_metrics, total_themes) |>
    dplyr::mutate(
      above_threshold = x_a >= threshold_q & p_m >= threshold_m,
      included = above_threshold & !(cc_iso3c %in% exclude_cc)
    ) |>
    .dqc_grade(threshold_q, threshold_m)

  out <- list(
    n_countries = sum(dq_data$included),
    countries = sort(dq_data$cc_iso3c[dq_data$included]),
    dq_data = dq_data,
    dq_ref = dq_ref,
    threshold_q = threshold_q,
    threshold_m = threshold_m,
    dq_data_themes = dq_data_themes,
    excluded_cc = exclude_cc
  )

  return(out)

}

# calculate the number of metrics by indicator
.dqc_indicators <- function(df) {
  
  df <- df |>
  dplyr::mutate(
    structure_id = floor(structure_id)
  ) |>
  dplyr::summarise(
    m_i = dplyr::n(), # number of metrics for indicator
    .by = c(cc_iso3c, structure_id)
  ) |>
  tidyr::complete(cc_iso3c, structure_id, fill = list(m_i = 0))
  
  return(df)
  
}

# calculate data quality for themes
# input df should be piped from .dq_indicators
.dqc_themes <- function(df, ref_df, threshold_t) {

  df <- df |>
    dplyr::mutate(
      i_t = m_i > 0, # indicator has any data
      structure_id = floor(structure_id/100) * 100
    ) |>
    dplyr::summarise(
      m_t = sum(m_i), # number of metrics in theme
      i_t = sum(i_t), # number of indicators in theme
      .by = c(cc_iso3c, structure_id)
    ) |>
    dplyr::mutate(
      p_t = m_t / max(m_t), .by = structure_id # percent of metrics for the theme
    )
  
  df <- df |>
    dplyr::left_join(ref_df, by = "structure_id") |>
    dplyr::mutate(
      x_t = ((m_t - i_t + 1) ^ 2) / i_T # theme information quotient
    )
  
  if (!is.null(threshold_t)) {
    df <- df |> dplyr::mutate(include = p_t >= threshold_t)
  } 

  return(df)

}

# calculate final data quality indicators
# input df should be piped to from .dq_theme_coverage
.dqc_overall <- function(df, n_metrics, n_themes) {

  df <- df |>
    dplyr::filter(i_t > 0) |>
    dplyr::summarise(
      m_a = sum(m_t), # total number of metrics
      p_m = m_a / n_metrics, # total percent of metrics
      i_a = sum(i_t), # total number of indicators
      n_t = dplyr::n(), # number of themes
      x_a = sum(x_t), # sum of information quotients
      .by = cc_iso3c
    ) |>
    # dplyr::mutate(
    #   q_a = x_a * (n_t / n_themes) # coverage adjusted information quotient
    # ) |>
    dplyr::arrange(cc_iso3c)
  
  return(df)

}

.dqc_grade <- function(df, threshold_q, threshold_m, show_intervals = FALSE) {
  
  q_thresholds <- c(
    quantile(df$x_a[!(df$above_threshold)], c(0.5)),
    threshold_q,
    quantile(df$x_a[df$above_threshold], c(0.25, 0.5, 0.75))
  )
  names(q_thresholds) <- rev(LETTERS[1:5])

  m_thresholds <- c(
    quantile(df$p_m[!(df$above_threshold)], c(0.5)),
    threshold_m,
    quantile(df$p_m[df$above_threshold], c(0.25, 0.5, 0.75))
  )
  names(m_thresholds) <- rev(LETTERS[1:5])

  df <- df |>
    dplyr::mutate(
      dq_grade = dplyr::case_when(
        x_a >= q_thresholds[5] & p_m >= m_thresholds[5] ~ "A",
        x_a >= q_thresholds[4] & p_m >= m_thresholds[4] ~ "B",
        x_a >= q_thresholds[3] & p_m >= m_thresholds[3] ~ "C",
        x_a >= q_thresholds[2] & p_m >= m_thresholds[2] ~ "D",
        x_a >= q_thresholds[1] & p_m >= m_thresholds[1] ~ "E",
        !is.na(x_a) & !is.na(p_m) ~ "F",
        TRUE ~ NA_character_
      )
    )
  
  if (show_intervals) {
    return(
      list(
        q_thresholds = q_thresholds, 
        m_thresholds = m_thresholds,
        frequency = table(df$dq_grade),
        frequency_pc = table(df$dq_grade)/nrow(df)
      )
    )
  } else {
    return(df)
  }
  
}

.get_exclude_cc <- function(df, ignore_cc) {

  exclude_cc <- character()
  
  if (!is.null(ignore_cc)) {
    if (!is.character(ignore_cc)) {
      cli::cli_abort(c(
        "x" = "{.arg ignore_cc} must be a character vector"
      ))
    }
    valid_ignore <- ignore_cc %in% unique(df$cc_iso3c)
    if (sum(valid_ignore) == 0) {
      cli::cli_warn(c(
        "x" = "{.arg ignore_cc} does not contain any codes included in {.arg df}",
        "!" = "codes not matching: {.arg ignore_cc}",
        "i" = "will proceed without excluding any data"
      ))
    } else if (sum(valid_ignore) != length(ignore_cc)) {
      cli::cli_warn(c(
        "x" = "{.arg ignore_cc} contains country codes not included in {.arg df}",
        "!" = "codes not matching: {ignore_cc[!valid_ignore]}",
        "i" = "excluding data for: {ignore_cc[valid_ignore]}"
      ))
      exclude_cc <- ignore_cc[valid_ignore]
    } else {
      cli::cli_alert_info(
        "excluding data for: {ignore_cc}"
      )
      exclude_cc <- ignore_cc[valid_ignore]
    }
  }

  return(exclude_cc)

}


dq_exclude_lowdata <- function(df, theme_dq) {

  excluded_themes <- theme_dq |>
    dplyr::filter(!include) |>
    dplyr::mutate(cc_theme = paste(cc_iso3c, structure_id, sep = "_")) |>
    dplyr::pull(cc_theme)

  df <- df |>
    dplyr::mutate(
      cc_theme = paste(cc_iso3c, floor(structure_id/100) * 100, sep = "_")
    ) |>
    dplyr::filter(!(cc_theme %in% excluded_themes)) |>
    dplyr::select(-cc_theme)

  return(df)

}
