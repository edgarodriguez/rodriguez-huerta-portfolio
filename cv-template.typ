// Editorial CV template — single column, ATS-safe.
// Uses the same fonts and palette tokens as the website's styles.css.

#let cv-ink   = rgb("#032425")
#let cv-muted = rgb("#6a8078")
#let cv-rule  = rgb("#c8d0cc")

#set page(paper: "us-letter", margin: (x: 0.7in, top: 0.6in, bottom: 0.6in))
#set text(font: ("EB Garamond", "Times New Roman"), size: 10pt, fill: cv-ink)
#set par(leading: 0.65em, justify: false)

#show link: it => text(fill: cv-muted, it)

#show heading.where(level: 1): it => block(below: 8pt, above: 14pt)[
  #text(
    font: ("Space Grotesk", "Helvetica"),
    size: 11pt,
    weight: 700,
    fill: cv-ink,
    it.body
  )
  #v(2pt)
  #line(length: 100%, stroke: 0.4pt + cv-rule)
]

#let cv-section(label) = heading(level: 1, label)

#let cv-subsection(label) = block(below: 4pt, above: 8pt)[
  #text(
    font: ("Space Grotesk", "Helvetica"),
    size: 9pt,
    weight: 500,
    fill: cv-muted,
    label
  )
]

#let cv-entry(date: "", title: "", org: "", desc: "", details: ()) = block(below: 10pt)[
  #grid(
    columns: (1.2in, 1fr),
    gutter: 14pt,
    text(font: ("Space Mono", "Menlo", "Courier"), size: 7.5pt, fill: cv-muted, date),
    [
      #text(weight: 600, size: 10.5pt, title)
      #if org != "" [#h(0.4em) #text(fill: cv-muted, size: 9.5pt, org)]
      #if desc != "" [
        #v(3pt)
        #text(size: 9.5pt, desc)
      ]
      #if details.len() > 0 [
        #v(5pt)
        #for d in details [
          #block(below: 3pt, inset: (left: 0pt))[
            #grid(columns: (10pt, 1fr), gutter: 4pt,
              text(size: 9pt, fill: cv-muted, "•"),
              text(size: 9.5pt, d))
          ]
        ]
      ]
    ]
  )
]

#let cv-pub-item(body) = block(below: 5pt)[
  #grid(columns: (10pt, 1fr), gutter: 4pt,
    text(size: 9pt, fill: cv-muted, "•"),
    text(size: 9.5pt, body))
]

#let cv-skill(category: "", items: "") = block(below: 5pt)[
  #grid(
    columns: (1.2in, 1fr),
    gutter: 14pt,
    text(font: ("Space Mono", "Courier"), size: 8pt, fill: cv-muted, category),
    text(size: 10pt, items)
  )
]

#let cv-header(name: "", position: "", address: "", contacts: "") = block(below: 14pt)[
  #align(center)[
    #text(font: ("EB Garamond", "Times New Roman"), size: 22pt, weight: 400, name)
    #if position != "" [
      #v(3pt)
      #text(
        font: ("Space Grotesk", "Helvetica"),
        size: 9.5pt,
        weight: 500,
        fill: cv-muted,
        position
      )
    ]
    #if address != "" [
      #v(3pt)
      #text(size: 9pt, fill: cv-muted, address)
    ]
    #if contacts != "" [
      #v(4pt)
      #text(size: 9pt, fill: cv-muted, contacts)
    ]
  ]
  #v(4pt)
  #line(length: 100%, stroke: 0.4pt + cv-rule)
]
