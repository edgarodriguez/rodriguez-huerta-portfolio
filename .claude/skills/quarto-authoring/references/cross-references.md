# Cross-References in Quarto

Quarto offers "a unified cross-reference system for figures, tables, equations, sections, theorems, and more."

## Key Labeling System

All cross-referenceable items need labels with specific type prefixes. For example, figures use `fig-`, tables use `tbl-`, and sections use `sec-`. References are created using the `@` symbol followed by the label (like `@fig-plot`).

## Recommended Approaches

The documentation suggests using div syntax for consistency across all element types rather than inline caption syntax, though both work functionally.

## Major Element Types Supported

- **Figures & Subfigures**: Code-generated or markdown images with grouped layouts
- **Tables & Subtables**: Both programmatically created and markdown-based tables
- **Sections**: Require `number-sections: true` in YAML configuration
- **Equations**: Display math with labels
- **Theorem Family**: Including theorems, lemmas, corollaries, propositions, conjectures, definitions, examples, and exercises
- **Code Listings**: With language specification and captions
- **Callouts**: Notes, tips, warnings, important items, and cautions

## Customization Options

Users can customize reference prefixes through YAML configuration, support multiple languages for localization, and define entirely custom cross-reference types for specialized content like videos.
