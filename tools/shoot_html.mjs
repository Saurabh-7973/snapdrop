// Render each mockup at DPR 3 and screenshot every .phone frame, clipped.
// Output -> qa/ref/<name>.png  (boards with 2 frames -> <name>-1.png/<name>-2.png)
import { chromium } from 'playwright';
import { fileURLToPath } from 'url';
import path from 'path';
import fs from 'fs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const mockDir = path.join(root, 'snapdrop_mockups');
const outDir = path.join(root, 'qa', 'ref');
fs.mkdirSync(outDir, { recursive: true });

// mockup file -> output base name(s). Boards have 2 frames (index order on page).
const MAP = {
  'snapdrop_select_images_faithful.html': ['select_images'],
  'snapdrop_qr_faithful.html': ['qr'],
  'snapdrop_onboarding_inlanguage.html': ['onboarding'],
  'snapdrop_empty_inlanguage.html': ['empty'],
  'snapdrop_transfer_faithful.html': ['transfer_progress', 'transfer_complete'],
  'snapdrop_qr_edge_states.html': ['qr_timeout', 'qr_nointernet'],
  'snapdrop_dialogs_inlanguage.html': ['dialog_permission', 'dialog_exit', 'dialog_share'],
};

const browser = await chromium.launch();
const ctx = await browser.newContext({ deviceScaleFactor: 3 });
const page = await ctx.newPage();

for (const [file, names] of Object.entries(MAP)) {
  const url = 'file://' + path.join(mockDir, file);
  await page.goto(url, { waitUntil: 'networkidle' });
  await page.waitForTimeout(300); // let fonts/gradients settle
  const phones = await page.$$('.phone');
  if (phones.length < names.length) {
    console.warn(`! ${file}: found ${phones.length} .phone, expected ${names.length}`);
  }
  for (let i = 0; i < names.length; i++) {
    const el = phones[i];
    if (!el) continue;
    const out = path.join(outDir, names[i] + '.png');
    await el.screenshot({ path: out });
    const box = await el.boundingBox();
    console.log(`${names[i]}.png  ${Math.round(box.width)}x${Math.round(box.height)} (css)`);
  }
}

await browser.close();
console.log('done -> qa/ref/');
