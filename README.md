# hugo-micro-module-fiddlings

> [!WARNING]
> **AI-authored:** This change was autonomously planned and implemented by an AI software factory from a human-authored specification, with possible subsequent human review or modification.

Experiments toward a composable Hugo orchestration model where micro-modules self-register into shared rendering pipelines through declarative contracts.

Requires `hugo` and `go` in PATH; verified on Hugo 0.165.0 and Go 1.27.1.

```sh
cd exampleSite && hugo server            # preview, writes to gitignored public/
cd exampleSite && hugo -d ../docs --cleanDestinationDir   # rebuild the published site
```

`docs/` is the built site, committed on `main`. GitHub Pages serves it with Settings → Pages → Deploy from a branch → `main` → `/docs`.

## Shape

The orchestrator ships a page skeleton and the resolution logic, and nothing else. Everything visible on the rendered page arrives as a contribution:

| Module        | Contributes                                                                         |
| ------------- | ----------------------------------------------------------------------------------- |
| `theme`       | design tokens, plus a site-supplied accent override (`head`)                        |
| `masthead`    | the top region, opening `header.start` and `header.end`                             |
| `colophon`    | the bottom region, opening `footer.panel` and `footer.baseline`                     |
| `logo`        | brand mark and wordmark (`header.start`)                                            |
| `nav`         | links (`header.start`) and a panel (`footer.panel`)                                 |
| `locale`      | placeholder language control (`header.end`)                                         |
| `social`      | outbound link list (`footer.panel`)                                                 |
| `copyright`   | one line of markup, no stylesheet (`footer.baseline`)                               |
| `composition` | registry cards (`main`), count badge (`header.end`), build line (`footer.baseline`) |
| `analytics`   | tracker script (`head`) and a status panel (`footer.panel`)                         |

Declared surfaces live in `orchestrator/data/hmm/surfaces.json`: `head`, `header`, `header.start`, `header.end`, `main`, `footer`, `footer.panel`, `footer.baseline`.

Two data roots with opposite ownership:

- `data/contributions/<module>.json` — shipped by the module. What it registers.
- `data/micromodules/<module>.json` — supplied by the site. Whether the module is active, and how it is configured.

## Notes

- Unsure how to proceed with this kind of approach, but is promising
- A URL in `data/` needs no leading slash: `/index.xml` is host-rooted and drops the Pages subpath, `index.xml` through `relURL` keeps it
- `publishDir = "../docs"` in config looks tidier but makes `hugo server` render to disk, overwriting the published site with localhost URLs and a livereload script; `-d ../docs` at build time avoids it
- Would allow for Hugo modules that support _any_ head imports (supporting any metadata, analytics on pages)
- Could this assist with reusable localization components?
