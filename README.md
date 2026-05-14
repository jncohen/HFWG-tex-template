# hfwgtex

A personal LaTeX template for academic manuscripts, distributed as an R package. Designed for **R Markdown** workflows. All formatting is controlled via YAML front matter -- no manual LaTeX editing required.

---

## Contents

1. [Prerequisites](#1-prerequisites)
2. [Installation](#2-installation)
3. [Project setup](#3-project-setup)
4. [Your first document](#4-your-first-document)
5. [Font presets and layout](#5-font-presets-and-layout)
6. [Title page and author block](#6-title-page-and-author-block)
7. [Writing body text](#7-writing-body-text)
8. [Citations and bibliography](#8-citations-and-bibliography)
9. [Tables](#9-tables)
10. [Figures](#10-figures)
11. [Preparing for submission](#11-preparing-for-submission)
12. [Quick reference: all YAML variables](#12-quick-reference-all-yaml-variables)
13. [Bibliography: supported source types](#13-bibliography-supported-source-types)
14. [Non-R installation](#14-non-r-installation)

---

## 1. Prerequisites

You need R, RStudio, and a TeX distribution. If you already have all three, skip to Section 2.

**R and RStudio.** R >= 4.0 and a recent RStudio are sufficient. RStudio bundles Pandoc, which handles the markdown-to-LaTeX conversion step.

**A TeX distribution.** LaTeX does the actual PDF typesetting. Most academic Windows users already have MiKTeX; most Mac users have MacTeX. If you need to install one:

- **macOS** -- [MacTeX](https://www.tug.org/mactex/) (~5 GB) or the lightweight `tinytex` R package
- **Windows** -- [MiKTeX](https://miktex.org/) or the lightweight `tinytex` R package
- **Linux** -- `sudo apt install texlive-full` (Debian/Ubuntu) or equivalent

TinyTeX is the easiest fresh install:

```r
install.packages("tinytex")
tinytex::install_tinytex()
```

---

## 2. Installation

Install the package from GitHub using `devtools`:

```r
install.packages("devtools")          # if not already installed
devtools::install_github("jncohen/HFWG-tex-template")
```

---

## 3. Project setup

Open your project in RStudio (or set the working directory to your project folder), then run:

```r
hfwgtex::hfwg_use()
```

This copies three things into your project folder:

| File / folder | What it is |
|---|---|
| `hfwgtemplate.tex` | The LaTeX template -- leave this alone |
| `fonts/` | Bundled OpenType fonts (EB Garamond, XITS, Source Serif 4, Fira Code) |
| `default.csl` | Author-date citation style |

Your project folder will look something like this:

```
my-paper/
|-- paper.Rmd          <- your document
|-- references.bib     <- your bibliography
|-- hfwgtemplate.tex    <- copied by hfwg_use()
|-- default.csl        <- copied by hfwg_use()
`-- fonts/             <- copied by hfwg_use()
    |-- EBGaramond-Regular.otf
    |-- XITS-Regular.otf
    `-- ...
```

**Updating.** After upgrading the package, re-run `hfwg_use(overwrite = TRUE)` to pull in any template changes.

---

## 4. Your first document

Create a new R Markdown file (`paper.Rmd`) with this minimal YAML header:

```yaml
---
title: "My Paper Title"
subtitle: "Optional subtitle"
author: "Your Name"
date: "`r format(Sys.Date(), '%B %d, %Y')`"

institution: "Household Finance Working Group"
series: "Snapshot"
number: 1

surname: "LastName"
runningtitle: "Short Running Title"

author_dept:  "Department of X"
author_inst:  "Your University"
author_addr:  "Street Address, City, State ZIP"
author_email: "you@university.edu"
author_web:   "https://yourwebsite.edu"
author_orcid: "0000-0000-0000-0000"

abstract: |
  Your abstract here (150-250 words recommended).

acknowledgements: |
  Optional. Funding, data sources, etc.

bibliography: references.bib
csl: default.csl
fontpath: fonts/

anonymize: false
doublespace: false
linenumbers: false
numbersections: false
maincolumns: 1
fontset: demography

output:
  pdf_document:
    template: hfwgtemplate.tex
    latex_engine: xelatex
    keep_tex: true

header-includes:
   - \usepackage{booktabs}
   - \usepackage{pdflscape}
---
```

**Important:** `template: hfwgtemplate.tex` must go inside the `output: pdf_document:` block, not at the top level. A top-level `template:` field is passed as document metadata and does not tell rmarkdown which template file to use. All other custom variables (`fontset`, `fontpath`, `surname`, etc.) stay at the top level.

Then write your document body in standard R Markdown below the `---`.

**Knitting to PDF.** Click the **Knit** button in RStudio (select "Knit to PDF"), or run from the R console:

```r
rmarkdown::render("paper.Rmd")
```

This produces `paper.pdf` in the same folder. If it is your first compile with TinyTeX and any LaTeX packages are missing, TinyTeX will download them automatically -- this takes a minute the first time, then they are cached.

**The `fontpath` variable** tells the template where to find the bundled fonts. `fonts/` works when the `.Rmd` file is in the same folder as the `fonts/` directory. If your document is in a subfolder, adjust the path: `fontpath: ../fonts/`.

---

## 5. Font presets and layout

The `fontset` variable switches between typographic registers. Choose the one that fits your output context.

```yaml
fontset: hfwg          # Source Serif 4 + Source Sans 3, Queens College Red accent -- HFWG working papers
fontset: humanities    # EB Garamond -- theory, AJS, Sociological Theory
fontset: demography    # XITS (Times-family) -- Demography, Social Forces
fontset: methods       # Source Serif 4 + Fira Code -- SMR, computational work
# (unset)             # TeX Gyre Pagella (Palatino-family) -- plain, journal-submission ready
```

Each preset adjusts the body font, margins, line spacing, and section heading style as a coordinated package.

| Preset | Body font | Headings | Margins | Spacing | Accent |
|---|---|---|---|---|---|
| *(unset)* | Palatino-family | Bold | 1 in | 1.5x | Black — **use for journal submissions** |
| `hfwg` | Source Serif 4 | Sans-serif bold + QC Red rule | 1.15 in | 1.45x | Queens College Red |
| `humanities` | EB Garamond | Small caps | 1.3 in | 1.55x | Black |
| `demography` | XITS / Times | Bold + rule | 1 in | 1.5x | Black |
| `methods` | Source Serif 4 | Bold + blue rule | 0.9 in | 1.25x | Deep blue |

**Plain / journal-submission preset.** Omitting `fontset` (or leaving it commented out) produces a clean Palatino-family document with standard 1-inch margins, 1.5× line spacing, and no color accents. This is the format to use when submitting to journals that impose their own typesetting: the template stays out of the way.

**HFWG preset.** `fontset: hfwg` is the branded working-paper format for Household Finance Working Group publications. It uses Source Serif 4 for body text, Source Sans 3 for headings, and Queens College Red (`#E71939`) for accent rules and links.

**pdfLaTeX fallback.** The bundled fonts require XeLaTeX or LuaLaTeX, which R Markdown uses by default when the fonts are present. If you are using pdfLaTeX, the template falls back gracefully to TeX distribution fonts and emits a warning in the log.

**Spacing override.** To force double spacing regardless of preset:

```yaml
doublespace: true
```

---

## 6. Title page and author block

The template generates a full title page from YAML. All fields are optional except `title`.

```yaml
---
title: "The Organizational Basis of Wage Inequality"
subtitle: "Evidence from Linked Employer-Employee Data"
date: "April 2026"

surname: "Cohen"
runningtitle: "Organizational Basis of Wage Inequality"

author:
  - name: "Joseph N. Cohen"

author_dept:  "Department of Sociology"
author_inst:  "Queens College, City University of New York"
author_addr:  "65-30 Kissena Blvd., Queens, NY 11367, USA"
author_email: "joseph.cohen@qc.cuny.edu"
author_web:   "https://jncohen.commons.gc.cuny.edu"
author_orcid: "0000-0002-6197-4453"

abstract: |
  This paper examines how organizational characteristics shape
  wage determination. [150-250 words recommended]

keywords:
  - wage inequality
  - organizations
  - economic sociology

acknowledgements: |
  The author thanks... Data provided by...
---
```

**Running header.** Renders as `Surname: Running Title` when both `surname` and `runningtitle` are set, `Running Title` alone when only `runningtitle` is set, and the document `title` when neither is set.

**Multiple authors.** Add additional `- name:` entries under `author:`. Contact details appear once below all author names -- they are intended for the corresponding author.

```yaml
author:
  - name: "Jane Doe"
  - name: "John Smith"
  - name: "Maria Garcia"
```

**Methods preset title page.** When `fontset: methods`, the title page uses a left-aligned layout with a full-width accent rule, rather than the centered layout used by the other presets.

---

## 7. Writing body text

The document body is standard R Markdown.

**Sections.** Use `#` for top-level sections, `##` for subsections, `###` for sub-subsections. Sections are unnumbered by default. To number them:

```yaml
numbersections: true
```

**Paragraphs.** Leave a blank line between paragraphs. First-line indent is applied automatically.

**Emphasis.** `*italics*` and `**bold**`. Use italics for titles and foreign terms; use bold sparingly.

**Footnotes.**

```markdown
This claim requires qualification.^[See the discussion in Smith (2018), who
argues that the relationship is conditional on organizational size.]
```

**Inline R.** knitr evaluates inline R expressions:

```markdown
The sample includes `r nrow(df)` respondents across `r length(unique(df$firm_id))` firms.
```

**Two-column layout.**

```yaml
maincolumns: 2
```

The bibliography automatically reverts to a single column.

---

## 8. Citations and bibliography

Citations are handled by Pandoc's built-in citation processor (citeproc) using your `.bib` file and a CSL style file. No BibTeX or biber compilation step is needed.

### Setting up your bibliography file

Create a `references.bib` file in your project folder. If you use **Zotero**, export your library (or a collection) using Better BibTeX: right-click -> Export Collection -> Better BibTeX -> keep file updated. The exported `.bib` file stays in sync as you add sources.

```yaml
bibliography: references.bib
csl: default.csl
```

The bundled `default.csl` produces author-date citations in a Chicago-derived format extended to cover modern source types (datasets, software, preprints). To use a different style, replace `default.csl` with any `.csl` file from the [Zotero style repository](https://www.zotero.org/styles).

### In-text citations

Pandoc uses `@key` syntax, where `key` is the BibTeX key in your `.bib` file.

| Markdown | Output |
|---|---|
| `@smith2020` | Smith (2020) |
| `[@smith2020]` | (Smith 2020) |
| `[@smith2020, p. 45]` | (Smith 2020, p. 45) |
| `[@smith2020; @jones2018]` | (Smith 2020; Jones 2018) |
| `[-@smith2020]` | (2020) -- suppresses author name |

**RStudio visual editor.** Use Insert -> Citation to search Zotero or DOI directly without typing BibTeX keys by hand.

### Where the bibliography appears

Pandoc appends the bibliography at the very end of the document by default. If your document has an appendix with tables or figures after the main text, the bibliography will appear after them unless you explicitly anchor it.

**To place the bibliography before an appendix,** use a `{#refs}` div to mark where references should go. Structure your `.Rmd` like this:

```markdown
[...main text...]

\clearpage

# References

::: {#refs}
:::

\clearpage

# Appendix

## Table A1

[...appendix tables and figures...]
```

The `::: {#refs} :::` div is Pandoc's explicit bibliography anchor. Without it, references are appended after the last line of the document regardless of section structure. The `\clearpage` calls ensure each section starts on a fresh page.

**To place the bibliography under a manual heading without an appendix,** simply add at the very end of your `.Rmd`:

```markdown
# References
```

### Citation keys

Better BibTeX's default key format (`[auth:lower][year][title:lower:keepfirst:nopunct]`) produces readable, consistent keys. Set your preferred format in Zotero -> Edit -> Preferences -> Better BibTeX -> Citation key formula.

---

## 9. Tables

### Basic markdown tables

```markdown
| Variable | Mean | SD | N |
|---|---:|---:|---:|
| Log wage | 2.84 | 0.61 | 4,210 |
| Tenure (years) | 6.3 | 5.1 | 4,210 |
| Firm size (log) | 4.7 | 1.8 | 4,210 |

: Descriptive statistics
```

Pandoc converts markdown tables to `longtable` environments in LaTeX. The template automatically applies `footnotesize` font and single spacing to all `longtable` environments.

### knitr tables with `knitr::kable()`

```r
# In a code chunk with echo=FALSE
knitr::kable(
  summary_table,
  format    = "latex",
  booktabs  = TRUE,
  caption   = "Descriptive statistics",
  col.names = c("Variable", "Mean", "SD", "N"),
  digits    = 2
)
```

### kableExtra for styled tables

```r
library(kableExtra)

knitr::kable(
  summary_table,
  format   = "latex",
  booktabs = TRUE,
  caption  = "Descriptive statistics.",
  digits   = 2
) |>
  kable_styling(latex_options = "hold_position") |>
  add_header_above(c(" " = 1, "Full sample" = 3))
```

### Table notes

```r
knitr::kable(...) |>
  footnote(
    general       = "Data: NLSY97. Standard errors in parentheses.",
    general_title = "Note:",
    footnote_as_chunk = TRUE
  )
```

---

## 10. Figures

Figures are inserted using standard R Markdown code chunks. Pandoc wraps figure output in `\begin{figure}...\end{figure}` float environments, which the template auto-scales to fit the page.

### R-generated figures

```r
# Chunk options: echo=FALSE, fig.cap="...", fig.width=6, fig.height=4, out.width="85%"
ggplot(df, aes(x = log_wage, fill = firm_quintile)) +
  geom_density(alpha = 0.4) +
  labs(x = "Log wage", y = "Density", fill = "Firm size quintile") +
  theme_minimal()
```

Key chunk options:

| Option | What it does |
|---|---|
| `fig.cap` | Caption text |
| `fig.width`, `fig.height` | Figure dimensions in inches |
| `out.width` | Output width as a percentage of text width, e.g. `"85%"` |
| `fig.align` | `"center"` (default), `"left"`, `"right"` |
| `fig.pos` | LaTeX placement specifier, e.g. `"h"` for here |

### External image files

```markdown
![Caption text.](figures/wage-dist.pdf){width=85%}
```

PDF and EPS figures produce the sharpest output. PNG and JPEG also work -- use at least 300 dpi for print quality.

---

## 11. Preparing for submission

### Anonymous review

Suppresses author name, date, acknowledgements, and affiliation from the title page.

```yaml
anonymize: true
```

Remove or set to `false` when submitting the final accepted version.

### Double spacing

```yaml
doublespace: true
```

Overrides the preset line spacing. Footnotes and the bibliography remain single-spaced.

### Line numbers

```yaml
linenumbers: true
```

Adds continuous line numbers in the left margin. **Known issue:** gutter alignment may drift slightly at 1.5x or 2x spacing due to an interaction between the `lineno` and `setspace` packages. The counter itself is always correct. Using `doublespace: true` is more reliable than the default 1.5x spacing when line numbers are active.

### A typical submission YAML

```yaml
---
title: "The Organizational Basis of Wage Inequality"
subtitle: "Evidence from Linked Employer-Employee Data"
date: "April 2026"
surname: "Cohen"
runningtitle: "Organizational Basis of Wage Inequality"

author:
  - name: "Joseph N. Cohen"
author_dept:  "Department of Sociology"
author_inst:  "Queens College, City University of New York"
author_email: "joseph.cohen@qc.cuny.edu"

abstract: |
  [Your abstract here.]

keywords:
  - wage inequality
  - organizations

bibliography: references.bib
csl: default.csl
fontpath: fonts/

fontset: demography
anonymize: true
doublespace: true
linenumbers: true

output:
  pdf_document:
    template: hfwgtemplate.tex
    latex_engine: xelatex
---
```

---

## 12. Quick reference: all YAML variables

### Document metadata

| Variable | Type | Description |
|---|---|---|
| `title` | string | Document title (required) |
| `subtitle` | string | Subtitle, rendered below title |
| `date` | string | Date string on title page |
| `surname` | string | Author surname for running header |
| `runningtitle` | string | Short title for running header |
| `abstract` | block | Abstract text |
| `keywords` | list | Keyword list, rendered below abstract |
| `acknowledgements` | block | Acknowledgements on title page |

### Author block

`author:` takes a list of `- name:` entries. Contact details are top-level variables and appear once below all author names.

| Variable | Description |
|---|---|
| `author_dept` | Department |
| `author_inst` | Institution |
| `author_addr` | Street address |
| `author_email` | Email (rendered in monospace) |
| `author_web` | Website (Markdown link syntax: `[label](url)`) |
| `author_orcid` | ORCID identifier |

### Typography and layout

| Variable | Values | Description |
|---|---|---|
| `fontset` | `hfwg`, `humanities`, `demography`, `methods`, or unset | Font and layout preset |
| `fontpath` | path string | Path to bundled fonts directory |
| `doublespace` | `true` or `false` | Full double spacing, overrides preset |
| `numbersections` | `true` or `false` | Number section headings |
| `maincolumns` | `1` or `2` | Body column count; bibliography always single-column |

### Submission modes

| Variable | Values | Description |
|---|---|---|
| `anonymize` | `true` or `false` | Suppress identifying metadata for blind review |
| `linenumbers` | `true` or `false` | Add continuous line numbers |

### Bibliography

| Variable | Description |
|---|---|
| `bibliography` | Path to `.bib` file |
| `csl` | Path to CSL style file |

### Complete YAML header

```yaml
---
title: "My Manuscript Title"
subtitle: "An Optional Subtitle"
date: "April 2026"
surname: "Cohen"
runningtitle: "Short Running Title"
fontset: humanities

author:
  - name: "Jane Doe"
  - name: "John Smith"

author_dept:  "Department of Sociology"
author_inst:  "Queens College, City University of New York"
author_addr:  "65-30 Kissena Blvd., Queens, NY 11367"
author_email: "jane@university.edu"
author_web:   "https://jane.example.edu"
author_orcid: "0000-0000-0000-0001"

abstract: |
  This paper examines... [150-250 words recommended]

keywords:
  - sociology
  - quantitative methods
  - open science

acknowledgements: |
  The authors thank... Funding provided by...

bibliography: references.bib
csl: default.csl
fontpath: fonts/

anonymize: false
doublespace: false
linenumbers: false
numbersections: false
maincolumns: 1

output:
  pdf_document:
    template: hfwgtemplate.tex
    latex_engine: xelatex
---
```

---

## 13. Bibliography: supported source types

The bundled `default.csl` handles modern source types that standard styles format poorly. Set the Zotero item type as follows:

| Source | Zotero item type | Notes |
|---|---|---|
| Journal article | Journal Article | DOI shown automatically |
| Book | Book | -- |
| Book chapter | Book Section | -- |
| Dissertation / thesis | Thesis | Set Type field: PhD, MA, etc. |
| Technical / institutional report | Report | Set Type and Report Number |
| Preprint / working paper | Manuscript | Set Genre: "Working Paper", "Preprint", etc. |
| Research dataset | Dataset | Set Version and Publisher (repository name) |
| R package / software | Software | Set Version; Publisher = CRAN or GitHub |
| Blog post | Blog Post | Set Accessed date |
| Social media post | Forum Post | Set container-title to platform name |
| YouTube video / podcast | Video Recording | Set Genre: [Video] or [Podcast episode] |
| Conference presentation | Presentation | -- |
| Web page | Web Page | Set Accessed date |

### R packages in Zotero

| Zotero field | Value |
|---|---|
| Title | Package name, e.g. `ggplot2` |
| Author | Authors from the `DESCRIPTION` file |
| Version | From CRAN or `packageVersion("ggplot2")` |
| Date | Release date of the version cited |
| Company | `CRAN` or `GitHub` |
| URL | `https://cran.r-project.org/package=...` |
| Accessed | Date retrieved |

Renders as: *Author (Year). Title (Version x.x.x) [Computer software]. Publisher. URL*

---

## 14. Non-R installation

For users without R, two shell scripts are provided.

**From a local clone:**

```bash
bash install.sh                              # installs to ~/Templates/hfwg-tex/
HFWG_TEMPLATE_DIR=/custom/path bash install.sh
```

**Directly from GitHub:**

```bash
bash fetch-template.sh
HFWG_BRANCH=v1.0.0 bash fetch-template.sh    # pin to a release tag
```

After installation, add to your document YAML:

```yaml
template: ~/Templates/hfwg-tex/hfwgtemplate.tex
fontpath: ~/Templates/hfwg-tex/fonts/
csl: ~/Templates/hfwg-tex/default.csl
```

And compile with Pandoc:

```bash
pandoc paper.md \
  --template=~/Templates/hfwg-tex/hfwgtemplate.tex \
  --csl=~/Templates/hfwg-tex/default.csl \
  --bibliography=references.bib \
  --pdf-engine=xelatex \
  -V fontpath=~/Templates/hfwg-tex/fonts/ \
  -o paper.pdf
```

---

## Design principles

- Engine-agnostic: pdfLaTeX, XeLaTeX, and LuaLaTeX
- Pandoc-native: no preprocessing scripts required
- All options in YAML -- stable single-file template
- Versioned via Git tags; filename never changes
- Intended for empirical articles, working papers, and blind review submissions; not a replacement for journal-specific `.cls` files where those are required
