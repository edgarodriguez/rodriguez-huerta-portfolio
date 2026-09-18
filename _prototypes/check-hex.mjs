// Checks H1–H10 for the hex listings on the preview pages; saves screenshots.
// Run from the project root with the preview server up:  node _prototypes/check-hex.mjs
import { withPage, reporter, BASE, sleep } from './drive.mjs';

const SHOTS = '_prototypes/shots/';
const GAP = 10;   // --hex-gap
const r = reporter();

// Every visible tile's box (page coordinates) plus the listing's right edge.
const TILES = `(() => {
  const list = document.querySelector('.quarto-listing-container-grid .list');
  const tiles = [...list.querySelectorAll('.g-col-1')].filter(t => getComputedStyle(t).display !== 'none');
  return { right: list.getBoundingClientRect().right, tiles: tiles.map(t => {
    const b = t.getBoundingClientRect();
    return { x: Math.round(b.x), y: Math.round(b.y + scrollY), w: Math.round(b.width), h: Math.round(b.height),
             clip: getComputedStyle(t).clipPath.startsWith('polygon') };
  }) };
})()`;

// '' when the tiles form a gap-free honeycomb: even rows flush left, odd rows half a
// tile in, rows spaced 0.866 × pitch apart, and every row but the last full.
function honeycomb({ right, tiles }) {
  if (!tiles.length) return 'no visible tiles';
  if (!tiles.every(t => t.clip)) return 'tiles are not clipped to a hexagon';
  const w = tiles[0].w, pitch = w + GAP, x0 = Math.min(...tiles.map(t => t.x));
  const rows = [...new Set(tiles.map(t => t.y))].sort((a, b) => a - b);
  for (let i = 0; i < rows.length; i++) {
    const row = tiles.filter(t => t.y === rows[i]).sort((a, b) => a.x - b.x);
    if (i && Math.abs(rows[i] - rows[i - 1] - 0.866 * pitch) > 2) return `row ${i} is ${rows[i] - rows[i - 1]}px below the last, want ${(0.866 * pitch).toFixed(0)}`;
    const start = x0 + (i % 2 ? pitch / 2 : 0);
    if (Math.abs(row[0].x - start) > 2) return `row ${i} starts at x=${row[0].x}, want ${start.toFixed(0)}`;
    for (let j = 1; j < row.length; j++)
      if (Math.abs(row[j].x - row[j - 1].x - pitch) > 2) return `hole in row ${i} before tile ${j}`;
    if (i < rows.length - 1 && row.at(-1).x + pitch + w <= right + 2) return `row ${i} has room for another tile`;
  }
  return '';
}

const layout = async (page, label, cols) => {
  const t = await page.eval(TILES);
  let why = honeycomb(t);
  const first = t.tiles.filter(x => x.y === Math.min(...t.tiles.map(y => y.y))).length;
  if (!why && cols && first !== cols) why = `${first} tiles in the first row, want ${cols}`;
  r.check(label.split(' ')[0], !why, `${label}${cols ? ` (${first} columns, ${t.tiles[0]?.w}px tiles)` : ''}${why ? ': ' + why : ''}`);
};

// Hover every tile: it must grow, show its text inside the hexagon, and no text
// line may be cut (clamped blocks are whole lines tall and fit the veil).
async function hoverAll(page, p, width, height) {
  await page.open(`${BASE}proto-${p}.html`, { width, height, settle: 2600 });
  const n = await page.eval(`document.querySelectorAll('.quarto-listing-container-grid .g-col-1').length`);
  let grown = 0, inside = 0, whole = 0, bands = 0;
  const bad = [];
  for (let i = 0; i < n; i++) {
    const c = await page.eval(`(() => { const t = document.querySelectorAll('.quarto-listing-container-grid .g-col-1')[${i}];
      t.scrollIntoView({ block: 'center', behavior: 'instant' }); const b = t.getBoundingClientRect(); return [b.x + b.width / 2, b.y + b.height / 2]; })()`);
    await page.mouse(c[0], c[1]);
    await sleep(750);
    const s = await page.eval(`(() => {
      const t = document.querySelectorAll('.quarto-listing-container-grid .g-col-1')[${i}];
      const cb = t.querySelector('.card-body'), title = t.querySelector('.listing-title');
      const desc = t.querySelector('.listing-description > p'), descOn = getComputedStyle(t.querySelector('.listing-description')).display !== 'none';
      const inside = el => { const b = el.getBoundingClientRect();
        return [[b.left + 1, b.top + 1], [b.right - 1, b.top + 1], [b.left + 1, b.bottom - 1], [b.right - 1, b.bottom - 1]]
          .every(([x, y]) => document.elementFromPoint(x, y)?.closest('.g-col-1') === t); };
      const wholeLines = el => { const n = el.offsetHeight / parseFloat(getComputedStyle(el).lineHeight); return n >= 0.9 && Math.abs(n - Math.round(n)) < 0.1; };
      return { scale: getComputedStyle(t).scale, veil: getComputedStyle(cb).opacity,
               inside: inside(title) && (!descOn || inside(desc)),
               band: cb.offsetWidth === t.offsetWidth && getComputedStyle(cb).backdropFilter.includes('blur')
                     && getComputedStyle(cb).borderTopWidth === '0px',
               whole: wholeLines(title) && (!descOn || wholeLines(desc)) && cb.scrollHeight <= cb.clientHeight + 1,
               title: title.textContent.trim().slice(0, 32), font: getComputedStyle(title).fontSize, descOn };
    })()`);
    if (s.scale === '1.15' && s.veil === '1') grown++; else bad.push(`not grown: ${s.title}`);
    if (s.inside) inside++; else bad.push(`spills: ${s.title}`);
    if (s.whole) whole++; else bad.push(`cut line: ${s.title}`);
    if (s.band) bands++; else bad.push(`band: ${s.title}`);
    if (i === 0) await page.shot(`${SHOTS}hex-${p}-${width}-hover.png`);
  }
  r.check('H5', grown === n, `${p} ${width}px: ${grown}/${n} tiles grow to 1.15 and show their text`);
  r.check('H10', inside === n, `${p} ${width}px: text inside the hexagon on ${inside}/${n}${bad.length ? ' — ' + bad.join('; ') : ''}`);
  r.check('H11', whole === n, `${p} ${width}px: no half-cut lines on ${whole}/${n}`);
  r.check('H12', bands === n, `${p} ${width}px: full-width glass band, no border, on ${bands}/${n}`);
  await page.mouse(1, 1);
  await sleep(750);
  const rest = await page.eval(`(() => { const t = document.querySelector('.quarto-listing-container-grid .g-col-1');
    return { scale: getComputedStyle(t).scale, veil: getComputedStyle(t.querySelector('.card-body')).opacity }; })()`);
  r.check('H5', rest.scale !== '1.15' && rest.veil === '0', `${p} ${width}px mouse away: scale ${rest.scale}, veil ${rest.veil}`);
}

// Visible-tile count vs. the count the filter should leave.
const COUNT = (field, value, subField, subValue) => `(() => {
  const val = (t, f) => t.querySelector('.card-other-values td.' + f)?.textContent.trim();
  const all = [...document.querySelectorAll('.quarto-listing-container-grid .g-col-1')];
  const want = all.filter(t => val(t, '${field}') === '${value}' && (!'${subField}' || val(t, '${subField}') === '${subValue}')).length;
  return { want, got: all.filter(t => getComputedStyle(t).display !== 'none').length };
})()`;

await withPage(async page => {
  // H1: honeycomb at three widths, reduced motion so the entrance stagger is already done.
  for (const [p, heights] of [['projects', [1600, 1500, 1300]], ['portfolio', [2600, 2200, 1500]]]) {
    for (const [i, width] of [400, 900, 1440].entries()) {
      await page.open(`${BASE}proto-${p}.html`, { width, height: heights[i], reduced: true });
      await layout(page, `H1 ${p} at ${width}px`, { projects: [2, 4, 4], portfolio: [2, 4, 4] }[p][i]);
      await page.shot(`${SHOTS}hex-${p}-${width}.png`);
    }
  }

  // The at-rest look with motion on (greyscale thumbnails), for the review.
  await page.open(`${BASE}proto-portfolio.html`, { height: 1400, settle: 2600 });
  await page.shot(`${SHOTS}hex-portfolio-1440-rest.png`);

  // H3: filters leave only matching tiles and the honeycomb closes up.
  for (const [url, field, value, shot] of [
    ['proto-portfolio.html#Code', 'type', 'Code', 'hex-portfolio-filter-code'],
    ['proto-portfolio.html#Visualisation', 'type', 'Visualisation', 'hex-portfolio-filter-viz'],
  ]) {
    await page.open(`${BASE}${url}`, { height: 1300, reduced: true });
    const c = await page.eval(COUNT(field, value, '', ''));
    r.check('H3', c.want > 0 && c.want === c.got, `${url}: ${c.got} visible, ${c.want} expected`);
    await layout(page, `H3 ${url} honeycomb`);
    await page.shot(`${SHOTS}${shot}.png`);
  }
  await page.open(`${BASE}proto-projects.html#Supply%20Chains`, { height: 1100, reduced: true });
  const sc = await page.eval(`(() => {
    const cats = t => decodeURIComponent(atob(t.getAttribute('data-categories'))).split(',').map(s => s.trim());
    const all = [...document.querySelectorAll('.quarto-listing-container-grid .g-col-1')];
    return { want: all.filter(t => cats(t).includes('Supply Chains')).length,
             got: all.filter(t => getComputedStyle(t).display !== 'none').length };
  })()`);
  r.check('H3', sc.want > 0 && sc.want === sc.got, `projects #Supply Chains: ${sc.got} visible, ${sc.want} expected`);
  await layout(page, 'H3 projects #Supply Chains honeycomb');
  await page.shot(`${SHOTS}hex-projects-filter-supply.png`);

  // H4: portfolio sub-filter row still appears and filters.
  await page.open(`${BASE}proto-portfolio.html`, { height: 1300, reduced: true });
  const sub = await page.eval(`(() => {
    document.querySelector('.filter-bar [data-filter="Visualisation"]').click();
    const bar = document.querySelector('.filter-sub');
    const btn = bar && [...bar.querySelectorAll('.filter-btn')].find(b => b.textContent !== 'All');
    if (!btn) return { shown: !!bar && !bar.hidden, value: null };
    btn.click();
    return { shown: !bar.hidden, value: btn.textContent };
  })()`);
  const sc2 = sub.value ? await page.eval(COUNT('type', 'Visualisation', 'subtype', sub.value)) : { want: 0, got: -1 };
  r.check('H4', sub.shown && sc2.want > 0 && sc2.want === sc2.got, `Visualisation → ${sub.value}: ${sc2.got} visible, ${sc2.want} expected`);
  await layout(page, 'H4 sub-filter honeycomb');
  await page.shot(`${SHOTS}hex-portfolio-filter-sub.png`);

  // H5 + H10 + H11: hover every tile on both pages at two widths.
  for (const [p, width, height] of [['projects', 1440, 1500], ['portfolio', 1440, 1500], ['projects', 900, 1400], ['portfolio', 900, 1600]])
    await hoverAll(page, p, width, height);

  // Dark palette, at rest and with one tile open, for the review.
  for (const p of ['portfolio', 'projects']) {
    await page.open(`${BASE}proto-${p}.html`, { height: 1300, settle: 2600 });
    await page.eval(`document.documentElement.setAttribute('data-palette', 'editorial-dark')`);
    await sleep(600);
    await page.shot(`${SHOTS}hex-${p}-1440-dark.png`);
    const c = await page.eval(`(() => { const b = document.querySelectorAll('.quarto-listing-container-grid .g-col-1')[1].getBoundingClientRect(); return [b.x + b.width / 2, b.y + b.height / 2]; })()`);
    await page.mouse(c[0], c[1]);
    await sleep(750);
    await page.shot(`${SHOTS}hex-${p}-1440-dark-hover.png`);
    await page.mouse(1, 1);
  }

  // H6: hit area is the hexagon. The gap between two tiles hits nothing; the corner of a
  // lower tile's box that overlaps the upper tile's hexagon hits the upper tile.
  await page.open(`${BASE}proto-portfolio.html`, { reduced: true });
  const hit = await page.eval(`(() => {
    const tiles = [...document.querySelectorAll('.quarto-listing-container-grid .g-col-1')];
    const [a, b] = tiles.map(t => t.getBoundingClientRect());
    const c = tiles.find(t => t.getBoundingClientRect().top > a.top + 5);
    const cb = c.getBoundingClientRect();
    const at = (x, y) => document.elementFromPoint(x, y)?.closest('.g-col-1');
    return { gap: !at((a.right + b.left) / 2, a.top + a.height / 2), corner: at(cb.left + 6, cb.top + 6) === tiles[0] };
  })()`);
  r.check('H6', hit.gap && hit.corner, `gap hits no tile: ${hit.gap}; overlapping box corner hits the hexagon you see: ${hit.corner}`);

  // H8: status badges sit inside their hexagon and let clicks through to the tile link.
  await page.open(`${BASE}proto-projects.html`, { height: 1300, reduced: true });
  const badges = await page.eval(`[...document.querySelectorAll('.listing-status')].map(s => {
    const t = s.closest('.g-col-1'), b = s.getBoundingClientRect();
    const pts = [[b.left + 1, b.top + 1], [b.right - 1, b.top + 1], [b.left + 1, b.bottom - 1], [b.right - 1, b.bottom - 1]];
    const through = document.elementFromPoint(b.left + b.width / 2, b.top + b.height / 2)?.closest('a') === t.querySelector('a');
    return { inside: pts.every(([x, y]) => document.elementFromPoint(x, y)?.closest('.g-col-1') === t), through };
  })`);
  r.check('H8', badges.length > 0 && badges.every(b => b.inside && b.through),
    `${badges.length} badges; inside hexagon: ${badges.filter(b => b.inside).length}; clicks pass through: ${badges.filter(b => b.through).length}`);

  // H9 + H10 (phone): no hover → titles always visible and inside the hexagon.
  for (const p of ['projects', 'portfolio']) {
    await page.open(`${BASE}proto-${p}.html`, { width: 400, height: 900, reduced: true, hoverNone: true });
    const t = await page.eval(`[...document.querySelectorAll('.quarto-listing-container-grid .g-col-1')].map(t => {
      t.scrollIntoView({ block: 'center', behavior: 'instant' });   // keep clear of the fixed navbar and footer
      const b = t.querySelector('.listing-title').getBoundingClientRect();
      const pts = [[b.left + 1, b.top + 1], [b.right - 1, b.top + 1], [b.left + 1, b.bottom - 1], [b.right - 1, b.bottom - 1]];
      return { veil: getComputedStyle(t.querySelector('.card-body')).opacity,
               inside: pts.every(([x, y]) => document.elementFromPoint(x, y)?.closest('.g-col-1') === t) };
    })`);
    await page.eval('scrollTo(0, 0)');
    r.check('H9', t.every(x => x.veil === '1'), `${p} touch: titles shown on ${t.filter(x => x.veil === '1').length}/${t.length}`);
    r.check('H10', t.every(x => x.inside), `${p} touch at 400px: titles inside hexagon ${t.filter(x => x.inside).length}/${t.length}`);
    await page.shot(`${SHOTS}hex-${p}-400-touch.png`);
  }

  // H7: keyboard. Tab from the last filter button lands on the first tile, which grows
  // with an accent-underlined title; Enter opens the entry.
  await page.open(`${BASE}proto-projects.html`, { height: 1300, settle: 2400 });
  await page.eval(`document.querySelector('.filter-bar .filter-btn:last-of-type').focus()`);
  await page.key('Tab', 'Tab', 9);
  await sleep(700);
  const k = await page.eval(`(() => {
    const a = document.activeElement, t = a.closest('.g-col-1');
    if (!t) return { onTile: false, what: a.outerHTML.slice(0, 60) };
    const title = getComputedStyle(t.querySelector('.listing-title'));
    return { onTile: true, href: a.href, scale: getComputedStyle(t).scale,
             underline: title.textDecorationLine, colour: title.textDecorationColor,
             accent: getComputedStyle(document.documentElement).getPropertyValue('--accent').trim() };
  })()`);
  await page.shot(`${SHOTS}hex-projects-keyboard.png`);
  r.check('H7', k.onTile && k.scale === '1.15' && k.underline === 'underline',
    k.onTile ? `Tab → tile: scale ${k.scale}, title ${k.underline} in ${k.colour}` : `Tab landed on ${k.what}`);
  if (k.onTile) {
    await page.key('Enter', 'Enter', 13, '\r');
    let url = '';
    for (let i = 0; i < 30 && !url.includes('/projects/'); i++) {
      await sleep(200);
      try { url = await page.eval('location.href'); } catch { /* page is navigating */ }
    }
    r.check('H7', url === k.href, `Enter opened ${url.replace(BASE, '')}`);
  }

  r.check('X1', page.errors.length === 0, page.errors.length ? page.errors.join(' | ') : 'no console errors or exceptions');
});

r.print();
