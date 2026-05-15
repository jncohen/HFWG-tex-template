#' Copy the hfwgtex template bundle into a project directory
#'
#' Copies `hfwgtemplate.tex`, `fonts/`, and `default.csl` from the
#' installed package into `path` (default: current working directory).
#' Run once per new project. Use `overwrite = TRUE` to update an
#' existing project to the currently installed template version.
#'
#' After running, add to your document's YAML front matter:
#' ```yaml
#' template: hfwgtemplate.tex
#' fontpath: fonts/
#' csl: default.csl
#' ```
#'
#' To update an existing project after installing a new package version:
#' ```r
#' hfwg_use(overwrite = TRUE)
#' ```
#'
#' @param path Destination directory. Defaults to current working directory.
#' @param overwrite If `TRUE`, replace existing files. Default `FALSE`.
#' @return Invisibly returns `path`.
#' @export
hfwg_use <- function(path = ".", overwrite = FALSE) {
  pkg <- "hfwgtex"

  template_src <- system.file("templates/hfwgtemplate.tex", package = pkg)
  fonts_src    <- system.file("fonts",                      package = pkg)
  csl_src      <- system.file("csl/default.csl",           package = pkg)

  if (!nzchar(template_src)) {
    stop("Package 'hfwgtex' does not appear to be installed. ",
         "Run: devtools::install_github(\"jncohen/HFWG-tex-template\")")
  }

  template_dst <- file.path(path, "hfwgtemplate.tex")
  fonts_dst    <- file.path(path, "fonts")
  csl_dst      <- file.path(path, "default.csl")

  .copy_if <- function(src, dst) {
    if (!file.exists(dst) || overwrite) {
      file.copy(src, dst, overwrite = overwrite)
      message("Copied:  ", dst)
    } else {
      message("Skipped: ", dst, "  (use overwrite = TRUE to replace)")
    }
  }

  # Template
  .copy_if(template_src, template_dst)

  # Fonts directory
  if (!dir.exists(fonts_dst)) dir.create(fonts_dst, recursive = TRUE)
  font_files <- list.files(fonts_src, full.names = TRUE)
  copied <- 0L
  for (f in font_files) {
    dst <- file.path(fonts_dst, basename(f))
    if (!file.exists(dst) || overwrite) {
      file.copy(f, dst)
      copied <- copied + 1L
    }
  }
  message("Fonts:   ", fonts_dst, "/  (", copied, " file(s) copied)")

  # CSL
  .copy_if(csl_src, csl_dst)

  message("\nAdd to your YAML front matter:")
  message("  template: hfwgtemplate.tex")
  message("  fontpath: fonts/")
  message("  csl: default.csl")

  invisible(path)
}
