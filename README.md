# Blavatnik Index of Public Administration 2024 

The Blavatnik Index of Public Administration provides comparative benchmarking
data on the activities and performance of civil services around the world. It
is produced and published by the
[Blavatnik School of Government, University of Oxford](https://www.bsg.ox.ac.uk).

The Index draws on 82 data points from 17 different data sources to compare the
functioning and characteristics of national-level public administrations and
civil services in 120 countries around the world.
 
The Blavatnik Index is a refreshed and updated approach to benchmarking that
builds on the foundations developed by the Blavatnik School of Government’s
involvement in the International Civil Service Effectiveness (InCiSE) Index,
from 2016 to 2020.

This repository contains the [R](https://www.r-project.org) source code to
calculate the Index as well as CSV versions of the Index data. You can view
the results and full methodology documentation on the Index's dedicated
website: https://index.bsg.ox.ac.uk

## Contents

This README should be read in conjunction with the READMEs of the two 
[associated repositories](#related-repositories-and-data)
and the Blavatnik Index of Public Administrations's full
[methodology articles](http://index.bsg.ox.ac.uk/methodology/).

This README has five main sections:

- [**Copyright and licensing**](#copyright-and-licensing) - please take note of
  how to re-use the work, the license conditions, and the licensing of
  original source data.
- [**Index results and data**](#index-results-and-data) - details of the files
  in the `data_out` folder that contain the results of the Blavatnik Index.
- [**Metadata and data structure**](#metadata-and-data-structure) - details of
  the files in the `data_ref` folder that provide metadata about the work and
  notes about the Index's data model.
- [**Workflow**](#workflow) - details of how to use the source code contained
  within this repository.
- [**Dependencies**](#dependencies) - details of other repository/data and the
  R software packages that the code in this repository depends on.

## Copyright and licensing

The Blavatnik Index of Public Administration is copyright of the Blavatnik
School of Government, University of Oxford. The results of the Index, this
report, any visualisations and articles associated with the Index produced by
the Blavatnik School of Government are licensed under CC BY 4.0,
https://creativecommons.org/licenses/by/4.0/. The software and source code
is released under the MIT License.

When re-using the Index data or associated materials, please cite the work
appropriately:
> Blavatnik Index of Public Administration 2024, Blavatnik School of
> Government, University of Oxford, https://index.bsg.ox.ac.uk

The original source data used to compile the Blavatnik Index of Public
Administration remains subject to licence terms of the original third-party
authors, please consult the original materials for specific licence terms and
conditions relating to each source.

## Index results and data

The results of the Index are available in the `data_out` folder, this contains
six CSV files:

- [`bipa2024_all_data.csv`](data_out/bipa2024_all_data.csv) the results of the
  Index and its constituent elements in "long format", see
  [below](#bipa2024_all_datacsv) for more detail.
- [`bipa2024_data_structure.csv`](data_out/bipa2024_data_structure.csv) the
  data structure of the output Index and its constituent elements, see
  [below](#bipa2024_data_structure) for more detail.
- [`bipa2024_dq_scores.csv`](data_out/bipa2024_dq_scores.csv) - the results
  of the data coverage calculations, see [below](#bipa2024_dq_scores) for
  more detail.
- [`bipa2024_index_domains_wide.csv`](data_out/bipa2024_index_domains_wide.csv)
  provides a "wide format" version of the overall index results and the scores
  for the four domains, each country is represented a single row with columns
  providing country labels, regional and income groupings, as well as the
  values and ranks for the Index and each of the domains. See the `name` column
  in the [data structure](#bipa2024_data_structure) CSV to interpret column
  names.
- [`bipa2024_index_themes_wide.csv`](data_out/bipa2024_index_themes_wide.csv)
  is similar to `bipa2024_index_domains_wide` except that instead of scores and
  ranks for the four domains it provides scores and ranks for the 16 themes that
  make up the domains. See the `name` column
  in the [data structure](#bipa2024_data_structure) CSV to interpret column
  names.

### `bipa2024_all_data.csv`
The [`bipa2024_all_data.csv`](data_out/bipa2024_all_data.csv) file contains the
results of the Index, domains, themes, indicators and metrics in "long format",
with the following columns:

- `cc_iso3c` - a three-character country code
- `structure_id` - a numeric code identifying the data point's position in
  the Index's data structure, the id for the Index itself is `0`, see
  [below](#bipa2024_data_structure) for more detail.
- `value` - the country's score for the relevant data point
- `rank` - the numeric rank of the country for that data point
- `rank_label` - a label for the country's rank indicating where that rank
  is held by more than one country.

### `bipa2024_data_structure`
The [`bipa2024_data_structure.csv`](data_out/bipa2024_data_structure.csv) file
provides a look up table for the `structure_id` column in the main
[`bipa2024_all_data.csv`](#bipa2024_all_datacsv) file, it contains four columns:

- `structure_id` - a numeric code consisting of a whole number of five digits
  and a fractional number of up to two decimal places.
- `level` - a reference to elements level or tier within the Index's data
  model.
- `name` - a short format name for use in "wide format" versions of the data.
- `label` - a human readable label for use in final outputs.

See the [metadata and data structure](#metadata-and-data-structure) section
of this README for further explanation of the Index's data structure.

### `bipa2024_dq_scores`
The [`bipa2024_dq_scores.csv`](data_out/bipa2024_dq_scores.csv) file provides
the outputs from the Index's data coverage assessment which determines country
inclusion, it has nine columns:

- `cc_name_short`: The country/territory name
- `cc_iso3c`: The 3-character code for the country/territory
- `cc_status`: Whether the country/territory is a UN member
- `bipa_region`: The geographic region the country/territory is located in
- `income_group`: The World Bank income classification (2023-24) for the
  country/territory
- `dq_grade`: The overall grade allocated to the country/territory by the
  data coverage assessment
- `x_a`: The country/territory's overall score from the data coverage
  assessment
- `p_m`: The country/territory's overall percentage of metrics
- `included`: A marker to indicate whether the country was or was not included
  in the Index based on their `x_a` and `p_m` values

## Metadata and data structure

The Blavatnik Index is based on 82 metrics drawn from 17 different data sources,
the integration of these data into the overall Index are defined by the Index's
conceptual framework and data model. This is both a top-down and bottom-up
approach with the Index's conceptual framework defining the upper levels (the
Index, its four domains and 20 themes) and the data model extending this and
defining its lower levels (the original source data, metrics and indicators)
based on the data identified for inclusion in the Index. From bottom-to-top
there are six levels:

- The original variables extracted from the source data (see the
  [`bipa2024_sourcedata`](https://github.com/blavatnik-index/bipa2024_sourcedata))
  repository for further details.
- The Index's **metrics**, these are normalised versions of the source data
  that range from 0 to 1, where 0 represents the 'lowest' performance and 1
  represents the 'highest' performance amongst the 120 countries included in
  the Index.
- The Index's **indicators**, the 82 metrics are grouped into 32 indicators
  based on their conceptual commonality - e.g. the measures around filing and
  paying taxes on-time are grouped into a single 'tax compliance' indicator.
- The Index's **themes**, the Index's conceptual framework splits up it's four
  domains into 20 themes (16 of which can be measured), each indicator is
  assigned to a single theme.
- The Index's **domains**, the Index's conceptual framework defines four domains
  that define broad groupings of the activities and characteristics of national
  public administrations and civil services.

### `source_variable` and `structure_id`

Each item extracted from the  source data has a unique variable name, this is
standardised to start with a short alphanumeric reference to the data source
itself and then a human readable variable name. These are only used in the
first stage of index calculation where the source data is collated and prepared
into the base dataset of metrics.

For the remaining five elements of the Index's data model, each element is
assigned a unique `structure_id` code. Variable names and human readable labels
are also defined but the processing and calculation itself relies on this code.

A `structure_id` code has the format `ABBCC.DD` where `A` relates to the domain
level of the Index's data model, `BB` relates to the theme level of the data
model, `CC` relates to the indicator level of the data model and `DD` relates
to the metric level of the data model.

The code `10102.01` relates to the "Setting strategic priorities" metric,
it is in the "Prioritisation" indicator (code `10102.00`), part of the
"Strategic capacity" theme (code `10100.00`) which itself is part of the
"Strategy & Leadership" domain (code `10000.00`). The Index overall has a
`structure_id` of `00000.00` (or simply `0`).

### Reference files

The CSV files in the `data_ref` folder provide metadata relating to the source
data, Index metrics and the data structure. There are five files:

- [`data_structure.csv`](data_ref/data_structure.csv) defines the
  elements of the data model above the metrics, note this is merged with
  information from the `metrics_metadata.csv` to produce the data structure
  file provided in the `data_out` folder. It has four columns:
    - `structure_id` - the unique identifier for the element
    - `level` - the level of the data model the element sits at
    - `name` - a short format name for use in "wide" versions of the data
    - `label` - a human readable label for use in outputs
- [`metrics_metadata.csv`](data_ref/metrics_metadata.csv) provides
  metadata for all of the metrics for use in processing the Index, see
  [below](#metrics_metadatacsv) for more detail.
- [`metrics_summary.csv`](data_ref/metrics_summary.csv) provides a collation
  of the metadata provided about the metrics in the Index's 
  [methodology documentation](https://index.bsg.ox.ac.uk/methodology)
  in human readable format. Note this only includes data for
  the 82 metrics used in the calculation of the Index
- [`source_summary.csv`](data_ref/source_summary.csv) provides a summary
  of the metadata provided about the metrics in the Index's methodology
  documentation in human readable format.

#### `metrics_metadata.csv`

The [`metrics_metadata.csv`](data_ref/metrics_metadata.csv) file provides
metadata associated with the metrics that are used in processing of the
source data into outputs of the Index. It has seven columns:

- `structure_id` - a unique numeric code identifier for the metric.
- `metric` - a short name for the metric for use in "wide format" versions
  of the data.
- `label` - a human readable label for use in outputs.
- `source_variable` - the variable name used in the original sources for this
  metric, the first part of this name (up to first underscore, `_`) identifies
  the original source.
- `source_label` - a human readable label derived from the source data
- `scope` - the scope of the metric (see below regarding
  [additional data](#additional-data)).
- `transformation` - the type of transformation the data undergoes to convert
  the source data from its original format into one of the Index's constituent
  metrics, see the [workflow](#workflow) section for further details.

### `metrics_summary.csv`

The [`metrics_summary.csv`](data_ref/metrics_summary.csv) file is an
alternative collation of metadata about the metrics that is used in the Index's
[methodology documents](https://index.bsg.ox.ac.uk/methodology). It is not
used directly in the processing code, and is a "human readable" format of the
`metrics_metadata.csv` file, it additionally contains information about the
type of data collection and number of countries covered by the original source
data.

### `source_summary.csv`

The [`source_summary.csv`](data_ref/metrics_summary.csv) file provides a
high-level summary of each of the 17 sources that contribute to the Index used
in the Index's [methodology documents](https://index.bsg.ox.ac.uk/methodology).
It is not used directly in the processing code.

### Additional data

In addition to the 17 sources used to calculate the Index, the
[`bipa2024_sourcedata`](https://github.com/blavatnik-index/bipa2024_sourcedata)
repository contains data from a further 6 sources limited to OECD/EU
countries and 1 source with global coverage, it also contains for one of the 17
sources used by the Index additional data relating to OECD/EU countries.

To subset the metrics to those just used by the Index use `scope == "global"`
in any filtering/subsetting operations.

The additional data relating to OECD/EU countries (`scope == "oecd_eu"`) was
excluded from inclusion in the final calculations after it was decided that
the Blavatnik Index of Public Administration should focus on developing an
Index with a broad international coverage. See the Index's methodology
document on [geographic scope](https://index.bsg.ox.ac.uk/posts/geographic_scope/)
for further discussion.

After initial consideration for inclusion it was ultimately decided not
to include data from the Open Budget Survey and Global Data Barometer relating
to the transparency of public finance data and budget documents in the
calculation of the Index, see the section of the methodology documentation
relating to
[financial management](https://index.bsg.ox.ac.uk/posts/source_alignment/#financial-management)
for further details.

## Workflow

The code for the Blavatnik Index of Public Administration is written in
[R](https://www.r-project.org), see the [dependencies](#dependencies) section
for details of the packages used. Note also that the code largely follows
[tidyverse](https://www.tidyverse.org) conventions.

This repository works in conjunction with the
[`bipa2024_sourcedata`](https://github.com/blavatnik-index/bipa2024_sourcedata)
and [`bipa2024_cartography`](https://github.com/blavatnik-index/bipa2024_cartography)
repositories, see the [dependencies](#dependencies) section for further details.

### R scripts

The main workflow scripts sit at the root level of the repository and start
with the numbers 0-4. These scripts must be run in-sequence within the same
session as they rely on objects created in the preceding script(s).

#### `0_preflight.R`

The [`0_preflight.R`](0_preflight.R) script sets up the R environment for
running the main Index code:

- it loads [bespoke functions](#r-bespoke-functions) written to enable checks
  and calculations
- it loads the [metadata and reference lists](#metadata-and-reference-lists)
- it runs checks on the metadata and reference list datasets

#### `1_load_source_data.R`

The [`1_load_source_data.R`](1_load_source_data.R) script loads the CSV files
contained in the `data_out` folder of the
[`bipa2024_sourcedata`](https://github.com/blavatnik-index/bipa2024_sourcedata)
repository, runs checks on the loaded data, performs final pre-processing of
data relating to gender representation and then produces a base dataset of
metrics for use in the data coverage calculations and calculation of the Index.

#### `2_data_quality.R`

The [`2_data_quality.R`](2_data_quality.R) script runs the data coverage checks
for the Index and produces a list object which includes the output of the
checks, including the list of countries to include in the final calculation of
the Index.

#### `3_calculate_index.R`

The [`3_calculate_index.R`](3_calculate_index.R) script takes the base dataset
of metrics and the list of countries for inclusion and calculates the Index
results and its constituent parts.

#### `4_export_results.R`

The [`4_export_results.R`](4_export_results.R) script saves the Index results
as CSV files in the repository's `data_out` folder.

### R bespoke functions

The `R` folder contains four scripts that load bespoke functions necessary to
run the code in the main workflow scripts and calculate the Index.

- [`calculate.R`](R/calculate.R) - functions used to calculate the Index and
  its constituent tables
- [`checks.R`](R/checks.R) - functions used to conduct checks on the metadata
  and source data files
- [`data_quality.R`](R/data_quality.R) - functions used to conduct the data
  coverage assessment
- [`transform_functions.R`](R/transform_functions.R) - functions used to apply
  transformations to the source data

See the README in the [R](R/) folder for further details.

### Metadata and reference lists

In addition to the [metadata reference](#reference-files) files discussed
above the workflow relies on three reference files in the
[`bipa2024_cartography`](https://github.com/blavatnik-index/bipa2024_cartography)
repository which provide reference lists of country codes and names,
geographic regions and World Bank income classifications.

### Sensitivity tests

The `sensitivity_tests` folder contains scripts that vary different aspects of
the Index's methodology. See the Index's methodology document on
[sensitivity analysis](https://index.bsg.ox.ac.uk/posts/sensitivity_analysis/)
for details of these tests.

## Dependencies

This repository has two types of dependencies: (a) two related repositories
that contain source data and reference lists, and (b) a number of R software
packages.

### Related repositories and data

In order to run the code in this repository you will need two related
repositories:

- [`bipa2024_sourcedata`](https://github.com/blavatnik-index/bipa2024_sourcedata)
  which contains the source data used to calculate the Blavatnik Index.
- [`bipa2024_cartography`](https://github.com/blavatnik-index/bipa2024_cartography)
  which contains geographic reference information, and cartography for making
  maps.

These repositories should be stored in the same repository as this, the
`bipa2024_index`, repository as per the diagram below.

```
home
  ├ bipa2024_cartography
  ├ bipa2024_index
  └ bipa2024_sourcedata
```

Please follow the instructions in the
[`bipa2024_sourcedata`](https://github.com/blavatnik-index/bipa2024_sourcedata)

repository and ensure the source data is fully collated 

### R package dependencies

The code for the Blavatnik Index makes heavy use of R's native pipe therefore a
version of R at 4.1 or is necessary, The code has been developed using versions
of R from 4.3.3 through to 4.4.2, no testing of the code using versions of R
earlier than 4.3.3 have been made.

R package dependencies are managed via
[`{renv}`](https://rstudio.github.io/renv/articles/renv.html). If you
do not already have `{renv}` installed in your R setup then it will be
automatically installed when you first open the project. To load the
project dependencies run `renv::restore()` after the project has first loaded.

The core packages used by the Index are:

- [`{cli}`](https://CRAN.R-project.org/package=cli) [3.6.3]
- [`{dplyr}`](https://CRAN.R-project.org/package=dplyr) [1.1.4]
- [`{forcats}`](https://CRAN.R-project.org/package=forcats) [1.0.0]
- [`{purrr}`](https://CRAN.R-project.org/package=purrr) [1.0.2]
- [`{readr}`](https://CRAN.R-project.org/package=readr) [2.1.5]
- [`{rlang}`](https://CRAN.R-project.org/package=rlang) [1.1.4]
- [`{scales}`](https://CRAN.R-project.org/package=scales) [1.3.0]
- [`{tibble}`](https://CRAN.R-project.org/package=tibble) [3.2.1]
- [`{tidyr}`](https://CRAN.R-project.org/package=tidyr) [1.3.1]
- [`{vroom}`](https://CRAN.R-project.org/package=vroom) [1.6.5]

If you want to run the sensitivity tests you will also need:

- [`{mice}`](https://CRAN.R-project.org/package=mice) [3.16.0]
- [`{psych}`](https://CRAN.R-project.org/package=psych) [2.4.6.26]
