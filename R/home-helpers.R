# Home-page card helpers.
# Reads YAML frontmatter from project/*.qmd and portfolio/*/index.qmd,
# selects featured items, and emits .home-card HTML blocks.
#
# Selection order (both sections):
#   1. Items with highlight: true in their frontmatter (pinned)
#   2. Remaining slots filled by most-recent date
#   For projects: active/in-review status is preferred over published.
#
# Usage:
#   source("R/home-helpers.R")
#   render_home_cards(get_featured_projects())
#   render_home_cards(get_featured_portfolio())
#
# To pin an item: add  highlight: true  to its YAML frontmatter.
# To unpin:       remove the field or set  highlight: false.
# After changing highlighted items, clear _freeze/index/ and re-render.

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

# Resolve an img path (relative to its QMD) to a root-relative path.
.home_img <- function(img, qmd_path) {
  if (!nzchar(img %||% "")) return("assets/images/img-network.svg")
  if (grepl("^https?://", img))  return(img)
  abs  <- normalizePath(file.path(dirname(qmd_path), img), mustWork = FALSE)
  root <- normalizePath(".", mustWork = FALSE)
  sub(paste0("^", root, "/"), "", abs)
}

# Categories list → "A · B · C"
.home_cats <- function(cats) {
  paste(as.character(unlist(cats %||% list())), collapse = " · ")
}

# Date value → 4-digit year string
.home_year <- function(d) {
  d <- as.character(d %||% "")
  if (!nzchar(d)) return("")
  tryCatch(format(as.Date(d), "%Y"), error = function(e) "")
}

# ---- Data collection --------------------------------------------------------

get_featured_projects <- function(n = 3) {
  paths <- list.files("projects", pattern = "\\.qmd$", full.names = TRUE)

  items <- lapply(paths, function(p) {
    fm <- tryCatch(rmarkdown::yaml_front_matter(p), error = function(e) NULL)
    if (is.null(fm) || isTRUE(fm$draft)) return(NULL)
    status <- tolower(trimws(as.character(fm$status %||% "active")))
    yr     <- .home_year(fm$date)
    stem   <- tools::file_path_sans_ext(basename(p))
    list(
      title       = fm$title       %||% "",
      description = fm$description %||% "",
      categories  = .home_cats(fm$categories),
      image       = .home_img(fm$image %||% "", p),
      date        = tryCatch(as.Date(as.character(fm$date %||% "2000-01-01")),
                             error = function(e) as.Date("2000-01-01")),
      highlight   = isTRUE(fm$highlight),
      is_active   = status %in% c("active", "in-review"),
      meta        = paste0(tools::toTitleCase(gsub("-", " ", status)), " · ", yr),
      link        = paste0("projects/", stem, ".html")
    )
  })
  items <- Filter(Negate(is.null), items)
  if (length(items) == 0) return(list())

  is_active <- vapply(items, `[[`, logical(1), "is_active")
  is_hl     <- vapply(items, `[[`, logical(1), "highlight")
  dates     <- vapply(items, function(x) as.numeric(x$date), numeric(1))
  ord       <- order(-is_active, -is_hl, -dates)

  items[ord][seq_len(min(n, length(items)))]
}

get_featured_portfolio <- function(n = 6) {
  dirs  <- list.dirs("portfolio", recursive = FALSE, full.names = TRUE)
  paths <- file.path(dirs, "index.qmd")
  paths <- paths[file.exists(paths)]

  items <- lapply(paths, function(p) {
    fm <- tryCatch(rmarkdown::yaml_front_matter(p), error = function(e) NULL)
    if (is.null(fm) || isTRUE(fm$draft)) return(NULL)
    folder <- basename(dirname(p))
    list(
      title       = fm$title       %||% "",
      description = fm$description %||% "",
      categories  = .home_cats(fm$categories),
      image       = .home_img(fm$image %||% "", p),
      date        = tryCatch(as.Date(as.character(fm$date %||% "2000-01-01")),
                             error = function(e) as.Date("2000-01-01")),
      highlight   = isTRUE(fm$highlight),
      meta        = .home_year(fm$date),
      link        = paste0("portfolio/", folder, "/")
    )
  })
  items <- Filter(Negate(is.null), items)
  if (length(items) == 0) return(list())

  is_hl <- vapply(items, `[[`, logical(1), "highlight")
  dates <- vapply(items, function(x) as.numeric(x$date), numeric(1))
  ord   <- order(-is_hl, -dates)

  items[ord][seq_len(min(n, length(items)))]
}

# ---- Rendering --------------------------------------------------------------

render_home_cards <- function(items) {
  if (length(items) == 0) return(invisible())
  for (item in items) {
    cat('<div class="home-card">\n')
    cat(sprintf('<div class="home-card-img"><img src="%s" class="home-card-svg" alt=""></div>\n',
                item$image))
    cat('<div class="home-card-body">\n')
    if (nzchar(item$categories))
      cat(sprintf('<div class="home-card-cats">%s</div>\n', item$categories))
    cat(sprintf('<div class="home-card-title">%s</div>\n', item$title))
    if (nzchar(item$description))
      cat(sprintf('<div class="home-card-desc">%s</div>\n', item$description))
    if (nzchar(item$meta %||% ""))
      cat(sprintf('<div class="home-card-meta">%s</div>\n', item$meta))
    cat(sprintf('<a href="%s" class="btn-outline btn-sm">View →</a>\n', item$link))
    cat('</div>\n')
    cat('</div>\n\n')
  }
}
