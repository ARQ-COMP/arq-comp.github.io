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
