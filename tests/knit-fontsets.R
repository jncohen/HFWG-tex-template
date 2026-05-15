#!/usr/bin/env Rscript

# Generate and render one fake R Markdown document for each fontset.
# Run from the repository root with:
#   Rscript tests/knit-fontsets.R
#
# To render only selected presets:
#   Rscript tests/knit-fontsets.R hfwg methods
#
# To generate the Rmd files without rendering PDFs:
#   Rscript tests/knit-fontsets.R --no-render

args <- commandArgs(trailingOnly = TRUE)
render_pdf <- !"--no-render" %in% args
selected <- setdiff(args, "--no-render")

script_path <- NA_character_
cmd_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", cmd_args, value = TRUE)
if (length(file_arg)) {
  script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]),
                               winslash = "/", mustWork = TRUE)
}
if (is.na(script_path) && requireNamespace("rstudioapi", quietly = TRUE)) {
  context <- tryCatch(rstudioapi::getActiveDocumentContext(), error = function(e) NULL)
  if (!is.null(context) && nzchar(context$path)) {
    script_path <- normalizePath(context$path, winslash = "/", mustWork = TRUE)
  }
}
if (is.na(script_path)) {
  script_path <- normalizePath(file.path(getwd(), "tests", "knit-fontsets.R"),
                               winslash = "/", mustWork = FALSE)
}

tests_dir <- dirname(script_path)

fontsets <- c(
  default = "",
  hfwg = "hfwg",
  humanities = "humanities",
  demography = "demography",
  methods = "methods"
)
fontset_numbers <- setNames(seq_along(fontsets), names(fontsets))

if (length(selected)) {
  unknown <- setdiff(selected, names(fontsets))
  if (length(unknown)) {
    stop("Unknown fontset test(s): ", paste(unknown, collapse = ", "),
         "\nAvailable tests: ", paste(names(fontsets), collapse = ", "))
  }
  fontsets <- fontsets[selected]
}

yaml_quote <- function(x) {
  paste0('"', gsub('"', '\\"', x, fixed = TRUE), '"')
}

write_fontset_rmd <- function(id, fontset) {
  title <- sprintf("Fontset Test: %s", id)
  fontset_line <- if (nzchar(fontset)) sprintf("fontset: %s", fontset) else NULL
  rmd_path <- file.path(tests_dir, sprintf("fontset-%s.Rmd", id))

  lines <- c(
    "---",
    sprintf("title: %s", yaml_quote(title)),
    'subtitle: "Synthetic document for visual regression checks"',
    'date: "May 2026"',
    "",
    'author:',
    '  - name: "Ada Template"',
    '  - name: "Sam Sample"',
    "",
    'surname: "Template"',
    sprintf("runningtitle: %s", yaml_quote(sprintf("Fontset Test: %s", id))),
    "",
    'author_dept: "Department of Sociology"',
    'author_inst: "Queens College, City University of New York"',
    'author_addr: "65-30 Kissena Blvd., Queens, NY 11367, USA"',
    'author_email: "ada.template@example.edu"',
    'author_web: "https://example.edu/fontset-test"',
    'author_orcid: "0000-0002-1825-0097"',
    "",
    'institution: "Household Finance Working Group"',
    'series: "Fontset Test Series"',
    sprintf("number: %d", fontset_numbers[[id]]),
    "",
    fontset_line,
    'fontpath: "../inst/fonts/"',
    'bibliography: "fontset-test.bib"',
    'csl: "../inst/csl/default.csl"',
    "",
    "anonymize: false",
    "doublespace: false",
    "linenumbers: false",
    "numbersections: true",
    "maincolumns: 1",
    "",
    "abstract: |",
    "  This fake manuscript tests title-page metadata, body typography,",
    "  citations, headings, mathematical notation, tables, figures, and code",
    "  formatting across the available HFWG template fontsets.",
    "",
    "keywords:",
    "  - font testing",
    "  - R Markdown",
    "  - LaTeX template",
    "",
    "acknowledgements: |",
    "  This synthetic acknowledgement is included to test the title-page",
    "  acknowledgement block and its spacing.",
    "",
    "output:",
    "  pdf_document:",
    '    template: "../inst/templates/hfwgtemplate.tex"',
    "    latex_engine: xelatex",
    "    keep_tex: true",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, fig.width = 5, fig.height = 3)",
    "```",
    "",
    "# Introduction",
    "",
    "This paragraph exercises ordinary prose, *emphasis*, **strong emphasis**,",
    "inline code such as `median_income`, and citations [@burnham2002; @warren2015].",
    "The metadata citation should also resolve cleanly [@hfwg2026].",
    "",
    "## Mathematical Notation",
    "",
    "Inline math should sit comfortably in text, as in $y_i = \\alpha + \\beta x_i + \\epsilon_i$.",
    "",
    "$$",
    "\\bar{x} = \\frac{1}{n}\\sum_{i=1}^{n} x_i",
    "$$",
    "",
    "## Table and Code",
    "",
    "```{r table-example}",
    "summary_table <- data.frame(",
    '  group = c("No degree", "BA", "Graduate"),',
    "  median_wealth = c(42000, 180000, 325000),",
    "  share = c(0.52, 0.31, 0.17)",
    ")",
    "knitr::kable(summary_table, caption = 'Synthetic household wealth by education')",
    "```",
    "",
    "## Figure",
    "",
    "```{r figure-example}",
    "barplot(",
    "  summary_table$median_wealth,",
    "  names.arg = summary_table$group,",
    "  col = c('#D9E2EC', '#8FB3D9', '#2E6FA3'),",
    "  border = NA,",
    "  ylab = 'Median wealth',",
    "  las = 1",
    ")",
    "```",
    "",
    "# Conclusion",
    "",
    "The final section gives section headings, spacing, references, and running",
    "headers a little more room to show themselves.",
    "",
    "# References"
  )

  writeLines(lines[!is.na(lines)], rmd_path, useBytes = TRUE)
  rmd_path
}

rmd_files <- Map(write_fontset_rmd, names(fontsets), fontsets)
message("Wrote test documents:")
message(paste("  -", basename(unlist(rmd_files)), collapse = "\n"))

if (render_pdf) {
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("The rmarkdown package is required to render these tests.")
  }

  oldwd <- setwd(tests_dir)
  on.exit(setwd(oldwd), add = TRUE)

  for (rmd in unlist(rmd_files)) {
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
  message("\nRendered PDFs in: ", tests_dir)
} else {
  message("\nSkipped rendering because --no-render was supplied.")
}
