#!/usr/bin/env Rscript

# Generate and optionally render the manual Snapshot inspection document.
#
# Run from the repository root with:
#   Rscript tests/knit-snapshot.R
#
# To generate the Rmd file without rendering PDF/WordPress outputs:
#   Rscript tests/knit-snapshot.R --no-render

args <- commandArgs(trailingOnly = TRUE)

script_path <- NA_character_
cmd_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", cmd_args, value = TRUE)
if (length(file_arg)) {
  script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]),
                               winslash = "/", mustWork = TRUE)
}
if (is.na(script_path)) {
  script_path <- normalizePath(file.path(getwd(), "tests", "knit-snapshot.R"),
                               winslash = "/", mustWork = FALSE)
}

tests_dir <- dirname(script_path)
publishing_script <- file.path(tests_dir, "knit-publishing-formats.R")

if (!file.exists(publishing_script)) {
  stop("Could not find tests/knit-publishing-formats.R")
}

source_args <- c("snapshot", args)
cmd <- c(shQuote(publishing_script), source_args)

status <- system2(file.path(R.home("bin"), "Rscript"), cmd)
if (!identical(status, 0L)) {
  quit(status = status)
}
