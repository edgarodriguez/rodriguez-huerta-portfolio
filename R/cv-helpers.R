# Helpers that read cv_inputs.xlsx and emit either HTML fenced divs
# or Typst commands, depending on the active Quarto output format.

suppressPackageStartupMessages({
  library(readxl)
})

CV_SHEETS <- c("meta", "education", "experience", "industry", "grants",
               "awards", "events", "teaching", "services", "training",
               "publications", "skills", "languages", "cv_negatives")

load_cv <- function(path = "cv_inputs.xlsx") {
  out <- lapply(CV_SHEETS, function(s) {
    df <- tryCatch(
      readxl::read_excel(path, sheet = s),
      error = function(e) data.frame()
    )
    if ("filter" %in% names(df)) {
      keep <- !is.na(df$filter) & as.logical(df$filter)
      df <- df[keep, , drop = FALSE]
    }
    df
  })
  names(out) <- CV_SHEETS
  out
}

out_fmt <- function() {
  fmt <- knitr::pandoc_to()
  if (length(fmt) && identical(fmt, "typst")) "typst" else "html"
}

.na_blank <- function(x) ifelse(is.na(x) | is.null(x), "", as.character(x))

.split_details <- function(s) {
  s <- .na_blank(s)
  if (!nzchar(s)) return(character(0))
  parts <- unlist(strsplit(s, "\n", fixed = TRUE))
  parts <- trimws(parts)
  parts <- parts[nzchar(parts)]
  sub("^[-*]\\s*", "", parts)
}

# Escape Typst-special characters in plain text (keep it minimal).
.typ_esc <- function(s) {
  s <- .na_blank(s)
  s <- gsub("\\\\", "\\\\\\\\", s)
  s <- gsub("\\[", "\\\\[", s)
  s <- gsub("\\]", "\\\\]", s)
  s <- gsub("#",  "\\\\#",  s)
  s <- gsub("@",  "\\\\@",  s)
  s
}

# ---- HTML body wrapper (no-op for Typst) ----

render_body_open  <- function() if (out_fmt() == "html") cat("\n::: {.cv-body}\n\n")
render_body_close <- function() if (out_fmt() == "html") cat("\n:::\n")

# Wrap raw Typst markup in a pandoc raw-attribute fence so pandoc emits it
# verbatim into the .typ output instead of escaping the `#` characters.
.typ_block <- function(...) {
  cat("\n```{=typst}\n")
  cat(..., sep = "")
  cat("\n```\n\n")
}

# ---- Header (name + plain-text contacts) ----

render_header <- function(meta_df) {
  m <- setNames(as.list(meta_df$value), meta_df$key)
  full_name <- paste0(.na_blank(m$lastname), ", ", .na_blank(m$firstname))
  contacts <- c(
    if (nzchar(.na_blank(m$email)))    paste0("email: ", m$email),
    if (nzchar(.na_blank(m$orcid)))    paste0("ORCID: ", m$orcid),
    if (nzchar(.na_blank(m$linkedin))) paste0("LinkedIn: ", m$linkedin),
    if (nzchar(.na_blank(m$website)))  paste0("web: ", m$website),
    if (nzchar(.na_blank(m$location))) m$location
  )
  contact_line <- paste(contacts, collapse = "  ·  ")

  if (out_fmt() == "typst") {
    .typ_block(sprintf("#cv-header(name: [%s], position: [%s], address: [%s], contacts: [%s])",
                       .typ_esc(full_name),
                       .typ_esc(.na_blank(m$position)),
                       .typ_esc(.na_blank(m$address)),
                       .typ_esc(contact_line)))
    return(invisible())
  } else {
    cat("::: {.cv-page-header}\n")
    cat("::: {}\n")
    cat("[07 — Curriculum Vitae]{.label}\n\n")
    cat(sprintf("::: {.h1}\n%s\n:::\n\n", full_name))
    if (nzchar(.na_blank(m$position)))
      cat(sprintf("[%s]{.cv-position}\n\n", .na_blank(m$position)))
    if (nzchar(.na_blank(m$address)))
      cat(sprintf("[%s]{.cv-address}\n\n", .na_blank(m$address)))
    if (nzchar(contact_line))
      cat(sprintf("[%s]{.cv-contacts}\n", contact_line))
    cat(":::\n")
    cat("[Download PDF](cv.pdf){.btn-primary}\n")
    cat(":::\n\n")
  }
}

# ---- Generic dated section (Education, Experience, Industry, Grants, Awards, Events, Teaching, Training) ----

render_dated <- function(df, label) {
  if (nrow(df) == 0) return(invisible())

  if (out_fmt() == "typst") {
    chunks <- character()
    chunks <- c(chunks, sprintf("#cv-section[%s]", .typ_esc(label)))
    for (i in seq_len(nrow(df))) {
      show_loc <- TRUE
      if ("filter_money" %in% names(df) && !is.na(df$filter_money[i]))
        show_loc <- as.logical(df$filter_money[i])
      loc <- if (show_loc) .typ_esc(.na_blank(df$location[i])) else ""

      details <- .split_details(df$details[i])
      detail_block <- if (length(details))
        paste0("(",
               paste(sprintf("[%s]", vapply(details, .typ_esc, "")), collapse = ", "),
               ",)")
      else "()"
      chunks <- c(chunks, sprintf("#cv-entry(date: [%s], title: [%s], org: [%s], desc: [%s], details: %s)",
                                  .typ_esc(.na_blank(df$date[i])),
                                  .typ_esc(.na_blank(df$title[i])),
                                  loc,
                                  .typ_esc(.na_blank(df$description[i])),
                                  detail_block))
    }
    .typ_block(paste(chunks, collapse = "\n"))
    return(invisible())
  }

  cat(sprintf("\n::: {.cv-section}\n::: {.cv-section-label}\n%s\n:::\n\n", label))
  for (i in seq_len(nrow(df))) {
    show_loc <- TRUE
    if ("filter_money" %in% names(df) && !is.na(df$filter_money[i]))
      show_loc <- as.logical(df$filter_money[i])

    cat("::: {.cv-row}\n")
    cat(sprintf("::: {.cv-period}\n%s\n:::\n", .na_blank(df$date[i])))
    cat("::: {}\n")
    cat(sprintf("::: {.cv-title}\n%s\n:::\n", .na_blank(df$title[i])))
    if (show_loc && nzchar(.na_blank(df$location[i])))
      cat(sprintf("::: {.cv-org}\n%s\n:::\n", .na_blank(df$location[i])))
    if (nzchar(.na_blank(df$description[i])))
      cat(sprintf("::: {.cv-desc}\n%s\n:::\n", .na_blank(df$description[i])))
    details <- .split_details(df$details[i])
    if (length(details)) {
      cat("::: {.cv-details}\n")
      for (d in details) cat(sprintf("- %s\n", d))
      cat(":::\n")
    }
    cat(":::\n")
    cat(":::\n\n")
  }
  cat(":::\n")
}

# ---- Publications (grouped by type) ----

PUB_TYPE_LABELS <- list(
  "peer-reviewed" = "Peer reviewed",
  "report"        = "Reports",
  "under-review"  = "Under review / In development",
  "other-outcome" = "Other selected outcomes"
)

.format_pub_text <- function(row) {
  parts <- c(.na_blank(row$authors))
  if (nzchar(.na_blank(row$year)))  parts <- c(parts, sprintf("(%s).", row$year))
  if (nzchar(.na_blank(row$title))) parts <- c(parts, paste0(row$title, "."))
  if (nzchar(.na_blank(row$venue))) parts <- c(parts, paste0("*", row$venue, "*."))
  txt <- paste(parts, collapse = " ")
  url <- .na_blank(row$url)
  if (!nzchar(url)) url <- .na_blank(row$doi)
  if (nzchar(url)) {
    if (!grepl("^https?://", url) && grepl("^10\\.", url)) url <- paste0("https://doi.org/", url)
    txt <- paste0(txt, " <", url, ">")
  }
  txt
}

.format_pub_typst <- function(row) {
  parts <- c(.typ_esc(.na_blank(row$authors)))
  if (nzchar(.na_blank(row$year)))  parts <- c(parts, sprintf("(%s).", row$year))
  if (nzchar(.na_blank(row$title))) parts <- c(parts, paste0(.typ_esc(row$title), "."))
  if (nzchar(.na_blank(row$venue))) parts <- c(parts, paste0("#emph[", .typ_esc(row$venue), "]."))
  txt <- paste(parts, collapse = " ")
  url <- .na_blank(row$url)
  if (!nzchar(url)) url <- .na_blank(row$doi)
  if (nzchar(url)) {
    if (!grepl("^https?://", url) && grepl("^10\\.", url)) url <- paste0("https://doi.org/", url)
    txt <- paste0(txt, " #link(\"", url, "\")")
  }
  txt
}

render_publications <- function(df, label = "Selected publications") {
  if (nrow(df) == 0) return(invisible())
  types_present <- unique(df$type)
  ordered_types <- c("peer-reviewed", "report", "under-review", "other-outcome")
  ordered_types <- ordered_types[ordered_types %in% types_present]

  if (out_fmt() == "typst") {
    chunks <- character()
    chunks <- c(chunks, sprintf("#cv-section[%s]", .typ_esc(label)))
    for (t in ordered_types) {
      sub <- df[df$type == t, , drop = FALSE]
      sub_label <- PUB_TYPE_LABELS[[t]] %||% t
      chunks <- c(chunks, sprintf("#cv-subsection[%s]", .typ_esc(sub_label)))
      for (i in seq_len(nrow(sub))) {
        chunks <- c(chunks, paste0("#cv-pub-item[", .format_pub_typst(sub[i, ]), "]"))
      }
    }
    .typ_block(paste(chunks, collapse = "\n"))
    return(invisible())
  }

  cat(sprintf("\n::: {.cv-section}\n::: {.cv-section-label}\n%s\n:::\n\n", label))
  for (t in ordered_types) {
    sub <- df[df$type == t, , drop = FALSE]
    sub_label <- PUB_TYPE_LABELS[[t]] %||% t
    cat(sprintf("::: {.cv-subsection-label}\n%s\n:::\n\n", sub_label))
    cat("::: {.cv-pub-list}\n")
    for (i in seq_len(nrow(sub))) {
      cat(sprintf("- %s\n", .format_pub_text(sub[i, ])))
    }
    cat(":::\n\n")
  }
  cat(":::\n")
}

`%||%` <- function(a, b) if (is.null(a) || is.na(a) || !nzchar(a)) b else a

# Inline an icon SVG, tinted with the editorial accent.
# Hexagon (#000000) -> accent; inner glyph (#ffffff) -> paper.
.accent_icon <- function(name, dir = "assets/icons") {
  path <- file.path(dir, paste0(name, ".svg"))
  svg <- tryCatch(paste(readLines(path, warn = FALSE), collapse = ""),
                  error = function(e) "")
  svg <- gsub("#000000", "var(--accent)", svg, fixed = TRUE)
  svg <- gsub("#ffffff", "var(--paper)",  svg, fixed = TRUE)
  svg
}

# ---- Skills, Languages, Services (category | items rows) ----

render_kv_rows <- function(df, label, key_col, val_col) {
  if (nrow(df) == 0) return(invisible())
  if (out_fmt() == "typst") {
    chunks <- character()
    chunks <- c(chunks, sprintf("#cv-section[%s]", .typ_esc(label)))
    for (i in seq_len(nrow(df))) {
      chunks <- c(chunks, sprintf("#cv-skill(category: [%s], items: [%s])",
                                  .typ_esc(.na_blank(df[[key_col]][i])),
                                  .typ_esc(.na_blank(df[[val_col]][i]))))
    }
    .typ_block(paste(chunks, collapse = "\n"))
    return(invisible())
  }
  cat(sprintf("\n::: {.cv-section}\n::: {.cv-section-label}\n%s\n:::\n\n", label))
  for (i in seq_len(nrow(df))) {
    cat("::: {.cv-row}\n")
    cat(sprintf("::: {.cv-period}\n%s\n:::\n", .na_blank(df[[key_col]][i])))
    cat("::: {}\n")
    cat(sprintf("::: {.cv-title}\n%s\n:::\n", .na_blank(df[[val_col]][i])))
    cat(":::\n:::\n\n")
  }
  cat(":::\n")
}

render_skills    <- function(df) render_kv_rows(df, "Skills",            "category", "items")
render_languages <- function(df) {
  if (nrow(df) == 0) return(invisible())
  combined <- data.frame(
    category = df$language,
    items    = df$level,
    stringsAsFactors = FALSE
  )
  render_kv_rows(combined, "Languages", "category", "items")
}
render_services  <- function(df) render_kv_rows(df, "Academic Service",  "category", "items")

# ---- Publications listing page (HTML only, no Typst) ----

render_publications_page <- function(df) {
  if (nrow(df) == 0) return(invisible())

  # Status counts read the FULL publications sheet (ignoring the filter
  # column), so the pipeline view stays accurate even when under-review or
  # in-development entries are filter=FALSE (and thus absent from `df`).
  pubs_all <- tryCatch(
    readxl::read_excel("cv_inputs.xlsx", sheet = "publications"),
    error = function(e) NULL
  )
  count_status <- function(s) {
    if (is.null(pubs_all) || !"status" %in% names(pubs_all)) return(0L)
    sum(!is.na(pubs_all$status) & pubs_all$status == s)
  }
  n_published    <- count_status("published")
  n_under_review <- count_status("under-review")
  n_in_dev       <- count_status("in-development")

  # Show only items with status "published" on the publications page.
  if ("status" %in% names(df)) {
    df <- df[!is.na(df$status) & df$status == "published", , drop = FALSE]
  }
  if (nrow(df) == 0) return(invisible())

  # Sort newest first by date; fall back to year when date is missing.
  date_col <- if ("date" %in% names(df)) df$date else rep(NA, nrow(df))
  year_col <- if ("year" %in% names(df)) df$year else rep(NA, nrow(df))
  df <- df[order(date_col, year_col, decreasing = TRUE, na.last = TRUE), , drop = FALSE]

  # Extract 4-digit year — always used for .row-year display
  get_year <- function(y) {
    m <- regmatches(.na_blank(y), regexpr("\\d{4}", .na_blank(y)))
    if (length(m) && nzchar(m)) m else "Other"
  }
  df$display_year <- vapply(df$year, get_year, character(1))

  # Filter keys: use 'categories' column (comma-separated) if present in xlsx,
  # else fall back to year. JS filter supports pipe-separated multi-value keys.
  .parse_cats <- function(x) {
    x <- .na_blank(x)
    if (!nzchar(x)) return(character(0))
    trimws(unlist(strsplit(x, ",\\s*")))
  }
  use_cats <- "categories" %in% names(df) && any(nzchar(.na_blank(df$categories)))
  if (use_cats) {
    df$filter_key <- vapply(df$categories, function(x) {
      cats <- .parse_cats(x)
      if (!length(cats)) return("") else paste(cats, collapse = "|")
    }, character(1))
    filter_labels <- sort(unique(unlist(lapply(df$categories, .parse_cats))))
    filter_labels <- filter_labels[nzchar(filter_labels)]
  } else {
    df$filter_key <- df$display_year
    filter_labels <- sort(unique(df$filter_key[df$filter_key != "Other"]), decreasing = TRUE)
    if (any(df$filter_key == "Other")) filter_labels <- c(filter_labels, "Other")
  }

  # Header — label above the flex row; h1 (left) and stats (right) are the
  # only two flex children so align-items: center works on equal-height items.
  cat("::: {.listing-header}\n")
  cat("[04 — Publications]{.label}\n\n")
  cat("::: {.pub-header}\n")
  cat("::: {.h1}\nPublications\n:::\n\n")
  cat("::: {.pub-stats}\n")
  pub_stats <- list(
    list(icon = "book-check-6gon-120",    n = n_published,    label = "Published"),
    list(icon = "text-search-6gon-120",   n = n_under_review, label = "Under review"),
    list(icon = "loader-circle-6gon-120", n = n_in_dev,       label = "In development")
  )
  for (s in pub_stats) {
    cat("::: {.split-3-item}\n")
    cat(sprintf('<div class="stat-icon">%s</div>\n\n', .accent_icon(s$icon)))
    cat(sprintf("[[%d]{.stat-count} %s]{.label}\n", s$n, s$label))
    cat(":::\n")
  }
  cat(":::\n")
  cat(":::\n\n")

  # Filter bar — raw HTML (permitted for filter buttons per CLAUDE.md)
  cat('<div class="filter-bar" data-filter-group data-filter-target="#pub-list">\n')
  cat('<button type="button" class="filter-btn is-active" data-filter="All">All</button>\n')
  for (k in filter_labels) {
    cat(sprintf('<button type="button" class="filter-btn" data-filter="%s">%s</button>\n', k, k))
  }
  cat('</div>\n')
  cat(":::\n\n")

  # Row list — grouped by type with subheadings
  ordered_types <- c("peer-reviewed", "report", "under-review", "other-outcome")
  ordered_types <- ordered_types[ordered_types %in% df$type]

  cat("::: {#pub-list .row-list}\n\n")
  for (tp in ordered_types) {
    sub_label <- PUB_TYPE_LABELS[[tp]] %||% tp
    cat(sprintf("::: {.cv-section-label}\n%s\n:::\n\n", sub_label))
    type_df <- df[df$type == tp, , drop = FALSE]
    for (i in seq_len(nrow(type_df))) {
      fk <- type_df$filter_key[i]
      yr <- type_df$display_year[i]
      cat(sprintf('::: {.row-pub data-filter-key="%s"}\n', fk))
      cat(sprintf("::: {.row-year}\n%s\n:::\n", yr))
      cat("::: {}\n")
      cat(sprintf("::: {.row-title}\n%s\n:::\n", .na_blank(type_df$title[i])))
      authors_str <- .na_blank(type_df$authors[i])
      venue_str   <- .na_blank(type_df$venue[i])
      pub_url     <- if ("url" %in% names(type_df)) .na_blank(type_df$url[i]) else ""
      if (!nzchar(pub_url) && "doi" %in% names(type_df)) pub_url <- .na_blank(type_df$doi[i])
      if (nzchar(pub_url) && !grepl("^https?://", pub_url) && grepl("^10\\.", pub_url))
        pub_url <- paste0("https://doi.org/", pub_url)
      parts <- character(0)
      if (nzchar(authors_str)) parts <- c(parts, sprintf("[%s]{.row-authors}", authors_str))
      if (nzchar(venue_str)) {
        if (nzchar(pub_url)) {
          parts <- c(parts, sprintf('[%s](%s){.tag target="_blank" rel="noopener"}', venue_str, pub_url))
        } else {
          parts <- c(parts, sprintf("[%s]{.tag}", venue_str))
        }
      }
      if (length(parts)) {
        cat("::: {.row-meta}\n")
        cat(paste(parts, collapse = " "))
        cat("\n:::\n")
      }
      cat(":::\n")
      cat(":::\n\n")
    }
  }
  cat(":::\n")
}

# ---- Conferences / Events listing page (HTML only, no Typst) ----

render_conferences_page <- function(df) {
  if (nrow(df) == 0) return(invisible())

  # Sort by date descending (newest event first); parse "MMM YYYY" or fall back to year
  .parse_event_date <- function(d) {
    d <- .na_blank(d)
    m <- regmatches(d, regexpr(
      "\\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\\s+\\d{4}\\b", d, perl = TRUE))
    if (length(m) && nzchar(m))
      return(tryCatch(as.numeric(as.Date(paste("01", m), "%d %b %Y")),
                      error = function(e) NA_real_))
    yr <- regmatches(d, regexpr("\\d{4}", d))
    if (length(yr) && nzchar(yr)) as.numeric(as.Date(paste0(yr, "-01-01")))
    else NA_real_
  }
  event_dates <- vapply(df$date, .parse_event_date, numeric(1))
  df <- df[order(event_dates, decreasing = TRUE, na.last = TRUE), , drop = FALSE]

  # Graceful fallback when xlsx events sheet has no type column yet
  if (!"type" %in% names(df)) df$type <- "Event"

  # Extract 4-digit year for display; ignores values outside 1990–2030 (e.g. Excel serial "4605")
  get_year <- function(d) {
    m <- regmatches(.na_blank(d), regexpr("\\d{4}", .na_blank(d)))
    if (length(m) && nzchar(m)) {
      yr <- suppressWarnings(as.integer(m))
      if (!is.na(yr) && yr >= 1990L && yr <= 2030L) return(m)
    }
    ""
  }
  df$display_year <- vapply(df$date, get_year, character(1))

  # Unique types in order of first appearance (preserves xlsx ordering)
  unique_types <- unique(df$type[!is.na(df$type) & nzchar(df$type)])

  # Parse city from location: take the segment after the last " — " (em-dash)
  parse_city <- function(s) {
    s <- .na_blank(s)
    parts <- strsplit(s, " — |\\s—\\s| — ", perl = FALSE)[[1]]
    if (length(parts) >= 2) trimws(tail(parts, 1)) else trimws(s)
  }

  # Strip leading "Conference:", "Workshop:", etc. prefix from event title
  strip_prefix <- function(s) {
    gsub("^(Conference|Workshop|Collaboration|Brown bag sessions?|Seminar):\\s*",
         "", .na_blank(s), perl = TRUE, ignore.case = TRUE)
  }

  # Header
  cat("::: {.listing-header}\n")
  cat("::: {}\n")
  cat("[06 — Conferences & Talks]{.label}\n\n")
  cat("::: {.h1}\nPresenting work, building conversations\n:::\n")
  cat(":::\n\n")

  # Filter bar
  cat('<div class="filter-bar" data-filter-group data-filter-target="#conf-list">\n')
  cat('<button type="button" class="filter-btn is-active" data-filter="All">All</button>\n')
  for (t in unique_types) {
    cat(sprintf('<button type="button" class="filter-btn" data-filter="%s">%s</button>\n', t, t))
  }
  cat('</div>\n')
  cat(":::\n\n")

  # Row list
  cat("::: {#conf-list .row-list}\n\n")
  for (i in seq_len(nrow(df))) {
    tp   <- .na_blank(df$type[i])
    yr   <- df$display_year[i]
    desc <- .na_blank(df$description[i])
    raw  <- .na_blank(df$title[i])
    clean <- strip_prefix(raw)

    # If description holds a talk title, use it as row-title; otherwise use clean title
    if (nzchar(desc)) {
      row_title <- desc
      row_event <- clean
    } else {
      row_title <- clean
      row_event <- ""
    }
    city <- parse_city(.na_blank(df$location[i]))

    cat(sprintf('::: {.row-conf data-filter-key="%s"}\n', tp))
    cat(sprintf("::: {.row-year}\n%s\n:::\n", yr))
    cat("::: {}\n")
    cat(sprintf("::: {.row-title}\n%s\n:::\n", row_title))
    if (nzchar(row_event))
      cat(sprintf("::: {.row-event}\n%s\n:::\n", row_event))
    cat(sprintf("::: {.row-loc}\n%s\n:::\n", city))
    cat(":::\n")
    cat("::: {}\n")
    if (nzchar(tp)) cat(sprintf("[%s]{.tag}\n", tp))
    cat(":::\n")
    cat(":::\n\n")
  }
  cat(":::\n")
}

# ---- CV of Failures page (HTML only) ----

render_cv_negatives <- function(df) {
  if (nrow(df) == 0) return(invisible())
  if ("id" %in% names(df)) df <- df[order(as.numeric(df$id)), , drop = FALSE]

  # Sections in order of first appearance after id-sort
  sections <- unique(df$section)

  for (sec in sections) {
    sub <- df[df$section == sec, , drop = FALSE]
    cat(sprintf("\n::: {.cv-section}\n::: {.cv-section-label}\n%s\n:::\n\n", sec))
    for (i in seq_len(nrow(sub))) {
      cat("::: {.cv-row .cv-failure}\n")
      cat(sprintf("::: {.cv-period}\n%s\n:::\n", .na_blank(sub$date[i])))
      cat("::: {}\n")
      cat(sprintf("::: {.cv-title}\n%s\n:::\n", .na_blank(sub$title[i])))
      if (nzchar(.na_blank(sub$location[i])))
        cat(sprintf("::: {.cv-org}\n%s\n:::\n", .na_blank(sub$location[i])))
      cat(":::\n")
      cat(":::\n\n")
    }
    cat(":::\n")
  }
}
