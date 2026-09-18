// Throwaway test driver: headless Chrome over the DevTools protocol.
// Node 22+ ships fetch and WebSocket, so no packages are needed.
// Real time only — Chrome's --virtual-time-budget hangs on these pages at 1440px.
import { spawn } from 'node:child_process';
import { writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const PORT = 9333;
export const BASE = 'http://localhost:8765/_site/';
export const sleep = ms => new Promise(r => setTimeout(r, ms));

export async function withPage(fn) {
  const chrome = spawn(CHROME, [
    '--headless=new', `--remote-debugging-port=${PORT}`, '--hide-scrollbars',
    // No analytics hits from test runs. Fontshare's CSS API intermittently stalls ~60s
    // (seen 11 Sep 2026), which blocks page load; tests fall back to system-ui for Switzer.
    '--host-resolver-rules=MAP *.googletagmanager.com ~NOTFOUND, MAP *.google-analytics.com ~NOTFOUND, MAP api.fontshare.com ~NOTFOUND',
    `--user-data-dir=${mkdtempSync(join(tmpdir(), 'proto-chrome-'))}`, 'about:blank',
  ], { stdio: 'ignore' });
  try {
    let target;
    for (let i = 0; i < 100 && !target; i++) {
      await sleep(100);
      try { target = (await (await fetch(`http://127.0.0.1:${PORT}/json/list`)).json()).find(t => t.type === 'page'); } catch {}
    }
    if (!target) throw new Error('Chrome did not start');
    const ws = new WebSocket(target.webSocketDebuggerUrl);
    await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });

    let nextId = 0;
    const pending = new Map(), handlers = [];
    ws.onmessage = e => {
      const m = JSON.parse(e.data);
      if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
      else handlers.forEach(h => h(m));
    };
    const send = (method, params = {}) => new Promise((res, rej) => {
      const id = ++nextId;
      const timer = setTimeout(() => { pending.delete(id); rej(new Error(`${method} timed out after 30s`)); }, 30000);
      pending.set(id, m => { clearTimeout(timer); m.error ? rej(new Error(`${method}: ${m.error.message}`)) : res(m.result); });
      ws.send(JSON.stringify({ id, method, params }));
    });
    const once = method => new Promise(res => {
      const h = m => { if (m.method === method) { handlers.splice(handlers.indexOf(h), 1); res(m.params); } };
      handlers.push(h);
    });

    const errors = [];   // console errors/warnings + uncaught exceptions, across every page opened
    handlers.push(m => {
      if (m.method === 'Runtime.consoleAPICalled' && ['error', 'warning'].includes(m.params.type))
        errors.push(`${m.params.type}: ${m.params.args.map(a => a.value ?? a.description).join(' ')}`);
      if (m.method === 'Runtime.exceptionThrown')
        errors.push(`exception: ${m.params.exceptionDetails.exception?.description ?? m.params.exceptionDetails.text}`);
    });
    await send('Page.enable');
    await send('Runtime.enable');

    const page = {
      errors,
      send,
      async open(url, { width = 1440, height = 900, reduced = false, hoverNone = false, settle = 400 } = {}) {
        await send('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: 1, mobile: false });
        await send('Emulation.setEmulatedMedia', { features: [
          { name: 'prefers-reduced-motion', value: reduced ? 'reduce' : 'no-preference' },
        ] });
        // Touch emulation is what flips (hover: none) — the media-feature override above ignores it.
        await send('Emulation.setTouchEmulationEnabled', { enabled: hoverNone, maxTouchPoints: 5 });
        // Hop through about:blank so a URL that differs only by #hash still loads fresh.
        const blank = once('Page.loadEventFired');
        await send('Page.navigate', { url: 'about:blank' });
        await Promise.race([blank, sleep(2000)]);
        const loaded = once('Page.loadEventFired');
        await send('Page.navigate', { url });
        await Promise.race([loaded, sleep(20000).then(() => { throw new Error(`load timed out: ${url}`); })]);
        await page.eval('document.fonts.ready.then(() => true)');
        await sleep(settle);
      },
      async eval(expression) {
        const r = await send('Runtime.evaluate', { expression, awaitPromise: true, returnByValue: true });
        if (r.exceptionDetails) throw new Error(`eval: ${r.exceptionDetails.exception?.description ?? r.exceptionDetails.text}`);
        return r.result.value;
      },
      async shot(path) {
        const { data } = await send('Page.captureScreenshot', { format: 'png' });
        writeFileSync(path, Buffer.from(data, 'base64'));
      },
      async mouse(x, y) { await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y }); },
      async key(key, code, keyCode, text) {
        await send('Input.dispatchKeyEvent', { type: 'keyDown', key, code, windowsVirtualKeyCode: keyCode, text });
        await send('Input.dispatchKeyEvent', { type: 'keyUp', key, code, windowsVirtualKeyCode: keyCode });
      },
    };
    await fn(page);
    ws.close();
  } finally {
    chrome.kill();
  }
}

// PASS/FAIL line collector shared by the check scripts.
export function reporter() {
  const lines = [];
  return {
    check(id, ok, note = '') { lines.push(`${ok ? 'PASS' : 'FAIL'}  ${id}  ${note}`); },
    print() { console.log(lines.join('\n')); if (lines.some(l => l.startsWith('FAIL'))) process.exitCode = 1; },
  };
}
