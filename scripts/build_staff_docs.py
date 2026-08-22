#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Build the Jarz POS staff / line-manager guide into ``web/docs/``.

    python scripts/build_staff_docs.py

The guide is generated from one bilingual content model so the English and
Arabic trees cannot drift apart. The output is plain static HTML that ships
with the Flutter **web** build and is served at ``/pos/docs/``; it is NOT Dart
code, so a docs change needs a web deploy, not a Shorebird patch.

Re-run this after editing anything under ``scripts/staff_docs/`` and commit the
generated HTML together with the source.
"""

from __future__ import annotations

import io
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
if HERE not in sys.path:
    sys.path.insert(0, HERE)

from staff_docs import layout, render  # noqa: E402
from staff_docs.pages_core import INDEX, LOGIN, POS, SHIFT  # noqa: E402
from staff_docs.pages_ops import COURIER, EXPENSES, KANBAN, LINE_MANAGER, TRIPS  # noqa: E402

ALL_PAGES = [INDEX, LOGIN, SHIFT, POS, KANBAN, COURIER, TRIPS, EXPENSES, LINE_MANAGER]

ROLES_LABEL = {"en": "For", "ar": "لمين"}

TITLE_SUFFIX = {"en": "Jarz POS Guide", "ar": "دليل جارز POS"}

BLOCK_RENDERERS = {
    "h": lambda a, lang: render.heading(a[0], lang, a[1] if len(a) > 1 else ""),
    "p": lambda a, lang: render.para(a[0], lang),
    "lead": lambda a, lang: render.lead(a[0], lang),
    "call": lambda a, lang: render.callout(a[0], a[1], a[2], lang),
    "steps": lambda a, lang: render.steps(a[0], lang),
    "bul": lambda a, lang: render.bullets(a[0], lang),
    "tbl": lambda a, lang: render.table(a[0], a[1], lang),
    "faq": lambda a, lang: render.faq(a[0], lang),
    "cards": lambda a, lang: render.cards(a[0], lang),
    "flow": lambda a, lang: render.flow(a[0], lang),
    "toc": lambda a, lang: render.toc(a[0], a[1], lang),
    "fig": lambda a, lang: render.figure(a[0], a[1], lang, DOCS_ROOT),
}

#: The figure block reads each screenshot's real pixel dimensions from here.
#: Regenerate the shots with:
#:   flutter test test/screenshots/docs_screenshots_test.dart --update-goldens
DOCS_ROOT = os.path.join(ROOT, "web", "docs")


def render_blocks(blocks, lang: str) -> str:
    out = []
    for block in blocks:
        kind, args = block[0], block[1:]
        if kind not in BLOCK_RENDERERS:
            raise KeyError("unknown block type: %s" % kind)
        out.append(BLOCK_RENDERERS[kind](args, lang))
    return "\n".join(out)


def build_page(spec: dict, lang: str) -> str:
    body = render.roles_bar(spec["roles"], ROLES_LABEL, lang)
    body += render_blocks(spec["blocks"], lang)
    title = "%s — %s" % (render.pick(spec["title"], lang), TITLE_SUFFIX[lang])
    return layout.page(
        page_key=spec["key"],
        lang=lang,
        title=title,
        icon=spec["icon"],
        hero_title=spec["hero"],
        hero_sub=spec["sub"],
        body=body,
        pages=render.PAGES,
    )


def write(path: str, text: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with io.open(path, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(text)


def main() -> int:
    docs = os.path.join(ROOT, "web", "docs")
    keys_in_nav = [key for key, _ in render.PAGES]
    keys_in_content = [page["key"] for page in ALL_PAGES]
    if keys_in_nav != keys_in_content:
        raise SystemExit(
            "nav order %s does not match content order %s" % (keys_in_nav, keys_in_content)
        )

    written = 0
    write(os.path.join(docs, "index.html"), layout.LANDING)
    write(os.path.join(docs, "assets", "styles.css"), layout.STYLES)
    written += 2

    for lang in ("en", "ar"):
        for spec in ALL_PAGES:
            filename = dict(render.PAGES)[spec["key"]]
            write(os.path.join(docs, lang, filename), build_page(spec, lang))
            written += 1

    print("staff guide: wrote %d files into %s" % (written, docs))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
