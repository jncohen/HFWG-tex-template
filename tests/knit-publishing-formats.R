#!/usr/bin/env Rscript

# Generate and optionally render manual inspection documents for publishing
# workflows: Snapshot and Blogpost.
#
# Run from the repository root with:
#   Rscript tests/knit-publishing-formats.R
#
# To generate the Rmd files without rendering PDFs or companions:
#   Rscript tests/knit-publishing-formats.R --no-render
#
# To render only selected workflows:
#   Rscript tests/knit-publishing-formats.R snapshot
#   Rscript tests/knit-publishing-formats.R blogpost

args <- commandArgs(trailingOnly = TRUE)
render_outputs <- !"--no-render" %in% args
selected <- setdiff(args, "--no-render")

script_path <- NA_character_
cmd_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", cmd_args, value = TRUE)
if (length(file_arg)) {
  script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]),
                               winslash = "/", mustWork = TRUE)
}
if (is.na(script_path)) {
  script_path <- normalizePath(file.path(getwd(), "tests", "knit-publishing-formats.R"),
                               winslash = "/", mustWork = FALSE)
}

tests_dir <- dirname(script_path)
repo_dir <- dirname(tests_dir)
workflows <- c("snapshot", "blogpost")

if (length(selected)) {
  unknown <- setdiff(selected, workflows)
  if (length(unknown)) {
    stop("Unknown publishing workflow(s): ", paste(unknown, collapse = ", "),
         "\nAvailable workflows: ", paste(workflows, collapse = ", "))
  }
  workflows <- selected
}

yaml_quote <- function(x) {
  paste0('"', gsub('"', '\\"', x, fixed = TRUE), '"')
}

write_snapshot_rmd <- function() {
  rmd_path <- file.path(tests_dir, "publishing-snapshot.Rmd")

  lines <- c(
    "---",
    'title: "College Completion Marks the Largest Visible Wealth Divide"',
    'subtitle: "Survey of Consumer Finances, 2022"',
    'date: "May 2026"',
    "",
    'author:',
    '  - name: "Ada Template"',
    "",
    'surname: "Template"',
    'runningtitle: "Snapshot Publishing Test"',
    'author_dept: "Department of Sociology"',
    'author_inst: "Queens College, City University of New York"',
    'author_addr: "65-30 Kissena Blvd., Queens, NY 11367, USA"',
    'author_email: "ada.template@example.edu"',
    'author_web: "https://example.edu/publishing-test"',
    'author_orcid: "0000-0002-1825-0097"',
    "",
    'institution: "Household Finance Lab"',
    'series: "Snapshot"',
    "number: 1",
    "",
    "snapshot: true",
    'snapshot_label: "Empirical Snapshot"',
    'snapshot_abstract_label: "Lead"',
    'snapshot_feature: "publishing-snapshot_files/figure-latex/featured-figure-1.png"',
    "accent: 0066CC",
    "fontset: hfwg",
    'fontpath: "../inst/fonts/"',
    "",
    "abstract: |",
    "  Households headed by adults with a bachelor's degree hold visibly more",
    "  wealth than households without one. This synthetic test document checks",
    "  the compact Snapshot header, lead treatment, featured visualization,",
    "  and WordPress companion output.",
    "",
    "output:",
    "  hfwgtex::snapshot_pdf:",
    '    template: "../inst/templates/hfwgtemplate.tex"',
    "    latex_engine: xelatex",
    "    keep_tex: true",
    "    wordpress: html",
    "    wordpress_assets: true",
    "    wordpress_checklist: true",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "knitr::opts_chunk$set(echo = FALSE, message = FALSE, warning = FALSE, fig.width = 6, fig.height = 3.5)",
    "```",
    "",
    "```{r featured-figure, include=FALSE, dev='png'}",
    "wealth <- c(42000, 91000, 265000, 410000)",
    "names(wealth) <- c('No diploma', 'High school', 'BA', 'Graduate')",
    "barplot(wealth, col = c('#B8C7D9', '#8FB3D9', '#0066CC', '#004C99'), border = NA, las = 1, ylab = 'Median net worth')",
    "```",
    "",
    "# Context",
    "",
    "This manual inspection file mimics a short empirical Snapshot. It is not",
    "intended to test estimates; it tests the publication shape that research",
    "assistants will use for public-facing Lab writing.",
    "",
    "# Finding",
    "",
    "The central result should be easy to identify from the lead, the section",
    "headings, and the featured visualization. The PDF should keep the header",
    "compact and make the chart feel like the object around which the text is",
    "built.",
    "",
    "# Implication",
    "",
    "The companion HTML should be pasteable into a WordPress post while keeping",
    "the prose, headings, links, and generated figure references in a simple",
    "editable structure.",
    "",
    "# Methodological footer",
    "",
    "This is synthetic data for rendering inspection only. No substantive claim",
    "should be inferred from the values shown here."
  )

  writeLines(lines, rmd_path, useBytes = TRUE)
  rmd_path
}

write_blogpost_rmd <- function() {
  rmd_path <- file.path(tests_dir, "publishing-blogpost.Rmd")

  lines <- c(
    "---",
    'title: "A Standard Lab Post Using the HFWG Report Style"',
    'subtitle: "Manual publishing workflow test"',
    'date: "May 2026"',
    "",
    'author:',
    '  - name: "Ada Template"',
    "",
    'surname: "Template"',
    'runningtitle: "Blogpost Publishing Test"',
    'author_dept: "Department of Sociology"',
    'author_inst: "Queens College, City University of New York"',
    'author_addr: "65-30 Kissena Blvd., Queens, NY 11367, USA"',
    'author_email: "ada.template@example.edu"',
    'author_web: "https://example.edu/publishing-test"',
    'author_orcid: "0000-0002-1825-0097"',
    "",
    'institution: "Household Finance Lab"',
    'series: "Blogpost"',
    "number: 1",
    "",
    "accent: 003DA5",
    "fontset: hfwg",
    'fontpath: "../inst/fonts/"',
    "",
    "abstract: |",
    "  This synthetic blogpost uses the standard HFWG report title page and",
    "  body styling, but it also emits a WordPress companion file.",
    "",
    "output:",
    "  hfwgtex::blogpost_pdf:",
    '    template: "../inst/templates/hfwgtemplate.tex"',
    "    latex_engine: xelatex",
    "    keep_tex: true",
    "    wordpress: html",
    "    wordpress_assets: true",
    "    wordpress_checklist: true",
    "---",
    "",
    "# Opening",
    "",
    "This manual inspection file exercises the Blogpost workflow. The PDF should",
    "look like a normal HFWG report rather than a compact Snapshot.",
    "",
    "## Figure",
    "",
    "```{r blogpost-figure, echo=FALSE, fig.width=5, fig.height=3}",
    "values <- c(30, 45, 55)",
    "barplot(values, names.arg = c('A', 'B', 'C'), col = '#003DA5', border = NA, ylab = 'Value')",
    "```",
    "",
    "# Closing",
    "",
    "The WordPress companion should be generated alongside the PDF, making this",
    "format suitable for Lab posts that need both a printable report and a web",
    "copy source."
  )

  writeLines(lines, rmd_path, useBytes = TRUE)
  rmd_path
}

rmd_files <- character()
if ("snapshot" %in% workflows) rmd_files <- c(rmd_files, write_snapshot_rmd())
if ("blogpost" %in% workflows) rmd_files <- c(rmd_files, write_blogpost_rmd())

message("Wrote publishing test documents:")
message(paste("  -", basename(rmd_files), collapse = "\n"))

if (render_outputs) {
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("The rmarkdown package is required to render these tests.")
  }
  if (requireNamespace("pkgload", quietly = TRUE)) {
    pkgload::load_all(repo_dir, quiet = TRUE)
  }

  oldwd <- setwd(tests_dir)
  on.exit(setwd(oldwd), add = TRUE)

  for (rmd in rmd_files) {
    output_file <- sub("\\.Rmd$", ".pdf", basename(rmd))
    message("\nRendering ", output_file)
    rmarkdown::render(
      input = basename(rmd),
      output_file = output_file,
      output_dir = tests_dir,
      envir = new.env(parent = globalenv()),
      quiet = FALSE
    )
  }
  message("\nRendered publishing outputs in: ", tests_dir)
} else {
  message("\nSkipped rendering because --no-render was supplied.")
}
