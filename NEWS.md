# hfwgtex 1.0.1

## Publishing workflows

- Added `hfwgtex::snapshot_pdf()` for Empirical Snapshots: a compact, visual-forward PDF format plus a WordPress companion file for CUNY Academic Commons publishing.
- Added `hfwgtex::blogpost_pdf()` for standard HFWG report-style PDFs that also emit a WordPress companion file.
- Added WordPress companion options shared by both publishing formats:
  - `wordpress: html`, `markdown`, or `none`
  - `wordpress_file`
  - `wordpress_assets`
  - `wordpress_checklist`
- Added conservative WordPress HTML export designed for RStudio-to-WordPress copy/paste without relying on optional Commons plugins.
- Added local image asset collection into `-wordpress-assets/` folders and a `-wordpress-checklist.txt` handoff checklist for research assistants.

## Snapshot PDF support

- Added `snapshot: true` template support for compact first-page Snapshot headers.
- Added Snapshot metadata fields:
  - `snapshot_label`
  - `snapshot_abstract_label`
  - `snapshot_feature`
  - `snapshot_feature_caption`
- Added optional featured visualization placement below the Snapshot lead.

## Template refinements

- Positioned `hfwg` title-page accent bars one inch from the top and bottom page edges, with one-inch left/right insets and a fixed 1.5-inch title offset below the upper bar.
- Loaded `pdflscape` in the template so wide tables can be placed on landscape pages without extra YAML header includes.
- Separated author/contact metadata from institution and series metadata on title pages with two baseline skips.
- Consolidated institution, series, and number rendering through a shared title-page series block.
- Preserved the reordered, centered title-page layout across `methods`, `hfwg`, and default title-page variants.
- Switched the `hfwg` preset to XITS with roman headings for a sharper, more classic report appearance.
- Centered Pandoc longtables so table bodies align with their captions.
- Tightened non-methods code blocks with smaller monospace text and denser line spacing.

## Tests and documentation

- Added `tests/knit-publishing-formats.R` to generate manual inspection documents for Snapshot and Blogpost workflows.
- Added `tests/knit-snapshot.R` as a Snapshot-specific manual inspection entry point.
- Added `docs/publishing-workflows.md` as the first split-out documentation page for longer workflow guidance.
- Expanded README documentation for Snapshot and Blogpost YAML, WordPress companion outputs, asset folders, and RA handoff checklists.

# hfwgtex 1.0.0

Initial public package release after the repository was rebranded from `jnctex` to `hfwgtex`.

## Package structure

- Packaged the HFWG LaTeX template for R Markdown workflows.
- Added `hfwg_use()` to copy the template, bundled fonts, and CSL file into a project directory.
- Added package metadata, namespace export, installation instructions, and user-facing README documentation.

## Template features

- Added manuscript title-page support driven by YAML metadata.
- Added author contact metadata fields:
  - `author_dept`
  - `author_inst`
  - `author_addr`
  - `author_email`
  - `author_web`
  - `author_orcid`
- Added institutional publication metadata:
  - `institution`
  - `series`
  - `number`
- Added running header support through `surname` and `runningtitle`.
- Added anonymized review mode, line numbering, double spacing, section numbering, and one- or two-column body layout.
- Added single-column bibliography handling when the main body uses two columns.

## Typography

- Added font presets:
  - default journal-submission preset
  - `humanities`
  - `demography`
  - `methods`
  - `hfwg`
- Added bundled font support for EB Garamond, XITS, Source Serif 4, and Fira Code.
- Added CUNY Blue branding for the `hfwg` preset.
- Added the `accent` YAML variable to override the accent color per document.
- Added font fallback behavior and warnings for missing fonts or pdfLaTeX use.

## Tables, figures, code, and citations

- Added Pandoc/R Markdown support for common table, figure, citation, and code-block workflows.
- Added safer handling of underscores and other special characters in body text and longtables.
- Added methods-style code block treatment for technical reports.
- Added bundled `default.csl` for author-date references and expanded README guidance for supported bibliography source types.

## Manual inspection

- Added fontset-oriented manual rendering fixtures under `tests/` for visual inspection of the template presets.
