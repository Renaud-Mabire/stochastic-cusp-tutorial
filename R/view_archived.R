# Run this script locally in R; see README.md for its purpose.
# Locate this project from the path passed to source(), independent of getwd().
(function() {
  source_files <- vapply(sys.frames(), function(frame) {
    value <- get0("ofile", envir = frame, inherits = FALSE)
    if (is.null(value) || length(value) != 1L) "" else as.character(value)
  }, character(1))
  source_files <- source_files[nzchar(source_files)]
  if (length(source_files)) {
    script <- tail(source_files, 1L)
    if (!file.exists(script) && file.exists(basename(script))) script <- basename(script)
    project_root <- dirname(dirname(normalizePath(script, mustWork = TRUE)))
  } else {
    project_root <- getwd()
  }
  if (!file.exists(file.path(project_root, "Cusp_Tutorial.Rproj"))) {
    stop("Project not found. Source this file by its full path from the extracted package.")
  }
  previous_directory <- setwd(project_root)
  on.exit(setwd(previous_directory), add = TRUE)

# READ-ONLY viewing: no fit, summary method, density evaluation, or simulation.
# Open Cusp_Tutorial.Rproj first, then source("R/view_archived.R").
if (!file.exists("results/coefficients.csv")) {
  stop("Open the supplied RStudio project, with the package root as working directory.")
}
cat(readLines("results/reader_summary_console.txt", warn = FALSE, encoding = "UTF-8"),
    sep = "\n")
archived_coefficients <- read.csv("results/coefficients.csv", check.names = FALSE)
archived_model_statistics <- read.csv("results/actual_summary_model_statistics.csv")
archived_profiles <- read.csv("results/conditional_density_profiles.csv")
cat("\nArchived public 95% confidence intervals:\n")
cat(readLines("results/confint_console.txt", warn = FALSE), sep = "\n")
cat("\nArchived tables loaded. No analysis has been run.\n")

})()
