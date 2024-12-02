# Blavatnik Index of Public Administration 2024
# =============================================
# calculation script 0: pre-flight set-up

# load functions ----

source("R/checks.R")
source("R/transform_functions.R")
source("R/data_quality.R")
source("R/calculate.R")

# metadata files ----

metrics_meta <- readr::read_csv("data_ref/metrics_metadata.csv")
data_structure <- readr::read_csv("data_ref/data_structure.csv")
cc_ref <- readr::read_csv("../bipa2024-cartography/entity_codes/entity_codes.csv")
cc_geo <- readr::read_csv("../bipa2024-cartography/entity_codes/entity_georegions.csv")
cc_wb <- readr::read_csv("../bipa2024-cartography/entity_codes/entity_wb_classification23.csv")

# check data sets

check_df(metrics_meta, c(
  "structure_id" = "numeric",
  "metric" = "character",
  "label" = "character",
  "source_variable" = "character",
  "source_label" = "character",
  "scope" = "character",
  "transformation" = "character"
))

check_df(data_structure, c(
  "structure_id" = "numeric",
  "level" = "character",
  "name" = "character",
  "label" = "character"
))

check_df(cc_ref, c(
  "cc_iso3c" = "character",
  "cc_name_long" = "character",
  "cc_name_short" = "character",
  "un_m49" = "numeric",
  "unicode_flag" = "character",
  "cc_status" = "character"
))


check_df(
  cc_geo,
  c("cc_iso3c" = "character",
    "un_region" = "character",
    "un_subregion" = "character",
    "un_subregion2" = "character",
    "bipa_region" = "character"),
  chk_cc = cc_ref$cc_iso3c
)

check_df(
  cc_wb, 
  c("cc_iso3c" = "character",
    "ref_year" = "numeric",
    "income_group" = "character",
    "income_group_num" = "numeric"
  ),
  chk_cc = cc_ref$cc_iso3c
)

# process metadata ----

# generate random number for blinding results
set.seed(44989)
cc_ref <- cc_ref |>
  dplyr::arrange(cc_iso3c) |>
  dplyr::mutate(
    rnum = runif(nrow(cc_ref))
  ) |> 
  dplyr::arrange(rnum) |>
  dplyr::mutate(
    rnum = 1000 - dplyr::row_number()
  ) |>
  dplyr::arrange(cc_iso3c)

# order world bank economy classifications
cc_wb <- cc_wb |>
  dplyr::mutate(
    income_group = forcats::fct_reorder(income_group, -income_group_num)
  )

# # eu members list
# cc_eu_list <- c(
#   "AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA",
#   "DEU", "GRC", "HUN", "IRL", "ITA", "LVA", "LTU", "LUX", "MLT", "NLD",
#   "POL", "PRT", "ROU", "SVK", "SVN", "ESP", "SWE"
# )

# # oecd members list
# cc_oecd_list <- c(
#   "AUS", "AUT", "BEL", "CAN", "CHL", "COL", "CRI", "CZE", "DNK", "EST", "FIN",
#   "FRA", "DEU", "GRC", "HUN", "ISL", "IRL", "ISR", "ITA", "JPN", "KOR", "LVA",
#   "LTU", "LUX", "MEX", "NLD", "NZL", "NOR", "POL", "PRT", "SVK", "SVN", "ESP",
#   "SWE", "CHE", "TUR", "GBR", "USA"
# )
