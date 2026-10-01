# A Step-by-Step Tutorial on the Stochastic Cusp Model in R

Fixed synthetic data and reader scripts accompanying the tutorial by Renaud Mabire-Yon, Raoul P. P. P. Grasman, and Han L. J. van der Maas.

**Companion materials v1.0.0.** These materials accompany manuscript package v1.7.0. The repository is public. Code is licensed under MIT; original data, results, and documentation are licensed under CC BY 4.0. The archival DOI is pending. The manuscript is being prepared for submission to *Advances in Methods and Practices in Psychological Science*.

## Start locally

1. Extract the reader files and open `Cusp_Tutorial.Rproj` in RStudio, or set R's working directory to this folder.
2. Use **cusp 2.3.8**. The recorded reader run used R 4.6.0 on macOS. No supplied script installs or changes packages automatically.
3. Open `R/tutorial.R` and run its numbered blocks in order alongside the article. Stop if a check fails.

If needed, explicitly install the required version in a suitable R library:

```r
install.packages("remotes") # only if needed
remotes::install_version("cusp", version = "2.3.8", upgrade = "never")
```

Installation from source may require a compiler toolchain. The RStudio project is optional; these materials are not an R package.

The observations are already standardized. The fixed example has 1,200 observations and identifier `D0_screen_28062027`. Use `data/analysis_data.rds` for the article's analysis. Substituting raw response scores changes coefficients and the likelihood scales used in comparisons.

## Choose a route

- **Interactive tutorial:** run the blocks of `R/tutorial.R` in order. They fit the model, inspect its output, calculate public confidence intervals, and draw diagnostics and conditional profiles.
- **Automated reproduction:** run `source("R/run_tutorial.R")` from this folder. It fits once and saves figures, results, warnings, errors, and session information in a new timestamped archive under `reader_output/`. Existing runs are never overwritten.
- **Read recorded output:** run `source("R/view_archived.R")`. It reads the supplied tables and printouts without fitting a model or evaluating densities.

Use either fitting route unless you intend to fit twice. Only a complete run can be compared with the recorded output. Scripts deliberately stop with another cusp version.

`source("R/plot_profiles.R")` loads two function definitions; `plot_tutorial_profiles(fit)` then evaluates conditional densities and draws the panels using that fitted object. The function source contains explanatory comments. The manuscript supplement and technical reference provide the corresponding explanation.

`R/export_confint.R` is an optional utility for applying the public `confint()` method to the saved fit. The recorded intervals are already supplied; this utility is unnecessary for reading them.

## What is supplied

- `R/`: the reader workflow and plotting helper.
- `data/`: fixed observations, analysis data, generating truth, preprocessing information, and input checksums.
- `results/`: recorded estimates, console output, confidence intervals, density profiles, and the saved fitted object.
- `provenance/`: a short English note on the origin and selection of the example, and the original native reader-results archive. Detailed historical records remain separately preserved for the planned archival deposit.
- `prepare_tutorial.R`: a file-preparation helper for the future online setup.
- `READER_FILES_MD5.csv`: the files fetched by that helper and their expected checksums.

The selected teaching example and its numerical checks do not establish general package performance, coverage, or false-positive rates. The short provenance note explains how the example was selected; the complete historical record remains separately preserved.

## Online setup and release status

Readers can source `prepare_tutorial.R` from the version-tagged URL below, then call `setwd(prepare_cusp_tutorial())`. This prepares the reader files and checks their hashes; it neither installs packages nor runs analyses. It refuses to overwrite an existing destination folder.

On October 1, 2026, the first author ran the public-download check under native R 4.6.0 on macOS: all 31 reader files matched their expected hashes, with no recorded errors or warnings. He subsequently confirmed that the complete interactive tutorial worked on his Mac. The interactive confirmation is a user report; it is not a new archived statistical-results audit. The earlier automated reader run remains archived. The setup function and analysis scripts are unchanged from the tested preparation. These checks do not establish performance on every R environment. A Zenodo DOI will be added after archival publication.

No models, simulations, densities, or statistical calculations were executed while preparing this repository. Original reader scripts, data, and archived results were copied without modification.

License scope and attribution are documented in `LICENSE.md`; full texts are in `LICENSES/`. The preferred citation will be finalized with the archival DOI. See `LICENSE_STATUS.md` and `CITATION.cff` for release metadata.

## Prepare the reader files from R

Run these commands from a directory where you want a new `Cusp_Tutorial` folder:

```r
source("https://raw.githubusercontent.com/Renaud-Mabire/stochastic-cusp-tutorial/v1.0.0/prepare_tutorial.R")
setwd(prepare_cusp_tutorial())
```

The `v1.0.0` tag identifies this release and will be kept fixed. Corrections will receive a new version. Its underlying commit identifier is recorded on the GitHub release page. File preparation runs no analysis; after it finishes, follow the article or the interactive route above.
