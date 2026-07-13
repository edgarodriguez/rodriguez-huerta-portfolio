# Diagrams in Quarto

Quarto provides native support for creating diagrams through two primary tools: Mermaid and Graphviz, both of which render automatically across different output formats.

## Mermaid Diagrams

Mermaid enables diagram creation using text-based definitions. You can create flowcharts with directional options like `TB`, `TD`, `BT`, `RL`, and `LR`. The syntax uses code blocks marked with `{mermaid}`.

Options are specified using `%%|` notation, allowing you to set labels, captions, dimensions, and responsiveness. All standard Mermaid types are supported, including sequence diagrams, class diagrams, state diagrams, entity-relationship diagrams, Gantt charts, and pie charts.

## Graphviz Diagrams

Graphviz uses the DOT language for graph descriptions. You distinguish between directed graphs using `digraph` and undirected graphs using `graph`. Options use `//|` notation.

## Styling and Configuration

For Mermaid theming, you can specify themes like "forest," "dark," or "neutral" within a YAML config block. The documentation notes: "When using `mermaid-format: js` (the default for HTML), Quarto controls theming and may override custom theme configurations."

To ensure custom theming works properly, use either native Quarto theming options in document YAML or switch to `mermaid-format: svg` or `mermaid-format: png`.

Graphviz allows DOT attribute styling for customization, while CSS can enhance HTML diagram presentation.

## Output Considerations

HTML outputs render diagrams with JavaScript or SVG, while PDF and DOCX outputs require Chrome/Chromium for image rendering. Diagrams support cross-referencing and can be combined with figure elements for documentation.
