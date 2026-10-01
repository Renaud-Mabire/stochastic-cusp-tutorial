# Download the fixed reader files; no package installation or analysis.
# After publication, source this file from its commit-pinned HTTPS URL, then use:
# setwd(prepare_cusp_tutorial())
# If sourced locally, provide the published directory URL as base_url.
prepare_cusp_tutorial <- local({
  paths <- vapply(sys.frames(), function(frame) {
    x <- get0("ofile", envir = frame, inherits = FALSE)
    if (is.null(x) || length(x) != 1L) "" else as.character(x)
  }, character(1))
  paths <- paths[grepl("^https://.*[/]prepare_tutorial[.]R$", paths)]
  source_base <- if (length(paths)) {
    sub("/prepare_tutorial[.]R$", "", tail(paths, 1L))
  } else NULL

  function(base_url = source_base,
           directory = file.path(getwd(), "Cusp_Tutorial")) {
    if (!is.character(base_url) || length(base_url) != 1L ||
        is.na(base_url) || !grepl("^https://", base_url)) {
      stop("Supply the published, version-pinned HTTPS directory URL as base_url.")
    }
    base_url <- sub("/+$", "", base_url)
    if (!is.character(directory) || length(directory) != 1L ||
        is.na(directory) || !nzchar(directory)) stop("Supply a new directory path.")
    if (file.exists(directory)) stop("Destination exists; nothing was overwritten.")
    parent <- normalizePath(dirname(directory), mustWork = TRUE)
    destination <- file.path(parent, basename(directory))
    stage <- tempfile("cusp-download-", tmpdir = parent)
    if (!dir.create(stage)) stop("Cannot create a download directory.")
    on.exit(unlink(stage, recursive = TRUE), add = TRUE)
    fetch <- function(relative, target) {
      status <- utils::download.file(paste0(base_url, "/", relative),
                                    target, mode = "wb", quiet = TRUE)
      if (!isTRUE(status == 0L) || !file.exists(target)) {
        stop("Download failed: ", relative)
      }
    }
    manifest_path <- file.path(stage, "READER_FILES_MD5.csv")
    fetch("READER_FILES_MD5.csv", manifest_path)
    manifest <- utils::read.csv(manifest_path, stringsAsFactors = FALSE)
    if (!identical(names(manifest), c("file", "md5")) ||
        !nrow(manifest) || anyNA(manifest) || anyDuplicated(manifest$file)) {
      stop("Invalid reader-file manifest.")
    }
    safe <- grepl("^[A-Za-z0-9_./-]+$", manifest$file) &
      !grepl("^/|(^|/)\\.\\.?(/|$)", manifest$file) &
      !grepl("/$|//", manifest$file)
    required <- c("Cusp_Tutorial.Rproj", "R/tutorial.R", "R/plot_profiles.R",
                  "R/run_tutorial.R", "data/analysis_data.rds", "data/INPUT_MD5.csv")
    if (!all(safe) || !all(required %in% manifest$file) ||
        "READER_FILES_MD5.csv" %in% manifest$file ||
        !all(grepl("^[a-f0-9]{32}$", manifest$md5))) {
      stop("Invalid paths, checksums, or missing required files in the manifest.")
    }
    for (i in seq_len(nrow(manifest))) {
      relative <- manifest$file[i]
      target <- file.path(stage, relative)
      dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
      message("Downloading ", i, "/", nrow(manifest), ": ", relative)
      fetch(relative, target)
    }
    actual <- unname(tools::md5sum(file.path(stage, manifest$file)))
    if (!identical(actual, manifest$md5)) stop("Downloaded-file checksum mismatch.")
    if (file.exists(destination)) stop("Destination was created meanwhile; stopping.")
    if (!file.rename(stage, destination)) stop("Cannot finalize the reader directory.")
    message("Files ready. No model or other analysis has been run.")
    message("Follow R/tutorial.R block by block after setting the working directory.")
    normalizePath(destination, mustWork = TRUE)
  }
})
