# Working notes for Claude Code

Context for picking this repository up mid-stream. `README.md` is the human-facing
documentation; this file is the things that are not obvious from the code and have
already cost time to discover.

Neither file is published — both are in `exclude:` in `_config.yml`.

## What this is

The website for ARQ-COMP, the Competition on Automated Reasoning for Quantum, at
<https://arq-comp.github.io/>. A three-page Jekyll site on the
[Dinky](https://github.com/pages-themes/dinky) theme, pinned via
`remote_theme: pages-themes/dinky@v0.2.0`.

Organizers: Johannes K. Fichte and Ondřej Lengál.

## How it deploys, and what follows from that

Push to `master`; GitHub Pages builds and publishes automatically, usually within a
minute. There is no CI.

The consequences are worth internalising, because several of them have caused real
bugs here:

- **Pages ignores `Gemfile` and `Gemfile.lock` entirely.** It builds with its own
  pinned environment, still on Jekyll 3.10. Changing the Gemfile cannot affect
  production.
- **Pages force-enables a set of plugins** regardless of `_config.yml`. Declaring
  `plugins:` is *additive*, it does not disable them — verified by the fact that
  `jekyll-github-metadata` still populates the stylesheet cache-buster.
- **A failed build does not publish and does not error visibly.** It looks like the
  site going stale. GitHub emails whoever pushed.
- **Local builds are Jekyll 4.4, production is 3.10.** Liquid, SCSS and content
  behave the same; version edge cases will not show up until deploy.

## Local development

```sh
bundle install
bundle exec jekyll serve   # http://127.0.0.1:4000
```

This works on current Ruby. The `github-pages` metagem is deliberately *not* used —
it pins a 2013-era dependency tree whose native extensions no longer compile, and
`bundle install` fails outright with it. That is why the Gemfile names Jekyll
directly.

Any Pages plugin that changes *output* must be listed in both `Gemfile` and
`_config.yml`, or local builds will quietly disagree with production. That is not
hypothetical: see the `jekyll-titles-from-headings` entry under Gotchas.

## Verifying a visual change

There is no browser automation configured, and the Chrome extension was declined.
What works is driving the locally installed Brave over the DevTools protocol:

```sh
bundle exec jekyll serve --port 4321 --detach
"/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
  --headless=new --no-sandbox --user-data-dir=/tmp/bt \
  --remote-debugging-port=9222 about:blank &
```

Then speak CDP over a WebSocket to the target from `http://127.0.0.1:9222/json/list`.
A ~60-line stdlib-only client is enough (`socket` + manual frame masking); no
`websocket` or `playwright` package is installed. Useful calls:
`Emulation.setDeviceMetricsOverride`, `Emulation.setEmulatedMedia` for
`prefers-color-scheme`, `Runtime.evaluate` for computed styles and rects,
`Page.captureScreenshot`, and `Network.enable` + `Network.requestWillBeSent` to see
what actually gets fetched.

**Brave's `--screenshot` and `--dump-dom` flags hang and produce nothing** — do not
waste time on them. The debugging port works fine.

To compare against what is deployed, build a pre-change copy with
`git archive HEAD | tar -x -C <dir>` and serve it on a second port.

## Repository map

| Path | Notes |
| --- | --- |
| `index.md` | Homepage. `title:` must stay `ARQ-COMP` — see Gotchas |
| `submit-benchmarks.md` | `permalink: /submit-benchmarks/` |
| `404.md` | `permalink: /404.html`, which is the path Pages serves |
| `_layouts/default.html` | Fork of Dinky's own layout. Nav, theme switch, GitHub button, both inline scripts |
| `assets/css/style.scss` | Theme tokens, dark mode, all overrides on top of Dinky |
| `assets/icons/` | Favicons, cropped to the Bloch sphere from the logo |
| `logo/` | Two `-512` web exports (used), two 1254px masters and six drafts (all excluded from the build) |

## How the theming works

Dinky hardcodes colours as literals, so a token layer is defined in
`assets/css/style.scss` and the affected theme rules are restated through `var()`.
Everything sits after the `@import`, so **plain source order wins the cascade** — no
`!important` anywhere. Keep it that way.

Three CSS states, which is what makes "follow the OS, but overridable" work:

- `:root` — light
- `:root:not([data-theme="light"])` inside `@media (prefers-color-scheme: dark)` — the OS default
- `:root[data-theme="dark"]` — an explicit choice, beating the OS

**No `data-theme` attribute means "follow the OS", and that is the default state.**
The choice lives in `localStorage` under `arq-theme`; an inline snippet in `<head>`
applies it before first paint so there is no flash. The dark palette is written once
as a SCSS mixin and included in both dark contexts.

## Gotchas that have already bitten

- **`jekyll-titles-from-headings` runs on Pages but not by default locally.** It lifts
  a page's first `<h1>` into `page.title`. This shipped a wrong `<title>` once: local
  builds looked correct and production did not. It is now in the Gemfile and
  `_config.yml` so the two agree.
- **`jekyll-seo-tag` only emits `<site.title> | <site.description>`** when `page.title`
  equals `site.title`. Any other homepage title produces the doubled
  `<page title> | ARQ-COMP`. Hence `title: ARQ-COMP` in `index.md`.
- **A custom `exclude:` merges with Jekyll's defaults**, it does not replace them, so
  `Gemfile` and friends stay unpublished. Verified.
- **`prefers-color-scheme` applies while printing too.** The print block must name
  every selector that can carry the dark palette, at matching specificity, or a
  dark-OS visitor prints a black page.
- **`<button>` gets `box-sizing: border-box` from the UA stylesheet, `<a>` does not.**
  Two controls with identical width/height/border rendered 2px apart until
  `.icon-button` set it explicitly.
- **Dinky's responsive rules fight this site's layout.** Its 960px breakpoint sets
  `header, section, footer { width: auto }`, so any unconditional width rule here
  beats it at every viewport — that broke mobile for months. The two-column widths
  are now scoped to `@media screen and (min-width: 961px)`; **keep them scoped.**
  Between 720px and 960px Dinky also pins `header ul` to `position: absolute`, which
  is undone in the 960px block.
- **`loading="lazy"` is load-bearing on the two logo `<img>`s.** A hidden image is
  never in the viewport, so it is never fetched; that is what stops both logos being
  downloaded on every page load. Removing it doubles the image payload.
- **HTML comments in the layout ship to visitors.** Use Liquid `{% comment %}` for
  maintainer notes.

## Decisions to respect

These were asked for explicitly. Do not reintroduce them without being asked:

- **No GitHub Actions workflow, no CI.** Added once, removed on request.
- **No git hooks.** A `.githooks/pre-push` was added and removed on request.
- **No Makefile.** Same.
- Building and serving are GitHub's job; the Gemfile is only an escape hatch for
  previewing locally.
- Dark mode uses a plain Light/Dark switch with no third "System" position; the
  default before any click follows the OS.
- In dark mode the sidebar drops the navy for neutral `#191d25` (this was chosen from
  a preview of three options).
- The dark logo is the light one with its lightness remapped in HLS — hue, gradient
  direction and alpha preserved. It is not an inversion, and regenerating it means
  redoing that transform rather than editing the PNG.

Commit messages here follow the existing history: an imperative subject line, then a
body explaining *why*, wrapped at ~72 characters.

## Current state

All work is deployed and verified live. Infrastructure is well ahead of content.

**Content gaps** — these are the real blockers, not the structural items below:

- Every entry in Important Dates is "To be announced".
- News is empty.
- `submit-benchmarks.md` is a single under-construction line, and it is the page
  participants get sent to.

**Known open items**, roughly in order of value:

1. **Accessibility.** Every page has two `<h1>` (the sidebar title and the page
   heading), no `<main>` landmark, no `<nav>` landmark, no skip link, and no
   `aria-current` on the active nav item.
2. **The nav is hardcoded** in `_layouts/default.html`, and `404.md` hand-links two
   pages as well. Moving the list to `_data/nav.yml` fixes both and gives
   `aria-current` for free.
3. **`logo/` mixes drafts, masters and web exports**, with publication decided by a
   hand-maintained `exclude:` list that defaults to publishing if forgotten. Splitting
   into `assets/img/` and a never-published `_design/` would remove the list. Note
   this changes public logo URLs.
4. **No sitemap and no `og:image`.** `jekyll-sitemap` is not among the Pages defaults;
   adding it to `plugins:` and setting a default `image:` in `_config.yml` covers both.
5. **The layout fork is unlabelled** — nothing records that it is a copy of Dinky's
   layout or which version.

`/logo/logo6-fixed.png` and `/logo/logo6-dark.png` were public URLs from August until
they were excluded from the build; restore them if anything external turns out to cite
them.
