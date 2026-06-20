#!/usr/bin/env python3
"""Overlay + heatmap diff between qa/ref/<s>.png and qa/app/<s>.png.

Usage: python3 tools/diff.py [name ...]   (default: all in qa/app)
Writes qa/out/<s>.overlay.png (ref @50% over app) and <s>.diff.png (heatmap),
prints a foreground mismatch % (top region only, to discount the bg glow).
"""
import sys, os
from PIL import Image
import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REF = os.path.join(ROOT, 'qa', 'ref')
APP = os.path.join(ROOT, 'qa', 'app')
OUT = os.path.join(ROOT, 'qa', 'out')
os.makedirs(OUT, exist_ok=True)


def load(p):
    return Image.open(p).convert('RGB')


def run(name):
    rp, ap = os.path.join(REF, name + '.png'), os.path.join(APP, name + '.png')
    if not os.path.exists(rp):
        print(f'{name}: NO REF'); return
    if not os.path.exists(ap):
        print(f'{name}: NO APP shot'); return
    ref = load(rp)
    app = load(ap)
    # resize ref to app dims (app is the real renderer / ground for geometry)
    ref = ref.resize(app.size)
    a = np.asarray(app).astype(np.int16)
    r = np.asarray(ref).astype(np.int16)
    d = np.abs(a - r).astype(np.uint8)

    # overlay: ref at 50% over app
    ov = Image.blend(app, ref, 0.5)
    ov.save(os.path.join(OUT, name + '.overlay.png'))

    # heatmap (amplified)
    hm = np.clip(d.astype(np.int16) * 3, 0, 255).astype(np.uint8)
    Image.fromarray(hm).save(os.path.join(OUT, name + '.diff.png'))

    # foreground mismatch %: per-pixel mean abs diff > threshold
    gray = d.mean(axis=2)
    mismatch = (gray > 24).mean() * 100
    print(f'{name}: {mismatch:5.1f}% pixels differ  ({app.size[0]}x{app.size[1]})')


if __name__ == '__main__':
    names = sys.argv[1:] or [f[:-4] for f in sorted(os.listdir(APP)) if f.endswith('.png')]
    for n in names:
        run(n)
