#!/usr/bin/env python3
"""Overlay + heatmap diff between qa/ref/<s>.png and qa/app/<s>.png.

Usage: python3 tools/diff.py [name ...]   (default: all in qa/app)
Writes qa/out/<s>.overlay.png (ref @50% over app) and <s>.diff.png (heatmap),
prints a foreground mismatch %.

Per-screen config (CONF): crop_top removes the status-bar strip from BOTH images
so content aligns with no global shift; masks zero out excluded content (the QR
camera viewport interior, placeholder photo grids, mono session ids) before the %.
"""
import sys, os
from PIL import Image
import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REF = os.path.join(ROOT, 'qa', 'ref')
APP = os.path.join(ROOT, 'qa', 'app')
OUT = os.path.join(ROOT, 'qa', 'out')
os.makedirs(OUT, exist_ok=True)

# fractions (0..1) of the frame. crop_top: strip removed from top of both.
# masks: (x0,y0,x1,y1) regions excluded from the % (content, not chrome).
CONF = {
    'onboarding':       {'crop_top': 0.055, 'masks': []},
    'empty':            {'crop_top': 0.055, 'masks': []},
    'select_images':    {'crop_top': 0.055, 'masks': [(0.0, 0.42, 1.0, 0.95)]},
    'qr':               {'crop_top': 0.055, 'masks': [(0.18, 0.30, 0.82, 0.62)]},
    'qr_timeout':       {'crop_top': 0.055, 'masks': [(0.20, 0.28, 0.80, 0.58)]},
    'qr_nointernet':    {'crop_top': 0.055, 'masks': [(0.18, 0.28, 0.82, 0.58)]},
    'transfer_progress':{'crop_top': 0.055, 'masks': [(0.0, 0.38, 1.0, 0.92)]},
    'transfer_complete':{'crop_top': 0.055, 'masks': [(0.0, 0.38, 1.0, 0.80)]},
    'dialog_permission':{'crop_top': 0.0, 'masks': []},
    'dialog_exit':      {'crop_top': 0.0, 'masks': []},
    'dialog_share':     {'crop_top': 0.0, 'masks': []},
}


def run(name):
    rp, ap = os.path.join(REF, name + '.png'), os.path.join(APP, name + '.png')
    if not os.path.exists(rp) or not os.path.exists(ap):
        print(f'{name}: missing ref or app'); return
    cfg = CONF.get(name, {'crop_top': 0.0, 'masks': []})

    app = Image.open(ap).convert('RGB')
    ref = Image.open(rp).convert('RGB').resize(app.size)
    w, h = app.size

    # crop the status-bar strip from both (chrome, never a target)
    top = int(h * cfg['crop_top'])
    if top:
        app = app.crop((0, top, w, h))
        ref = ref.crop((0, top, w, h))
        h -= top

    a = np.asarray(app).astype(np.int16)
    r = np.asarray(ref).astype(np.int16)
    d = np.abs(a - r).astype(np.uint8)

    Image.blend(app, ref, 0.5).save(os.path.join(OUT, name + '.overlay.png'))
    hm = np.clip(d.astype(np.int16) * 3, 0, 255).astype(np.uint8)
    Image.fromarray(hm).save(os.path.join(OUT, name + '.diff.png'))

    gray = d.mean(axis=2)
    keep = np.ones((h, w), bool)
    for (x0, y0, x1, y1) in cfg['masks']:
        keep[int(y0 * h):int(y1 * h), int(x0 * w):int(x1 * w)] = False
    mismatch = (gray[keep] > 24).mean() * 100 if keep.any() else 0.0
    print(f'{name}: {mismatch:5.1f}% foreground differs  '
          f'(masked {100*(1-keep.mean()):.0f}%)')


if __name__ == '__main__':
    names = sys.argv[1:] or [f[:-4] for f in sorted(os.listdir(APP)) if f.endswith('.png')]
    for n in names:
        run(n)
