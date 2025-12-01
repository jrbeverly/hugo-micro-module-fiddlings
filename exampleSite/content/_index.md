---
title: Home
---

# A page assembled from micro-modules

Fixture home page for a composable Hugo build. The orchestrator ships a skeleton with
eight named surfaces and no feature code — the brand mark, the navigation, the language
control, this typography, the cards below and every part of the footer arrive as declared
contributions from ten independent modules.

## Overview

A module is a directory with a `go.mod`, a registration file under `data/contributions/`,
and whatever templates and assets it needs. Installing one adds an import; activating it
means giving it a data record at `data/micromodules/<module>.json`. Presence is the
switch and the contents are the settings — an installed module with no record resolves as
inactive and renders nothing.

Site config holds only generics: title, base URL, and whether to emit build traces.
Nothing in it names a module's templates, and nothing in the orchestrator knows what a
footer is.

## The contract

Each entry names a surface, a renderer, and an ordering weight. Renderers come in two
kinds — a partial the orchestrator calls, or a stylesheet it links:

```
{ "id": "logo-mark",    "hook": "header.start", "partial": "logo/mark.html" }

{ "id": "theme-tokens", "hook": "head", "type": "style",
  "resource": "theme/theme.css", "weight": -100 }
```

Surfaces belong to the orchestrator; modules may not invent their own:

- `head` — document head
- `header` — top region
- `header.start` / `header.end` — leading and trailing groups inside it
- `main` — after page content
- `footer` — bottom region
- `footer.panel` / `footer.baseline` — the panel row and the strip beneath it

The nested four are opened, not declared, by the modules that render their regions. The
`masthead` module draws the top bar and asks who wants the leading and trailing edges;
`logo`, `nav`, `composition` and `locale` answer without any of them knowing the others
exist. The `colophon` module does the same below, and `nav`, `social`, `analytics` and
`copyright` fill it in.
