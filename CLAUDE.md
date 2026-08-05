# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Course website for the UF "Ecological Forecasting & Dynamics" course (https://course.naturecast.org), taught by Morgan Ernest and Ethan White. It is a [Quarto](https://quarto.org/) website. The repository is almost entirely **course content** (markdown lessons + data files); there is no application code, no test suite, and no linting.

The site was migrated from Hugo + HugoBlox (Wowchemy) to Quarto. Anything still referring to Hugo, Wowchemy, HugoBlox, widgets, or a `content/` directory is stale.

`paper.md` / `paper.bib` are the JOSE paper describing the course; they are not part of the site build.

## Commands

```sh
quarto preview                       # local preview with live reload
quarto render                        # production build into _site/
Rscript scripts/build_schedule.R     # regenerate the schedule table by hand (rarely needed)
```

Building requires Quarto (1.8 or newer) and R. R is needed only for the schedule pre-render script, which uses base R and no packages — the R *tutorials* are still not executed, see "R code is not executed" below.

Deployment runs in GitHub Actions (`.github/workflows/publish.yml`), not on Netlify: it installs R and Quarto, renders, and uploads `_site` to Netlify. Pushes to `main` publish to production; pull requests get a preview deploy commented on the PR. `netlify.toml` sets `ignore = "exit 0"` so Netlify skips its own build, which would fail for lack of R. Requires `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` repository secrets.

## Content architecture

### Lessons

Each lesson is a directory in `lessons/<lesson-slug>/`. Create new ones by copying `lessons/LessonTemplate/`, which defines the standard set of pages and their `order` within a lesson:

| File | order | Purpose |
| --- | --- | --- |
| `index.qmd` | — | Lesson landing page: title, learning-objectives callout, `listing:` of the lesson's pages |
| `material.qmd` | 1 | Readings, data downloads, software setup |
| `discussion_questions.qmd` | 2 | Conceptual lessons only |
| `r_tutorial.qmd` | 3 | R lessons only |
| `instructor_notes.qmd` | 4 | Conceptual lessons only |

Two lesson flavors exist and are not mixed: **conceptual** lessons (paper discussion → `discussion_questions.qmd` + `instructor_notes.qmd`) and **R tutorial** lessons (slug prefixed `R-` → `r_tutorial.qmd`).

Front matter is `title`, optional `description` (shown in listings), and `order`. The `order` on a lesson's `index.qmd` controls its position on the Lessons page; it is independent of the teaching order on the Schedule page.

**Adding a lesson requires two edits**: create the folder, and add a `section:` entry to `website.sidebar` in `_quarto.yml`. The sidebar is explicit rather than auto-generated because teaching order is not alphabetical. The Lessons landing page (`lessons/index.qmd`) picks up new lessons automatically via its `listing:` sorted on `order`.

### Schedule

`schedule/schedule.csv` is the source of truth: one row per class meeting, with columns `date`, `lesson`, `kind`.

- `kind: lesson` — `lesson` must exactly match a lesson `index.qmd`'s `title:`, and renders as a link.
- `kind: event` — a meeting with no lesson page (project work days, presentations), rendered as plain text.

`scripts/build_schedule.R` reads the CSV and writes `schedule/_schedule_table.md`, which `schedule/index.qmd` pulls in with `{{< include >}}`. The Description column is pulled from each lesson's `description:` front matter rather than stored in the CSV, so editing a lesson's description updates both the Lessons page and the Schedule. Rows with `kind: event` get a blank description.

**You do not need to run the script by hand.** It is wired up as `pre-render` in `_quarto.yml`, so every `quarto render` and `quarto preview` regenerates the table from the CSV first. An unmatched title exits nonzero and aborts the entire render, which is deliberate — the Hugo version this replaced silently degraded typo'd titles into greyed-out placeholder rows.

Two things to know about this setup:

- **The generated file is still committed.** Quarto resolves `{{< include >}}` while enumerating project inputs, which happens *before* pre-render runs, so the file has to already exist. If it ever goes missing the render fails with "could not find file" — run `Rscript scripts/build_schedule.R` once to bootstrap it. CI separately fails the build if the committed copy is stale relative to the CSV.
- The script is base R with no packages and no YAML parser (it reads `title:` with a regex), so CI only has to install R itself.

### R code is not executed

`execute: enabled: false` in `_quarto.yml`. R chunks are syntax-highlighted and displayed but never run, which matches the pre-migration behaviour — the site has never shown computed output or plots, and there are no figures in the lessons.

**Building still requires the `knitr` and `rmarkdown` packages.** Disabling execution does not stop Quarto from selecting the knitr *engine* for any file containing ```` ```{r} ```` chunks, and that engine has to be installed to process the file at all. Six tutorials currently trigger this. CI installs the two packages explicitly; locally you will usually already have them. Setting `engine: markdown` in `_quarto.yml` does *not* avoid this — project-level `engine` is not honored for engine selection.

Consequences: the build needs no R and no package installs, and code that reaches the network (there is a `read.csv()` from a raw GitHub URL in the EDM tutorial) cannot break a deploy. Turning execution on later means installing every package the tutorials use (mvgam, the EDM stack, and so on) and almost certainly adding `freeze: auto` with a committed `_freeze/` directory so CI doesn't re-run slow models.

### Data files

`data/*.csv` (and `.R`, `.zip`) are published at `/data/<filename>` via the `resources` list in `_quarto.yml`. Link them from `material.qmd` as `/data/portal_timeseries.csv`.

### Markdown conventions

- Callouts: `::: {.callout-note}` … `:::`
- Math: plain LaTeX, `$inline$` and `$$block$$`
- Table of contents: automatic (`toc: true`), no per-page markup needed
- **Leave a blank line before any list, heading, or `---` rule.** Pandoc is stricter than Hugo's Goldmark about blocks interrupting a paragraph, and all three failure modes are silent:
  - `**Learning Objectives:**` followed directly by `* item` → one run-on paragraph with literal asterisks.
  - A `## Heading` directly after a paragraph or bullet → swallowed into that block and shown as literal `## Heading` text.
  - A `---` rule directly after a line of text → read as a setext underline, turning that text into a heading.

  The whole corpus was swept for these during the migration. Watch for them when editing.

Lesson landing-page listings show only the page title. Quarto falls back to dumping a page's body text into a listing's `description` column whenever that page has no `description:` front matter, and an explicit empty string does not suppress it, so the column is omitted rather than showing whole documents.

## URLs and redirects

Hugo published each page as a directory (`/lessons/x/material/`); Quarto publishes a file (`/lessons/x/material.html`). Lesson landing pages and top-level sections still resolve natively through `index.html`, so only child pages needed mapping. `netlify.toml` holds 301 redirects from the old paths — **keep them**, the site is linked from a published JOSE paper and from Canvas.

Adding a new *kind* of lesson page (a name other than `material` / `discussion_questions` / `instructor_notes` / `r_tutorial`) does not need a redirect, since no old URL exists for it.

## Repository quirks

- `lessons/R-state-space-models-1/r_tutorial_new.qmd` and `r_tutorial_new_notes.qmd` are raw R with no front matter — work-in-progress scratch files. They are excluded from the render in `_quarto.yml`. Hugo used to publish them as broken untitled pages.
- `scripts/build_schedule.R` is the only script in the repo, and it is wired into the render. The one-shot helpers used to perform the Hugo-to-Quarto conversion were deliberately not kept.
- `Contributing/` (site page) is not in the navbar and largely duplicates `CONTRIBUTING.md`.
- This working tree is inside a Syncthing share. Bulk file moves can race with Syncthing and produce `*.sync-conflict-*` copies; if that happens, restore from git and delete the conflict files.
