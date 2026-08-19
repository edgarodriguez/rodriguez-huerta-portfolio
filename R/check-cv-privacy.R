#!/usr/bin/env Rscript
# Guard for the filter_money column: any grant amount marked FALSE must never
# appear in the published CV. Checks the freeze caches (what CI publishes from,
# and what the PDF is built from) plus the rendered HTML.
#   Rscript R/check-cv-privacy.R
suppressPackageStartupMessages(library(readxl))

g <- readxl::read_excel("cv_inputs.xlsx", sheet = "grants")
hidden <- as.character(g$location)[!is.na(g$filter_money) & !as.logical(g$filter_money)]
hidden <- hidden[!is.na(hidden) & nzchar(hidden)]
stopifnot("no rows hidden by filter_money - check the grants sheet" = length(hidden) > 0)

# Match on the digits only: JSON and Typst both escape the pound sign.
amounts <- unique(gsub("[^0-9,]", "", hidden))
amounts <- amounts[nzchar(amounts)]

targets <- c("_freeze/cv/execute-results/typ.json",
             "_freeze/cv/execute-results/html.json",
             "_site/cv.html")
for (f in targets[file.exists(targets)]) {
  txt <- paste(readLines(f, warn = FALSE), collapse = "\n")
  leaked <- amounts[vapply(amounts, grepl, logical(1), x = txt, fixed = TRUE)]
  if (length(leaked))
    stop(sprintf("filter_money leak in %s: %s", f, paste(leaked, collapse = ", ")))
  cat("ok  ", f, "\n")
}
cat("No hidden grant amounts in the CV output.\n")
