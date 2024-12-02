# Blavatnik Index of Public Administration 2024 - R functions

This folder contains four scripts that load bespoke functions necessary to
run the code in the main workflow scripts and calculate the Blavatnik Index of
Public Administration.

- [`calculate.R`](#calculater) - functions used to calculate the Index and
  its constituent tables
- [`checks.R`](#checksr) - functions used to conduct checks on the metadata
  and source data files
- [`data_quality.R`](#data_qualityr) - functions used to conduct the data
  coverage assessment
- [`transform_functions.R`](#transform_functionsr) - functions used to apply
  transformations to the source data

## `calculate.R`

The [`calculate.R`](calculate.R) script contains two functions for calculating
the Blavatnik Index and its constituent elements: `calculate_metrics()` and
`calculate_tier()`.

### `calculate_metrics()`

The `calculate_metrics()` function takes four
inputs to return a tibble of the Index's metric scores, the necessary inputs
are:

- `df` - the base dataset of metrics, in practice the `metrics_base` object
  created by the [`1_source_data.R`](../1_load_source_data.R) script.
- `countries` - the list of countries to include in the Index, in practice
  the `countries` item in the `dqc_bipa2024` list (`dqc_bipa2024$countries`).
- `theme_dq` - a tibble of theme-level data coverage information, in practice
  the `dq_data_themes` item in the `dqc_bipa2024` list
  (`dqc_bipa2024$dq_data_themes`)
- `r` - the level of rounding to apply to the data, in practice this is set
  as a default to `2`.

The function first conducts some checks on the `df` and `theme_df` to ensure
they conform to the expected structure.

After the checks are complete, the function takes the `df` excludes themes
with low data coverage, limits the data to the countries of interest and the 
metrics with a "global" scope. The function then applies the relevant
transformation as specified by the `transformation` function that converts the
data to a normalised 0 to 1 scale. Finally, the normalised values are rounded
to the specified number of decimal places (default is 2) and ranks are
calculated such that countries with the highest score are ranked first.

### `calculate_tier()`

The `calculate_tier()` function takes three inputs to return a
tibble of the higher levels of the Index's data model, the necessary inputs
are:

- `df` - the metrics dataset produced by the `calculate_metrics()` function.
- `tier` - the level of the Index's data model you wish to calculate, one of:
  `"indicator"`, `"theme"`, `"domain"` or `"index"`.
- `r` - the level of rounding to apply to the data, in practice this is set
  as a default to `2`.

As with `calculate_metrics()` the function first runs a basic check on the
provided `df` to ensure it conforms to the format expected. A further check
is then made to check that the `structure_id` is provided for the calculation
of the relevant tier.

For the tiers above metrics the components of the Index are calculated as
the simple mean of its constituent parts. This is operationalised through
manipulation of the `structure_id` of a data point. The `structure_id` of a
metric is a decimal number comprised of a 5-digit whole number and a 2-digit
fractional number (e.g. `10203.04`), a metric's indicator can be calculated
simply by rounding down the metric's `structure_id` to the nearest integer.
An indicator's theme is calculated by dividing its `structure_id` by 100,
rounding this down the nearest integer and then multiplying this by 100 to
get back to a 5-digit value. A theme's domain is calculated by dividing
its `structure_id` by 10000, rounding this down to the nearest integer and
then multiplying it by 100 to get back to a 5-digit value.

```
metric:    10203.04
indicator: 10203
theme:     10200
domain:    10000
```

After the checks are complete, the `tier` argument is used to determine the
divisor that should be applied to the `structure_id` to convert them to
their relevant value in the subsequent tier. After converting the
`structure_id` values, the arithmetic mean for each combination of
`structure_id` and country code (`cc_iso3c`) is calculated. Finally, the
normalised values are rounded to the specified number of decimal places
(default is 2) and ranks are calculated such that countries with the highest
score are ranked first.

## `checks.R`

The [`checks.R`](checks.R) script contains 6 functions that are used to assist
the processing and calculation of the Index by providing in-flight checks of
objects or vectors.

### `check_source_data()` and `.check_vars()`
The `check_source_data()` is a specialised function for checking
the collated source data that is read in the
[`1_load_source_data.R`](../1_load_source_data.R) script. It requires two
inputs:

- `df` - the dataset of source data, in practice the `source_data` object
  created in the `1_load_source_data.R` script.
- `metrics_df` - the dataset of metadata relating to the metrics, in practice
  the `metrics_meta` objecte created in the [`0_preflight.R`](../0_preflight.R)
  script.

The `df` and `metrics_df` files are checked that they contain necessary columns
(the column `variable` in `df` and the column `source_variable` in
`metrics_df`). If they pass these checks then `df` is passed to
`.check_vars()` function which checks whether it contains the
source variables defined in `metrics_df`.

### `check_df()`, `.chk_type()` and `check_cc()`

The `check_df()` function is a generic function for checking
that a data frame has the expected columns, optionally it will also check
country codes contained in the data. It has three inputs:

- `df` - the data frame for checking.
- `columns` - a named character vector of expected columns (see below).
- `check_cc` - either `NULL` (the default) or a vector of country codes to
  check are contained in the data frame's `cc_iso3c` column.

The `columns` argument should be a named character vector that is the same
length as the number of columns in the `df`. The names of this character vector
should be the same as the column names in the `df`, the values of the character
vector should be the column type (either `numeric`, `character` or `logical`).

For each column in `df` the function calls `.chk_type(x, type)` which checks
that the column matches the expected type defined in the `columns` argument.

If a list of country codes is supplied in the `chk_cc` argument then the
`check_cc()` function is called with the values of `chk_cc` supplied
as the `cc_list` argument. This function checks that the codes supplied in
the `df$cc_iso3c` column match with codes in the `chk_cc` list.

### `.check_tier_input()`

The `check_tier_input(x, tier)` is used in [`calculate_tier()`](#calculate_tier)
function to check that the `structure_id` values provided conform to the
expected format for the relevant tier calculation.

## `data_quality.R`

The [`data_quality.R`](data_quality.R) script contains 7 functions to
conducting the data coverage assessment.

### `dq_countries()` and its helpers

The `dq_countries()` function is the principal function for calculating the
data coverage assessment, it has seven arguments:

- `df` - the base dataset of metrics, in practice the `metrics_base` object
  created in the [`1_load_source_data.R`](../1_load_source_data.R) script.
- `scope` - the scope for the assessment, in practice this should be `"global"`.
- `metrics_df` - the metadata for the metrics, in practice the `metrics_meta`
  object created in the [`0_preflight.R`](../0_preflight.R) script.
- `threshold_q` - the threshold for the data coverage score, in practice this
  is set to `NULL` to apply the default (half the theoretical maximum)
- `threshold_m` - the threshold for the overall percent of metrics, in practice
  this is set to `NULL` to apply the default (two-thirds)
- `threshold_t` - the threshold for excluding themes based on low-data coverage,
  in practice this is set to `NULL` to apply the default (20%)
- `ignore_cc` - a list of country codes to exclude

The function returns a list with 8 elements:

- `n_countries` - the number of countries that pass the data quality assessment
- `countries` - a character vector of the country codes for the countries that
  pass the data quality assessment
- `dq_data` - a tibble with the results of the data coverage assessment
- `dq_ref` - a tibble showing the reference values for comparison if a country
  has data for all possible metrics
- `threshold_q` - the threshold value for the data coverage score
- `threshold_m` - the threshold value for the overall percentage of metrics
- `dq_data_themes` - a tibble showing the data quality calculations for each
  country-theme combination, used in `calculate_metrics()` to exclude themes
  with low data quality
- `excluded_cc` - a list of country codes that have been explicitly excluded by
  the original call

The data quality assessment is based on the chi-square test, see the Index's
methodology document on
[country selection](https://index.bsg.ox.ac.uk/posts/country_selection/) for
more detail.

The `.dqc_indicators()`, `.dqc_themes()` and `.dqc_overall()` functions
calculate from the supplied `df` the relevant variables for producing the
final calculation of the data coverage assessment.

The output of `.dqc_themes()` is also provided as the `dq_data_themes` item
in the list returned by `dq_countries()`, this is used to exclude data for
countries with low data coverage in specific themes (see below).

The `.dq_grade()` function is used to calculate the overall data coverage grade
based on a country's data coverage score and overall percent of metrics.

The `dq_data` item in the returned list provides 9 columns for all countries
with data in the supplied `df`:

- `cc_iso3c` - the 3-character code for the country/territory.
- `m_a` - the total number of metrics that the country/territory has data for.
- `p_m` - the overall percentage of metrics that the country/territory has data
  for.
- `i_a` - the overall number of indicators that the country/territory has data
  for.
- `n_t` - the overall number of themes that the country/territory has data for.
- `x_a` - the overall data coverage score for the country/territory.
- `above_threshold` - a marker for whether the country/territory is above the
  thresholds for `x_a` and `p_m`.
- `included` - a marker for whether the country/territory is included in the
  final index, in practice this is `above_threshold` excluding codes listed in
  `ignore_cc`.
- `dq_grade` - a grade from A-F, A-D is based on quartiles of `x_a` and `p_m`
  for countries/territories included in the Index, E-F are split by the median
  value of `x_a` and `p_m` for countries/territories that are not included in
  the Index.

### `dq_exclude_lowdata()`

The `dq_exclude_lowdata()` function is used in `calculate_metrics()` to exclude
the data for specific country-theme combinations. Some themes have many more
metrics than others, to ensure that a country's score for a specific theme
is not based on a small fraction of the potential data themes where a country
has less than 20% of possible data are excluded - i.e. where a theme is based
on 6 metrics then a country with only 1 metric for that theme will have that
data point excluded.

## `transform_functions.R`

The [`transform_functions.R`](transform_functions.R) script contains 8
functions for converting the source data into metrics. Please consult the
Index's methodology document on
[rescaling and transformation](https://index.bsg.ox.ac.uk/posts/rescaling_transformation/)
of source data.

### `scale_data()`, `scale_value()` and its helpers

The `scale_data()` function is called as part of the `calculate_metrics()`
function, to convert source data from its base format into a normalised 0 to 1
scale. The `scale_data()` function is a lightweight wrapper function that
performs some simple checks on the input data frame before calling
`scale_value()`.

The `scale_value()` function specifies the transformation to be applied and
then calls either the `.rescale_simple()` or `.rescale_distance()` functions
with the relevant parameters.

In-turn, `.rescale_simple()` is a wrapper around
[`scales::rescale()`](https://scales.r-lib.org/reference/rescale.html), where
`scale_value()` provides different ranges for the conversion.

The `.rescale_simple()` function assumes a linear transformation of the source
data into a output scale. The `.rescale_distance()` function handles the cases
where the re-scaling is compared to a reference value, it calculates the
reference value and then calls `.distance_scaled()` which then calculates the
scaling based on the reference value.

### gender_vars() and its helpers

The `gender_vars()` function is used in [1_load_source_data.R](../1_load_source_data.R)
to choose between potential measures of gender representation. It calls either
`.gender_all()` or `.gender_senior()` to select the variable that is used in
the Index calculation for for the overall representation of women in public
administration or the representation of women at senior levels of the public
sector. For the overall level if ILO data for the public administration is
not available then data for the public sector overall is used. For senior
levels if the EIGE data is not available then ILO data is used.