# Rodríguez-Huerta — Research Portfolio

A static editorial portfolio for **Edgar Rodríguez-Huerta**, PhD researcher in socio-ecological systems & modern slavery.

Built with [Quarto](https://quarto.org), styled with hand-written CSS, and published to GitHub Pages.

## Local preview

```bash
quarto preview
```

Live-reloading dev server at `http://localhost:4xxx` (Quarto picks the port).

## Build only

```bash
quarto render
```

Builds the static site into `/_site/`. Useful for catching errors before pushing.

## Deploy

Just push to `main`. The GitHub Action in [`.github/workflows/publish.yml`](.github/workflows/publish.yml) renders the site and publishes the output to the `gh-pages` branch automatically.

To set up the first time:

1. In your GitHub repo settings → **Pages** → set the source to the `gh-pages` branch.
2. Push to `main`.
3. Wait ~30 seconds, refresh, your site is live.

## Adding a new entry

Drop a `.qmd` into the matching folder:

| Section | Folder | Template |
|---|---|---|
| Projects | [`/projects/`](projects/) | [example-project.qmd](projects/example-project.qmd) |
| Publications | [`/publications/`](publications/) | [example-pub.qmd](publications/example-pub.qmd) |
| Portfolio | [`/portfolio/`](portfolio/) | [example-viz.qmd](portfolio/example-viz.qmd) |
| Conferences | [`/conferences/`](conferences/) | [example-talk.qmd](conferences/example-talk.qmd) |
| Blog | [`/blog/`](blog/) | [2026-05-01-welcome.qmd](blog/2026-05-01-welcome.qmd) |

The listing page auto-picks it up. The new entry also becomes its own dedicated page at `/<section>/<slug>.html`.

## Structure

See [`CLAUDE.md`](CLAUDE.md) for a full file-by-file walkthrough and [`project_specs.md`](project_specs.md) for the project blueprint.
