# arq-comp.github.io

Source for the [ARQ-COMP](https://arq-comp.github.io/) website — the Competition
on Automated Reasoning for Quantum.

This file is repository documentation and is **not** published; the public
homepage is [`index.md`](index.md).

## Layout

| Path | What it is |
| --- | --- |
| `index.md` | The homepage |
| `submit-benchmarks.md` | The Submit Benchmarks page (`permalink: /submit-benchmarks/`) |
| `404.md` | Served by GitHub Pages for any missing path (`permalink: /404.html`) |
| `assets/icons/` | Favicons — the Bloch sphere cropped out of the logo, light and dark |
| `_config.yml` | Site config, and the `exclude:` list that keeps drafts off the live site |
| `_layouts/default.html` | Page shell — sidebar, nav, theme switch. Forked from the Dinky theme's own layout |
| `assets/css/style.scss` | All styling: theme tokens, dark mode, and the overrides on top of Dinky |
| `logo/` | Logo artwork — see below |
| `Gemfile`, `Gemfile.lock` | Local previews only; GitHub Pages ignores both |

The theme is [Dinky](https://github.com/pages-themes/dinky), pinned via
`remote_theme: pages-themes/dinky@v0.2.0`. Everything in `assets/css/style.scss`
loads *after* the theme, so overrides win on source order alone.

## Adding a page

1. Create `your-page.md` with front matter:
   ```yaml
   ---
   layout: default
   title: Your Page
   permalink: /your-page/
   ---
   ```
2. Add a link to the sidebar list in `_layouts/default.html` — the nav is
   currently hardcoded there.

## Logos

| File | Role |
| --- | --- |
| `logo6-fixed-512.png` | Light mode, used by the site |
| `logo6-dark-512.png` | Dark mode, used by the site |
| `logo6-fixed.png`, `logo6-dark.png` | Full-resolution sources (1254px) |
| `logo1`–`logo5`, `logo6` | Superseded drafts, excluded from the build |

The dark variant is the light one with its lightness remapped in HLS; hue,
gradient direction and alpha are preserved, so it is the same mark rather than
an inversion. Regenerating it means redoing that transform, not editing the PNG
by hand.

## Icons

`assets/icons/` holds the Bloch sphere cropped out of the logo, in a light and a
dark variant apiece. The layout offers each pair through a `media` query for
`prefers-color-scheme` on the `<link rel="icon">`, so the browser picks one — the
mark is tinted artwork, and a single version disappears against one chrome or
the other.

| File | Where it is used |
| --- | --- |
| `favicon-32-{light,dark}.png` | The tab strip |
| `icon-180-{light,dark}.png` | Bookmarks and high-DPI tabs |
| `apple-touch-icon.png` | iOS home screen; opaque, no alpha |

Both sizes are derived from the 1254px masters in `logo/`, and two things about
that derivation are easy to get wrong:

- **A plain area-average downscale destroys the mark.** The wireframe is
  sub-pixel thin at 32px, so averaging spreads each stroke's alpha across its
  whole block: the first version of these icons ended up with a mean alpha of
  24/255 and a single pixel above 159, which is invisible on any background.
  Coverage has to lean on the *maximum* alpha in each block, not the mean, or
  thin strokes do not survive. The current 32px pair takes
  `max(mean * 8.0, blockmax * 0.25)`; weighting the mean term that much higher
  than the max keeps the continuous strokes dominant and leaves the dashed guide
  ellipses subdued, which is what stops the icon reading as a busy ball.
- **The framing is size-specific, deliberately.** The 32px pair is cropped to
  the sphere alone — a square of half-width 336 about (619, 515) in the master,
  which is the circle's radius of 327 plus a 9px margin. The axis labels (`z`,
  `x`, `y`, `|0>`, `|1>`) are illegible at that size and only spend contrast, so
  they are cropped away. The 180px pair keeps the wider framing that includes
  them, matching `apple-touch-icon.png`; the tight crop would chop the `z`
  arrowhead there.

The dark variants also get their ink lifted 25% toward white, on top of the HLS
remap the footer logo uses. That remap was tuned against the page ground
(`#11141a`), and a browser's dark tab strip is much lighter — Chrome's is about
`#35363a` — so the footer tone alone lands under 4.5:1 there.

## Colour theme

The site follows the visitor's OS setting by default and offers a Light/Dark
switch in the sidebar. There are three CSS states, which is what makes that
work:

- `:root` — light
- `:root:not([data-theme="light"])` inside `@media (prefers-color-scheme: dark)` — the OS default
- `:root[data-theme="dark"]` — an explicit choice, which beats the OS

No `data-theme` attribute means "follow the OS". The choice is stored in
`localStorage` under `arq-theme`; an inline snippet in `<head>` applies it
before first paint so there is no flash of the light page.

## Building locally

```sh
bundle install
bundle exec jekyll serve   # http://127.0.0.1:4000
```

Needs a reasonably current Ruby (3.2+) and network access on first run, since
`remote_theme` fetches Dinky from GitHub.

> [!NOTE]
> **A local build is close to production, but not identical.** GitHub Pages
> ignores this `Gemfile` and builds with its own pinned environment, still on
> Jekyll 3.10; locally we use Jekyll 4.4. Liquid, SCSS and content behave the
> same, so a local preview is trustworthy for anything you are likely to
> change — but Jekyll 3-vs-4 edge cases will not show up until deploy.
>
> The `github-pages` metagem, which would make the two match, is deliberately
> not used: it pins a 2013-era dependency tree whose native extensions no
> longer compile, so `bundle install` fails outright with it.

This is only an escape hatch for checking a change before it is public — the
published site is always built and served by GitHub.

## Deploying

Push to `master`. GitHub Pages builds and publishes automatically, usually
within a minute.

Nothing else checks the build first. If it fails, Pages simply does not
publish, so breakage looks like the site going stale rather than like an error
— though GitHub does email whoever pushed. Running `bundle exec jekyll build`
once beforehand avoids that, and is worth it if you have touched the layout,
the stylesheet or a page's front matter.
