"""Build throwaway preview pages: _site/proto-<page>.html.

Each preview is a real rendered page with the candidate stylesheet, head
include (fonts) and after-body script from _prototypes/ swapped in, so it shows
exactly what the site will look like after the change. Source files are never
touched. Run from the project root, after `quarto render`:  python3 _prototypes/build.py
"""
from pathlib import Path

# The candidate stylesheet is served from _prototypes/, so its relative url()
# assets (the self-hosted navbar font) need to resolve from here too.
link = Path("_prototypes/assets")
if not link.exists():
    link.symlink_to(Path("../assets").resolve(), target_is_directory=True)

PAGES = ["index", "about", "projects", "publications", "portfolio",
         "conferences", "blog", "cv", "cv-negative"]

old_js = Path("_includes/after-body.html").read_text().strip()
new_js = Path("_prototypes/after-body.html").read_text().strip()
new_head = Path("_prototypes/head.html").read_text().strip()
# Pandoc rewrites head.html slightly (crossorigin="", &amp;), so swap the span
# between its first line and the end of its palette script instead of the exact text.
HEAD_START = '<link rel="preconnect" href="https://fonts.googleapis.com">'
HEAD_END = "saved || 'editorial-light');"

for page in PAGES:
    html = Path(f"_site/{page}.html").read_text()
    assert 'href="styles.css"' in html, f"{page}: stylesheet link not found"
    assert old_js in html, f"{page}: after-body script not found, run `quarto render` first"
    start = html.index(HEAD_START)
    end = html.index("</script>", html.index(HEAD_END)) + len("</script>")
    html = html[:start] + new_head + html[end:]
    html = html.replace('href="styles.css"', 'href="../_prototypes/styles.css"')
    html = html.replace(old_js, new_js)
    Path(f"_site/proto-{page}.html").write_text(html)
    print(f"built _site/proto-{page}.html")
