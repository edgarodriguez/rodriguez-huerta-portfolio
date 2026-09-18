# Site-wide content statistics for the About page.
# Counts active projects, publications and each portfolio type from
# cv_inputs.xlsx, then renders them as a miniature honeycomb: one hexagon
# per output type, linking to that type on its listing page.

suppressPackageStartupMessages({
  library(readxl)
})

# ---- counts -----------------------------------------------------------------
# Every count reads cv_inputs.xlsx, not the .qmd files: the sheet is the source
# of truth for what exists (R/xlsx-to-entries.R writes the entries from it), so
# a count can never drift from the spreadsheet the site is built from.

.sheet <- function(name, path = "cv_inputs.xlsx") {
  tryCatch(as.data.frame(readxl::read_excel(path, sheet = name)),
           error = function(e) NULL)
}

# Excel gives TRUE/FALSE as logicals, but a hand-typed cell arrives as text.
.truthy <- function(x) tolower(trimws(as.character(x))) %in% c("true", "yes", "1")
.equals <- function(x, value) tolower(trimws(as.character(x))) == tolower(value)

.count_rows <- function(sheet, cols, keep) {
  d <- .sheet(sheet)
  if (is.null(d) || !all(cols %in% names(d))) return(0L)
  sum(keep(d), na.rm = TRUE)
}

# Projects still running: status "active", not a draft.
count_active_projects <- function() {
  .count_rows("projects", c("draft", "status"),
              function(d) !.truthy(d$draft) & .equals(d$status, "active"))
}

# Published portfolio entries of one type: Data, Code, Visualisation or
# Miscellaneous. These are the same values the portfolio filter bar uses.
count_portfolio_type <- function(type) {
  .count_rows("portfolio", c("draft", "type"),
              function(d) !.truthy(d$draft) & .equals(d$type, type))
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

# The icons are a hexagon plate with a glyph drawn on top of it. The gauge
# needs the two apart: the plate is the tile, the glyph is drawn twice (once
# for the unfilled zone, once for the filled one) so it reads either way.
.icon_parts <- function(name, dir = "assets/icons") {
  svg <- tryCatch(paste(readLines(file.path(dir, paste0(name, ".svg")), warn = FALSE), collapse = ""),
                  error = function(e) "")
  if (!nzchar(svg)) return(list(plate = "", glyph = ""))
  cut <- regexpr("<g transform=", svg, fixed = TRUE)
  list(plate = paste0(substr(svg, 1, cut - 1), "</svg>"),          # hexagon, no glyph
       glyph = sub("<polygon[^>]*/>", "", svg))                    # glyph, no hexagon
}

.tint <- function(svg, hexagon = NULL, glyph = NULL) {
  if (!is.null(hexagon)) svg <- gsub("#000000", hexagon, svg, fixed = TRUE)
  if (!is.null(glyph))   svg <- gsub("#ffffff", glyph,   svg, fixed = TRUE)
  svg
}

# Render the counts as a row of hexagons (HTML output, used with results:
# asis). Each tile is its own count: the numeral is the figure, the icon sits
# enlarged and faint behind it so the tile still says what it counts. Nothing
# is scaled against another type — a project and a publication are not the
# same unit. Raw HTML rather than fenced divs because each tile is a link
# wrapped around block content, which markdown cannot express. Each tile opens
# its own type on the listing page: the filter bar reads the URL hash, so
# #Code lands on Code already filtered.
render_stats_strip <- function() {
  stats <- list(
    list(icon = "folder-open-6gon-120",   label = "Active projects",
         n = count_active_projects(),                        href = "projects.html"),
    list(icon = "file-text-6gon-120",     label = "Publications",
         n = count_sheet_status("publications", "published"), href = "publications.html"),
    list(icon = "database-6gon-120",      label = "Datasets",
         n = count_portfolio_type("Data"),                   href = "portfolio.html#Data"),
    list(icon = "code-6gon-120",          label = "Code",
         n = count_portfolio_type("Code"),                   href = "portfolio.html#Code"),
    list(icon = "chart-network-6gon-120", label = "Visualisations",
         n = count_portfolio_type("Visualisation"),          href = "portfolio.html#Visualisation"),
    list(icon = "ampersand-6gon-120",     label = "Miscellaneous",
         n = count_portfolio_type("Miscellaneous"),          href = "portfolio.html#Miscellaneous")
  )

  cat('<div class="stat-hex-grid">\n')
  for (s in stats) {
    parts <- .icon_parts(s$icon)
    cat(sprintf(paste0(
      '<a class="stat-hex" href="%s">',
      '<span class="stat-hex-tile">',
      '<span class="stat-layer">%s</span>',
      '<span class="stat-layer stat-mark">%s</span>',
      '<span class="stat-layer stat-num">%d</span>',
      '<span class="stat-hex-body"><span class="stat-hex-label">%s</span></span>',
      '</span></a>\n'),
      s$href,
      .tint(parts$plate, hexagon = "var(--accent)"),
      .tint(parts$glyph, glyph = "var(--paper)"),
      s$n, s$label))
  }
  cat("</div>\n")
}
