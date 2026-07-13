# Site-wide content statistics for the Home and About pages.
# Counts projects, portfolio items and publications, then renders the
# icon stats strip. Reads project/portfolio .qmd front matter and the
# publications sheet of cv_inputs.xlsx.

suppressPackageStartupMessages({
  library(readxl)
})

# Front matter of a .qmd file as a list (empty list on failure).
.fm <- function(file) {
  fm <- tryCatch(rmarkdown::yaml_front_matter(file), error = function(e) NULL)
  if (is.null(fm)) list() else fm
}

# Content .qmd files in a folder, recursing into sub-folders, minus _metadata.yml.
.content_files <- function(dir) {
  f <- list.files(dir, pattern = "\\.qmd$", full.names = TRUE, recursive = TRUE)
  f[basename(f) != "_metadata.yml"]
}

# Projects still in progress — any status other than "published".
count_active_projects <- function(dir = "projects") {
  st <- vapply(.content_files(dir), function(f) {
    s <- .fm(f)$status
    if (is.null(s)) "" else tolower(trimws(as.character(s)[1]))
  }, character(1))
  sum(nzchar(st) & st != "published")
}

# Portfolio items carrying a given category tag.
count_portfolio_category <- function(category, dir = "portfolio") {
  hits <- vapply(.content_files(dir), function(f) {
    category %in% as.character(.fm(f)$categories)
  }, logical(1))
  sum(hits)
}

# Count rows of a cv_inputs.xlsx sheet with a given status (respects filter).
count_sheet_status <- function(sheet, status, path = "cv_inputs.xlsx") {
  df <- tryCatch(readxl::read_excel(path, sheet = sheet),
                 error = function(e) NULL)
  if (is.null(df) || !"status" %in% names(df)) return(0L)
  if ("filter" %in% names(df)) {
    df <- df[!is.na(df$filter) & as.logical(df$filter), , drop = FALSE]
  }
  sum(df$status == status, na.rm = TRUE)
}

# Inline an icon SVG, tinted with the editorial accent.
# The hexagon (#000000) becomes the accent; the glyph (#ffffff) becomes the
# paper colour so it stays legible against the accent in both palettes.
.accent_icon <- function(name, dir = "assets/icons") {
  path <- file.path(dir, paste0(name, ".svg"))
  svg <- tryCatch(paste(readLines(path, warn = FALSE), collapse = ""),
                  error = function(e) "")
  svg <- gsub("#000000", "var(--accent)", svg, fixed = TRUE)
  svg <- gsub("#ffffff", "var(--paper)",  svg, fixed = TRUE)
  svg
}

# Render the six-item icon stats strip (HTML output, used with results: asis).
render_stats_strip <- function() {
  stats <- list(
    list(icon = "folder-open-6gon-120",
         n = count_active_projects(),
         label = "Active projects"),
    list(icon = "file-text-6gon-120",
         n = count_sheet_status("publications", "published"),
         label = "Publications"),
    list(icon = "database-6gon-120",
         n = count_portfolio_category("Dataset"),
         label = "Datasets"),
    list(icon = "code-6gon-120",
         n = count_portfolio_category("Code"),
         label = "Codes"),
    list(icon = "chart-network-6gon-120",
         n = count_portfolio_category("Visualisation"),
         label = "DataVizs"),
    list(icon = "ampersand-6gon-120",
         n = count_sheet_status("others", "published"),
         label = "Miscellaneous (gists,artefacts & outtakes)")
  )

  cat("::: {.stats-strip}\n")
  for (s in stats) {
    cat("::: {.stat-item}\n")
    cat(sprintf('<div class="stat-icon">%s</div>\n\n', .accent_icon(s$icon)))
    cat(sprintf("[[%d]{.stat-count} %s]{.label}\n", s$n, s$label))
    cat(":::\n")
  }
  cat(":::\n")
}
