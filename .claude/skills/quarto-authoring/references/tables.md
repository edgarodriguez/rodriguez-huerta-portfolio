# Tables in Quarto

Quarto supports several table formats with extensive customization options.

## Main Table Types

**Pipe tables** are the most common format, using pipes and dashes:
```
| Column 1 | Column 2 |
| -------- | -------- |
| Data     | Data     |
```

**List tables** handle complex content like multiple paragraphs and code blocks using nested bullet lists within a `.list-table` container.

**Computational tables** generate tables directly from code using R (knitr, gt), Python (pandas), or other languages.

## Key Features

- **Alignment**: Use `:---` (left), `:---:` (center), or `---:` (right) for column alignment
- **Column widths**: Control via dash count, explicit percentages like `[25,75]`, or document-level settings
- **Captions**: Add with syntax like `::: {#tbl-example}` and reference using `@tbl-example`
- **Cross-references**: Tables use `tbl-` prefix for referencing
- **Bootstrap styling** (HTML): Apply `.striped`, `.hover`, `.bordered`, `.sm`, `.responsive` classes
- **Caption location**: Position at top, bottom, or margin

## Advanced Options

List tables support `header-rows`, `header-cols`, `aligns`, and `widths` attributes. Row and column spans use `colspan` and `rowspan` syntax. Subtables can share captions using `layout-ncol`. For PDF output, use `longtable = TRUE` for multi-page tables.
