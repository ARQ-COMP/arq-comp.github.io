# arq-comp.github.io

Source for the [ARQ-COMP](https://arq-comp.github.io/) website — the Competition
on Automated Reasoning for Quantum.

This file is repository documentation and is **not** published; the public
homepage is [`index.md`](index.md).

## Layout

| Path | What it is |
| --- | --- |
| `index.md` | The homepage |
| `submit-benchmarks.md` | The Call for problems/benchmarks/comments page (`permalink: /submit-benchmarks/`) |
| `404.md` | Served by GitHub Pages for any missing path (`permalink: /404.html`) |
| `assets/icons/` | Favicons — the Bloch sphere cropped out of the logo, light and dark |
| `assets/fonts/` | Inter, self-hosted and subsetted, with the OFL text the licence requires |
| `_data/nav.yml` | The sidebar navigation — the single source for it, used by the layout and `404.md` |
| `_config.yml` | Site config, and the `exclude:` list that keeps drafts off the live site |
| `_layouts/default.html` | Page shell — sidebar, nav, theme switch. Forked from the Dinky theme's own layout |
| `assets/css/style.scss` | All styling: theme tokens, dark mode, and the overrides on top of Dinky |
| `_sass/jekyll-theme-dinky.scss` | Dinky's own stylesheet, vendored to drop one line — see below |
| `assets/img/` | Logo artwork the site renders — see below |
| `_design/` | Logo masters and superseded drafts; never published, because of the underscore |
| `Gemfile`, `Gemfile.lock` | Local previews only; GitHub Pages ignores both |
| `LICENSE` | The MIT licence text, and nothing else, so it is detected as MIT |
| `NOTICE` | What that licence covers and does not, plus the theme and font attributions |

The theme is [Dinky](https://github.com/pages-themes/dinky), pinned via
`remote_theme: pages-themes/dinky@v0.2.0`. Everything in `assets/css/style.scss`
loads *after* the theme, so overrides win on source order alone.

Dinky's stylesheet itself is **vendored** at `_sass/jekyll-theme-dinky.scss`,
and `style.scss` imports it by that name rather than as `{{ site.theme }}`. The
copy is the upstream file with a single line deleted — its
`@import url(...fonts.googleapis.com...)` for Arvo, which was the last thing on
the site reaching a third party and could not be removed from outside, since a
CSS `@import` is always fetched and Sass cannot suppress one declared by a file
it imports. Importing by name is what makes the shadowing work: the site's
`_sass` is searched before the theme's, whereas the theme's own placeholder
resolved the name next to itself.

> [!IMPORTANT]
> If `remote_theme` is ever moved off `v0.2.0`, re-vendor that file from the new
> tag. Otherwise the site silently keeps serving v0.2.0's rules.

## Adding a page

1. Create `your-page.md` with front matter:
   ```yaml
   ---
   layout: default
   title: Your Page
   permalink: /your-page/
   ---
   ```
2. Add an entry to [`_data/nav.yml`](_data/nav.yml). That is the only place the
   navigation lives: the sidebar in `_layouts/default.html` and the recovery
   links on `404.md` are both generated from it, and the entry whose `url`
   matches the current page gets `aria-current="page"` automatically.

## Logos

Artwork is split by directory, and that split is the whole point: `assets/img/`
is published, `_design/` never is, because Jekyll skips directories whose names
begin with an underscore.

| File | Role |
| --- | --- |
| `assets/img/logo-light-390.png` | Light mode, rendered in the footer |
| `assets/img/logo-dark-390.png` | Dark mode, rendered in the footer |
| `assets/img/social-card.png` | The `og:image` social card, composed for 1200×630 |
| `_design/logo6-fixed.png`, `logo6-dark.png` | The 1254px masters everything is derived from |
| `_design/logo-light-512.png`, `logo6-dark-512.png` | Square 512px exports, unreferenced since the card replaced them |
| `_design/logo1`–`logo5`, `logo6` | Superseded drafts |

`_config.yml` used to carry nine `exclude:` lines for this artwork, and the list
defaulted to publishing: a draft dropped in the wrong place went live until
somebody noticed. Nothing needs remembering now — put working files in
`_design/`, and only what the site renders in `assets/img/`.

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
| `apple-touch-icon.png` | iOS home screen; opaque, no alpha |

A 180x180 pair used to sit alongside these, declared for bookmarks and
high-DPI tabs. Watching the network showed nothing ever requested it -- the
32px file serves the tab and iOS takes the touch icon -- so it was removed.

Both sizes are derived from the 1254px masters in `_design/`, and two things about
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

## Fonts

Both faces are **self-hosted and subsetted**: Inter for body copy, Arvo for
headings, all in `assets/fonts/`.

Inter used to come from Google too, as two subset files totalling 130 KB — 47 KB
of `latin`, plus 83 KB of `latin-ext` that the page fetched for a single
character, the r-caron in one organizer's name. Subsetting the upstream variable
font to latin plus Latin Extended-A, with the weight axis clamped to the 400–700
the site uses, gives **one 31 KB file**. The `@font-face` block at the top of
`assets/css/style.scss` carries the exact `fonttools` commands to regenerate it.

Two consequences worth knowing:

- The bundled file makes this repository a redistributor of Inter, so the OFL
  text must travel with it — hence `assets/fonts/Inter-OFL.txt`. Do not delete
  it, and see [`NOTICE`](NOTICE).
- Latin Extended-A is deliberately wider than the current content needs. It
  covers Central and Western European names in general, so a new organizer or a
  cited author does not silently fall back to a system font. Content outside
  that range — Greek, Cyrillic, Vietnamese — would.

Arvo got the same treatment, at 10 KB per face against the 16.9 KB Google served
for one. Two caveats specific to it:

- **Arvo has almost no Latin Extended-A.** No r-caron, e-caron or u-ring, so a
  *heading* containing Czech falls back to a system serif for those letters.
  That was equally true of Google's copy — it is the typeface, not the subset.
- Dinky `@import`s Arvo's stylesheet from Google at the top of its own CSS, and
  that cannot be removed without giving up importing Dinky. It still costs a
  0.8 KB request, but it only *declares* faces, and the declarations in
  `style.scss` come later and win — so nothing is fetched from
  `fonts.gstatic.com`. Confirmed by watching the network: zero requests to it.

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

## Verifying a visual change

There is no browser automation configured. What works is driving a local
headless Chromium over the DevTools protocol. On Ubuntu, Chromium is a snap
(`sudo snap install chromium`); the `chromium` apt package no longer exists and
`chromium-browser` is only a shim for the snap.

For a plain screenshot, the one-shot flag is enough:

```sh
bundle exec jekyll serve --port 4321 --detach
mkdir -p "$HOME/cdp-work"
chromium --headless --no-sandbox --disable-gpu \
  --screenshot="$HOME/cdp-work/home.png" --window-size=1100,820 \
  http://127.0.0.1:4321/
```

Spell that path with `$HOME`, not `~`: the shell does not expand a tilde after
an `=` in an argument, so `--screenshot=~/cdp-work/home.png` reaches Chromium
literally and writes nothing.

For anything the flag cannot express — emulating `prefers-color-scheme`,
resizing to a phone viewport, reading computed styles — start Chromium with
`--remote-debugging-port=9222`, take the page target from
`http://127.0.0.1:9222/json/list`, and speak CDP to its WebSocket. A ~90-line
stdlib-only client is enough (`socket` plus manual frame masking); no
`websocket` or `playwright` package is installed. The useful calls are
`Emulation.setDeviceMetricsOverride`, `Emulation.setEmulatedMedia` for
`prefers-color-scheme`, `Runtime.evaluate` for computed styles and rects,
`Page.captureScreenshot`, and `Network.enable` with `Network.requestWillBeSent`
to see what actually gets fetched.

Four things will waste your time, in rough order of how long they cost:

- **Do not settle on `document.readyState` alone after `Page.navigate`.**
  `about:blank` is *already* `"complete"`, so a poll started right after the
  navigate returns on its first iteration and you screenshot and measure the
  previous page. This reads exactly like a broken stylesheet: computed link
  colour comes back as the UA default `rgb(0, 0, 238)` and `body` as
  `rgba(0, 0, 0, 0)`. Require the location to have actually changed and
  `document.styleSheets.length > 0` as well.
- **The snap can only see non-hidden paths under `$HOME`.** `/tmp` and any
  dotted directory are invisible to it. So `--screenshot=/tmp/x.png` exits 0 and
  silently writes nothing (the reason is in stderr: `Failed to write file ...
  Permission denied`), and a `--user-data-dir` pointing at a dotted path is
  ignored rather than honoured — the profile lands in
  `~/snap/chromium/common/chromium` instead. A CDP client is unaffected, because
  there *your* process writes the file, not Chromium's.
- **Only one snap Chromium runs at a time.** Because `--user-data-dir` is
  ignored, a second invocation collides on the shared profile's `SingletonLock`
  and aborts with `Failed to create a ProcessSingleton for your profile
  directory`. Stop the first one before launching another.
- **`pkill -f 'remote-debugging-port=9222'` kills the shell that runs it**, since
  the pattern matches that command's own arguments. Use `pkill -x chromium`.

> [!IMPORTANT]
> **The favicons cannot be checked this way.** They render in the browser's tab
> strip, which is chrome, not page content — a headless screenshot captures the
> viewport only and will never show them. Judge them by compositing the PNG onto
> the tab-strip greys and measuring contrast (see [Icons](#icons)), then confirm
> by opening the deployed site in a normal window and looking at the tab.

To compare against what is already deployed, build a pre-change copy with
`git archive HEAD | tar -x -C <dir>` and serve it on a second port.

## Deploying

Push to `master`. GitHub Pages builds and publishes automatically, usually
within a minute.

Nothing else checks the build first. If it fails, Pages simply does not
publish, so breakage looks like the site going stale rather than like an error
— though GitHub does email whoever pushed. Running `bundle exec jekyll build`
once beforehand avoids that, and is worth it if you have touched the layout,
the stylesheet or a page's front matter.

## Licence

The source of the site is under MIT. It is split across two files on purpose:

- [`LICENSE`](LICENSE) holds the licence text and nothing else. Anything
  appended to it -- even a scope note -- stops GitHub's detector recognising
  the file, and the repository then reports `NOASSERTION` instead of `MIT`.
- [`NOTICE`](NOTICE) holds everything that would otherwise have been appended:
  what the licence covers, what it does not, and what the site is built on.

Two things are outside the licence, and `NOTICE` says so: the logo and the
favicons cropped from it are the competition's identity and are not licensed
for reuse, and the GitHub mark in the sidebar is GitHub's trademark rather than
ours to license.

`NOTICE` also attributes the [Dinky theme](https://github.com/pages-themes/dinky).
Dinky is CC0 1.0 and asks for nothing, but this site is a real derivative of it
-- the layout started as a copy of Dinky's, and the stylesheet imports Dinky's
and restates its rules -- so the attribution is recorded deliberately.
