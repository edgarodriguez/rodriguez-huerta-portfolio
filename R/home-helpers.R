# Home-page "latest outcomes" cards.
#
# The three cards at the foot of index.qmd (Latest Publication / Active
# Research / Data Visualisation) are picked from cv_inputs.xlsx — the same
# workbook that feeds the CV, the About-page counts and every Projects and
# Portfolio entry — so the Home page can never drift from the rest of the site.
#
# One rule, three times: drop the rows that cannot be shown, sort highlighted
# first and newest first, take the top one.
#   - Mark one row highlight TRUE and it is the card.
#   - Mark several TRUE and the newest of them wins.
#   - Mark none TRUE and the newest row wins anyway, so a card is never empty.
#
# Drafts are skipped: _quarto.yml sets draft-mode: gone, so a draft entry
# renders as an empty page and linking the Home page to one is a dead end.
#
# Usage (index.qmd):
#   source("R/home-helpers.R")
#   render_home_outcomes()
#
# After editing a highlight cell, delete _freeze/index/ before re-rendering:
# freeze: auto watches the .qmd, not the workbook or this file.

suppressPackageStartupMessages(library(readxl))

WORKBOOK <- "cv_inputs.xlsx"

# ---- reading ----------------------------------------------------------------

.sheet <- function(name) {
  tryCatch(as.data.frame(readxl::read_excel(WORKBOOK, sheet = name)),
           error = function(e) NULL)
}

# A column as trimmed text, or blanks when the sheet has no such column.
.col <- function(d, name) {
  if (!name %in% names(d)) return(rep("", nrow(d)))
  v <- as.character(d[[name]])
  ifelse(is.na(v), "", trimws(v))
}

# A column as-is, or all-NA when the sheet has no such column.
.raw <- function(d, name) if (name %in% names(d)) d[[name]] else rep(NA, nrow(d))

# Excel hands TRUE/FALSE back as a logical, but a hand-typed cell arrives as
# text ("YES"), so both have to count. Same helper as R/site-stats.R.
.truthy <- function(x) tolower(trimws(as.character(x))) %in% c("true", "yes", "1")
.equals <- function(x, value) tolower(trimws(as.character(x))) == tolower(value)

# A date column mixing real dates with text is read whole as text, so one
# column can hold "2026-02-20", the serial "46235" and the bare year "2021".
# All three become a sortable Date; anything unreadable sorts last.
.as_date <- function(x) {
  if (inherits(x, "POSIXt")) return(as.Date(x, tz = "UTC"))
  if (inherits(x, "Date"))   return(x)
  s <- trimws(as.character(x))
  s[is.na(s)] <- ""
  out    <- rep(as.Date(NA), length(s))
  serial <- grepl("^[0-9]{5}(\\.[0-9]+)?$", s)
  year   <- grepl("^[0-9]{4}$", s)
  iso    <- nzchar(s) & !serial & !year
  # Both branches name the format: as.Date() throws on a free-text cell rather
  # than returning NA, and paste0() on an empty selection yields "-01-01"
  # rather than nothing. With a format, either case is just NA.
  out[serial] <- as.Date(floor(as.numeric(s[serial])), origin = "1899-12-30")
  out[year]   <- as.Date(paste0(s[year], "-01-01"), format = "%Y-%m-%d")
  out[iso]    <- as.Date(s[iso], format = "%Y-%m-%d")
  out[is.na(out)] <- as.Date("1900-01-01")
  out
}

# ---- selection --------------------------------------------------------------

# One row of `sheet`: highlighted first, then newest. `keep` is an optional
# extra filter on the data frame (Portfolio uses it to keep Visualisations).
pick_outcome <- function(sheet, keep = NULL, d = .sheet(sheet)) {
  if (is.null(d) || nrow(d) == 0) return(NULL)

  d <- d[nzchar(.col(d, "title")), , drop = FALSE]   # blank/spacer rows
  d <- d[!.truthy(.raw(d, "draft")), , drop = FALSE]
  if (!is.null(keep)) d <- d[keep(d), , drop = FALSE]
  if (nrow(d) == 0) return(NULL)

  # The publications sheet has spelled this column both ways.
  hl <- if ("highlight" %in% names(d)) d$highlight else .raw(d, "highlighted")
  ord <- order(-.truthy(hl), -as.numeric(.as_date(.raw(d, "date"))))
  row <- d[ord[1], , drop = FALSE]
  row$.year <- format(.as_date(.raw(row, "date")), "%Y")
  row
}

# ---- rendering --------------------------------------------------------------

.one <- function(row, name) if (is.null(row)) "" else .col(row, name)[1]

# "Nature Food · 2025" — blanks drop out rather than leaving stray separators.
.meta <- function(...) {
  parts <- c(...)
  paste(parts[nzchar(parts)], collapse = " · ")
}

# Square brackets in a title would end the link text early.
.esc <- function(s) gsub("([\\[\\]])", "\\\\\\1", s)

.card <- function(num, label, title, href, meta) {
  if (!nzchar(title)) return(invisible())
  attrs <- if (grepl("^https?://", href)) '{target="_blank" rel="noopener"}' else ""
  cat("::: {.split-3-item}\n")
  cat("::: {.section-num}\n")
  cat(sprintf("[%s]{.label} [%s]{.label}\n", label, num))
  cat(":::\n\n")
  cat("::: {.h3}\n")
  cat(sprintf("[%s](%s)%s\n", .esc(title), href, attrs))
  cat(":::\n\n")
  cat(sprintf("[%s]{.body-sm}\n", meta))
  cat(":::\n\n")
}

render_home_outcomes <- function() {
  pub <- pick_outcome("publications")
  prj <- pick_outcome("projects")
  viz <- pick_outcome("portfolio", keep = function(d) .equals(.raw(d, "type"), "Visualisation"))

  cat("::: {.split-3}\n\n")

  # Publications have no page of their own on this site, so the card opens the
  # paper itself and falls back to the listing when the sheet has no link.
  href <- .one(pub, "url")
  if (!nzchar(href)) href <- .one(pub, "doi")
  if (nzchar(href) && !grepl("^https?://", href)) href <- paste0("https://doi.org/", href)
  if (!nzchar(href)) href <- "publications.html"
  .card("01", "Latest Publication", .one(pub, "title"), href,
        .meta(.one(pub, "venue"), .one(pub, ".year")))

  status <- .one(prj, "pub-journal")
  if (!nzchar(status)) status <- tools::toTitleCase(gsub("-", " ", .one(prj, "status")))
  .card("02", "Active Research", .one(prj, "title"),
        paste0("projects/", .one(prj, "slug"), ".html"),
        .meta(status, .one(prj, ".year")))

  .card("03", "Data Visualisation", .one(viz, "title"),
        paste0("portfolio/", .one(viz, "slug"), "/"),
        .meta(.one(viz, "subtype"), .one(viz, ".year")))

  cat(":::\n")
}

# ---- self-check -------------------------------------------------------------
# Rscript R/home-helpers.R   — exercises the picking rule on made-up rows, so a
# broken sort is caught without rendering the site or opening the workbook.

.selfcheck <- function() {
  ck <- function(label, got, want) {
    if (!identical(got, want)) stop(sprintf("%s: got %s, wanted %s", label, got, want))
    cat("ok  ", label, "\n")
  }

  ck("serial date", format(.as_date("46235")), "2026-08-01")
  ck("iso date",    format(.as_date("2026-02-20")), "2026-02-20")
  ck("bare year",   format(.as_date("2021")), "2021-01-01")
  ck("column with no bare-year rows", format(.as_date(c("2026-02-20", "46235"))),
     c("2026-02-20", "2026-08-01"))
  ck("blank and junk dates sort last", format(.as_date(c("", "n/a"))),
     c("1900-01-01", "1900-01-01"))

  rows <- data.frame(
    slug      = c("old-hl",     "new-plain",  "new-hl",     "draft-hl",   "other-type"),
    date      = c("2020-01-01", "2026-01-01", "2025-01-01", "2026-09-01", "2026-08-01"),
    highlight = c(TRUE,         FALSE,        TRUE,         TRUE,         TRUE),
    draft     = c(FALSE,        FALSE,        FALSE,        TRUE,         FALSE),
    type      = c("Visualisation", "Visualisation", "Visualisation", "Visualisation", "Data"),
    title     = "t", stringsAsFactors = FALSE)
  # Pick from a named subset of those rows.
  pick <- function(slugs, ..., d = rows) {
    .one(pick_outcome(NULL, ..., d = d[d$slug %in% slugs, , drop = FALSE]), "slug")
  }

  ck("highlighted beats a newer plain row",
     pick(c("new-plain", "new-hl")), "new-hl")
  ck("newest of several highlighted wins",
     pick(c("old-hl", "new-hl")), "new-hl")
  ck("a draft is skipped even when highlighted",
     pick(c("new-hl", "draft-hl")), "new-hl")
  ck("nothing highlighted falls back to newest",
     pick(c("old-hl", "new-plain", "new-hl"), d = transform(rows, highlight = FALSE)),
     "new-plain")
  ck("keep filter is applied",
     pick(rows$slug, keep = function(x) .equals(.raw(x, "type"), "Data")), "other-type")
  ck("a hand-typed YES counts as true",
     pick(c("new-plain", "new-hl"),
          d = transform(rows, highlight = ifelse(rows$slug == "new-hl", "YES", ""))),
     "new-hl")
  ck("no eligible rows gives nothing",
     is.null(pick_outcome(NULL, d = rows[0, ])), TRUE)
  ck("every row a draft gives nothing",
     is.null(pick_outcome(NULL, d = transform(rows, draft = TRUE))), TRUE)

  cat("\nAll home-helpers checks passed.\n")
}

if (!interactive() && sys.nframe() == 0) .selfcheck()
