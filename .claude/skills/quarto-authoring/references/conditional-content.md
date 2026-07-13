# Conditional Content in Quarto

Quarto enables developers to display or conceal content based on output format, metadata values, or project profiles.

## Key Mechanisms

**Format-Based Control**: Use `.content-visible` and `.content-hidden` classes with `when-format` or `unless-format` attributes. As noted, "Show content only for specific formats" using syntax like `::: {.content-visible when-format="html"}`.

**Format Grouping**: Quarto provides aliases—`html` encompasses HTML, EPUB, RevealJS, and Dashboard formats, while `pdf` includes PDF, LaTeX, and Beamer outputs.

**Metadata Conditions**: Control visibility through document metadata. Content appears when `when-meta="draft"` matches YAML properties, or use `unless-meta` for inverted logic.

**Profile-Based Rendering**: Define profiles in `_quarto.yml` and render selectively with `quarto render --profile development` to switch between development and production configurations.

**Inline Content**: Apply conditions to spans for granular text-level control within paragraphs.

## Conditional Code Execution

Access execution context through the `QUARTO_EXECUTE_INFO` environment variable. Both R and Python can read this JSON file to determine the output format and conditionally execute appropriate code paths—enabling format-specific visualizations or interactive components.

## Advanced Patterns

Developers can combine multiple conditions (both must be true), nest conditions for hierarchical logic, and include different files based on format using the `{{< include >}}` directive within conditional blocks.
