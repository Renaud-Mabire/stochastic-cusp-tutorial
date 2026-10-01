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

# Automated reproduction and export of the fixed example.
# The analysis workflow was executed by the first author on September 24, 2026.
# Open Cusp_Tutorial.Rproj, then source("R/run_tutorial.R").
# It fits the fixed dataset once; it does not generate a dataset or select a seed.

run_tutorial <- function() {
  if (!file.exists("Cusp_Tutorial.Rproj")) {
    stop("Open Cusp_Tutorial.Rproj and use the package root as working directory.")
  }
  if (!requireNamespace("cusp", quietly = TRUE)) {
    stop("Install cusp 2.3.8 before running this script; see README.md.")
  }
  if (as.character(utils::packageVersion("cusp")) != "2.3.8") {
    stop("This tutorial requires exactly cusp 2.3.8. No package was changed.")
  }
  manifest <- utils::read.csv("data/INPUT_MD5.csv", stringsAsFactors = FALSE)
  if (any(!file.exists(manifest$file))) stop("A fixed input is missing.")
  actual_hashes <- unname(tools::md5sum(manifest$file))
  if (!identical(actual_hashes, manifest$md5)) stop("A fixed input hash differs.")

  source("R/plot_profiles.R", local = TRUE)
  dat <- readRDS("data/analysis_data.rds")
  expected_names <- c("id", "personal_resources_z", "acute_stress_z",
                      "adaptive_functioning_z")
  if (!is.data.frame(dat) || !identical(names(dat), expected_names) || nrow(dat) != 1200L) {
    stop("The analysis data do not match the fixed tutorial structure.")
  }
  if (any(!is.finite(as.matrix(dat[expected_names[-1L]])))) {
    stop("The fixed analysis data contain nonfinite values.")
  }

  stamp <- format(Sys.time(), "%Y%m%d_%H%M%S", tz = "UTC")
  out <- file.path("reader_output", paste0("tutorial_", stamp, "_UTC_", Sys.getpid()))
  if (file.exists(out) || file.exists(paste0(out, ".zip"))) {
    stop("Output path already exists; nothing was overwritten.")
  }
  if (!dir.create(out, recursive = TRUE)) stop("Cannot create the new output directory.")
  writeLines(capture.output(sessionInfo()), file.path(out, "sessionInfo.txt"))
  warnings_seen <- character()
  status <- "INCOMPLETE"
  error_text <- character()
  on.exit({
    writeLines(warnings_seen, file.path(out, "warnings.txt"))
    writeLines(error_text, file.path(out, "errors.txt"))
    writeLines(status, file.path(out, "STATUS.txt"))
    archive <- paste0(out, ".zip")
    zip_status <- utils::zip(archive, files = list.files(out, full.names = TRUE), flags = "-j")
    if (isTRUE(zip_status == 0L) && file.exists(archive)) {
      cat("\nResults archive:\n", normalizePath(archive), "\n", sep = "")
    } else message("ZIP creation failed. Files remain in: ", normalizePath(out))
  }, add = TRUE)

  tryCatch(withCallingHandlers({
    RNGkind("Mersenne-Twister", "Inversion", "Rejection")
    set.seed(28062027L) # fixed for session provenance; no data are generated here
    message("Fitting the fixed example with the unmodified public function.")
    fit <- cusp::cusp(
      y ~ adaptive_functioning_z,
      alpha ~ personal_resources_z,
      beta ~ acute_stress_z,
      data = dat,
      optim.method = "L-BFGS-B"
    )
    saveRDS(fit, file.path(out, "fit_native.rds"))
    checks <- list(code = fit$code, converged = fit$converged,
                OK = fit$OK, rank = fit$rank)
    print(checks)
    writeLines(capture.output(str(fit, max.level = 1)), file.path(out, "fit_structure.txt"))
    writeLines(capture.output(print(checks)), file.path(out, "fit_checks.txt"))
    if (!isTRUE(fit$converged) || !identical(as.integer(fit$code), 0L) ||
        !isTRUE(fit$OK) || fit$rank != 6L || any(!is.finite(coef(fit)))) {
      stop("Native checks failed. Inspect the saved fit and log; do not interpret Wald tests.")
    }

    message("Printing the native summary, including its built-in linear comparator.")
    sm <- summary(fit)
    saveRDS(sm, file.path(out, "summary_object.rds"))
    writeLines(capture.output(print(sm)), file.path(out, "summary_console.txt"))
    print(sm)
    if (!identical(dim(sm$coefficients), c(6L, 4L)) ||
        any(!is.finite(sm$coefficients)) || any(sm$coefficients[, "Std. Error"] <= 0)) {
      stop("The native coefficient table is incomplete or invalid.")
    }
    utils::write.csv(sm$coefficients, file.path(out, "coefficients.csv"))

    pdf_plot <- function(filename, draw) {
      grDevices::pdf(file.path(out, filename), width = 10, height = 8)
      on.exit(grDevices::dev.off(), add = TRUE)
      draw()
    }
    message("Exporting the public confidence intervals for this reader fit.")
    intervals <- stats::confint(fit, level = 0.95)
    if (!identical(dim(intervals), c(6L, 2L)) || any(!is.finite(intervals))) {
      stop("Invalid public interval output.")
    }
    utils::write.csv(intervals, file.path(out, "confint_native_95.csv"))
    writeLines(capture.output(print(intervals)), file.path(out, "confint_console.txt"))
    print(intervals)
    message("Saving the public diagnostic displays and conditional profiles.")
    pdf_plot("plot_cusp_standard.pdf", function() graphics::plot(fit))
    pdf_plot("cusp3d_standard.pdf", function() cusp::cusp3d(fit))
    profiles <- tutorial_profiles(fit)
    utils::write.csv(profiles, file.path(out, "conditional_density_profiles.csv"), row.names = FALSE)
    pdf_plot("geometry_and_densities.pdf", function() plot_tutorial_profiles(fit, profiles))
    writeLines(c("Fixed data: D0_screen_28062027; cusp 2.3.8",
      "One public fit; no new simulation, selection, multistart, or reference analysis.",
      "The built-in summary comparison is the same one shown in the manuscript.",
      "Inspect this archive before replacing any reported value."), file.path(out, "PROVENANCE.txt"))
    status <- "COMPLETE_READER_REPRODUCTION_NOT_A_NEW_VALIDATION"
    invisible(list(fit = fit, summary = sm, directory = out))
  }, warning = function(w) {
    warnings_seen <<- c(warnings_seen, conditionMessage(w))
    # Keep warnings visible to the reader as well as saving them.
  }), error = function(e) {
    error_text <<- conditionMessage(e)
    stop(e)
  })
}

tutorial_result <- run_tutorial()

})()
