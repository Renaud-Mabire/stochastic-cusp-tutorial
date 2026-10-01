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

# Export the standard confidence intervals from the saved fit.
# Public Wald intervals from the archived native fit; no refit or new Hessian.
# From the project root: source("R/export_confint.R")

export_archived_confint <- function() {
  if (!file.exists("Cusp_Tutorial.Rproj")) stop("Open the supplied R project first.")
  if (!requireNamespace("cusp", quietly = TRUE) ||
      as.character(utils::packageVersion("cusp")) != "2.3.8") {
    stop("Exactly cusp 2.3.8 is required; no package has been installed or changed.")
  }
  # SHA-256 is checked by the document QA; this reader check uses a fixed MD5.
  expected_md5 <- "753df950221924794ef50b6a206cddcb"
  path <- "results/fit_native.rds"
  if (!file.exists(path) || unname(tools::md5sum(path)) != expected_md5) {
    stop("The archived fit is missing or differs from the supplied fixed object.")
  }
  stamp <- format(Sys.time(), "%Y%m%d_%H%M%S", tz = "UTC")
  out <- file.path("reader_output", paste0("confint_", stamp, "_UTC_", Sys.getpid()))
  if (file.exists(out) || file.exists(paste0(out, ".zip"))) {
    stop("The output already exists; nothing was overwritten.")
  }
  if (!dir.create(out, recursive = TRUE)) stop("Cannot create output directory.")
  writeLines(capture.output(sessionInfo()), file.path(out, "sessionInfo.txt"))
  warnings_seen <- character()
  errors_seen <- character()
  status <- "INCOMPLETE"
  on.exit({
    writeLines(status, file.path(out, "STATUS.txt"))
    writeLines(warnings_seen, file.path(out, "warnings.txt"))
    writeLines(errors_seen, file.path(out, "errors.txt"))
    archive <- paste0(out, ".zip")
    files <- list.files(out, full.names = TRUE)
    zip_status <- utils::zip(archive, files = files, flags = "-j")
    if (isTRUE(zip_status == 0L) && file.exists(archive)) {
      cat("\nResults archive:\n", normalizePath(archive), "\n", sep = "")
    } else {
      message("ZIP creation failed. The files remain in: ", normalizePath(out))
    }
  }, add = TRUE)
  tryCatch(withCallingHandlers({
    fit <- readRDS(path)
    if (!inherits(fit, "cusp") || !isTRUE(fit$converged) || !isTRUE(fit$OK) ||
        !identical(as.integer(fit$code), 0L) || fit$rank != 6L) {
      stop("Archived fit checks failed; no intervals produced.")
    }
    intervals <- stats::confint(fit, level = 0.95)
    if (!identical(dim(intervals), c(6L, 2L)) || any(!is.finite(intervals)) ||
        any(intervals[, 1L] > intervals[, 2L])) stop("Invalid interval output.")
    utils::write.csv(intervals, file.path(out, "confint_native_95.csv"))
    writeLines(capture.output(print(intervals)), file.path(out, "confint_console.txt"))
    writeLines(c("Fixed dataset: D0_screen_28062027", "cusp: 2.3.8",
                 "Command: stats::confint(fit, level = 0.95)",
                 paste("Archived fit MD5:", expected_md5),
                 "No refit; no replacement Hessian; no new selection."),
               file.path(out, "PROVENANCE.txt"))
    status <- "COMPLETE_PUBLIC_CONFINT_EXPORT_NOT_A_NEW_VALIDATION"
    print(intervals)
    invisible(intervals)
  }, warning = function(w) {
    warnings_seen <<- c(warnings_seen, conditionMessage(w))
  }), error = function(e) {
    errors_seen <<- conditionMessage(e)
    stop(e)
  })
}

confint_export <- export_archived_confint()

})()
