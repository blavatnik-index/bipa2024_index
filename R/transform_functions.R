
scale_data <- function(df, transformation) {

  if(!is.data.frame(df)) {
    cli::cli_abort(c(
      "x" = "{.arg df} must be a data frame"
    ))
  }

  if (!rlang::is_scalar_character(transformation)){
    cli::cli_abort(c(
      "x" = "{.arg transformation} must be a character vector of length 1"
    ))
  }

  df |>
    dplyr::mutate(value = scale_value(value, transformation))

}

scale_value <- function(x, transformation = NULL) {

  if (is.null(transformation)) {
    transformation <- ""
  } else if (is.na(transformation)) {
    transformation <- ""
  } else if (!rlang::is_scalar_character(transformation)) {
    cli::cli_abort(c(
      "x" = "{.arg transformation} must be a character vector of length 1"
    ))
  }

  if (transformation == "bti_rescale") {
    .rescale_simple(x, to = c(0, 0.8))
  } else if (transformation == "gender_parity") {
    .rescale_distance(x, dist_from = 0.5, to = c(1, 0))
  } else if (transformation == "gender_payratio") {
    .rescale_distance(x, dist_from = 1, to = c(1, 0), two_sided = TRUE)
  } else if (transformation == "invert") {
    .rescale_simple(x, to = c(1, 0))
  } else if (transformation == "median_distance") {
    .rescale_distance(x, dist_from = "median", to = c(1, 0), two_sided = TRUE)
  } else if (transformation == "sgi_rescale") {
    .rescale_simple(x, to = c(0.3, 1))
  } else {
    .rescale_simple(x)
  }

}

# basic rescaling of a vector
.rescale_simple <- function(x, to = c(0, 1)) {

  if(!is.numeric(x)){
    cli::cli_abort(c(
      "x" = "{.arg x} must be a numeric vector"
    ))
  }

  if(!rlang::is_bare_double(to, 2)){
    cli::cli_abort(c(
      "x" = "{.arg to} must be a numeric vector of length 2"
    ))
  }

  scales::rescale(x, to = to)
}

# rescale based on a distance
.rescale_distance <- function(x, dist_from = NULL, to = c(0, 1), two_sided = FALSE) {

  if (is.null(dist_from)) {
    cli::cli_abort(
      c(
        "x" = "{.arg dist_from} cannot be {.cls NULL}",
        "!" = "{.arg dist_from} must either be a single numeric value or \"median\""
      )
    )
  }

  compare_mode <- NULL
  if (rlang::is_string(dist_from, "median")) {
    compare_mode <- "median"
  } else if (rlang::is_scalar_double(dist_from)) {
    compare_mode <- "numeric"
    distance <- dist_from
  }

  if (is.null(compare_mode)) {
    cli::cli_abort(
      c(
        "x" = "{.arg dist_from} cannot be {.val NULL}",
        "!" = "{.arg dist_from} must either be a single numeric value or \"median\"",
        "i" = "{.arg dist_from}: {.val {dist_from}}"
      )
    )
  }

  if (compare_mode == "median") {
    y <- x - median(x, na.rm = TRUE)
  } else {
    y <- x - distance
  }

  .distance_scaled(y, to = to, two_sided = two_sided)

}

# scale distances, use `two_sided = TRUE` to scale each side separately
.distance_scaled <- function(x, to = c(0, 1), two_sided = FALSE) {

  if (!is.numeric(x)) {
    cli::cli_abort(c(
      "x" = "{.arg x} must be a numeric vector")
    )
  }

  if (!rlang::is_bare_numeric(to, 2)) {
    cli::cli_abort(c(
      "x" = "{.arg to} must be a numeric vector of length 2"
    ))
  }

  if (!rlang::is_scalar_logical(two_sided)) {
    cli::cli_abort(c(
      "x" = "{.arg two_sided} must be {.cls TRUE} or {.cls FALSE}")
    )
  }
  
  if (two_sided) {
    x_p <- scales::rescale(x * (x >= 0), to = to)
    x_n <- scales::rescale(abs(x * (x <= 0)), to = to)
    y <- dplyr::if_else(x >= 0, x_p, x_n)
  } else {
    y <- scales::rescale(abs(x), to = to)
  }

  return(y)

}

gender_vars <- function(df, transformation = NULL) {
  
  if(!is.data.frame(df)) {
    cli::cli_abort(c(
      "x" = "{.arg df} must be a data frame"
    ))
  }

  if (is.null(transformation)) {
    return(df)
  } else if (is.na(transformation)) {
    return(df)
  }

  if(!rlang::is_scalar_character(transformation)) {
    cli::cli_abort(c(
      "x" = "{.arg transformation} must be a character vector of length 1"
    ))
  }
  
  if (transformation == "zzz_gender_all") {
    return(.gender_all(df))
  } else if (transformation == "zzz_gender_senior") {
    return(.gender_senior(df)) 
  } else {
    return(df)
  }

}

.gender_all <- function(df) {

  df_name <- rlang::as_name(rlang::enquo(df))

  .check_vars(df, c("ilo_pubad_female", "ilo_pse_female"), df_name)

  df |>
    dplyr::add_count(cc_iso3c) |>
    dplyr::mutate(
      keep = dplyr::case_when(
        variable == "ilo_pubad_female" ~ TRUE,
        n == 1 & variable == "ilo_pse_female" ~ TRUE,
        TRUE ~ FALSE
      )
    ) |>
    dplyr::filter(keep) |>
    dplyr::mutate(
      variable = "zzz_gender_pubadmin"
    ) |>
    dplyr::select(cc_iso3c, ref_year, variable, value)

}

.gender_senior <- function(df) {

  df_name <- rlang::as_name(rlang::enquo(df))

  .check_vars(df, c("eige_senior_women", "ilo_ps_snrmgr_female"), df_name)

  df |>
    dplyr::add_count(cc_iso3c) |>
    dplyr::mutate(
      keep = dplyr::case_when(
        variable == "eige_senior_women" ~ TRUE,
        n == 1 & variable == "ilo_ps_snrmgr_female" ~ TRUE,
        TRUE ~ FALSE
      )
    ) |>
    dplyr::filter(keep) |>
    dplyr::mutate(
      variable = "zzz_gender_senior"
    ) |>
    dplyr::select(cc_iso3c, ref_year, variable, value)

}
