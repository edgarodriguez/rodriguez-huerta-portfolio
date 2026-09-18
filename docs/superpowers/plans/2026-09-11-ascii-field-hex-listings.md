# ASCII Header Field + Hex Listings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an ambient ASCII-plasma field behind the first header of every top-level page, and turn the Projects and Portfolio grids into a filterable honeycomb of the logo's rounded hexagon. Both are proven first in isolated preview pages, then applied without touching any content file.

**Architecture:** Both features only change how existing markup looks. The plasma is one new section in the site's single script (`_includes/after-body.html`). It writes each frame into a `data-ascii` attribute, and a CSS `::before` prints it, so no DOM nodes are added and no layout rule sees it. The honeycomb is pure CSS on Quarto's own grid-listing markup. It *replaces* the old card-grid block in `styles.css`. Row offsets come from a floated `shape-outside`, not `:nth-child`, so the existing filter script works unchanged. All work happens first in `_prototypes/` copies of the two files, previewed through real rendered pages (`_site/proto-*.html`). Applying means copying the approved files back.

**Tech Stack:** Quarto 1.7 static site; hand-written CSS (`clip-path`, `shape-outside`, `mask-image`, `:has`, `color-mix`, `scale`); vanilla ES5-style JS (`ResizeObserver`, `IntersectionObserver`, `requestAnimationFrame`); Python 3 (preview builder); headless Google Chrome (screenshots, DOM dumps, console capture).

**Spec:** `project_specs.md` → section "Feature: ASCII header field + hex listings". It is written in Task 1; the full text is in Task 1 Step 5.

## Global Constraints

- No new dependencies: no JS/CSS libraries, no new CDN links, no Quarto extensions, no custom listing templates (EJS).
- Zero edits to any `.qmd` file, anything in `R/`, or `_quarto.yml`. In the repo, only `styles.css`, `_includes/after-body.html`, `project_specs.md` and `.impeccable.md` change.
- JS matches `_includes/after-body.html`: it goes inside the existing IIFE as one `// ── NAME ───` section and uses `var` and function declarations. No modules, arrow functions or classes.
- CSS uses existing tokens only: `--ink --paper --rule --muted --subtle --accent --font-serif --font-sans --font-mono --ease-out-expo --pad`. No new colours. New sections get the same `/* ==== */` banner comments as the rest of the file.
- Replace, don't override: delete the old rectangular card-grid rules; don't neutralise them with more `!important`.
- Respect `prefers-reduced-motion`: show a still frame and use no transitions.
- Do not copy code from asciiart.eu (its licence forbids reuse) or from motion.dev. The plasma is our own implementation of the standard sine plasma.
- Git: the working tree holds unrelated uncommitted work. Never run `git add -A` or `git add .`. Commit only with explicit paths: `git commit -F - -- <paths>`. Never commit `_prototypes/`, `_site/` or `_freeze/`. Never push, because pushing `main` deploys the live site.
- Target browsers: current Chrome, Safari and Firefox.

---

## Desk feasibility (checked while writing this plan)

| Question | Finding | Evidence |
|---|---|---|
| Can the hex grid reuse Quarto's markup? | Yes. Both pages render `.list.grid > .g-col-1 > a.quarto-grid-link > .quarto-grid-item > p.card-img-top + .card-body`. Only `projects.qmd` and `portfolio.qmd` use `type: grid`. | `_site/projects.html`, `_site/portfolio.html` |
| Will the filters keep working? | Yes, with no change. The filter script only sets `style.display` on `.g-col-1` and reads `data-categories` / `.card-other-values`, which all stay in the DOM. A float-based honeycomb reflows around hidden tiles. No pagination: 18 portfolio items, 8 projects. | `_includes/after-body.html` FILTER UI section |
| Same hexagon as the logo? | Yes. The logo is a pointy-top hexagon (circumradius 30) with corners rounded by a 48px round-join stroke. It's traced to a 42-point percentage polygon (Task 4, Appendix); height/width = 1.0804. | `assets/icons/*-6gon-120.svg`, logo SVG in after-body |
| Where does the plasma go? | On the first match of `.split-2-fullh > :last-child, .listing-header, .page-band, .cv-page-header`. That covers all 9 top-level pages; no detail page uses these classes. On Home it is the hero's right-hand panel, which keeps its `--subtle` fill (the field paints above a host's own background). | grep over `*.qmd` and `R/cv-helpers.R` |
| Why `::before` and not a `<pre>` child? | The Home hero's columns rely on `.split-2-fullh > *`, `:first-child`, `:last-child` and `.scroll-hint + *` rules, so any injected child would break them. Those selectors can't see a pseudo-element, and none of the four header classes already uses `::before`. | `styles.css` lines 404–420 |
| Can the reference code be reused? | No. asciiart.eu reserves all rights to its code. The motion.dev header (a canvas with 18px cells on a solid colour band) is a visual reference only; its colours are not used. | asciiart.eu credits section; motion.dev/examples markup |
| Use asciify-engine (asciify.org) instead? | No. The code is MIT and clean (no tracking, no `eval`; one `fetch` only for GIF URLs you pass it). But it has one maintainer, no signed releases, 38 stars, and 126 versions in 7 months, four of them major versions released on 9 Sep 2026. Its README says "zero dependencies" while its package lists four. Its backgrounds are a downloaded template that adds a `<canvas>` child (which breaks the Home hero's layout rules), takes hex colours and follows the OS theme instead of the site's toggle. That means more glue code than the ~60 lines it would replace. Its "fluid" motion is copied in spirit by a domain warp in our own plasma (Task 3). | npm registry, GitHub API, package source |
| Can the previews match the real site exactly? | Yes. Quarto copies `after-body.html` into each page unchanged and links `href="styles.css"`, so a script can swap in the candidate files. 5 of the 9 pages in `_site/` are stale builds from 19 Aug, so render first. | python check on `_site/*.html` |
| Tooling for checks | Headless Chrome works for screenshots, DOM dumps and console capture (tested). | probe run |
| Design-system conflict | `.impeccable.md` says motion must "never loop". The plasma loops, so it stays quiet (rule-coloured, paused off-screen, a still frame under reduced motion), and that principle gets a one-line exception (Task 6). | `.impeccable.md` principle 3 |
| Clash with work in progress | `styles.css` and `_includes/after-body.html` have uncommitted portfolio sub-filter edits. Commit them first, or this feature's commit would include them. | `git status` |

**Verdict:** both features look feasible with 1 new JS section, 1 new CSS section, 1 replaced CSS block and 3 small CSS edits. Tasks 2–5 test this in a browser before anything is applied.

## Decisions baked in (change them at the Task 1 gate if wrong)

1. The plasma appears on the 9 top-level pages only, not on single project/post pages or the 404 page.
2. The field sits on the right of each header and fades out under the text on the left. On Home, the right "Coming soon" panel keep its `--subtle` fill so the field shows there.
3. Glyphs are `--rule`-coloured on the normal paper background, in 8px Commit Mono cells at ~15 fps, using the ramp ` .:-=+*\/–·` minimal colour change from `--paper`. There's no cursor interaction because "motion is a whisper".
4. A hexagon at rest shows a faint greyscale thumbnail on `--subtle` (the existing image filter is kept). On hover or keyboard focus it grows 10% and shows the title and description (clamped to 4 lines) on a 92% paper veil. Categories are hidden inside the hexagon but still drive the filters.
5. Hex sizes scale with the viewport: Projects 160–300px wide, Portfolio 150–230px. Descriptions are hidden below a 900px viewport, and touch screens show titles all the time.
6. The project status badge moves to the top centre of its hexagon.

## File map

| File | Status | Responsibility |
|---|---|---|
| `project_specs.md` | modify (Task 1) | Feature spec and "done" checklist (approval gate) |
| `_prototypes/styles.css` | create (Task 2), edit (Tasks 3–4) | Candidate full stylesheet, i.e. the future `styles.css` |
| `_prototypes/after-body.html` | create (Task 2), edit (Task 3) | Candidate full script, i.e. the future `_includes/after-body.html` |
| `_prototypes/build.py` | create (Task 2) | Builds `_site/proto-<page>.html` from the real rendered pages with the candidates swapped in |
| `_prototypes/ascii-field.css` | create (Task 3) | New ASCII FIELD block, spliced into the candidate stylesheet |
| `_prototypes/hex-listing.css` | create (Task 4) | New HEX LISTING block, spliced into the candidate stylesheet |
| `_prototypes/FEASIBILITY.md` | create (Task 2), fill (Tasks 3–5) | Result of each check, plus GO/NO-GO |
| `_prototypes/shots/` | create (Task 2) | Screenshots |
| `styles.css`, `_includes/after-body.html` | overwrite (Task 6) | Copied from the approved candidates |
| `.impeccable.md` | modify (Task 6) | One-line exception to "never loop" |

`_prototypes/` starts with `_`, so Quarto never renders or publishes it. Task 6 deletes it.

**Headless Chrome:** every command blocks Google Analytics (`HL` flags). Without it, pages never settle and each run hangs, and test runs would count as visits in the site's analytics.

**Preview server (Tasks 3–6 need it):** `curl -sI http://localhost:8765/_site/proto-index.html | head -1` must print `HTTP/1.0 200 OK`. If it doesn't, run `python3 -m http.server 8765` in the background from the project root.

---

### Task 1: Spec entry and approval gate

**Files:**
- Modify: `project_specs.md` (Tech stack "Animation" row; new section before `## Data models`)

**Interfaces:**
- Consumes: nothing.
- Produces: the approved spec that Tasks 2–6 implement. Nothing else starts until the user approves it.

- [ ] **Step 1: Read the project rules**

Read `CLAUDE.md` and `project_specs.md` in full (CLAUDE.md Rule 1).

- [ ] **Step 2: Check the in-progress work is committed**

Run: `git diff --stat -- styles.css _includes/after-body.html`
Expected: no output.
If there is output, tell the user: "styles.css and _includes/after-body.html have uncommitted changes (the portfolio sub-filter). Please commit them before Task 6, otherwise this feature's commit would include them." Tasks 1–5 never commit these two files, so continue; Task 6 Step 1 enforces it.

- [ ] **Step 3: Create the branch**

Run: `git switch -c feat/ascii-hex`
Expected: `Switched to a new branch 'feat/ascii-hex'`. Uncommitted work elsewhere in the tree comes along untouched.

- [ ] **Step 4: Update the Animation row**

In `project_specs.md`, replace:
```markdown
| Animation | None (deferred) | Skipped for the first cut per user direction. |
```
with:
```markdown
| Animation | CSS + one vanilla-JS section in `_includes/after-body.html`; no libraries | Ambient ASCII field in page headers; hex listing expand on hover. |
```

- [ ] **Step 5: Add the feature section**

In `project_specs.md`, insert immediately before the line `## Data models`:
```markdown
## Feature: ASCII header field + hex listings (Sept 2026)

**What it does**
- **ASCII field**: a slow, low-contrast, fluid-moving plasma of small (8px) monospace characters behind the first header of each top-level page (Home hero, About, Projects, Publications, Portfolio, Conferences, Blog, CV, CV of Failures). On Home it fills the hero's right-hand panel, which keeps its `--subtle` fill. The header band on motion.dev/examples is a reference for the look only; all colours come from the site's own tokens. Glyphs use `--rule`, barely different from the paper, and fade out under the text. Single project/post pages and the 404 page get none.
- **Hex listings**: Projects and Portfolio show entries as a responsive honeycomb of the logo's hexagon (pointy-top, rounded corners). Hovering over a hexagon, or focusing it with the keyboard, makes it grow and reveals its title and description. Clicking opens the entry. The filter bars, including the portfolio sub-filter row, work as before.

**How it's built**
- One new section in `_includes/after-body.html` writes each plasma frame into a `data-ascii` attribute, and `styles.css` prints it with `::before`. No DOM nodes are added.
- The honeycomb is CSS applied to Quarto's own grid-listing markup. The old rectangular card-grid rules are deleted, not overridden.
- No changes to any `.qmd` file, `R/` script or `_quarto.yml`. No libraries, new CDN links or Quarto templates.
- The plasma is original code, because the asciiart.eu demo's licence forbids reusing its code.

**Behaviour rules**
- Reduced motion: one still frame, and hexagons change state without transitions.
- The plasma pauses while its header is off-screen or the tab is hidden.
- Touch screens (no hover): hexagon titles are always shown.
- The light/dark toggle recolours both features instantly (tokens only).
- Design exception: this is the site's one looping animation (`.impeccable.md` principle 3 amended).

**Process**
1. Isolated previews (`_site/proto-*.html`, built from `_prototypes/`) and a feasibility report. No source files change.
2. The user approves the previews.
3. Apply: copy the approved candidate files over `styles.css` and `_includes/after-body.html`.

**Done when**
- [ ] Every check in `_prototypes/FEASIBILITY.md` is PASS or has an accepted fallback.
- [ ] `quarto render` succeeds, all 9 top-level pages show the field in their first header, and there are no new console errors.
- [ ] Projects and Portfolio show the honeycomb at 400px, 900px and 1440px. Every filter button (and portfolio sub-filter) shows the right entries, and the honeycomb reflows with no holes.
- [ ] Hovering or keyboard-focusing a hexagon makes it grow and shows the title and description, and clicking it or pressing Enter opens the entry.
- [ ] Reduced motion and dark mode have been checked by hand.
```

- [ ] **Step 6: Show the file and wait**

Show the user the two changed parts of `project_specs.md` and the "Decisions baked in" list from this plan. STOP until the user approves (CLAUDE.md Rule 2). If they ask for changes, make them in both the spec and this plan before continuing.

- [ ] **Step 7: Commit**

```bash
git commit -F - -- project_specs.md <<'EOF'
docs: spec ASCII header field and hex listings

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
```
Expected: `1 file changed`.

---

### Task 2: Preview harness and baseline

**Files:**
- Create: `_prototypes/styles.css` (copy of `styles.css`)
- Create: `_prototypes/after-body.html` (copy of `_includes/after-body.html`)
- Create: `_prototypes/build.py`
- Create: `_prototypes/FEASIBILITY.md`
- Create: `_prototypes/shots/`

**Interfaces:**
- Consumes: the approved spec (Task 1).
- Produces: `python3 _prototypes/build.py`, which writes `_site/proto-<page>.html` for the 9 pages in `PAGES`, and the preview server at `http://localhost:8765/` (root = project root). Tasks 3–6 use both.

- [ ] **Step 1: Fresh full render**

Run: `quarto render`
Expected: finishes with `Output created: _site/index.html` and no `ERROR`. This takes a few minutes, because R reruns for pages whose source changed.
If it fails for a reason unrelated to this feature (an R package, a missing xlsx), STOP and report the error to the user. Don't fix it here.

- [ ] **Step 2: Make the candidate copies**

```bash
mkdir -p _prototypes/shots _prototypes/base
cp styles.css _prototypes/styles.css
cp _includes/after-body.html _prototypes/after-body.html
cp styles.css _includes/after-body.html _prototypes/base/   # snapshot: Task 6 checks nobody changed the originals since
```

- [ ] **Step 3: Write the preview builder**

Create `_prototypes/build.py`:
```python
"""Build throwaway preview pages: _site/proto-<page>.html.

Each preview is a real rendered page with the candidate stylesheet and
after-body script from _prototypes/ swapped in, so it shows exactly what the
site will look like after the change. Source files are never touched.
Run from the project root, after `quarto render`:  python3 _prototypes/build.py
"""
from pathlib import Path

PAGES = ["index", "about", "projects", "publications", "portfolio",
         "conferences", "blog", "cv", "cv-negative"]

old_js = Path("_includes/after-body.html").read_text().strip()
new_js = Path("_prototypes/after-body.html").read_text().strip()

for page in PAGES:
    html = Path(f"_site/{page}.html").read_text()
    assert 'href="styles.css"' in html, f"{page}: stylesheet link not found"
    assert old_js in html, f"{page}: after-body script not found, run `quarto render` first"
    html = html.replace('href="styles.css"', 'href="../_prototypes/styles.css"')
    html = html.replace(old_js, new_js)
    Path(f"_site/proto-{page}.html").write_text(html)
    print(f"built _site/proto-{page}.html")
```

- [ ] **Step 4: Run it**

Run: `python3 _prototypes/build.py`
Expected: 9 lines of `built _site/proto-<page>.html` and no `AssertionError`.

- [ ] **Step 5: Start the preview server**

Run in the background, from the project root: `python3 -m http.server 8765`
Open http://localhost:8765/_site/proto-projects.html. It must look identical to http://localhost:8765/_site/projects.html, because the candidates are still unmodified copies.

- [ ] **Step 6: Baseline console log**

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
HL=(--headless=new "--host-resolver-rules=MAP *.googletagmanager.com ~NOTFOUND, MAP *.google-analytics.com ~NOTFOUND" --timeout=15000)
for p in index about projects publications portfolio conferences blog cv cv-negative; do
  echo "== $p"
  "$CHROME" "${HL[@]}" --enable-logging=stderr --v=0 --virtual-time-budget=3000 \
    --dump-dom "http://localhost:8765/_site/$p.html" 2>&1 >/dev/null | grep "CONSOLE"
done
```
Expected: each page name, with any `CONSOLE` lines listed under it. Save this output in the "Baseline console" block of FEASIBILITY.md. These messages exist before the feature and don't count against it.

- [ ] **Step 7: Baseline screenshots**

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
HL=(--headless=new "--host-resolver-rules=MAP *.googletagmanager.com ~NOTFOUND, MAP *.google-analytics.com ~NOTFOUND" --timeout=15000)
for p in index projects portfolio; do
  "$CHROME" "${HL[@]}" --hide-scrollbars --window-size=1440,1800 --virtual-time-budget=4000 \
    --screenshot="_prototypes/shots/before-$p-1440.png" "http://localhost:8765/_site/$p.html" 2>/dev/null
done
ls _prototypes/shots
```
Expected: `before-index-1440.png before-portfolio-1440.png before-projects-1440.png`.

- [ ] **Step 8: Create the report skeleton**

Create `_prototypes/FEASIBILITY.md`:
```markdown
# Feasibility: ASCII header field + hex listings

Preview: from the project root run `python3 -m http.server 8765`, then open
http://localhost:8765/_site/proto-index.html (also proto-projects, proto-portfolio, proto-about, …).
After any JS edit in `_prototypes/`, rebuild with `python3 _prototypes/build.py`; CSS edits only need a browser reload.

## Baseline console
(paste the Task 2 Step 6 output here)

## Checks
| # | Check | How | Pass when | Result | Notes |
|---|---|---|---|---|---|
| A1 | Field attaches to the first header on all 9 pages | DOM dump loop (Task 3) | every page shows `headers=1` and `chars` > 1000 | | |
| A2 | Frame renders as rows of characters | screenshots | neat rows, no wrapping, fills the header | | |
| A3 | The field doesn't change the layout | before/after screenshots | text, rules and spacing identical | | |
| A4 | Hidden from screen readers | DevTools → Elements → header → Accessibility pane | no accessible text from `::before` | | |
| A5 | Frame cost | DevTools → Performance, 5 s on proto-index at 1440×900 | no long tasks; frame work < 8 ms | | |
| A6 | Reduced motion | `--force-prefers-reduced-motion` screenshots 2 s apart | identical still frame | | |
| A7 | Dark mode | click ● in the navbar | glyphs recolour instantly and stay subtle | | |
| A8 | Pauses off-screen | Performance recording while scrolled past the header | no `draw` calls | | |
| H1 | Honeycomb built from Quarto's markup | screenshots 400/900/1440 | offset rows, even gaps | | |
| H2 | Same hexagon as the logo | zoom next to the navbar logo | same corners, same orientation | | |
| H3 | Filters reflow | `#Code`, `#Visualisation`, `#Supply%20Chains` screenshots | only matching hexes, no holes | | |
| H4 | Portfolio sub-filter row | click Visualisation → a subtype | row appears and filters correctly | | |
| H5 | Hover grow/shrink | mouse | grows, title + description show, shrinks on leave, no flicker | | |
| H6 | Only the hexagon itself reacts | hover the gap between three hexes | nothing reacts | | |
| H7 | Keyboard | Tab through tiles | focused hex grows, title underlined in accent, Enter opens entry | | |
| H8 | Status badge | proto-projects | inside the hexagon, readable, clicks pass through | | |
| H9 | Touch | DevTools device toolbar → iPhone | titles visible without hover | | |
| H10 | Text fits | longest title (CLIDEWO) at 1440 and 400 | nothing spills outside the hexagon | | |
| X1 | No new console errors | console loop (Task 5) | only baseline messages | | |
| X2 | Size of change | `git diff --no-index --stat` | JS ≤ 70 added lines; CSS net ≤ +20 lines | | |

## Verdict
(written in Task 5)
```

- [ ] **Step 9: No commit**

`_prototypes/` is throwaway and never committed, so there's nothing to commit in this task.

---

### Task 3: ASCII field prototype

**Files:**
- Modify: `_prototypes/after-body.html` (new section before `// ── STAGGER DELAYS`)
- Create: `_prototypes/ascii-field.css`
- Modify: `_prototypes/styles.css` (splice in the new block before the `GRID COLOR TRANSITION` banner)
- Modify: `_prototypes/FEASIBILITY.md` (results A1–A8)

**Interfaces:**
- Consumes: `reducedMotion()`, already defined in the MOTION HELPERS section of the same IIFE (returns `true` when the user prefers reduced motion); the harness and preview server from Task 2.
- Produces: the CSS hook `.has-ascii` (a class JS adds to the chosen header) and the attribute `data-ascii` (the frame, with rows separated by `\n`). The constants `ASCII_CELL_H = 8` and `ASCII_CELL_W = 8 * 0.55` must stay in sync with the `.has-ascii::before` font (8px/8px).

- [ ] **Step 1: Write the failing check**

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
HL=(--headless=new "--host-resolver-rules=MAP *.googletagmanager.com ~NOTFOUND, MAP *.google-analytics.com ~NOTFOUND" --timeout=15000)
for p in index about projects publications portfolio conferences blog cv cv-negative; do
  dom=$("$CHROME" "${HL[@]}" --virtual-time-budget=3000 --dump-dom "http://localhost:8765/_site/proto-$p.html" 2>/dev/null)
  echo "$p headers=$(grep -c 'class="[^"]*has-ascii' <<<"$dom") chars=$(tr -d '\n' <<<"$dom" | grep -o 'data-ascii="[^"]*"' | wc -c | tr -d ' ')"
done
```

- [ ] **Step 2: Run it to see it fail**

Expected: every line shows `headers=0 chars=0`.

- [ ] **Step 3: Add the JS section**

In `_prototypes/after-body.html`, insert immediately before the line `  // ── STAGGER DELAYS ───────────────────────────────────────────`:
```js
  // ── ASCII FIELD ──────────────────────────────────────────────────
  // Ambient plasma behind the first page header (home hero's right
  // panel, listing headers, page bands, CV header). Our own version of
  // the classic demoscene sine plasma, with a domain warp so it flows
  // like liquid: the asciiart.eu demo it is modelled on is not licensed
  // for reuse. Each frame is one string written to the header's
  // data-ascii attribute and printed by `.has-ascii::before` in
  // styles.css, so no DOM nodes are added. ~15 fps, idle off-screen, a
  // single still frame under reduced motion.
  var ASCII_RAMP   = ' .:-=+*\\/–·';   // low values → high values
  var ASCII_CELL_H = 8;               // px, must match the ::before font-size / line-height
  // ponytail: guessed glyph width, a bit narrow on purpose so the field
  // over-fills and overflow:hidden crops it. Measure it if edges ever show.
  var ASCII_CELL_W = 8 * 0.55;

  function asciiFrame(cols, rows, t) {
    var out = '', top = ASCII_RAMP.length - 1;
    for (var y = 0; y < rows; y++) {
      var py = y * ASCII_CELL_H / 24;   // 24px units: wave size stays put whatever the cell size
      for (var x = 0; x < cols; x++) {
        var px = x * ASCII_CELL_W / 24;
        // Domain warp: bend the coordinates before sampling so the bands flow like liquid.
        var wx = px + Math.sin(py * 0.7 + t * 0.9) * 1.2;
        var wy = py + Math.cos(px * 0.6 - t * 0.7) * 1.2;
        var v = Math.sin(wx * 0.9 + t)
              + Math.sin(wy * 1.1 - t * 0.8)
              + Math.sin((wx + wy) * 0.6 + t * 0.5)
              + Math.sin(Math.sqrt(wx * wx + wy * wy) * 0.8 - t * 1.2);   // -4 … 4
        out += ASCII_RAMP.charAt(Math.round((v + 4) / 8 * top));
      }
      out += '\n';
    }
    return out;
  }

  function initAsciiField() {
    var el = document.querySelector('.split-2-fullh > :last-child, .listing-header, .page-band, .cv-page-header');
    if (!el || !window.ResizeObserver) return;
    el.classList.add('has-ascii');

    var cols = 0, rows = 0, t = 0, last = 0, visible = true;
    function draw() { el.setAttribute('data-ascii', asciiFrame(cols, rows, t)); }

    // Fires once on observe, so it also paints the first (or only) frame.
    new ResizeObserver(function () {
      cols = Math.ceil(el.clientWidth / ASCII_CELL_W);
      rows = Math.ceil(el.clientHeight / ASCII_CELL_H);
      draw();
    }).observe(el);
    if (reducedMotion()) return;

    new IntersectionObserver(function (entries) {
      visible = entries[entries.length - 1].isIntersecting;
    }).observe(el);

    requestAnimationFrame(function tick(now) {
      requestAnimationFrame(tick);
      if (!visible || now - last < 66) return;   // ~15 fps; rAF already sleeps in hidden tabs
      last = now;
      t = now * 0.0006;
      draw();
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAsciiField);
  } else {
    initAsciiField();
  }

```

- [ ] **Step 4: Write the CSS block**

Create `_prototypes/ascii-field.css`:
```css
/* ============================================================
   ASCII FIELD — ambient plasma behind the first page header
   initAsciiField() in after-body.html adds .has-ascii to the header
   and writes one frame of characters into its data-ascii attribute;
   the ::before below prints it. A pseudo-element, not a child node,
   so the headers' `> *` / :first-child layout rules never see it.
   Glyphs use --rule: the field reads as texture, never as content.
   ============================================================ */
.has-ascii {
  position: relative;
  isolation: isolate;   /* the z-index:-1 field paints above the header's own background */
  overflow: hidden;
}
.has-ascii::before {
  content: attr(data-ascii) / "";   /* `/ ""` = decorative; screen readers skip it */
  position: absolute;
  inset: 0;
  z-index: -1;
  white-space: pre;
  font: 8px/8px var(--font-mono);   /* keep in sync with ASCII_CELL_* in after-body.html */
  /* Plain glyphs only: kerning, ligatures and contextual alternates make
     every frame's text layout far more expensive for no visible gain. */
  font-kerning: none;
  font-variant-ligatures: none;
  font-feature-settings: "calt" 0, "liga" 0;
  text-rendering: optimizeSpeed;
  color: var(--rule);
  pointer-events: none;
  /* The field lives on the right; the text column stays on clean paper. */
  mask-image: linear-gradient(to right, transparent 20%, #000 80%);
}

```
Note: browsers that don't support `content: … / ""` drop the whole declaration and show no field, which is a safe failure.

- [ ] **Step 5: Splice it in before the GRID COLOR TRANSITION section**

```bash
python3 - <<'EOF'
from pathlib import Path
p = Path("_prototypes/styles.css")
css = p.read_text()
at = css.rindex("/*", 0, css.index("GRID COLOR TRANSITION"))
p.write_text(css[:at] + Path("_prototypes/ascii-field.css").read_text() + css[at:])
print("inserted at line", css[:at].count("\n") + 1)
EOF
```
Expected: `inserted at line 1026` or close to it (the opening line of the GRID COLOR TRANSITION banner).

- [ ] **Step 6: Rebuild and run the check**

Run `python3 _prototypes/build.py`, then run the Step 1 loop again.
Expected: every line shows `headers=1`, with `chars` well above 1000 (8px cells: ~15,000 on Home).

- [ ] **Step 7: Screenshots (normal and reduced motion)**

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
HL=(--headless=new "--host-resolver-rules=MAP *.googletagmanager.com ~NOTFOUND, MAP *.google-analytics.com ~NOTFOUND" --timeout=15000)
for p in proto-index proto-about proto-projects proto-cv; do
  for size in 400,900 1440,900; do
    "$CHROME" "${HL[@]}" --hide-scrollbars --window-size=$size --virtual-time-budget=4000 \
      --screenshot="_prototypes/shots/$p-${size%%,*}.png" "http://localhost:8765/_site/$p.html" 2>/dev/null
  done
done
for b in 2000 4000; do
  "$CHROME" "${HL[@]}" --hide-scrollbars --force-prefers-reduced-motion --window-size=1440,900 \
    --virtual-time-budget=$b --screenshot="_prototypes/shots/proto-index-reduced-$b.png" \
    "http://localhost:8765/_site/proto-index.html" 2>/dev/null
done
cmp _prototypes/shots/proto-index-reduced-2000.png _prototypes/shots/proto-index-reduced-4000.png && echo "A6 still frame: PASS"
```
Expected: 8 normal screenshots, then `A6 still frame: PASS`. If `cmp` reports a difference, open both images: a difference only in the navbar logo is fine, but a changed field is a fail.
Open the screenshots and compare `proto-index-1440.png` with `before-index-1440.png`. Text, rules and spacing must be identical (A3), the Home right panel keeps its `--subtle` fill, and the field must sit in neat rows on the right (A2).

- [ ] **Step 8: Tune (only if the screenshots call for it)**

The only knobs to change are:
- the coefficients inside `asciiFrame`, including the warp amount `1.2`;
- the `mask-image` stops;
- `66` (the gap between frames, in ms);
- an `opacity` on `.has-ascii::before`, if the field reads too strong.

Rebuild after JS changes. Keep the glyph colour as `--rule` and the user's `ASCII_RAMP`.

- [ ] **Step 9: Manual checks A4, A5, A7, A8**

In Chrome at http://localhost:8765/_site/proto-index.html:
- A4: DevTools → Elements → select the hero's right panel (`.coming-soon-panel`) → Accessibility pane. Its name must not contain plasma characters.
- A5: DevTools → Performance → record 5 s in a 1440×900 window. There should be no red long-task markers, and Scripting + Rendering should stay under 8 ms per frame.
- A7: click ● in the navbar. The glyphs should switch to the dark `--rule` colour right away.
- A8: scroll to the bottom and record 3 s. There should be no `draw` calls in the flame chart.
Repeat A2 quickly in Safari and Firefox (open the same URL).

- [ ] **Step 10: Record results**

Fill rows A1–A8 in `_prototypes/FEASIBILITY.md` with PASS/FAIL and the screenshot names. No commit.

---

### Task 4: Hex listing prototype

**Files:**
- Create: `_prototypes/hex-listing.css`
- Modify: `_prototypes/styles.css` (replace the `QUARTO AUTO-LISTING` block; delete the outline rules; edit one focus selector and one reduced-motion line)
- Modify: `_prototypes/FEASIBILITY.md` (results H1–H10)

**Interfaces:**
- Consumes:
  - Quarto's grid markup: `.quarto-listing-container-grid > .list > .g-col-1 > a > .quarto-grid-item > p.card-img-top + .card-body`.
  - The `.listing-status` badges and `.filter-sub` row that the existing script creates.
  - The `itemReveal` entrance animation on `.g-col-1`. It animates `transform`, so the hover growth uses the separate `scale` property to avoid a clash.
  - The harness and preview server from Task 2.
- Produces: CSS custom properties on `.quarto-listing-container-grid`: `--hex-w` (tile width), `--hex-gap`, `--hex-h`, `--hex-row` (spacing between row centres) and `--hex-shape` (the logo polygon). `#listing-projects-listing` overrides `--hex-w`.

- [ ] **Step 1: Write the failing check (screenshots, including filters)**

Run as ONE command, because the `shoot` helper only exists inside it:
```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
HL=(--headless=new "--host-resolver-rules=MAP *.googletagmanager.com ~NOTFOUND, MAP *.google-analytics.com ~NOTFOUND" --timeout=15000)
shoot() { "$CHROME" "${HL[@]}" --hide-scrollbars --window-size=$2 --virtual-time-budget=4000 \
  --screenshot="_prototypes/shots/$3.png" "http://localhost:8765/_site/$1" 2>/dev/null; }
shoot proto-projects.html 400,1600 hex-projects-400
shoot proto-projects.html 900,1600 hex-projects-900
shoot proto-projects.html 1440,1400 hex-projects-1440
shoot proto-portfolio.html 400,2400 hex-portfolio-400
shoot proto-portfolio.html 900,2000 hex-portfolio-900
shoot proto-portfolio.html 1440,1400 hex-portfolio-1440
shoot 'proto-portfolio.html#Code' 1440,1200 hex-portfolio-filter-code
shoot 'proto-portfolio.html#Visualisation' 1440,1400 hex-portfolio-filter-viz
shoot 'proto-projects.html#Supply%20Chains' 1440,1200 hex-projects-filter-supply
ls _prototypes/shots | grep hex-
```

- [ ] **Step 2: Run it to see it fail**

Expected: 9 `hex-*.png` files that still show the old rectangular cards, so H1 fails.

- [ ] **Step 3: Write the new block**

Create `_prototypes/hex-listing.css`:
```css
/* ============================================================
   HEX LISTING (projects + portfolio pages)
   Quarto's own grid-listing markup laid out as a honeycomb of the
   navbar logo's hexagon (pointy-top, round-stroked corners):
     .quarto-listing-container-grid > .list > .g-col-1 > a.quarto-grid-link
       > .quarto-grid-item > p.card-img-top + .card-body
   Tiles are inline-blocks; a float whose shape-outside blocks every
   second line pushes those rows half a tile right. The offset comes
   from the float, not from :nth-child, so the filter bar can hide any
   tile (display:none) and the honeycomb simply reflows.
   ============================================================ */
.quarto-listing { padding: 0 !important; margin: 0 !important; }

.quarto-listing-container-grid {
  --hex-w:   clamp(150px, 17vw, 230px);                         /* flat side to flat side */
  --hex-gap: 10px;
  --hex-h:   calc(var(--hex-w) * 1.0804);                      /* the logo hexagon's height / width */
  --hex-row: calc(0.866 * (var(--hex-w) + var(--hex-gap)));    /* distance between row centres */
  /* The logo hexagon (polygon + 48px round stroke, as in assets/icons/*-6gon-120.svg)
     traced as a polygon in 10° steps per corner. Percentages, so it scales;
     clip-path (unlike a mask) also limits hover and clicks to the hexagon. */
  --hex-shape: polygon(38.0% 3.0%, 41.8% 1.3%, 45.8% 0.3%, 50.0% 0.0%, 54.2% 0.3%, 58.2% 1.3%, 62.0% 3.0%, 88.0% 16.9%, 91.4% 19.1%, 94.4% 21.8%, 96.8% 25.0%, 98.6% 28.5%, 99.6% 32.3%, 100.0% 36.1%, 100.0% 63.9%, 99.6% 67.7%, 98.6% 71.5%, 96.8% 75.0%, 94.4% 78.2%, 91.4% 80.9%, 88.0% 83.1%, 62.0% 97.0%, 58.2% 98.7%, 54.2% 99.7%, 50.0% 100.0%, 45.8% 99.7%, 41.8% 98.7%, 38.0% 97.0%, 12.0% 83.1%, 8.6% 80.9%, 5.6% 78.2%, 3.2% 75.0%, 1.4% 71.5%, 0.4% 67.7%, 0.0% 63.9%, 0.0% 36.1%, 0.4% 32.3%, 1.4% 28.5%, 3.2% 25.0%, 5.6% 21.8%, 8.6% 19.1%, 12.0% 16.9%);
  display: flex;                /* gives .list a definite height, so the float's % height works */
  padding: var(--pad) !important;
}
#listing-projects-listing { --hex-w: clamp(160px, 24vw, 300px); }

.quarto-listing-container-grid .list {
  display: block !important;    /* Bootstrap's .grid is display:grid */
  flex: 1;
  font-size: 0;                 /* no whitespace gaps between inline-block tiles */
  padding-bottom: calc(var(--hex-h) - var(--hex-row));   /* room for the last row's overlap */
}
.quarto-listing-container-grid .list::before {
  content: "";
  float: left;
  width: calc(var(--hex-w) / 2 + var(--hex-gap) / 2);
  height: 120%;
  shape-outside: repeating-linear-gradient(
    transparent 0 calc(2 * var(--hex-row) - 4px),
    #000 0 calc(2 * var(--hex-row) - 1px));
}

.quarto-listing-container-grid .g-col-1 {
  display: inline-block;
  vertical-align: top;
  position: relative;
  width: var(--hex-w);
  height: var(--hex-h);
  margin: 0 calc(var(--hex-gap) / 2) calc(var(--hex-row) - var(--hex-h));
  clip-path: var(--hex-shape);
  background: var(--subtle);
  font-size: 15px;
  transition: scale 0.5s var(--ease-out-expo);
}
/* `scale`, not `transform`: the itemReveal entrance animation owns transform. */
.quarto-listing-container-grid .g-col-1:hover,
.quarto-listing-container-grid .g-col-1:has(> a:focus-visible) { scale: 1.1; z-index: 2; }

.quarto-listing-container-grid .g-col-1 > a {
  display: block;
  height: 100%;
  color: inherit !important;
  text-decoration: none !important;
}
/* The grow + accent-underlined title is the focus cue; a rectangular ring would be clipped. */
.quarto-listing-container-grid .g-col-1 > a:focus-visible { outline: none; }

.quarto-listing-container-grid .quarto-grid-item {
  height: 100%;
  border: 0 !important;
  border-radius: 0 !important;
  background: transparent !important;
  box-shadow: none !important;
}
.quarto-listing-container-grid p.card-img-top { margin: 0 !important; height: 100%; }
.quarto-listing-container-grid p.card-img-top img {
  width: 100% !important;
  height: 100% !important;      /* beats Quarto's inline image-height */
  object-fit: cover !important;
  border-radius: 0 !important;
}

/* Title + description: hidden until the tile grows. */
.quarto-listing-container-grid .card-body {
  position: absolute !important;
  inset: 0;
  display: flex !important;
  flex-direction: column;
  justify-content: center;
  padding: 24% 15% !important;  /* % of width: keeps text inside the hexagon's straight sides */
  text-align: center;
  background: color-mix(in oklch, var(--paper) 92%, transparent) !important;
  border: 0 !important;
  opacity: 0;
  transition: opacity 0.35s var(--ease-out-expo);
}
.quarto-listing-container-grid .g-col-1:hover .card-body,
.quarto-listing-container-grid .g-col-1:has(> a:focus-visible) .card-body { opacity: 1; }

.quarto-listing-container-grid .listing-categories { display: none !important; }   /* still drive the filters */
.quarto-listing-container-grid .listing-title {
  font-family: var(--font-serif) !important;
  font-size: 17px !important;
  font-weight: 400 !important;
  line-height: 1.3 !important;
  color: var(--ink) !important;
  margin: 0 0 8px !important;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 3;
  overflow: hidden;
}
.quarto-listing-container-grid .g-col-1:has(> a:focus-visible) .listing-title {
  text-decoration: underline;
  text-decoration-color: var(--accent);
  text-underline-offset: 4px;
}
.quarto-listing-container-grid .listing-description,
.quarto-listing-container-grid .listing-description > p {
  font-family: var(--font-sans) !important;
  font-size: 12px !important;
  line-height: 1.5 !important;
  color: var(--muted) !important;
  margin: 0 !important;
}
.quarto-listing-container-grid .listing-description > p {
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 4;
  overflow: hidden;
}

/* Small tiles: title only. */
@media (max-width: 900px) {
  .quarto-listing-container-grid .listing-title { font-size: 14px !important; }
  .quarto-listing-container-grid .listing-description { display: none !important; }
}
/* No hover on touch screens: keep titles up over a faint image. */
@media (hover: none) {
  .quarto-listing-container-grid .card-body {
    opacity: 1;
    background: color-mix(in oklch, var(--paper) 80%, transparent) !important;
  }
  .quarto-listing-container-grid .listing-description { display: none !important; }
}

/* Quarto prints custom listing fields (status, type, subtype) into this
   table — hide it; the after-body script reads it for badges and filters. */
.card-other-values { display: none; }

/* Project status badge — top-centre of each project hexagon, created by
   the after-body script from the project's status field. */
.listing-status {
  position: absolute;
  top: 10%;
  left: 50%;
  transform: translateX(-50%);
  z-index: 3;
  pointer-events: none;         /* clicks go to the tile's link */
  display: flex;
  align-items: center;
  gap: 6px;
  white-space: nowrap;
  font-family: var(--font-mono);
  font-size: 11px;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--muted);
  background: var(--paper);
  border: 1px solid var(--rule);
  padding: 4px 9px;
}
.listing-status::before {
  content: "";
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--accent);
  flex-shrink: 0;
}
.listing-status[data-state="closed"]::before {
  background: transparent;
  border: 1px solid var(--muted);
}

```

- [ ] **Step 4: Splice it in place of the old card-grid block**

```bash
python3 - <<'EOF'
from pathlib import Path
p = Path("_prototypes/styles.css")
css = p.read_text()
start = css.rindex("/*", 0, css.index("QUARTO AUTO-LISTING (projects + portfolio pages)"))
end = css.rindex("/*", 0, css.index("QUARTO FENCED-DIV CONTENT"))
p.write_text(css[:start] + Path("_prototypes/hex-listing.css").read_text() + css[end:])
print("replaced", css[start:end].count("\n"), "old lines")
EOF
```
Expected: `replaced 209 old lines`, give or take a few. That's the whole block, from the `QUARTO AUTO-LISTING` banner up to just before the `QUARTO FENCED-DIV CONTENT` banner.

- [ ] **Step 5: Delete the rectangular hover outline**

In the GRID COLOR TRANSITION section of `_prototypes/styles.css`, delete:
```css
.quarto-listing-container-grid .quarto-grid-item {
  outline: 1px solid transparent;
  outline-offset: -1px;
  transition: background 0.35s, outline-color 0.35s;
}
.quarto-listing-container-grid .g-col-1:hover .quarto-grid-item {
  outline-color: var(--accent);
}
```
Keep the greyscale-to-colour image rules above it, because the hexagons still use them.

- [ ] **Step 6: Remove grid cards from the inset focus-ring rule**

In the KEYBOARD FOCUS section, delete this one line (the hex block handles focus itself):
```css
.quarto-listing-container-grid .g-col-1 > a:focus-visible,
```

- [ ] **Step 7: Reduced motion: no transitions on tiles**

In the REDUCED MOTION section, replace:
```css
  .quarto-listing-container-grid .g-col-1 { animation: none !important; }
```
with:
```css
  .quarto-listing-container-grid .g-col-1,
  .quarto-listing-container-grid .card-body { animation: none !important; transition: none !important; }
```

- [ ] **Step 8: Rebuild and re-run the Step 1 screenshots**

Run `python3 _prototypes/build.py`, then run the Step 1 command again.
Expected, checked by opening each image:
- H1: `hex-*-400/900/1440` show rounded hexagons in interlocking offset rows with even gaps, and no rectangles or grey hairlines.
- H3: `hex-portfolio-filter-code` shows only Code items, `hex-portfolio-filter-viz` only Visualisation items, and `hex-projects-filter-supply` only Supply Chains projects, with no holes in the honeycomb.
- H8: on `hex-projects-1440`, the badges sit inside the top of their hexagons.
- H10: no text shows outside a hexagon at 400 and 1440. Titles stay hidden until hover in headless screenshots, so also check H10 by hand in Step 10.

- [ ] **Step 9: Tune (only if the screenshots call for it)**

The only knobs to change are the `--hex-w` clamps, `--hex-gap`, the `.card-body` padding, the badge's `top` and the hover `scale`. If H2 shows visible facets, regenerate `--hex-shape` with 5° steps: in the Appendix script, change `range(7)` → `range(13)` and `10*k` → `5*k`.

- [ ] **Step 10: Manual checks H2, H4–H7, H9, H10**

In Chrome at http://localhost:8765/_site/proto-portfolio.html and proto-projects.html:
- H2: zoom to 200% and compare a hexagon's corners with the navbar logo.
- H4: click Visualisation, wait for the subtype row, then pick a subtype. Only those items should remain, and the honeycomb should reflow.
- H5: move the mouse across the tiles. Each one should grow and show its title and description, then shrink when the mouse leaves, with no flicker at the edges.
- H6: rest the cursor in the gap where three hexagons meet. Nothing should grow.
- H7: press Tab from the filter bar. The focused hexagon should grow with its title underlined in the accent colour, and Enter should open the entry.
- H9: DevTools → device toolbar → iPhone 14. Every hexagon should show its title without tapping.
- H10: hover the CLIDEWO project at 1440 and 400 widths. No text should leave the hexagon.
Repeat H1 and H5 in Safari and Firefox.

- [ ] **Step 11: Record results**

Fill rows H1–H10 in `_prototypes/FEASIBILITY.md`. No commit.

---

### Task 5: Feasibility report and review gate

**Files:**
- Modify: `_prototypes/FEASIBILITY.md` (X1, X2, verdict)

**Interfaces:**
- Consumes: the finished candidates from Tasks 3–4, and the preview server.
- Produces: a GO/NO-GO for each feature and the user's approval. Task 6 starts only after approval.

- [ ] **Step 1: Console check (X1)**

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
HL=(--headless=new "--host-resolver-rules=MAP *.googletagmanager.com ~NOTFOUND, MAP *.google-analytics.com ~NOTFOUND" --timeout=15000)
for p in index about projects publications portfolio conferences blog cv cv-negative; do
  echo "== $p"
  "$CHROME" "${HL[@]}" --enable-logging=stderr --v=0 --virtual-time-budget=3000 \
    --dump-dom "http://localhost:8765/_site/proto-$p.html" 2>&1 >/dev/null | grep "CONSOLE"
done
```
Expected: the same messages as the Baseline console block and nothing new.

- [ ] **Step 2: Size of change (X2)**

```bash
git diff --no-index --stat _includes/after-body.html _prototypes/after-body.html
git diff --no-index --stat styles.css _prototypes/styles.css
```
Expected: about 65 insertions and 0 deletions for after-body. For styles.css, insertions minus deletions should be ≤ +20, because the hex block is shorter than the block it replaces.

- [ ] **Step 3: Write the verdict**

Replace `(written in Task 5)` in FEASIBILITY.md with one line per feature, `ASCII field: GO` or `NO-GO`, plus the reason and any fallback used. If a check failed and tuning didn't fix it, try these fallbacks in order:
- A2 (a browser ignores the newlines): drop the `'\n'`, set `word-break: break-all` on the `::before`, and make it exactly `cols` characters wide using a `--ascii-cols` custom property set from JS.
- A5 (too slow): change the frame gap from `66` to `100`, then the cell size from 14px to 16px (the CSS font and `ASCII_CELL_H` together).
- H1/H3 (the float offset breaks in a browser): remove the `.list::before` rule. Tiles fall back to straight rows of hexagons that don't interlock, and nothing else changes.

- [ ] **Step 4: Stop for review**

Send the user:
- the preview links (proto-index, proto-about, proto-projects, proto-portfolio);
- the key screenshots (`proto-index-1440`, `hex-projects-1440`, `hex-portfolio-1440`, `hex-portfolio-400`);
- the verdict lines;
- the X2 numbers.

STOP until they approve each feature. If they reject one, undo that feature's changes in the candidates (Task 3 Steps 3–5 or Task 4 Steps 3–7), rebuild, and ask again.

---

### Task 6: Apply, verify on the real site, clean up

**Files:**
- Overwrite: `styles.css` ← `_prototypes/styles.css`
- Overwrite: `_includes/after-body.html` ← `_prototypes/after-body.html`
- Modify: `.impeccable.md` (principle 3)
- Delete: `_prototypes/`, `_site/proto-*.html`

**Interfaces:**
- Consumes: the approved candidates and the preview server.
- Produces: the finished feature on branch `feat/ascii-hex` (not pushed).

- [ ] **Step 1: Check that nobody changed the originals in the meantime, and that they are committed**

```bash
cmp styles.css _prototypes/base/styles.css && cmp _includes/after-body.html _prototypes/base/after-body.html && echo "originals unchanged"
git diff --stat -- styles.css _includes/after-body.html
```
Expected: `originals unchanged`, then no output from `git diff`.
- If `cmp` reports a difference, someone edited the originals after Task 2 copied them. STOP and ask the user, because copying would wipe out their edit.
- If `git diff` prints anything, the portfolio sub-filter work is still uncommitted. STOP and ask the user to commit it first, otherwise this feature's commit would include it.

- [ ] **Step 2: Apply**

```bash
cp _prototypes/styles.css styles.css
cp _prototypes/after-body.html _includes/after-body.html
git diff --stat -- styles.css _includes/after-body.html
```
Expected: the same numbers as the X2 check.

- [ ] **Step 3: Amend the motion principle**

In `.impeccable.md`, replace:
```markdown
3. **Motion is a whisper.** Animations confirm state changes and entrances; they never demand attention or loop.
```
with:
```markdown
3. **Motion is a whisper.** Animations confirm state changes and entrances; they never demand attention or loop. The one exception is the ASCII field behind page headers: `--rule`-coloured, idle off-screen, a still frame under reduced motion.
```

- [ ] **Step 4: Render**

Run: `quarto render`
Expected: finishes without `ERROR`.

- [ ] **Step 5: Verify the real pages**

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
HL=(--headless=new "--host-resolver-rules=MAP *.googletagmanager.com ~NOTFOUND, MAP *.google-analytics.com ~NOTFOUND" --timeout=15000)
for p in index about projects publications portfolio conferences blog cv cv-negative; do
  dom=$("$CHROME" "${HL[@]}" --virtual-time-budget=3000 --dump-dom "http://localhost:8765/_site/$p.html" 2>/dev/null)
  echo "$p headers=$(grep -c 'class="[^"]*has-ascii' <<<"$dom") chars=$(tr -d '\n' <<<"$dom" | grep -o 'data-ascii="[^"]*"' | wc -c | tr -d ' ')"
  "$CHROME" "${HL[@]}" --enable-logging=stderr --v=0 --virtual-time-budget=3000 \
    --dump-dom "http://localhost:8765/_site/$p.html" 2>&1 >/dev/null | grep "CONSOLE"
done
"$CHROME" "${HL[@]}" --virtual-time-budget=3000 --dump-dom "http://localhost:8765/_site/projects/project-clidewo.html" 2>/dev/null | grep -c 'class="[^"]*has-ascii'
for p in projects portfolio; do
  "$CHROME" "${HL[@]}" --hide-scrollbars --window-size=1440,1400 --virtual-time-budget=4000 \
    --screenshot="_prototypes/shots/after-$p-1440.png" "http://localhost:8765/_site/$p.html" 2>/dev/null
done
```
Expected:
- 9 lines with `headers=1` and `chars` > 1000, and no CONSOLE lines beyond the baseline.
- The detail page prints `0`.
- `after-projects-1440.png` and `after-portfolio-1440.png` match the approved `hex-*-1440.png` previews.

Then check by hand in the browser, starting at http://localhost:8765/_site/index.html: click through Home → Projects → a project → back → Portfolio → the Code filter → a portfolio item. Check dark mode once.

- [ ] **Step 6: Commit**

```bash
git commit -F - -- styles.css _includes/after-body.html .impeccable.md <<'EOF'
feat: ASCII header field and hex listings

Ambient sine plasma behind the first header of each top-level page,
printed from a data attribute by a ::before (no DOM nodes added).
Projects and Portfolio listings become a honeycomb of the logo's
rounded hexagon; the old card-grid CSS is replaced, filters unchanged.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
```
Expected: `3 files changed`.

- [ ] **Step 7: Clean up**

Ask the user whether to keep the screenshots, then:
```bash
rm -rf _prototypes
rm -f _site/proto-*.html
pkill -f "http.server 8765"
git status --short -- styles.css _includes/after-body.html .impeccable.md
```
Expected: the last command prints nothing, because all three files are committed.
Merging `feat/ascii-hex` into `main` deploys the site, so that's the user's decision. Use superpowers:finishing-a-development-branch.

---

## Appendix: where `--hex-shape` comes from

The navbar logo hexagon is `polygon points="60,30 85.98,45 85.98,75 60,90 34.02,75 34.02,45"`, drawn with a 48px round-join stroke. That's a pointy-top hexagon (circumradius 30) expanded outward by 24px with rounded corners. This script regenerates the polygon and can be run from anywhere:
```bash
python3 - <<'EOF'
import math
R, r, cx, cy = 30, 24, 60, 60
x0, y0 = cx - (R*math.sqrt(3)/2 + r), cy - (R + r)
w, h = 2*(R*math.sqrt(3)/2 + r), 2*(R + r)
pts = []
for i in range(6):
    th = math.radians(-90 + 60*i)
    vx, vy = cx + R*math.cos(th), cy + R*math.sin(th)
    for k in range(7):
        ph = th + math.radians(-30 + 10*k)
        pts.append(((vx + r*math.cos(ph) - x0)/w*100, (vy + r*math.sin(ph) - y0)/h*100))
print(f"height/width = {h/w:.4f}")
print("polygon(" + ", ".join(f"{x:.1f}% {y:.1f}%" for x, y in pts) + ")")
EOF
```
Expected: `height/width = 1.0804` and the same polygon as in Task 4 Step 3.

---

## Execution notes (11 Sep 2026)

- **Checks run through a driver, not CLI loops.** `--virtual-time-budget` hangs at 1440px even on the live pages, so screenshots and checks run through `_prototypes/drive.mjs` (Node + Chrome DevTools protocol, no packages) and `_prototypes/check-ascii.mjs` / `check-hex.mjs`. This also automates the "manual" DevTools checks (hover, keyboard, touch, dark mode, frame cost, accessibility tree). Safari and Firefox are still checked by hand.
- **Test runs block `api.fontshare.com`.** Fontshare's CSS API intermittently stalled for ~60s from this machine, which blocks page load. Screenshots therefore show system-ui instead of Switzer for body text. Live/proto comparisons are unaffected.
- **Frame cost fix.** At 8px the field is ~12,600 characters. With Commit Mono's contextual alternates and ligatures on, style + layout took 24 ms per frame (A5 fail). Turning them off in `.has-ascii::before` cut it to 0.9 ms. The CSS block in Task 3 Step 4 includes the fix.
- **Hex honeycomb needed JS (pending the user's choice at the Task 5 gate).** The float + `shape-outside` offset failed H3: with `#Visualisation` (12 of 18 tiles), the flex container sizes `.list` from a first layout pass without offsets. The offset rows then need one more line than that height allows, so the last row sits unshifted and overlaps the content below. No CSS-only fix was found: a fixed or tall float extends main's height and narrows the advance band. The prototype therefore drops the float/flex rules and adds `hexRows()` (39 lines, new `// ── HEX ROWS` section in `after-body.html`) plus one `.hex-shift` CSS rule. It is decoupled from the filter code: a ResizeObserver plus a MutationObserver on the tiles' `style`. If the user picks the no-JS option instead, remove that section and rule to get straight rows.
- **Round 2 (user feedback, 11 Sep 2026): option A chosen (JS honeycomb), plus these tweaks.**
  - ASCII glyph colour `color-mix(in oklch, var(--rule), var(--ink) 12%)`.
  - Home field on the whole hero (`.split-2-fullh`). The panel fill is now painted by the hero as a 50/50 gradient, and the panel paints it again when stacked at ≤900px.
  - Listings: no side padding, and `container-type: inline-size`. Tile width = `max(--hex-min, 100cqw / --hex-cols − gap)`, with 4 columns on Portfolio and 3 on Projects.
  - Tiles are size containers too: title `clamp(14px, 6.8cqw, 20px)`, and descriptions are hidden on tiles narrower than 250px. `flex-shrink: 0` fixes the half-cut last title line.
  - Hover grows to 1.15, and the veil is a radial gradient (94% paper up to 70% of the radius, 45% at the rim).
  - Dark tiles use `--muted` with thumbnails at 0.3 opacity. Listing thumbnail rules moved from GRID COLOR TRANSITION into the HEX block.
  - New check H11 (no half-cut lines). 83/83 checks pass.
- **Round 3 (user feedback, 11 Sep 2026).**
  - Home field on the whole page (`#quarto-content`), with only on-screen rows drawn. The hover veil is replaced by a centred paper box with a hairline border.
  - Fonts switched to DM Sans + Averia Serif Libre (Google Fonts), which drops Fontshare. The 22 MB thumbnail was replaced by a 118 KB WebP (content change, left uncommitted with the user's other portfolio edits).
  - **Task 6 changes because of this:**
    - Also copy `_prototypes/head.html` → `_includes/head.html`; its snapshot is in `_prototypes/base/`.
    - Update the Fonts row in `project_specs.md`, the Fonts line in `CLAUDE.md` and the fonts section of `DESIGN_SYSTEM.md`.
    - Add `_includes/head.html` and those docs to the commit.
    - `cv-template.typ` (PDF) still uses locally installed EB Garamond; it doesn't depend on Fontshare, so it is left alone unless the user asks.
- **Round 4 (user feedback, 11 Sep 2026).** Changes:
  - Hover band is full-width glass (65% paper + backdrop blur, no border) with an ink-based description.
  - Home glyphs are `--rule` + 5% `--ink`.
  - Navbar name is Averia Serif Libre 300 (head.html loads the 300 weight).
  - Cell width is the measured 0.6em, and the scroll margin is 4 rows.
  - 91/91 checks pass.
  - **Task 6 addition:** `.impeccable.md` lists "glassmorphism" as an anti-reference. Amend it to allow the hex hover band, which the user asked for explicitly.
