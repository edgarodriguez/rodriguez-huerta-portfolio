# Project Specs — Rodríguez-Huerta Research Portfolio

## What this is

A personal academic portfolio website for **Edgar Rodríguez-Huerta**, a PhD researcher working at the intersection of **socio-ecological systems and modern slavery** (climate-driven vulnerability, supply-chain analysis, complex networks, social life-cycle assessment).

The site is editorial in style — typographic, restrained, monochrome by default — and treats research outputs (papers, talks, visualisations, projects, blog posts) as **first-class linkable items**, each with its own page.

## Who uses it

- **Edgar** (author) — to publish his work and update it by dropping new `.qmd` files into the right folder.
- **Academic peers / collaborators** — to read papers, see talks, get in touch.
- **Funders, hiring committees, journalists** — to assess credentials quickly via CV, publications, and visual portfolio.
- **General readers** — via the blog.

## Tech stack

| Concern | Choice | Why |
|---|---|---|
| Framework | **Quarto** (latest, ≥ 1.4) | Native support for academic content, listings, citations, code cells; renders to static HTML. |
| Language | Markdown (`.qmd`) + HTML/CSS where needed | Plain content authoring; HTML escape hatches for editorial layouts. |
| Styling | Hand-written `styles.css` on top of Quarto's `cosmo` base theme | Full control over the editorial design tokens. |
| Optional computation | R or Python in code cells | Only when a page needs a live chart or table. Most pages have none. |
| Hosting | **GitHub Pages** | Free, static, fits Quarto's render-to-HTML model. |
| CI/CD | GitHub Actions (`quarto-dev/quarto-actions/publish@v2`) | Auto-builds and publishes to `gh-pages` on every push to `main`. |
| Fonts | Google Fonts (EB Garamond, Space Grotesk, Space Mono) | Editorial serif + utilitarian sans + technical mono. Free, web-safe. |
| Animation | None (deferred) | Skipped for the first cut per user direction. |

**No** Next.js, **no** Supabase, **no** Vercel, **no** Stripe, **no** auth — this is a static, public, content-first site.

## Pages and user flows

All pages are public. There is no authenticated area.

### Top-level navigation
| Order | Label | URL | Type |
|---|---|---|---|
| 1 | Home | `/` | Editorial split hero + 3 featured items |
| 2 | About | `/about.html` | Research statement + bio + sidebar facts |
| 3 | Projects | `/projects.html` | Listing → opens individual project pages |
| 4 | Publications | `/publications.html` | Listing → opens individual publication pages |
| 5 | Portfolio | `/portfolio.html` | Listing (grid) → opens individual visualisation pages |
| 6 | Conferences | `/conferences.html` | Listing → opens individual talk pages |
| 7 | CV ▾ | (dropdown) | Two items: Curriculum Vitae, CV of Failures |
| 7a | Curriculum Vitae | `/cv.html` | Standalone two-column document |
| 7b | CV of Failures | `/cv-negative.html` | Rejected papers, declined grants, lessons |
| 8 | Blog | `/blog.html` | Listing → opens individual blog posts |

### Listings → individual pages
For Projects, Publications, Portfolio, Conferences, and Blog: each `.qmd` file inside the corresponding folder (`/projects/`, `/publications/`, etc.) becomes **its own standalone page** at `/<section>/<slug>.html`. The listing page (`projects.qmd`, etc.) auto-generates cards/rows that link to these standalone pages. Adding a new entry = drop a new `.qmd` into the folder.

## Data models

No database. All content is files in the repo.

### Listing item frontmatter (shared shape)
```yaml
---
title: "Item title"
description: "One-line summary used in listing cards"
date: 2026-04-30
categories: [tag1, tag2]
image: "thumbnail.jpg"   # optional, relative to the .qmd file
---
```

Per-section additional fields:
- **Publications**: `author`, `journal`, `doi`, `pdf`, `bibtex`
- **Conferences**: `venue`, `location`, `slides`
- **Portfolio**: `viz` (which SVG partial to embed: network / scatter / timeseries / heatmap / sankey)
- **Projects**: `repo`, `status` (active / archived)

## Where data lives

- All content: in this repo as `.qmd` files (rendered to static HTML at build time).
- Generated site output: `/_site/` (gitignored locally; published to the `gh-pages` branch by the GH Action).
- Listing thumbnails: `/assets/images/`.
- Bibliography (if used): `references.bib` at project root.

## Third-party services

- **GitHub Pages** — hosting (free, public).
- **Google Fonts** — webfonts via CDN (no account needed).
- **GitHub Actions** — CI/CD (free for public repos).

That's it. No analytics, no comments, no payment, no auth — by design. Can be added later if needed.

## What "done" looks like for the rebuild

- [ ] All 9 navigation entries render without errors via `quarto render`.
- [ ] Default visual matches the editorial design from `Edgar Portfolio.html` side-by-side: same typography (EB Garamond / Space Grotesk / Space Mono), same palette (`mp085-light` Lighthouse), same two-column splits with rule dividers, same `01 — Section` numerals, same button styles.
- [ ] CV nav item is a dropdown with two children (Curriculum Vitae / CV of Failures) that each open a working page.
- [ ] Each listing page renders at least one seed entry, and clicking it opens a working standalone detail page with a "← back" link.
- [ ] Site is responsive at 640px (nav stacks, splits collapse to single column).
- [ ] No console errors in the browser.
- [ ] `_quarto.yml` has GitHub Pages publish configured.
- [ ] `.github/workflows/publish.yml` exists and is syntactically valid.
- [ ] CLAUDE.md "Tech Stack" and "File Structure" sections updated to describe what this project actually is.
- [ ] README explains how to run locally and how deploy works.

## CV Pipeline (xlsx → HTML + PDF)

The Curriculum Vitae page is **data-driven from a single Excel file**.

### How it works (plain English)

1. All CV data lives in `cv_inputs.xlsx` at the project root — one sheet per section (Education, Experience, Industry, Grants, Awards, Events, Teaching, Services, Training, Publications, Skills, Languages, Meta).
2. An R script (`R/init-cv-template.R`) creates that xlsx pre-filled with real data. Run it once.
3. `cv.qmd` has tiny R chunks that read the xlsx and emit either fenced-div HTML (for the website) or Typst commands (for the PDF) — same data, two outputs.
4. A custom Typst template (`cv-template.typ`) styles the PDF to match the site's palette and fonts while keeping it ATS-safe (single column, plain-text contacts, real heading elements, no icon glyphs).
5. The xlsx is **gitignored** (private). Quarto's `freeze: auto` caches the rendered output to `_freeze/cv/`, which IS committed — so GitHub Actions can publish without ever reading the xlsx.

### Filtering rows

Every section sheet has a `filter` column. Set it to `FALSE` to hide an entry from the rendered CV without deleting the row.

### Schema (sheet → columns)

| Sheet | Columns |
|---|---|
| `meta` | `key, value` |
| `education`, `experience`, `industry`, `grants`, `awards`, `events`, `teaching`, `training` | `title, location, date, description, details, filter` |
| `publications` | `type, authors, year, title, venue, url, doi, details, filter` (type ∈ peer-reviewed / non-peer-reviewed / under-review / other-outcome) |
| `skills` | `category, items, filter` |
| `languages` | `language, level, filter` |
| `services` | `category, items, filter` |

### User workflow

1. Edit `cv_inputs.xlsx` in Excel.
2. `quarto preview cv.qmd` → check website.
3. `quarto render cv.qmd --to typst` → produces `_site/cv.pdf`.
4. `cp _site/cv.pdf cv.pdf` → copy to project root (so CI bundles it as a website resource).
5. `git add _freeze/cv/ cv.pdf && git push` → CI publishes site (HTML) and bundles cv.pdf.

## Out of scope for this rebuild (deferred)

- GSAP / Svelte animations and full-screen section transitions.
- The 10-palette tweaks panel (we ship 2: editorial-light default + 1 dark toggle).
- Coloured variants of the SVG visualisations (we render monochrome only).
- Search, comments, RSS for non-blog sections (blog gets RSS).
- Analytics.
