// Checks A1–A8 for the ASCII field on the preview pages; saves screenshots.
// Run from the project root with the preview server up:  node _prototypes/check-ascii.mjs
import { withPage, reporter, BASE, sleep } from './drive.mjs';

const PAGES = ['index', 'about', 'projects', 'publications', 'portfolio', 'conferences', 'blog', 'cv', 'cv-negative'];
const SHOTS = '_prototypes/shots/';
const r = reporter();

// Boxes of the header content; adding the field must not move any of them.
const LAYOUT = `JSON.stringify([...document.querySelectorAll(
  'main h1, main .label, main .filter-bar, main .btn-row, main .tag-row, main .split-2-fullh > *, main .cv-page-header > *')]
  .map(e => { const b = e.getBoundingClientRect(); return [e.tagName, b.x, b.y, b.width, b.height].map(v => typeof v === 'number' ? Math.round(v) : v); }))`;

// Field facts: how many hosts, frame size, and whether the frame over-fills its host.
const FIELD = `(() => {
  const hosts = document.querySelectorAll('.has-ascii');
  const el = hosts[0];
  if (!el) return { n: 0 };
  const rows = el.getAttribute('data-ascii').split('\\n').filter(Boolean);
  const probe = document.createElement('span');
  probe.style.cssText = 'position:absolute;visibility:hidden;white-space:pre;font:8px/8px var(--font-mono)';
  probe.textContent = '-'.repeat(200);
  document.body.appendChild(probe);
  const glyph = probe.getBoundingClientRect().width / 200;
  probe.remove();
  const busiest = rows.reduce((a, b) => (b.replace(/ /g, '').length > a.replace(/ /g, '').length ? b : a));
  return { n: hosts.length, host: el.className, rows: rows.length, cols: rows[0].length, glyph: +glyph.toFixed(2),
           coversW: rows[0].length * glyph >= el.clientWidth, coversH: rows.length * 8 >= el.clientHeight,
           sample: busiest.trim().slice(0, 24) };
})()`;

const COUNT_DRAWS = ms => `new Promise(res => {
  let n = 0;
  const mo = new MutationObserver(() => n++);
  mo.observe(document.querySelector('.has-ascii'), { attributes: true, attributeFilter: ['data-ascii'] });
  setTimeout(() => { mo.disconnect(); res(n); }, ${ms});
})`;

await withPage(async page => {
  // A1 + A2 + A4 + screenshots, reduced motion so every entrance animation is already finished.
  for (const p of PAGES) {
    await page.open(`${BASE}proto-${p}.html`, { reduced: true });
    const f = await page.eval(FIELD);
    r.check('A1', f.n === 1, `${p}: ${f.n} host (${f.host ?? '-'}), ${f.rows}×${f.cols} cells`);
    r.check('A2', f.coversW && f.coversH, `${p}: frame fills host (glyph ${f.glyph}px)`);
    const ax = JSON.stringify(await page.send('Accessibility.getFullAXTree'));
    r.check('A4', !ax.includes(f.sample), `${p}: plasma text absent from accessibility tree ("${f.sample}")`);
    await page.shot(`${SHOTS}proto-${p}-1440.png`);
  }
  for (const p of ['index', 'projects']) {
    await page.open(`${BASE}proto-${p}.html`, { width: 400, height: 900, reduced: true });
    await page.shot(`${SHOTS}proto-${p}-400.png`);
  }

  // A3: the field must not move anything: same preview page with and without its hooks.
  const WITHOUT = `(() => { document.querySelector('.has-ascii').classList.remove('has-ascii');
    return new Promise(r => requestAnimationFrame(() => r(true))); })()`;
  for (const [p, width] of [...PAGES.map(p => [p, 1440]), ['index', 400], ['projects', 400], ['about', 400]]) {
    await page.open(`${BASE}proto-${p}.html`, { width, height: 900, reduced: true });
    const withField = await page.eval(LAYOUT);
    await page.eval(WITHOUT);
    r.check('A3', withField === (await page.eval(LAYOUT)), `${p} at ${width}px: boxes identical with and without the field`);
  }
  for (const p of ['index', 'projects', 'portfolio']) {
    await page.open(`${BASE}${p}.html`, { reduced: true });
    await page.shot(`${SHOTS}before-${p}-1440.png`);
  }

  // A9: on Home the field covers the whole page: full width, hero and the cards below.
  await page.open(`${BASE}proto-index.html`, { reduced: true });
  const home = await page.eval(`(() => { const el = document.querySelector('.has-ascii'), b = el.getBoundingClientRect();
    return { id: el.id, left: b.left, right: b.right, vw: innerWidth, hero: el.contains(document.querySelector('.split-2-fullh')),
             cards: el.contains(document.querySelector('.split-3')) }; })()`);
  r.check('A9', home.id === 'quarto-content' && home.left <= 0 && home.right >= home.vw - 1 && home.hero && home.cards,
    `Home host #${home.id}: x ${home.left}→${home.right} of ${home.vw}px, hero ${home.hero}, cards ${home.cards}`);

  // A10 + F1: Home glyphs are lighter (rule + 5% ink); navbar name is Averia Serif Libre Light.
  const look = await page.eval(`document.fonts.ready.then(() => {
    const probe = document.createElement('div');
    probe.style.color = 'color-mix(in oklch, var(--rule), var(--ink) 5%)';   // same as #quarto-content.has-ascii::before
    document.body.appendChild(probe);
    const want = getComputedStyle(probe).color;
    probe.remove();
    const brand = getComputedStyle(document.querySelector('.navbar-brand'));
    return { want, got: getComputedStyle(document.querySelector('.has-ascii'), '::before').color,
             weight: brand.fontWeight, family: brand.fontFamily.split(',')[0],
             light: [...document.fonts].some(f => f.family.includes('Movement') && f.status === 'loaded') };
  })`);
  r.check('A10', look.want === look.got, `Home glyph colour ${look.got} (want ${look.want})`);
  r.check('F1', look.weight === '100' && look.light, `navbar name: ${look.family} weight ${look.weight}, face loaded: ${look.light}`);

  // A5: frame cost on the biggest field (the whole Home page), on two screen sizes.
  for (const [w, h] of [[1440, 900], [1920, 1080]]) {
    await page.open(`${BASE}proto-index.html`, { width: w, height: h, settle: 1200 });
    if (w === 1440) await page.shot(`${SHOTS}proto-index-1440-moving.png`);
    const cost = await page.eval(`(() => {
      const el = document.querySelector('.has-ascii'), s = el.getAttribute('data-ascii');
      const lines = s.split('\\n').slice(0, -1), drawn = lines.filter(l => l.length).length;
      const cols = Math.max(...lines.map(l => l.length)), ramp = ' .:-=+*\\\\/–·';
      let t0 = performance.now(), out = '';
      for (let k = 0; k < 10; k++) {             // same maths and string building as asciiFrame, drawn rows only
        out = ''; const t = k, bendY = [];
        for (let x = 0; x < cols; x++) bendY[x] = Math.cos(x * 4.8 / 24 * 0.6 - t * 0.7) * 1.2;
        for (let y = 0; y < drawn; y++) { const py = y * 8 / 24, bendX = Math.sin(py * 0.7 + t * 0.9) * 1.2;
          for (let x = 0; x < cols; x++) {
            const wx = x * 4.8 / 24 + bendX, wy = py + bendY[x];
            const v = Math.sin(wx * 0.9 + t) + Math.sin(wy * 1.1 - t * 0.8) + Math.sin((wx + wy) * 0.6 + t * 0.5)
                    + Math.sin(Math.sqrt(wx * wx + wy * wy) * 0.8 - t * 1.2);
            out += ramp.charAt(Math.round((v + 4) / 8 * (ramp.length - 1))); }
          out += '\\n'; } }
      const build = (performance.now() - t0) / 10, alt = s.replace(/[.:]/g, '=');
      t0 = performance.now();
      for (let i = 1; i <= 20; i++) { el.setAttribute('data-ascii', i % 2 ? alt : s); document.body.getBoundingClientRect(); }
      return { rows: lines.length, drawn, cells: drawn * cols, build: +build.toFixed(2), layout: +((performance.now() - t0) / 20).toFixed(2) };
    })()`);
    const longTasks = await page.eval(`new Promise(res => {
      let n = 0;
      new PerformanceObserver(l => { n += l.getEntries().length; }).observe({ type: 'longtask' });
      setTimeout(() => res(n), 3000);
    })`);
    const draws = await page.eval(COUNT_DRAWS(2000));
    r.check('A5', cost.build + cost.layout < 8 && longTasks === 0 && draws >= 20,
      `${w}×${h}: ${cost.drawn}/${cost.rows} rows drawn, ${cost.cells} cells: build ${cost.build}ms + style/layout ${cost.layout}ms; ${longTasks} long tasks; ${draws} draws in 2s`);
  }

  // A6: reduced motion = one still frame.
  await page.open(`${BASE}proto-index.html`, { reduced: true });
  const still = await page.eval(COUNT_DRAWS(1500));
  r.check('A6', still === 0, `reduced motion: ${still} redraws in 1.5s`);

  // A7: dark palette recolours the glyphs to the dark --rule.
  await page.open(`${BASE}proto-about.html`);
  const dark = await page.eval(`(() => {
    document.documentElement.setAttribute('data-palette', 'editorial-dark');
    const probe = document.createElement('div');
    probe.style.color = 'color-mix(in oklch, var(--rule), var(--ink) 12%)';   // same as .has-ascii::before
    document.body.appendChild(probe);
    const want = getComputedStyle(probe).color;
    probe.remove();
    return { want, got: getComputedStyle(document.querySelector('.has-ascii'), '::before').color };
  })()`);
  await sleep(500);   // let the palette's 0.4s colour transition finish before the screenshot
  await page.shot(`${SHOTS}proto-about-1440-dark.png`);
  r.check('A7', dark.want === dark.got, `dark glyph colour ${dark.got} (want ${dark.want})`);

  // A8: no drawing once the header is scrolled out of view (portfolio is long
  // enough for that; the blog page's header stays partly visible at its bottom).
  await page.open(`${BASE}proto-portfolio.html`);
  await page.eval('window.scrollTo(0, document.documentElement.scrollHeight)');
  await sleep(300);
  const offscreen = await page.eval(`document.querySelector('.has-ascii').getBoundingClientRect().bottom < 0`);
  const idle = await page.eval(COUNT_DRAWS(1500));
  r.check('A8', offscreen && idle === 0, `portfolio scrolled past header: ${idle} redraws in 1.5s`);

  r.check('X1', page.errors.length === 0, page.errors.length ? page.errors.join(' | ') : 'no console errors or exceptions');
});

r.print();
