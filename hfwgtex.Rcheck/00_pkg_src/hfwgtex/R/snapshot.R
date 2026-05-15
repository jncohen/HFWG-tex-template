#' Render a Snapshot PDF and WordPress companion file
#'
#' Use this as an R Markdown output format for public-facing Lab Snapshots.
#' It renders the PDF with the bundled LaTeX template and, after knitting,
#' converts the knitted markdown to a WordPress-ready companion file.
#'
#' Add to YAML:
#' ```yaml
#' snapshot: true
#' output:
#'   hfwgtex::snapshot_pdf:
#'     wordpress: html
#' ```
#'
#' @param ... Arguments passed to [rmarkdown::pdf_document()].
#' @param template LaTeX template path. Defaults to `hfwgtemplate.tex`.
#' @param latex_engine LaTeX engine for the PDF. Defaults to `xelatex`.
#' @param wordpress Companion output type: `"html"`, `"markdown"`, or `"none"`.
#' @param wordpress_file Optional companion output filename. When `NULL`,
#'   uses the PDF filename with `-wordpress.html` or `-wordpress.md`.
#' @param wordpress_assets If `TRUE`, copy local images referenced by the
#'   companion file into a sibling `-wordpress-assets/` directory and rewrite
#'   image paths to point there.
#' @param wordpress_checklist If `TRUE`, write a short manual publishing
#'   checklist for RStudio-to-WordPress handoff.
#' @return An R Markdown output format.
#' @export
snapshot_pdf <- function(...,
                         template = "hfwgtemplate.tex",
                         latex_engine = "xelatex",
                         wordpress = c("html", "markdown", "none"),
                         wordpress_file = NULL,
                         wordpress_assets = TRUE,
                         wordpress_checklist = TRUE) {
  wordpress <- match.arg(wordpress)

  companion_pdf_document(
    ...,
    template = template,
    latex_engine = latex_engine,
    companion = wordpress,
    companion_file = wordpress_file,
    companion_assets = wordpress_assets,
    companion_checklist = wordpress_checklist
  )
}

#' Render a Blogpost PDF and WordPress companion file
#'
#' Use this output format for public-facing Lab posts that should keep the
#' standard HFWG report PDF styling while also producing a WordPress-ready
#' companion file.
#'
#' Add to YAML:
#' ```yaml
#' output:
#'   hfwgtex::blogpost_pdf:
#'     wordpress: html
#' ```
#'
#' @param ... Arguments passed to [rmarkdown::pdf_document()].
#' @param template LaTeX template path. Defaults to `hfwgtemplate.tex`.
#' @param latex_engine LaTeX engine for the PDF. Defaults to `xelatex`.
#' @param wordpress Companion output type: `"html"`, `"markdown"`, or `"none"`.
#' @param wordpress_file Optional companion output filename. When `NULL`,
#'   uses the PDF filename with `-wordpress.html` or `-wordpress.md`.
#' @param wordpress_assets If `TRUE`, copy local images referenced by the
#'   companion file into a sibling `-wordpress-assets/` directory and rewrite
#'   image paths to point there.
#' @param wordpress_checklist If `TRUE`, write a short manual publishing
#'   checklist for RStudio-to-WordPress handoff.
#' @return An R Markdown output format.
#' @export
blogpost_pdf <- function(...,
                         template = "hfwgtemplate.tex",
                         latex_engine = "xelatex",
                         wordpress = c("html", "markdown", "none"),
                         wordpress_file = NULL,
                         wordpress_assets = TRUE,
                         wordpress_checklist = TRUE) {
  wordpress <- match.arg(wordpress)

  companion_pdf_document(
    ...,
    template = template,
    latex_engine = latex_engine,
    companion = wordpress,
    companion_file = wordpress_file,
    companion_assets = wordpress_assets,
    companion_checklist = wordpress_checklist
  )
}

companion_pdf_document <- function(...,
                                   template,
                                   latex_engine,
                                   companion,
                                   companion_file = NULL,
                                   companion_assets = TRUE,
                                   companion_checklist = TRUE) {
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("The rmarkdown package is required for this output format.",
         call. = FALSE)
  }

  format <- rmarkdown::pdf_document(
    ...,
    template = template,
    latex_engine = latex_engine
  )

  previous_post_processor <- format$post_processor

  format$post_processor <- function(metadata, input_file, output_file, clean, verbose) {
    final_output <- output_file
    if (is.function(previous_post_processor)) {
      final_output <- previous_post_processor(
        metadata = metadata,
        input_file = input_file,
        output_file = output_file,
        clean = clean,
        verbose = verbose
      )
    }

    if (!identical(companion, "none")) {
      make_wordpress_companion_file(
        input_file = input_file,
        output_file = final_output,
        companion = companion,
        companion_file = companion_file,
        copy_assets = companion_assets,
        write_checklist = companion_checklist,
        metadata = metadata,
        verbose = verbose
      )
    }

    final_output
  }

  format
}

make_wordpress_companion_file <- function(input_file,
                                          output_file,
                                          companion,
                                          companion_file = NULL,
                                          copy_assets = TRUE,
                                          write_checklist = TRUE,
                                          metadata = list(),
                                          verbose = FALSE) {
  ext <- if (identical(companion, "html")) "html" else "md"
  if (is.null(companion_file)) {
    companion_file <- paste0(tools::file_path_sans_ext(output_file),
                             "-wordpress.", ext)
  }

  to <- if (identical(companion, "html")) "html5" else "gfm"
  options <- if (identical(companion, "html")) {
    c("--section-divs", "--wrap=none")
  } else {
    c("--wrap=none")
  }

  rmarkdown::pandoc_convert(
    input = input_file,
    to = to,
    output = companion_file,
    options = options,
    verbose = verbose
  )

  assets_dir <- NULL
  if (isTRUE(copy_assets)) {
    assets_dir <- copy_wordpress_assets(
      companion_file = companion_file,
      input_file = input_file,
      companion = companion
    )
  }

  if (isTRUE(write_checklist)) {
    write_wordpress_checklist(
      output_file = output_file,
      companion_file = companion_file,
      assets_dir = assets_dir,
      metadata = metadata
    )
  }

  if (verbose) {
    message("WordPress companion written to: ", companion_file)
    if (!is.null(assets_dir)) {
      message("WordPress assets written to: ", assets_dir)
    }
  }

  invisible(companion_file)
}

copy_wordpress_assets <- function(companion_file, input_file, companion) {
  if (!file.exists(companion_file)) {
    return(NULL)
  }

  text <- readLines(companion_file, warn = FALSE, encoding = "UTF-8")
  refs <- image_references(text, companion)
  refs <- refs[is_local_asset_ref(refs)]
  if (!length(refs)) {
    return(NULL)
  }

  companion_dir <- dirname(normalizePath(companion_file, winslash = "/",
                                         mustWork = FALSE))
  input_dir <- dirname(normalizePath(input_file, winslash = "/",
                                     mustWork = FALSE))
  assets_dir <- paste0(tools::file_path_sans_ext(companion_file),
                       "-assets")
  dir.create(assets_dir, recursive = TRUE, showWarnings = FALSE)

  copied <- character()
  replacements <- setNames(character(length(refs)), refs)
  for (ref in unique(refs)) {
    src <- resolve_asset_path(ref, c(companion_dir, input_dir, getwd()))
    if (is.na(src)) {
      next
    }

    dest_name <- unique_asset_name(basename(src), copied)
    copied <- c(copied, dest_name)
    dest <- file.path(assets_dir, dest_name)
    file.copy(src, dest, overwrite = TRUE)
    replacements[[ref]] <- file.path(basename(assets_dir), dest_name)
  }

  replacements <- replacements[nzchar(replacements)]
  if (length(replacements)) {
    for (ref in names(replacements)) {
      text <- gsub(ref, replacements[[ref]], text, fixed = TRUE)
    }
    writeLines(text, companion_file, useBytes = TRUE)
  }

  normalizePath(assets_dir, winslash = "/", mustWork = FALSE)
}

image_references <- function(text, companion) {
  html <- gregexpr("<img[^>]+src=[\"'][^\"']+[\"']", text,
                  ignore.case = TRUE, perl = TRUE)
  html_refs <- regmatches(text, html)
  html_refs <- unlist(html_refs, use.names = FALSE)
  html_refs <- sub("^.*src=[\"']([^\"']+)[\"'].*$", "\\1", html_refs,
                   perl = TRUE)

  md_refs <- character()
  if (identical(companion, "markdown")) {
    md <- gregexpr("!\\[[^]]*\\]\\([^)]+\\)", text, perl = TRUE)
    md_refs <- regmatches(text, md)
    md_refs <- unlist(md_refs, use.names = FALSE)
    md_refs <- sub("^!\\[[^]]*\\]\\(([^)]+)\\)$", "\\1", md_refs,
                   perl = TRUE)
  }

  unique(c(html_refs, md_refs))
}

is_local_asset_ref <- function(refs) {
  nzchar(refs) &
    !grepl("^(https?:)?//", refs, ignore.case = TRUE) &
    !grepl("^data:", refs, ignore.case = TRUE) &
    !grepl("^mailto:", refs, ignore.case = TRUE) &
    !grepl("^#", refs)
}

resolve_asset_path <- function(ref, roots) {
  ref <- sub("[?#].*$", "", ref)
  ref <- utils::URLdecode(ref)

  candidates <- if (grepl("^([A-Za-z]:|/)", ref)) {
    ref
  } else {
    file.path(roots, ref)
  }

  candidates <- normalizePath(candidates, winslash = "/", mustWork = FALSE)
  found <- candidates[file.exists(candidates)]
  if (length(found)) found[[1]] else NA_character_
}

unique_asset_name <- function(name, existing) {
  if (!name %in% existing) {
    return(name)
  }

  stem <- tools::file_path_sans_ext(name)
  ext <- tools::file_ext(name)
  ext <- if (nzchar(ext)) paste0(".", ext) else ""

  i <- 2L
  repeat {
    candidate <- paste0(stem, "-", i, ext)
    if (!candidate %in% existing) {
      return(candidate)
    }
    i <- i + 1L
  }
}

write_wordpress_checklist <- function(output_file,
                                      companion_file,
                                      assets_dir = NULL,
                                      metadata = list()) {
  checklist_file <- paste0(tools::file_path_sans_ext(companion_file),
                           "-checklist.txt")
  title <- metadata$title
  if (is.null(title) || !nzchar(title)) {
    title <- tools::file_path_sans_ext(basename(output_file))
  }

  lines <- c(
    paste0("WordPress publishing checklist: ", title),
    "",
    "1. Open the WordPress companion file in a browser or text editor.",
    "2. Upload any files in the assets folder to the WordPress Media Library.",
    "3. Paste the companion HTML into the WordPress editor.",
    "4. Replace local image paths with Media Library image URLs if needed.",
    "5. Set the post title, excerpt, categories, tags, and featured image.",
    "6. Preview the post on desktop and mobile before publishing.",
    "7. Attach or link the PDF as the archival/download version.",
    "",
    paste0("PDF: ", normalizePath(output_file, winslash = "/",
                                  mustWork = FALSE)),
    paste0("Companion: ", normalizePath(companion_file, winslash = "/",
                                        mustWork = FALSE)),
    if (!is.null(assets_dir)) {
      paste0("Assets: ", normalizePath(assets_dir, winslash = "/",
                                       mustWork = FALSE))
    } else {
      "Assets: none detected"
    }
  )

  writeLines(lines, checklist_file, useBytes = TRUE)
  invisible(checklist_file)
}
