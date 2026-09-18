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
| Fonts | EB Garamond + DM Sans (Google Fonts, one request), Commit Mono (Fontsource/jsDelivr); navbar name in Movement Direct Thin (self-hosted in `assets/fonts/`, CC BY-ND 4.0) | Serif + sans + high-x-height technical mono. All free; Switzer was dropped because Fontshare stalled for 30 s+ in Sept 2026. |
| Animation | CSS + two vanilla-JS sections in `_includes/after-body.html`; no libraries | Ambient ASCII field (whole page on Home, first header elsewhere); honeycomb row offsets and expand-on-hover for hex listings. |

**No** Next.js, **no** Supabase, **no** Vercel, **no** Stripe, **no** auth — this is a static, public, content-first site.

## Pages and user flows

All pages are public. There is no authenticated area.

### Top-level navigation
| Order | Label | URL | Type |
|---|---|---|---|
| 1 | Home | `/` | Single full-bleed hero (network viz) + scroll-to-advance band |
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

## Feature: ASCII header field + hex listings (Sept 2026)

**What it does**
- **ASCII field**: a slow, low-contrast, fluid-moving plasma of small (8px) monospace characters.
  - On Home it covers the whole page, margins included (`--rule` + 5% `--ink`), and the Coming-soon panel is translucent so it shows through.
  - On the other top-level pages it sits behind the first header (`--rule` + 12% `--ink`), fading out under the text.
  - Single project/post pages and the 404 page get none. The motion.dev/examples header is a reference for the look only; all colours come from the site's tokens.
- **Hex listings**: Projects (3 columns) and Portfolio (4 columns) show entries as a full-width, responsive honeycomb of the logo's hexagon (pointy-top, rounded corners).
  - At rest a tile is a faint greyscale thumbnail; in dark mode the tile is `--muted` grey.
  - Hovering or keyboard-focusing a tile makes it grow 15%, turns the figure full colour and shows the title and description on a frosted-glass band across the full tile width.
  - Clicking opens the entry. The filter bars, including the portfolio sub-filter row, work as before.
- **Fonts**: EB Garamond (serif) and DM Sans (sans) from Google Fonts. Averia Serif Libre was the serif for one release in Sept 2026; EB Garamond was restored on 18 Sept 2026. Switzer (Fontshare) is gone for good.

**How it's built**
- `_includes/after-body.html` gets two new sections:
  - ASCII FIELD writes each plasma frame (on-screen rows only) into a `data-ascii` attribute, and `styles.css` prints it with `::before`, so no DOM nodes are added.
  - HEX ROWS marks the first tile of every second row (`.hex-shift`), because CSS can't know where rows wrap once the filter hides tiles.
- The honeycomb is otherwise CSS on Quarto's own grid-listing markup. The old rectangular card-grid rules are deleted, not overridden.
- Fonts load in `_includes/head.html`. No libraries, no Quarto templates, and no changes to `R/` or `_quarto.yml`.
- The plasma is original code, because the asciiart.eu demo's licence forbids reusing its code.

**Behaviour rules**
- Reduced motion: one still frame, and hexagons change state without transitions.
- The plasma pauses while its host is off-screen or the tab is hidden.
- Touch screens (no hover): hexagon titles are always shown.
- The light/dark toggle recolours both features instantly (tokens only).
- Design exceptions (`.impeccable.md` amended): the site's one looping animation, and the frosted hover band.

**Process**
1. Isolated previews (`_site/proto-*.html`, built from `_prototypes/`) and a feasibility report (`_prototypes/FEASIBILITY.md`). No source files change.
2. The user approves the previews.
3. Apply: copy the approved candidates over `styles.css`, `_includes/after-body.html` and `_includes/head.html`.

**Done when**
- [x] Every check in `_prototypes/FEASIBILITY.md` is PASS or has an accepted fallback.
- [x] `quarto render` succeeds, all 9 top-level pages show the field, and there are no new console errors.
- [x] Projects and Portfolio show the honeycomb at 400px, 900px and 1440px. Every filter button (and portfolio sub-filter) shows the right entries, and the honeycomb reflows with no holes.
- [x] Hovering or keyboard-focusing a hexagon makes it grow and shows the title and description, and clicking it or pressing Enter opens the entry.
- [ ] Reduced motion and dark mode have been checked (automated in Chrome; Safari and Firefox by hand).

## Feature: Home-page "latest outcomes" from cv_inputs.xlsx (Sept 2026)

**What it does**

The three cards at the foot of the Home page (Latest Publication / Active
Research / Data Visualisation) are no longer typed by hand into `index.qmd`.
Each is picked from `cv_inputs.xlsx` — the same workbook that feeds the CV, the
About-page counts and every Projects and Portfolio entry — so the Home page
cannot drift from the rest of the site.

**How each card is picked**

| Card | Sheet | Rows considered | Winner |
|---|---|---|---|
| 01 Latest Publication | `publications` | every row | `highlight` TRUE, newest `date` |
| 02 Active Research | `projects` | `draft` not TRUE | `highlight` TRUE, newest `date` |
| 03 Data Visualisation | `portfolio` | `draft` not TRUE **and** `type` = `Visualisation` | `highlight` TRUE, newest `date` |

One rule, three times: drop the rows that cannot be shown, sort highlighted
first and newest first, take the top one.

- Mark one row `highlight` TRUE and it is the card.
- Mark several TRUE and the newest of them wins.
- Mark none TRUE and the newest row wins anyway, so a card is never empty.

Two practical details:

- **Drafts are skipped.** `_quarto.yml` sets `draft-mode: gone`, so a draft
  entry renders as an empty page and linking the Home page to one is a dead
  end. Set `draft` FALSE in the sheet to make an entry eligible.
- **Either spelling of the column works** (`highlight` or `highlighted`) and
  either value style (TRUE / YES / 1), because the `publications` sheet has
  used both.

**Where each card links**

- Publication → the paper itself (`url`, else `doi`, prefixed with
  `https://doi.org/` when the cell is a bare DOI), opening in a new tab.
  Falls back to `publications.html`; publications have no page of their own.
- Project → `projects/<slug>.html`
- Visualisation → `portfolio/<slug>/`

**What each card shows**

Title, then a one-line meta: `venue · year` for the publication,
`pub-journal` (else title-cased `status`) `· year` for the project,
`subtype · year` for the visualisation. Dates arrive from Excel as real dates,
as 5-digit serial numbers, or as a bare year; all three are read.

**How it's built**

- `R/home-helpers.R` holds the rule and emits the existing `.split-3` markup
  as Quarto fenced divs, the same shape `R/cv-helpers.R` uses. It replaced an
  earlier dead version of the file that read `.qmd` frontmatter and emitted a
  `.home-card` layout `index.qmd` never used.
- `index.qmd` has `execute: freeze: auto`, a hidden setup chunk that sources
  the helper, and one `results: asis` chunk. The hero above it is untouched.
- `_freeze/index/` is committed (already un-ignored in `.gitignore`) so GitHub
  Actions publishes without ever reading the private `cv_inputs.xlsx`.
- No new CSS, no new classes, no new dependency: `readxl` was already in use.
- `Rscript R/home-helpers.R` runs a self-check of the picking rule against
  made-up rows — no workbook, no render needed.

**Gotcha: the sheet is the source of truth, the `.qmd` files are the copy**

Editing a cell does not change the entry on disk until `Rscript
R/xlsx-to-entries.R` is run, but the Home cards read the workbook directly. So
a Home card can name something the entry page still contradicts. As of Sept
2026 the two have drifted: 14 portfolio `image` cells have lost their `.svg`
extension, and running the sync would break those thumbnails. Fix the image
cells before running it.

**Done when**

- [x] `quarto render index.qmd` succeeds with no errors.
- [x] The three cards match the highlighted rows in the workbook.
- [x] Every card's link opens a real page (no draft, no 404).
- [x] `Rscript R/home-helpers.R` passes.
- [ ] `_freeze/index/execute-results/html.json` is committed.

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
- [ ] Default visual matches the editorial design from `Edgar Portfolio.html` side-by-side: same typography (EB Garamond / Switzer / Commit Mono), same palette (`mp085-light` Lighthouse), same two-column splits with rule dividers, same `01 — Section` numerals, same button styles.
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
