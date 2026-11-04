# The claude.ai slide deck artifact

A working recipe for building and publishing a deck with the claude.ai Slides artifact type, and
its pitfalls. The Artifact tool's own instructions take precedence.

## Creating the deck

1. `Artifact` with `action: "quickstart"`, `intent: "slides"`. The result names the Slides type's
   `type_url` and how to fill it.
2. `Artifact` publish with that `type_url`, a `title`, and `auto_open: "after_first_write"`. This
   returns the deck's `url`. Keep the url; every later publish goes to it.
3. Write the deck's own files under a local root:

```
<root>/project/deck.json
<root>/project/slides/<slide-id>.html     one file per slide
```

`deck.json` shape:

```json
{"v": 4, "createdOnFiles": {"v": 1, "at": "<ISO time>"}, "lists": "css",
 "title": "<deck title>",
 "order": ["cover", "fact", "...", "fulltable"],
 "sections": {"s1": {"description": "Background ...", "start": "cover"},
              "s4": {"description": "Appendix", "start": "opportunity"}},
 "faces": {"ibm-plex-sans": {"family": "IBM Plex Sans",
           "href": "https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;600&display=swap"}},
 "designSystems": []}
```

Each slide is a single `<section id="<slide-id>" style="...">` with inline styles. The canvas is
1920×1080; padding of about 104-128 px leaves widths of up to 1664 px. A
section with `description` starting with "Appendix" marks where the appendix begins, and the lint
reads that.

## Publishing changes

- Publish to the same `url` with `root`, a `file_path` of one changed file, and `files` mapping
  every other changed file: `{"project/slides/next.html": "project/slides/next.html"}`.
- Remove a slide by mapping its path to `null` and deleting its id from `order` in `deck.json`.
- Run `scripts/lint_deck.py <root>/project` before each publish.
- Copy the final source somewhere preserved after the meeting; a scratchpad disappears with the
  session.

## Pitfalls

- `<sub>` is not in the slide subset and was removed. `<sup>` is not verified.
- Leading spaces collapse. Use `&#160;` for indentation, e.g. in a text-drawn tree.
- `<aside>` inside a section is the speaker-notes panel. It folds line breaks, so structured
  bullets become one paragraph and editing is awkward. Keep the notes in the meeting document
  Keep at most a short pointer in `<aside>`.
- Charts: simple stacked bars as sized `div`s, with labels inside or beside them, worked well and
  needed no library. Compute the widths from the data with a script.
- A source line (model, unit, machine, runs) can sit at `position:absolute; bottom:64px` with the
  section's bottom padding raised to about 160 px so it does not overlap the content.

## Default design tokens

| role | value |
|---|---|
| background | `#FFFFFF` |
| text | `#111111` |
| secondary text | `#555555` |
| accent (one) | `#1F5FAD` |
| chart greys | `#8A939C`, `#D3D7DB` |
| title | 56 px, weight 600 |
| body | 26-36 px; captions 24 px |
| font | IBM Plex Sans, then Arial |
