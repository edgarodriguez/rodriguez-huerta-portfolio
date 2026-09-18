# Feasibility: ASCII header field + hex listings

Preview: from the project root run `python3 -m http.server 8765`, then open
http://localhost:8765/_site/proto-index.html (also proto-projects, proto-portfolio, proto-about, …).
After any JS edit in `_prototypes/`, rebuild with `python3 _prototypes/build.py`; CSS edits only need a browser reload.

## Baseline console
All 9 live pages (index, about, projects, publications, portfolio, conferences, blog, cv, cv-negative):
no `CONSOLE` messages at all (Google Analytics hosts blocked in headless runs).

## Checks
| # | Check | How | Pass when | Result | Notes |
|---|---|---|---|---|---|
| A1 | Field attaches to the first header on all 9 pages | DOM dump loop (Task 3) | every page shows `headers=1` and `chars` > 1000 | PASS | 9/9 pages have exactly one host; Home = the whole page `#quarto-content` (margins included) |
| A2 | Frame renders as rows of characters | screenshots | neat rows, no wrapping, fills the header | PASS | frame over-fills every host (glyph measured 4.8px, cell guess 4.4px). `proto-*-1440.png` |
| A3 | The field doesn't change the layout | before/after screenshots | text, rules and spacing identical | PASS | boxes identical with and without the field on each preview page: 9 pages at 1440px, index/projects/about at 400px |
| A4 | Hidden from screen readers | DevTools → Elements → header → Accessibility pane | no accessible text from `::before` | PASS | plasma text absent from Chrome's full accessibility tree on all 9 pages |
| A5 | Frame cost | DevTools → Performance, 5 s on proto-index at 1440×900 | no long tasks; frame work < 8 ms | PASS (after fixes) | Home, whole page: 1440×900 → 31,800 cells, ~4.1 ms; 1920×1080 → 51,200 cells, 6.2–6.5 ms over 3 runs; 0 long tasks, 15 fps. Fixes: no kerning/ligatures/calt; only on-screen rows drawn; warp computed per row/column; measured 0.6em cell width |
| A6 | Reduced motion | `--force-prefers-reduced-motion` screenshots 2 s apart | identical still frame | PASS | reduced motion: 0 redraws in 1.5 s |
| A7 | Dark mode | click ● in the navbar | glyphs recolour instantly and stay subtle | PASS | glyphs are `--rule` + 12% `--ink`; dark = oklch(0.37 0.006 93) instantly. `proto-about-1440-dark.png` |
| A8 | Pauses off-screen | Performance recording while scrolled past the header | no `draw` calls | PASS | blog scrolled past header: 0 redraws in 1.5 s |
| A9 | Home field covers the whole page | host box vs viewport | full width, contains hero and cards | PASS | `#quarto-content`, x 0→1440 of 1440 |
| H1 | Honeycomb built from Quarto's markup | screenshots 400/900/1440 | offset rows, even gaps | PASS | honeycomb, no side padding: Portfolio 4 columns (273px tiles at 1440, 203px at 900, 2 × 140px at 400); Projects 3 columns (368 / 275, 2 × 160px at 400) |
| H2 | Same hexagon as the logo | zoom next to the navbar logo | same corners, same orientation | PASS | identical outline and 1.0804 ratio. `h2-logo.png` vs `h2-tile.png` |
| H3 | Filters reflow | `#Code`, `#Visualisation`, `#Supply%20Chains` screenshots | only matching hexes, no holes | PASS (after change) | #Code 1/1, #Visualisation 12/12, #Supply Chains 1/1, honeycomb intact. The CSS-only float version failed #Visualisation (last row unshifted, hanging 208px below the list); replaced by `hexRows()` JS. `hex-portfolio-filter-viz.png` |
| H4 | Portfolio sub-filter row | click Visualisation → a subtype | row appears and filters correctly | PASS | Visualisation → Infographic: 1/1 visible, honeycomb intact. `hex-portfolio-filter-sub.png` |
| H5 | Hover grow/shrink | mouse | grows, title + description show, shrinks on leave, no flicker | PASS | every tile (5 projects, 18 portfolio) grows to 1.15 at 1440 and 900 and shrinks on leave. `hex-*-hover.png` |
| H6 | Only the hexagon itself reacts | hover the gap between three hexes | nothing reacts | PASS | gap between tiles hits nothing; a lower tile's box corner hits the hexagon you actually see |
| H7 | Keyboard | Tab through tiles | focused hex grows, title underlined in accent, Enter opens entry | PASS | Tab → first tile grows, title underlined in accent; Enter opens project-clidewo.html. `hex-projects-keyboard.png` |
| H8 | Status badge | proto-projects | inside the hexagon, readable, clicks pass through | PASS | 5/5 badges inside their hexagon, 5/5 let clicks through |
| H9 | Touch | DevTools device toolbar → iPhone | titles visible without hover | PASS | touch emulation: titles shown on 5/5 projects and 18/18 portfolio. `hex-*-400-touch.png` |
| H10 | Text fits | longest title (CLIDEWO) at 1440 and 400 | nothing spills outside the hexagon | PASS | text box and its text inside the hexagon on every tile at 1440 and 900 (hover) and 400 (touch) |
| H11 | No half-cut lines | hover every tile at 1440 and 900 | title/description are whole lines and fit the veil | PASS | 46/46 hovers; the cut last line was a flex-squeezed line clamp (fixed with `flex-shrink: 0`, title size from tile width, description hidden on tiles < 250px) |
| A10 | Home glyphs lighter | computed ::before colour | `--rule` + 5% `--ink` | PASS | oklch(0.80 0.013 164) |
| F1 | Navbar name weight | computed style + loaded faces | Averia Serif Libre 300, Light face loaded | PASS | |
| H12 | Hover band | computed style on every hover | full tile width, glass (backdrop blur), no border | PASS | 46/46 hovers; `glass-*.png` close-ups |
| X1 | No new console errors | console loop (Task 5) | only baseline messages | PASS | no console errors or exceptions on any preview page (both check suites) |
| X2 | Size of change | `git diff --no-index --stat` | JS ≤ 70 added lines; CSS net ≤ +20 lines | CSS PASS / JS over | styles.css +200 / −184 (net +16); after-body.html +123 (ASCII field 84, hex rows 39); head.html +3 / −6 |

## Verdict
- **ASCII field: GO.** A1–A8 pass in Chrome.
- **Hex listings: GO with option A** (the user chose it on 11 Sep): the honeycomb via `hexRows()` (39 lines of JS). H1–H11 pass.
- **Round 2 (user feedback, 11 Sep):**
  - ASCII glyphs: a little more contrast (`--rule` + 12% `--ink`).
  - Home: the field spans both hero columns; the hero now paints the right panel's fill itself.
  - Listings: no side padding; 4 columns on Portfolio, 3 on Projects.
  - Hover: grows to 1.15. Title size follows the tile; no cut lines. The veil is dense in the middle and thin at the rim, so the figure shows in colour.
  - Dark mode: tiles at rest are `--muted` grey with a faint thumbnail wash.
- **Round 3 (user feedback, 11 Sep):**
  - Home field covers the whole page, margins included. It fades from 35% on the left to full strength, and the Coming-soon panel fill is now 60% translucent so the field shows through.
  - Hover: a centred paper box with a hairline border (like the status badges) holds title + description; the rest of the hexagon shows the figure in full colour. Quarto's `.post-contents { height: 100% }` needed `height: auto !important`.
  - Fonts: DM Sans + Averia Serif Libre from one Google Fonts request (`_prototypes/head.html`), replacing Switzer (Fontshare) and EB Garamond. `build.py` now swaps the head include too.
  - Thumbnail: `assets/images/img-solarPV-profile.webp` (118 KB, 800×1000) replaces the 22 MB SVG in `portfolio/viz-semsj-country-profile/index.qmd`. The old path's case (`solarpv` vs `solarPV`) would 404 on GitHub Pages. The SVG is still on disk, pending the user's OK to delete.
- **Round 4 (user feedback, 11 Sep):**
  - Hover band spans the full tile width (the hexagon's edges cut its ends), with no border and a glass look: 65% paper + `backdrop-filter: blur(10px) saturate(1.3)`. The description is ink-based (78% ink), because `--muted` disappeared on the dark glass.
  - Home glyphs are lighter again (`--rule` + 5% `--ink`).
  - The navbar name uses Averia Serif Libre Light (300), now loaded in `head.html`.
- **Still to check by hand:** Safari and Firefox.
- **Load time (not caused by this feature):** Fontshare's CSS stalled 30 s+ during testing (three `curl` timeouts), keeping pages "loading" for up to ~73 s. `assets/images/img-solarpv-profile.svg` is 22 MB (the Portfolio page downloads ~25 MB). The ASCII field costs ~3 ms per frame and starts after the page is parsed.

Re-run everything: `node _prototypes/check-ascii.mjs && node _prototypes/check-hex.mjs` (preview server on :8765).
