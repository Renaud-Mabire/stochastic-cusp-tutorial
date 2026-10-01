# Follow the cusp tutorial in R

These files contain the fixed data and reader scripts for version 1.7.0 of *A Step-by-Step Tutorial on the Stochastic Cusp Model in R*. No observations need to be generated.

1. Use R with **cusp 2.3.8**. The recorded run used R 4.6.0 on macOS. Scripts never install or change packages automatically; installation instructions are in README.md.
2. Set the working directory to the folder containing this file. In RStudio, opening `Cusp_Tutorial.Rproj` does this for you. If using the proposed online setup, `setwd(prepare_cusp_tutorial())` does both file preparation and directory selection after you source the published setup script.
3. Follow the blocks in `R/tutorial.R` in order, stopping if a check fails. All ten blocks are shown in the article. This performs an actual fit and evaluates densities; preparing the files alone does neither.

`source("R/plot_profiles.R")` loads two function definitions. The following `plot_tutorial_profiles(fit)` call evaluates conditional densities and draws the four panels from the already fitted object. The complete source is in that file, and the supplement and technical reference explain it.

For automated fitting and export instead, run `source("R/run_tutorial.R")`. It creates a timestamped results archive without overwriting previous runs. Do not run both routes unless you intend to fit the model twice. To read archived output without fitting, use `source("R/view_archived.R")`.

The reader download contains no historical validation archives or LaTeX build files. A short English provenance note and the native reader archive are available in the repository; detailed historical records remain separately preserved for the planned archival deposit. No public download URL exists yet; the online setup still needs author testing after hosting is configured.
