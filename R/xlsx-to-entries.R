# Update projects/ and portfolio/ entries from the `projects` and `portfolio`
# sheets of cv_inputs.xlsx.
#
#   Rscript R/xlsx-to-entries.R              write the entries
#   Rscript R/xlsx-to-entries.R --preview    show what would change, write nothing
#   (either form takes an optional workbook path, default cv_inputs.xlsx)
#
# Only the YAML block at the top of each entry is written: the page text below
# it is never touched, and an entry with no row in the sheet is left as is
# (never deleted). A slug that has no file yet becomes a new entry whose page
# text is copied from projects/_template.qmd or portfolio/_template/index.qmd.
# Renaming a slug in the sheet creates a NEW entry: move the old file/folder
# to the new name first (git mv), then run this.

suppressPackageStartupMessages(library(readxl))

# Column order = sheet column order. R/entries-to-xlsx.R uses the same list.
FIELDS <- list(
  projects  = c("slug", "draft", "title", "description", "date", "date-modified",
                "highlight", "categories", "image", "status", "pub-journal",
                "doi", "repo"),
  portfolio = c("slug", "draft", "title", "description", "date", "date-modified",
                "highlight", "type", "subtype", "categories", "image", "repo",
                "page-layout")
)

# Fields emitted as YAML "key: value" with no quotes. Everything else that is
# free text gets double-quoted. ponytail: no YAML emitter, 13 keys is not a parser.
BARE <- c("draft", "date", "date-modified", "highlight", "status", "type",
          "subtype", "image")

# ---- coercion ---------------------------------------------------------------

.chr <- function(x) {
  if (length(x) == 0) return("")
  x <- x[[1]]
  if (is.null(x) || is.na(x)) return("")
  trimws(as.character(x))
}

.bool <- function(x, default = FALSE) {
  if (length(x) == 0) return(default)
  x <- x[[1]]
  if (is.null(x) || is.na(x)) return(default)
  if (is.logical(x)) return(x)
  s <- tolower(trimws(as.character(x)))
  if (s %in% c("true", "yes", "y", "1")) TRUE
  else if (s %in% c("false", "no", "n", "0")) FALSE
  else default
}

# Excel gives dates back as POSIXct; in a column that mixes real dates with
# text, readxl reads the whole column as text and real dates arrive as their
# serial number ("46235"), numeric or as a string. All end up "YYYY-MM-DD".
.date <- function(x) {
  if (length(x) == 0) return("")
  x <- x[[1]]
  if (is.null(x) || is.na(x)) return("")
  if (inherits(x, "POSIXt")) return(format(as.Date(x, tz = "UTC"), "%Y-%m-%d"))
  if (inherits(x, "Date"))   return(format(x, "%Y-%m-%d"))
  s <- trimws(as.character(x))
  if (grepl("^[0-9]{5}(\\.[0-9]+)?$", s)) {
    return(format(as.Date(floor(as.numeric(s)), origin = "1899-12-30"), "%Y-%m-%d"))
  }
  s
}

.quote <- function(x) {
  x <- gsub("\\", "\\\\", x, fixed = TRUE)
  x <- gsub("\"", "\\\"",  x, fixed = TRUE)
  paste0("\"", x, "\"")
}

# ---- paths ------------------------------------------------------------------

# file.exists() ignores letter case on macOS, but GitHub Pages serves from a
# case-sensitive disk: "img-solarpv.svg" works locally and 404s once published.
.file_ok <- function(path) {
  file.exists(path) && basename(path) %in% list.files(dirname(path), all.files = TRUE)
}

entry_path <- function(section, slug) {
  if (section == "projects") file.path("projects", paste0(slug, ".qmd"))
  else file.path("portfolio", slug, "index.qmd")
}

template_path <- function(section) {
  if (section == "projects") "projects/_template.qmd" else "portfolio/_template/index.qmd"
}

# Real content entries: anything underscore-prefixed is scaffolding.
entry_files <- function(section) {
  f <- if (section == "projects") {
    list.files("projects", pattern = "\\.qmd$", full.names = TRUE)
  } else {
    list.files("portfolio", pattern = "^index\\.qmd$", full.names = TRUE, recursive = TRUE)
  }
  f[!grepl("(^|/)_", f)]
}

slug_of <- function(section, path) {
  if (section == "projects") tools::file_path_sans_ext(basename(path)) else basename(dirname(path))
}

# ---- write ------------------------------------------------------------------

# One row -> the lines that go between the --- markers.
yaml_block <- function(section, row) {
  out <- character(0)
  for (k in setdiff(FIELDS[[section]], c("slug", "page-layout"))) {
    v <- if (k %in% c("date", "date-modified")) .date(row[[k]])
         else if (k %in% c("draft", "highlight")) tolower(as.character(.bool(row[[k]])))
         else .chr(row[[k]])
    # draft is always written (it decides whether the page publishes at all);
    # every other empty field is left out rather than emitted as "".
    if (!nzchar(v) && k != "draft") next
    if (k == "highlight" && v == "false") next
    if (k == "categories") {
      cats <- trimws(unlist(strsplit(v, ",")))
      out <- c(out, paste0("categories: [", paste(cats[nzchar(cats)], collapse = ", "), "]"))
    } else if (k %in% BARE) {
      out <- c(out, paste0(k, ": ", v))
    } else {
      out <- c(out, paste0(k, ": ", .quote(v)))
    }
  }
  if (section == "portfolio") {
    pl <- .chr(row[["page-layout"]])
    if (nzchar(pl)) out <- c(out, "format:", "  html:", paste0("    page-layout: ", pl))
  }
  out
}

# Body of an existing file (everything after the closing ---), else the template's.
body_lines <- function(path, section) {
  src <- if (file.exists(path)) path else template_path(section)
  lines <- readLines(src, warn = FALSE)
  ends <- which(lines == "---")
  if (length(ends) < 2 || ends[1] != 1) {
    if (file.exists(path)) return(lines)   # no front matter: keep the file whole
    stop("template has no front matter: ", src)
  }
  lines[-seq_len(ends[2])]
}

sheet_rows <- function(path, section) {
  df <- readxl::read_excel(path, sheet = section)
  if (nrow(df) && !"slug" %in% names(df)) stop(section, " sheet has no 'slug' column")
  df
}

generate <- function(path = "cv_inputs.xlsx", dest = ".", sections = names(FIELDS)) {
  for (section in sections) {
    df <- sheet_rows(path, section)
    if (nrow(df) == 0) { cat(sprintf("%-10s sheet empty, skipped\n", section)); next }
    for (i in seq_len(nrow(df))) {
      row <- as.list(df[i, ])
      slug <- .chr(row$slug)
      if (!nzchar(slug)) next
      rel <- entry_path(section, slug)
      out <- file.path(dest, rel)
      action <- if (file.exists(rel)) "update" else "create"
      content <- c("---", yaml_block(section, row), "---", body_lines(rel, section))
      # A new entry's folder doesn't exist yet: its template sits at the same
      # depth, so ../ paths resolve the same from there.
      img  <- .chr(row$image)
      base <- if (dir.exists(dirname(rel))) dirname(rel) else dirname(template_path(section))
      if (nzchar(img) && !grepl("^https?://", img) && !.file_ok(file.path(base, img))) {
        message("! image not found for ", rel, ": ", img)
      }
      dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
      writeLines(content, out)
      cat(sprintf("%-10s %-6s %s\n", section, action, rel))
    }
  }
  invisible(TRUE)
}

# ---- preview ----------------------------------------------------------------

# Generate into a temp folder and compare with what is on disk now.
# Returns the number of entries that would change (0 = nothing to do).
preview <- function(path = "cv_inputs.xlsx") {
  tmp <- file.path(tempdir(), "entries-preview")
  unlink(tmp, recursive = TRUE)
  invisible(capture.output(generate(path, dest = tmp)))
  parts <- function(f) {
    l <- readLines(f, warn = FALSE); e <- which(l == "---")
    list(fm = l[2:(e[2] - 1)], body = l[-seq_len(e[2])])
  }
  n <- 0
  for (section in names(FIELDS)) {
    slugs <- vapply(sheet_rows(path, section)$slug, .chr, "")
    slugs <- slugs[nzchar(slugs)]
    for (s in slugs) if (!file.exists(entry_path(section, s))) {
      n <- n + 1; cat("NEW (page text from template):", entry_path(section, s), "\n")
    }
    for (f in entry_files(section)) {
      if (!slug_of(section, f) %in% slugs) { cat("NOT IN SHEET (left as is):", f, "\n"); next }
      a <- parts(f); b <- parts(file.path(tmp, f))
      if (!identical(a$body, b$body)) cat("BODY WOULD CHANGE (bug!):", f, "\n")
      gone <- setdiff(a$fm, b$fm); added <- setdiff(b$fm, a$fm)
      if (length(gone) || length(added)) {
        n <- n + 1
        cat("\nCHANGE", f, "\n")
        for (x in gone)  cat("  -", x, "\n")
        for (x in added) cat("  +", x, "\n")
      }
    }
  }
  cat(if (n == 0) "\nNo changes.\n" else sprintf("\n%d entr%s would change.\n", n, if (n == 1) "y" else "ies"))
  invisible(n)
}

if (!interactive() && sys.nframe() == 0) {
  a <- commandArgs(trailingOnly = TRUE)
  path <- c(a[a != "--preview"], "cv_inputs.xlsx")[1]
  if ("--preview" %in% a) preview(path) else generate(path)
}
