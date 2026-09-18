# Write the current projects/ and portfolio/ entries into a workbook, one row
# per entry, in the same columns R/xlsx-to-entries.R reads. Use it to check
# the sheets against what is on disk before running the update.
#
#   Rscript R/entries-to-xlsx.R                 writes cv_input_test.xlsx
#   Rscript R/entries-to-xlsx.R other.xlsx      writes other.xlsx
#
# Round-trip check: Rscript R/xlsx-to-entries.R --preview cv_input_test.xlsx
# should report "No changes." (apart from dropped YAML comments/empty fields).

source("R/xlsx-to-entries.R")   # FIELDS + helpers; its own run block stays off
suppressPackageStartupMessages(library(writexl))

extract_section <- function(section) {
  rows <- lapply(entry_files(section), function(p) {
    fm <- rmarkdown::yaml_front_matter(p)
    row <- list(
      slug            = slug_of(section, p),
      draft           = .bool(fm$draft),
      title           = .chr(fm$title),
      description     = .chr(fm$description),
      date            = .date(fm$date),
      `date-modified` = .date(fm$`date-modified`),
      highlight       = .bool(fm$highlight),
      categories      = paste(as.character(unlist(fm$categories)), collapse = ", "),
      image           = .chr(fm$image)
    )
    if (section == "projects") {
      row$status        <- .chr(fm$status)
      row$`pub-journal` <- .chr(fm$`pub-journal`)
      row$doi           <- .chr(fm$doi)
      row$repo          <- .chr(fm$repo)
    } else {
      row$type          <- .chr(fm$type)
      row$subtype       <- .chr(fm$subtype)
      row$repo          <- .chr(fm$repo)
      row$`page-layout` <- .chr(fm$format$html$`page-layout`)
    }
    as.data.frame(row[FIELDS[[section]]], check.names = FALSE, stringsAsFactors = FALSE)
  })
  df <- do.call(rbind, rows)
  df[order(df$date, decreasing = TRUE), , drop = FALSE]
}

extract <- function(out = "cv_input_test.xlsx") {
  sheets <- lapply(names(FIELDS), extract_section)
  names(sheets) <- names(FIELDS)
  writexl::write_xlsx(sheets, out)
  for (s in names(sheets)) cat(sprintf("%-10s %2d entries -> %s\n", s, nrow(sheets[[s]]), out))
  invisible(sheets)
}

if (!interactive() && sys.nframe() == 0) {
  a <- commandArgs(trailingOnly = TRUE)
  extract(if (length(a)) a[1] else "cv_input_test.xlsx")
}
