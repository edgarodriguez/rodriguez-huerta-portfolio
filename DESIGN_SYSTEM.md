# Editorial Design System

> **For Claude:** This file describes a design language. When building any artifact,
> page, app, or component, follow these rules so the result matches this aesthetic.
> Treat the tokens, type scale, and component patterns below as the source of truth.
> Do **not** invent new colors, fonts, or spacing values — use the tokens.

This system comes from an editorial research portfolio. The feeling is **quiet, premium,
print-like**: lots of whitespace, hairline rules, serif headlines, mono labels, one
restrained accent color, and subtle motion. Think of a well-set academic journal or a
gallery catalogue — not a SaaS dashboard.

---

## 1. Design principles (non-negotiable)

1. **Editorial, not decorative.** Structure comes from 1px rules and grid lines, not
   shadows or boxes. Cards are separated by hairline borders, not drop shadows.
2. **One accent only.** Everything is ink-on-paper. A single accent color (raspberry in
   light mode, mint in dark) marks active/important states — nothing else.
3. **No emoji icons. No generic gradients. No rounded corners** (border-radius is `0`
   almost everywhere). Buttons, tags, cards are all square.
4. **Type does the work.** Serif for headlines and body emphasis, mono for labels/metadata,
   sans for UI and running text. Size + weight + letter-spacing create hierarchy.
5. **Generous, fluid spacing.** Padding scales with the viewport via `clamp()`.
6. **Subtle motion only.** Fade-up on entry, gentle hover nudges, color crossfades. Always
   respect `prefers-reduced-motion`.
7. **Whitespace is a feature.** Let things breathe. When in doubt, add space, remove chrome.

---

## 2. Color tokens

Colors are defined in **OKLCH**. Drop these into `:root` (light is the default). Dark mode
is applied by setting `data-palette="editorial-dark"` on the root element.

### Light (default)

```css
:root,
[data-palette="editorial-light"] {
  --ink:    oklch(14% 0.025 192);  /* near-black teal — text & strong UI */
  --paper:  oklch(96% 0.004 165);  /* off-white, faintly green — page bg */
  --rule:   oklch(83% 0.012 162);  /* light sage gray — all hairline borders */
  --muted:  oklch(53% 0.038 168);  /* muted sage — secondary text, labels */
  --subtle: oklch(92% 0.008 158);  /* pale sage — hover/section backgrounds */
  --accent: oklch(58% 0.20 10);    /* vibrant raspberry — active/important only */
}
```

### Dark

```css
[data-palette="editorial-dark"] {
  --ink:    oklch(91% 0.013 80);   /* warm off-white */
  --paper:  oklch(10% 0.003 175);  /* near-black */
  --rule:   oklch(19% 0.003 175);  /* dark gray border */
  --muted:  oklch(50% 0.009 80);   /* warm gray */
  --subtle: oklch(13% 0.003 175);  /* very dark hover bg */
  --accent: oklch(96% 0.18 114);   /* mint */
}
```

### Hex reference (for non-CSS tools: R, ggplot, slides, design apps)

These are the exact sRGB hex equivalents of the OKLCH tokens above.

| Token | Light | Dark |
|-------|-------|------|
| `ink`    | `#000C0C` | `#E6E0D8` |
| `paper`  | `#EFF3F1` | `#030403` |
| `rule`   | `#C1CAC5` | `#121414` |
| `muted`  | `#577368` | `#66635E` |
| `subtle` | `#E0E6E2` | `#060807` |
| `accent` | `#D5305F` | `#F1FF5E` |

### Usage rules

| Token | Use for |
|-------|---------|
| `--ink` | Body text, headlines, primary button fill, borders that need emphasis |
| `--paper` | Page background, button text on ink |
| `--rule` | **Every** divider and border (1px) — grids, cards, footer, nav |
| `--muted` | Labels, metadata, secondary text, inactive nav links |
| `--subtle` | Hover backgrounds, alternating section backgrounds |
| `--accent` | Active nav underline, active filter, important counts, link hover — **never** for large fills or decoration |

If you build in a framework with its own theme variables (Bootstrap, Tailwind, shadcn),
**map those variables to these tokens** rather than introducing new colors.

---

## 3. Typography

### Fonts

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400;1,400&family=Space+Grotesk:wght@400;500&family=Space+Mono:wght@400&display=swap" rel="stylesheet">
```

```css
--font-serif: 'EB Garamond', Georgia, serif;     /* headlines, titles, body emphasis */
--font-sans:  'Space Grotesk', system-ui, sans-serif; /* UI, nav, running text */
--font-mono:  'Space Mono', monospace;           /* labels, metadata, tags, dates */
```

Base body: `--font-sans`, `15px`, `line-height: 1.6`, color `--ink`, bg `--paper`,
`-webkit-font-smoothing: antialiased`.

### Type scale & utilities

These are the reusable text classes. Match them exactly.

```css
/* Big serif headline */
.h1 {
  font-family: var(--font-serif);
  font-size: clamp(32px, 5vw, 60px);
  font-weight: 400;
  line-height: 1.22;
  letter-spacing: -0.015em;
  color: var(--ink);
  max-width: 85ch;
}

/* Serif subhead */
.h3 {
  font-family: var(--font-serif);
  font-size: clamp(17px, 2vw, 22px);
  font-weight: 400;
  line-height: 1.35;
}

/* Mono uppercase label — the signature element */
.label {
  font-family: var(--font-mono);
  font-size: 11px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--muted);
  display: inline-block;
}

/* Running body copy */
.body    { font-size: 15px; line-height: 1.75; max-width: 640px; color: var(--ink); }
.body-sm { font-size: 13px; line-height: 1.6;  color: var(--muted); }
```

Native heading scale (apply the serif treatment to `h1–h4`):

```css
h1,h2,h3,h4 { font-family: var(--font-serif); font-weight: 400; color: var(--ink); }
h1 { font-size: clamp(32px, 5vw, 60px);   letter-spacing: -0.015em; line-height: 1.22; }
h2 { font-size: clamp(24px, 3.4vw, 36px); line-height: 1.28; }
h3 { font-size: clamp(17px, 2vw, 22px);   line-height: 1.35; }
h4 { font-size: clamp(14px, 1.5vw, 16px); line-height: 1.45; }
p, li { font-size: 15px; line-height: 1.75; }
code, pre { font-family: var(--font-mono); font-size: 13px; }
```

**Hierarchy recipe:** a section usually opens with a mono `.label` (e.g. `01 — RESEARCH`),
then a serif headline (`.h1`/`h2`), then sans/serif body. Labels are uppercase, tracked
wide, and muted; the accent color is reserved for the *active* or *numbered* label.

Long body paragraphs use `text-align: justify; hyphens: auto;` in editorial blocks.

---

## 4. Spacing & layout

```css
--pad:    clamp(32px, 6vw, 96px);  /* the master padding rhythm — use everywhere */
--nav-h:  56px;
--foot-h: 34px;
```

`--pad` shrinks to `24px` on screens ≤ 640px.

### Layout primitives

Everything is built from **CSS grids divided by 1px rules**. Reuse these:

```css
/* Two equal columns with a vertical hairline between */
.split-2 { display: grid; grid-template-columns: 1fr 1fr; }
.split-2 > * { padding: var(--pad); }
.split-2 > *:first-child { border-right: 1px solid var(--rule); }

/* Asymmetric bio split (text-heavy left, sidebar right) */
.split-bio { display: grid; grid-template-columns: 1.6fr 1fr; }
.split-bio > * { padding: clamp(32px, 5vw, 80px); }
.split-bio > *:first-child { border-right: 1px solid var(--rule); }

/* Three columns, hairline-separated, hover-highlightable */
.split-3 { display: grid; grid-template-columns: repeat(3,1fr); border-top: 1px solid var(--rule); }
.split-3 > * { padding: clamp(24px,4vw,48px); border-right: 1px solid var(--rule); transition: background .2s; }
.split-3 > *:last-child { border-right: none; }
.split-3 > a:hover { background: var(--subtle); }

/* Generic full-bleed band */
.page-band { padding: var(--pad); }
.subtle-bg, .page-band-subtle { background: var(--subtle); }
```

**Responsive rule:** below 900px, all splits collapse to a single column and vertical
hairlines (`border-right`) become horizontal ones (`border-bottom`).

**Grid card decks** (e.g. a 3-up feature grid) are made by setting `gap: 1px;
background: var(--rule);` on the container and `background: var(--paper)` on each cell —
the gap *is* the gridline. No borders on the cells themselves.

---

## 5. Components

### Buttons (square, uppercase, mono-spaced tracking)

```css
.btn-primary, .btn-outline {
  display: inline-block;
  padding: 11px 28px;
  font-family: var(--font-sans);
  font-size: 11px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  border: 1px solid var(--ink);
  transition: background .2s, color .2s, opacity .2s, border-color .2s;
}
.btn-primary { background: var(--ink); color: var(--paper); }
.btn-primary:hover { opacity: 0.75; }
.btn-outline { background: transparent; color: var(--ink); }
.btn-outline:hover { background: var(--ink); color: var(--paper); }
/* press */
.btn-primary:active, .btn-outline:active { transform: translateY(1px); transition-duration: .06s; }
```

### Tags (tiny mono pills with a hairline border)

```css
.tag {
  display: inline-block;
  font-family: var(--font-mono);
  font-size: 9.5px;
  letter-spacing: 0.09em;
  text-transform: uppercase;
  border: 1px solid var(--rule);
  padding: 3px 8px;
  color: var(--muted);
  background: transparent;
  transition: border-color .2s, color .2s, transform .18s cubic-bezier(.16,1,.3,1);
}
.tag:hover { border-color: var(--ink); color: var(--ink); }
a.tag:hover { transform: translateY(-1px); }  /* subtle nudge */
```

### Filter buttons (active state uses accent)

```css
.filter-btn {
  padding: 5px 14px;
  font-family: var(--font-mono); font-size: 10px;
  letter-spacing: 0.1em; text-transform: uppercase;
  border: 1px solid var(--rule); background: transparent; color: var(--muted);
}
.filter-btn:hover:not(.is-active) { color: var(--ink); border-color: var(--ink); }
.filter-btn.is-active { background: var(--accent); border-color: var(--accent); color: var(--paper); }
```

### Navbar

Fixed top, `56px` tall, `--paper` background, 1px `--rule` bottom border. Brand is serif
`22px`. Nav links are sans, `10.5px`, uppercase, `letter-spacing: 0.13em`, `--muted`;
active link is `--ink` with an accent-colored bottom border.

### Footer

Fixed bottom, `34px` tall, `--paper` bg, 1px top rule. Content is mono, `9px`, uppercase,
tracked `0.12em`, `--muted`. Left = copyright, right = attribution/links.

### Listing rows (publications / references)

A grid row with a year column and a content column, separated by a bottom hairline:

```css
.row-pub {
  padding: 22px 0; border-bottom: 1px solid var(--rule);
  display: grid; grid-template-columns: 52px 1fr; gap: 20px;
}
.row-pub .row-year  { font-family: var(--font-sans); font-size: 14px; color: var(--muted); }
.row-pub .row-title { font-family: var(--font-serif); font-size: 16px; line-height: 1.55; color: var(--ink); }
.row-pub:hover .row-title { color: var(--accent); }
.row-pub .row-authors { font-size: 14px; color: var(--muted); }
```

### Cards (feature / portfolio)

Square, no shadow, hairline-separated. Structure: image (`min-height: 180px`,
`object-fit: cover`) → body with **mono category label → serif title → mono description →
mono meta row** (in that visual order), each section divided by `border-top: 1px solid
var(--rule)`. Card background `--paper`; hover background `--subtle`.

Image treatment: thumbnails start near-invisible greyscale and bloom to full color on
hover — `filter: grayscale(100%) opacity(.22)` → `grayscale(0) opacity(1)`, transitioned
over `0.55s cubic-bezier(.16,1,.3,1)`.

### Callouts (notes / tips)

No colored box. Just `border-left: 2px solid` + `--subtle` background, square corners,
no icon. Note → `--muted` left border; tip → `--accent`; important → `--ink`.

---

## 6. Motion

Easing of choice: **`cubic-bezier(0.16, 1, 0.3, 1)`** (a soft ease-out). Keep durations
short (0.2s for hovers, ~0.5–0.75s for entrances).

```css
/* Page entrance */
@keyframes fadeUp { from { opacity:0; transform: translateY(22px); } to { opacity:1; transform:none; } }
main { animation: fadeUp .75s cubic-bezier(.16,1,.3,1) both; }

/* Staggered item reveal (lists/grids) — delay set per item */
@keyframes itemReveal { from { opacity:0; transform: translateY(8px); } to { opacity:1; transform:none; } }

/* Always honor reduced motion */
@media (prefers-reduced-motion: reduce) {
  main { animation: none !important; }
  /* disable transforms/transitions on interactive elements too */
}
```

Hover micro-interactions: cards lift their image `scale(1.04)`, tags nudge `translateY(-1px)`,
buttons press `translateY(1px)`. Color/background changes crossfade, they never snap.

---

## 7. Hard rules — do NOT

- ❌ No `border-radius` (everything is square). One exception: small circular icon toggles.
- ❌ No box-shadows for structure (a faint dropdown shadow `0 8px 32px rgba(0,0,0,.08)` is the only allowed shadow).
- ❌ No emoji as UI icons. Use inline SVG.
- ❌ No gradients.
- ❌ No new colors outside the 6 tokens. No new fonts outside the 3 families.
- ❌ No inline `style=""` — put everything in classes/CSS and reuse the tokens.
- ❌ Don't crowd. Respect `--pad` and let whitespace breathe.

---

## 8. R / ggplot2 figures

Charts must read like the rest of the system: **paper background, ink text, hairline
`rule` gridlines, mono labels, serif titles, and `accent` used only for the series you want
to emphasize.** Minimal chrome — drop the gray panel, drop the legend box, keep one set of
faint gridlines.

### Palette object

```r
edgar <- list(
  ink    = "#000C0C",
  paper  = "#EFF3F1",
  rule   = "#C1CAC5",
  muted  = "#577368",
  subtle = "#E0E6E2",
  accent = "#D5305F"
)

# Dark variant — use when the figure sits on a dark page
edgar_dark <- list(
  ink = "#E6E0D8", paper = "#030403", rule = "#121414",
  muted = "#66635E", subtle = "#060807", accent = "#F1FF5E"
)
```

### Discrete (categorical) palette

Order matters: lead with the accent for the most important series, then recede into
ink/muted tones so the accent always reads first.

```r
# Up to 5 categories, accent-first
edgar_cat <- c("#D5305F", "#000C0C", "#577368", "#C1CAC5", "#9AA59D")

scale_colour_edgar <- function(...) ggplot2::scale_colour_manual(values = edgar_cat, ...)
scale_fill_edgar   <- function(...) ggplot2::scale_fill_manual(values   = edgar_cat, ...)
```

For a **sequential / continuous** scale, ramp from `paper`/`subtle` up to `accent` (or to
`ink` for a neutral ramp):

```r
scale_fill_edgar_c <- function(...)
  ggplot2::scale_fill_gradient(low = "#EFF3F1", high = "#D5305F", ...)
```

### Theme

```r
library(ggplot2)

theme_editorial <- function(base_size = 12,
                            serif = "EB Garamond",
                            sans  = "Space Grotesk",
                            mono  = "Space Mono") {
  theme_minimal(base_size = base_size, base_family = sans) +
    theme(
      plot.background  = element_rect(fill = edgar$paper, colour = NA),
      panel.background = element_rect(fill = edgar$paper, colour = NA),
      panel.grid.major = element_line(colour = edgar$rule, linewidth = 0.3),
      panel.grid.minor = element_blank(),
      axis.line.x      = element_line(colour = edgar$rule, linewidth = 0.4),
      axis.ticks       = element_blank(),

      # Serif title, mono everything-label
      plot.title    = element_text(family = serif, face = "plain",
                                   size = base_size * 1.8, colour = edgar$ink,
                                   margin = margin(b = 6)),
      plot.subtitle = element_text(family = sans, colour = edgar$muted,
                                   size = base_size * 0.95, margin = margin(b = 14)),
      plot.caption  = element_text(family = mono, colour = edgar$muted,
                                   size = base_size * 0.7, hjust = 0,
                                   margin = margin(t = 14)),
      axis.title    = element_text(family = mono, colour = edgar$muted,
                                   size = base_size * 0.72),
      axis.text     = element_text(family = mono, colour = edgar$muted,
                                   size = base_size * 0.72),

      # No boxed legend; mono labels
      legend.position   = "top",
      legend.title      = element_text(family = mono, colour = edgar$muted,
                                       size = base_size * 0.72),
      legend.text       = element_text(family = mono, colour = edgar$muted,
                                       size = base_size * 0.72),
      legend.key        = element_blank(),

      strip.text = element_text(family = mono, colour = edgar$ink,
                                size = base_size * 0.75, hjust = 0),
      plot.margin = margin(20, 20, 16, 16)
    )
}
```

> Convention reminder for axis/legend titles: the mono treatment looks best **UPPERCASE
> with wide tracking**, mirroring the web `.label`. Either uppercase your strings, or add
> `axis.title.x = element_text(...)` overrides per plot. (ggplot can't letter-space text,
> so just type labels in CAPS where you want that look.)

### Fonts in R

The three Google Fonts aren't available to R's graphics device by default. Register them once:

```r
# Option A — system fonts (if EB Garamond / Space Grotesk / Space Mono are installed)
library(systemfonts)              # ships with ragg
# then save with ragg for crisp text:
ggsave("fig.png", p, device = ragg::agg_png, width = 7, height = 4.5, dpi = 300)

# Option B — pull straight from Google Fonts, no install needed
library(showtext)
sysfonts::font_add_google("EB Garamond",  "EB Garamond")
sysfonts::font_add_google("Space Grotesk", "Space Grotesk")
sysfonts::font_add_google("Space Mono",    "Space Mono")
showtext_auto()
```

### Usage

```r
ggplot(df, aes(x, y, colour = group)) +
  geom_line(linewidth = 0.8) +
  scale_colour_edgar() +
  labs(title = "A serif headline",
       subtitle = "Sans subtitle for context",
       x = "TIME", y = "VALUE",
       caption = "Source: …") +
  theme_editorial()
```

If you regenerate the hex values, derive them from the OKLCH tokens in §2 so the figure
palette never drifts from the website.

---

## 9. Quick-start checklist for a new artifact

1. Paste the `:root` light + dark token blocks and the three `--font-*` vars.
2. Load the three Google Fonts.
3. Set body to `--font-sans / 15px / 1.6`, `--ink` on `--paper`.
4. Build structure from `.split-*` grids divided by 1px `--rule` lines.
5. Open sections with a mono `.label`, headline with serif `.h1/h2`, body in `.body`.
6. Use `.btn-primary` / `.btn-outline` and `.tag` for actions and metadata.
7. Add `fadeUp` on entry; keep all motion subtle and reduced-motion-safe.
8. Reserve `--accent` for active/important states only.
