# function to compare imported source data against metrics reference data
check_source_data <- function(df, metrics_df) {

  if (!("variable" %in% names(df))) {
    cli::cli_abort(c(
      "x" = "{.var variable} not found in {.arg df}"
    ))
  }

  if (!("source_variable" %in% names(metrics_df))) {
    cli::cli_abort(c(
      "x" = "{.var source_variable} not found in {.arg metrics_df}"
    ))
  }

  # get expected variables
  vars <- metrics_df$source_variable

  # ignore placeholders
  vars <- vars[!grepl("^zzz", vars)]

  .check_vars(df, vars, "df")

  cli::cli_alert_success("source data contains expected variables")

}

# generic function to check data frame for specified set of variables
.check_vars <- function(df, chk_vars, .df_name = NULL) {

  if (is.null(.df_name)) {
    .df_name <- rlang::as_name(rlang::enquo(df))
  }

  # get unique list of variables in data frame and 
  df_vars <- sort(unique(df$variable))
  chk_vars <- sort(unique(chk_vars))

  err <- NULL

  err_msg <- c(
    "x" = "necessary variables not detected",
    "!" = "{.arg {(.df_name)}} does not have necessary variables"
  )
  
  if (!identical(df_vars, chk_vars)) {

    vars_matched <- sum(chk_vars %in% df_vars)

    if (vars_matched == length(chk_vars)) {
      err <- TRUE
      oth_vars <- df_vars[!(df_vars %in% chk_vars)]
      err_msg <- c(
        "!" = "variables in {.arg {(.df_name)}} do not identically match {.arg chk_vars}",
        "i" = "all variables in {.arg chk_vars} have been detected",
        "i" = "additional variables detected: {.var {oth_vars}}"
      )
    } else if (length(df_vars) < length(chk_vars)) {
      err <- TRUE
      mis_vars <- chk_vars[!(chk_vars %in% df_vars)]
      err_msg <- c(
        err_msg,
        "!" = "{.arg {(.df_name)}} has less variables than expected",
        "i" = "{length(chk_vars)} variables expected",
        "i" = "{length(df_vars)} variables found",
        "i" = "missing variables: {.var {mis_vars}}"
      )
    } else if (length(df_vars) > length(chk_vars)) {
      err <- TRUE
      mis_vars <- chk_vars[!(chk_vars %in% df_vars)]
      oth_vars <- df_vars[!(df_vars %in% chk_vars)]
      err_msg <- c(
        err_msg,
        "!" = "{.arg {(.df_name)}} has more variables than expected, some variables in {.arg chk_vars} are missing",
        "i" = "{length(chk_vars)} variables expected",
        "i" = "{length(df_vars)} variables found",
        "i" = "missing variables: {.var {mis_vars}}",
        "i" = "additional variables: {.var {oth_vars}}"
      )
    } else {
      err <- TRUE
      err_msg <- c(
      err_msg,
      "!" = "{.arg {(.df_name)}} has some other mismatch with {.arg chk_vars}",
      "i" = "variables detected: {.var {df_vars}}"
    )
    }

  } else {
    err <- FALSE
  }

  if (err) {
    cli::cli_abort(err_msg)
  }

}

check_df <- function(df, columns, chk_cc = NULL, .quiet = TRUE) {
  
  if (!rlang::is_named(columns) | 
    !rlang::is_character(columns, ncol(df)) |
    sum(is.na(columns)) != 0 | sum(is.na(names(columns)) != 0)) {
    cli::cli_abort(c(
      "x" = "{.arg columns} is invalid",
      "i" = "{.arg columns} must be a named character vector",
      "i" = "{.arg columns} must be the same length as the number of columns in {.arg df}"
    )
    )
  }

  if (!identical(sort(names(df)), sort(names(columns)))) {
    cli::cli_abort(c(
      "x" = "{.arg df} does not have expected columns",
      "i" = "{.arg names(df)} ({length(columns)}): {.var {names(columns)}}",
      "i" = "{.arg columns} ({length(names(df))}): {.var {names(df)}}"
    ))
  }

  chk_types <- purrr::map2_lgl(
    .x = names(columns),
    .y = columns,
    .f = ~.chk_type(df[[.x]], .y)
  )

  if (sum(!chk_types) != 0) {
    df_col_types <- purrr::map_chr(
      .x = names(df),
      .f = ~class(df[[.x]])[1]
    )
    cli::cli_abort(c(
      "x" = "columns in {.arg df} do not match types specified in {.arg columns}",
      "i" = paste0(
        "expected ({length(columns)}): ", paste0(
        "{.var ", names(columns), "} {.cls ", columns, "}",
        collapse = ", "
      )),
      "i" = paste0("actual ({length(names(df))}): ", paste0(
        "{.var ", names(df), "} {.cls ", df_col_types, "}",
        collapse = ", "
      ))
    ))
  }

  if (!is.null(chk_cc)) {
    if (!is.character(chk_cc)) {
      cli::cli_abort(c(
        "x" = "{.arg chk_cc} must be {.val NULL} or a character vector"
      ))
    } else if (sum(!grepl("^[A-Z]{3}$", chk_cc)) > 0) {
      cli::cli_abort(c(
        "x" = "{.arg chk_cc} must contain only codes made up of 3 characters from A-Z (uppercase only)"
      ))
    }
    check_cc(df, chk_cc)
  }

  if (!.quiet) {
    cli::cli({
      cli::cli_alert_success("{.arg df} has expected variables of expected type")
      cli::cli_alert_info(c("i" = paste0("{.var ", names(columns), "} {.cls ", columns, "}", collapse = ", ")))
    })
  }

}

.chk_type <- function(x, type) {
  if (type == "numeric"){
    return(is.numeric(x))
  } else if (type == "character") {
    return(is.character(x))
  } else if (type == "logical") {
    return(is.logical(x))
  } else {
    return(FALSE)
  }
}

check_cc <- function(df, cc_list) {

  if (!is.character(cc_list) | length(cc_list) == 0) {
    cli::cli_abort(c(
      "x" = "{.arg cc_list} must be a character vector"
    ))
  }

  if (!("cc_iso3c" %in% names(df))) {
    cli::cli_abort(c(
      "x" = "{.var cc_iso3c} variable not found in {.arg df}"
    ))
  }

  unq_cc <- sort(unique(df$cc_iso3c))
  cc_invalid <- unq_cc[!(unq_cc %in% cc_list)]

  if (length(cc_invalid) == length(unq_cc)) {
    cli::cli_abort(c(
      "x" = "all country codes in {.arg df$cc_iso3c} are invalid"
    ))
  }
  if (length(cc_invalid) > 0) {
    
    cli::cli_abort(c(
      "x" = "invalid country codes detected in {.arg df$cc}",
      "i" = "invalid codes {(length(cc_invalid))}: {cc_invalid}"
    ))
  }

}

.chk_tier_input <- function(x, tier = c("indicator", "theme", "domain", "index")) {
  
  tier <- rlang::arg_match(tier)

  x <- unique(x)

  err_msg <- character(0)

  x_tier <- character(0)
  x_type <- typeof(type.convert(x, as.is = TRUE))
  x_char_min <- min(nchar(x))
  x_char_max <- max(nchar(x))
  x_ind <- as.numeric(substr(x, 4, 5))
  x_thm <- as.numeric(substr(x, 2, 3))
  x_dom <- as.numeric(substr(x, 1, 1))
  chk_x <- FALSE

  if (x_char_min != x_char_max) { 
    # structure_id should have the same length
    
    chk_x <- NULL
    x_tier <- NA_character_
    err_msg <- "Supplied tier {.val structure_id} values are not identical lengths"

  } else if (!(x_char_max == 8 || x_char_max == 5)) {
    # structure_id should either be 8 (metrics) or 5 (other tiers) in lengths

    chk_x <- NULL
    x_tier <- NA_character_
    err_msg <- "Supplied tier {.val structure_id} values are not of expected length"

  }
  else if (tier == "indicator") {
    # input should be metrics - metrics are double format, 8-character length,
    # all components should be non-zero
    
    if (x_type == "double" & x_char_max == 8) {
      x_met <- as.numeric(substr(x, 7, 8))
      chk_x <- x_type == "double" && 
        x_char_max == 8 &&
        sum(x_met == 0) == 0 && 
        sum(x_ind == 0) == 0 && 
        sum(x_thm == 0) == 0 && 
        sum(x_dom == 0) == 0
    } else {
      chk_x <- FALSE
    }

    if (!chk_x) {
      x_tier <- "metric"
      err_msg <- "Metrics should be numbers of the form ABBCC.DD (e.g. 10203.04)"
    }

  } else if (tier == "theme") {
    # input should be indicators - indicators are integers of 5-character length
    # all components should be non-zero

    chk_x <- x_type == "integer" && 
      x_char_max == 5 &&
      sum(x_ind == 0) == 0 && 
      sum(x_thm == 0) == 0 && 
      sum(x_dom == 0) == 0

    if (!chk_x) {
      x_tier <- "indicator"
      err_msg <- "Indicators should be numbers of the form ABBCC (e.g. 10203)"
    }

  } else if (tier == "domain") {
    # input should be themes - themes are integers of 5-character length
    # indicator component should be zero, theme and domain components should
    # be non-zero
    
    chk_x <- x_type == "integer" && 
      x_char_max == 5 &&
      sum(x_ind != 0) == 0 && 
      sum(x_thm == 0) == 0 && 
      sum(x_dom == 0) == 0
    
    if (!chk_x) {
      x_tier <- "theme"
      err_msg <- "Themes should be numbers of the form ABB00 (e.g. 10200)"
    }

  } else if (tier == "index") {
    # input should be domains - domains are integers of 5-character length,
    # only domain should be the non-zero component

    chk_x <- x_type == "integer" && 
      x_char_max == 5 &&
      sum(x_ind != 0) == 0 && 
      sum(x_thm != 0) == 0 && 
      sum(x_dom == 0) == 0
    
    if (!chk_x) {
      x_tier <- "domain"
      err_msg <- "Domains should be numbers of the form A0000 (e.g. 10000)"
    }

  }

  if (is.null(chk_x)) {
    cli::cli_abort(c(
      "x" = "Values not expected length",
      "!" = err_msg,
      "i" = "Supplied values: {.val {x}}"
    ))
  } else if (!chk_x) {
    cli::cli_abort(c(
      "x" = "Invalid tier provided",
      "!" = "For {tier} calculation {x_tier} values required",
      "i" = err_msg,
      "i" = "Supplied values: {.val {x}}"
    ))
  }

}
