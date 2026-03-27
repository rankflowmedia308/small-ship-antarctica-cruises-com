# Small Ship Antarctica Cruises

Independent editorial rankings of the best small ship Antarctica expedition cruise operators for 2026.

**Domain:** small-ship-antarctica-cruises.com

## Build

```bash
bash build.sh
```

Assembles all 7 HTML pages from `components/` + `content/` source files.

## Deploy (GitHub Pages)

```bash
git add -A
git commit -m "Update rankings"
git push
```

Pages redeploy in ~1 minute. Custom domain: `CNAME` file points to `small-ship-antarctica-cruises.com`.

## Structure

- `content/` — editable source files for each page
- `components/` — shared header and footer
- `css/` — global.css + ranking.css
- `js/nav.js` — mobile nav toggle only
- `images/` — logo.svg, hero image (add when available)
- `build.sh` — assembles built output files

**Rule:** Only edit files in `content/`, `components/`, `css/`, `images/`. Run `bash build.sh` after every change.
