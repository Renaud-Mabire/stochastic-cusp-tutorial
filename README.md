# A Step-by-Step Tutorial on the Stochastic Cusp Model in R

Fixed synthetic data and reader scripts accompanying the tutorial by Renaud Mabire-Yon, Raoul P. P. P. Grasman, and Han L. J. van der Maas.

**Preparation version.** These materials are derived from the manuscript package v1.7.0. Public release and the archival DOI are pending. The first author approved MIT for code and CC BY 4.0 for the data and documentation. The manuscript is being prepared for submission to *Advances in Methods and Practices in Psychological Science*.

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
- `provenance/`: the selected-example record and the original native reader-results archive. Historical validation archives remain separately preserved in the full companion package.
- `prepare_tutorial.R`: a file-preparation helper for the future online setup.
- `READER_FILES_MD5.csv`: the files fetched by that helper and their expected checksums.

The selected teaching example and its numerical checks do not establish general package performance, coverage, or false-positive rates. The selection record is retained in the companion materials.

## Online setup and release status

After public hosting, readers will be able to source `prepare_tutorial.R` from a URL pinned to the approved Git commit, then call `setwd(prepare_cusp_tutorial())`. This prepares the reader files and checks their hashes; it neither installs packages nor runs analyses. It refuses to overwrite an existing destination folder.

No working public setup URL or DOI is supplied in this preparation version. The helper has been parsed and statically inspected but has not been tested against a hosted release. The first author must test it before its command is added to the article. The complete interactive tutorial, including its single-profile plot, also awaits native-R execution by the first author. The automated reader run is already archived.

No models, simulations, densities, or statistical calculations were executed while preparing this repository. Original reader scripts, data, and archived results were copied without modification.

License scope and attribution are documented in `LICENSE.md`; full texts are in `LICENSES/`. The preferred citation will be finalized with the archival DOI. See `LICENSE_STATUS.md` and `CITATION.cff` for preparation metadata.

## Planned versioned console command

After public release and native-R testing, the reader command will use a readable version tag rather than a long commit identifier. The proposed tag `v1.0.0` has not yet been created:

```r
source("https://raw.githubusercontent.com/Renaud-Mabire/stochastic-cusp-tutorial/v1.0.0/prepare_tutorial.R")
setwd(prepare_cusp_tutorial())
```

This is a planned command, not a working public link. The release tag will be kept fixed; corrections will receive a new version. GitHub tags can technically be moved, so the underlying commit identifier will also be recorded in the release and the Zenodo archive.
