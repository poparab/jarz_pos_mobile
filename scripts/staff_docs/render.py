"""HTML rendering helpers for the Jarz POS staff / line-manager guide.

The guide is generated from a single bilingual content model (``content.py``)
so English and Arabic can never drift apart: every block carries both
languages, and a missing translation raises at build time instead of shipping
a page that is half English.

Output is plain static HTML under ``web/docs/``, served by the Flutter **web**
build at ``/pos/docs/``. Nothing here runs at request time.
"""

from __future__ import annotations

import html
import re
from typing import Iterable

BRAND = "#E85D04"

#: Matches an HTML character reference that ``html.escape`` has just mangled.
ENTITY_RE = re.compile(r"&amp;(#[0-9]+|#x[0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]{1,31});")

#: ``[text](kanban.html#ofd)`` in the content becomes a link. The target is
#: restricted to a sibling guide page and an optional anchor on purpose: there
#: is no reason for this guide to link anywhere else, and a narrow pattern
#: means the href never needs escaping.
LINK_RE = re.compile(r"\[([^\]\[]+)\]\(([a-z-]+\.html(?:#[a-z0-9-]+)?)\)")

# Order matters: this drives the nav bar and the index card grid.
PAGES = [
    ("index", "index.html"),
    ("login", "login.html"),
    ("shift", "shift.html"),
    ("pos", "pos.html"),
    ("kanban", "kanban.html"),
    ("courier-balances", "courier-balances.html"),
    ("trips", "trips.html"),
    ("expenses", "expenses.html"),
    ("line-manager", "line-manager.html"),
]


def esc(text: str) -> str:
    """Escape text, but let a small set of inline tags through.

    Content is written as prose with ``<strong>``/``<em>``/``<code>``/``<br>``
    inline, which reads far better in the content file than a nested tag model
    would. Everything else is escaped.
    """
    out = html.escape(str(text), quote=False)
    for tag in ("strong", "em", "code", "b", "span"):
        out = out.replace("&lt;%s&gt;" % tag, "<%s>" % tag)
        out = out.replace("&lt;/%s&gt;" % tag, "</%s>" % tag)
    out = out.replace("&lt;br&gt;", "<br>")
    # Character references written in the content (&rarr;, &#8942;, ...) survive
    # the escape: html.escape turned the leading & into &amp;, which would print
    # the reference literally on the page. A bare & is still escaped.
    out = ENTITY_RE.sub(r"&\1;", out)
    out = LINK_RE.sub(
        r'<a href="\2" class="text-brand font-semibold underline '
        r'underline-offset-2 hover:text-brand-dark">\1</a>',
        out,
    )
    return out


def pick(value, lang: str) -> str:
    """Resolve a bilingual value. A plain string is the same in both languages."""
    if isinstance(value, dict):
        if lang not in value:
            raise KeyError("missing '%s' translation for: %r" % (lang, value))
        return value[lang]
    return value


# -- Blocks ---------------------------------------------------------------

def lead(value, lang: str) -> str:
    return '<p class="text-stone-600 leading-relaxed mb-6">%s</p>' % esc(pick(value, lang))


def heading(value, lang: str, anchor: str = "") -> str:
    aid = ' id="%s"' % anchor if anchor else ""
    return (
        '<h2%s class="text-xl font-bold text-stone-800 mt-12 mb-4 pb-2 '
        'border-b-2 border-brand/20 scroll-mt-24">%s</h2>' % (aid, esc(pick(value, lang)))
    )


def para(value, lang: str) -> str:
    return '<p class="text-stone-700 leading-relaxed mb-4">%s</p>' % esc(pick(value, lang))


# The mark is a plain Unicode glyph rather than an emoji: emoji fall back to a
# different face per platform and, on the Arabic pages, drag the line height
# around. These render identically everywhere.
CALLOUT_STYLES = {
    "info": ("bg-sky-50", "border-sky-400", "text-sky-900", "&#8505;"),      # information
    "warn": ("bg-amber-50", "border-amber-400", "text-amber-900", "&#9888;"),  # warning
    "stop": ("bg-red-50", "border-red-400", "text-red-900", "&#10005;"),      # cross
    "ok": ("bg-emerald-50", "border-emerald-400", "text-emerald-900", "&#10003;"),  # check
    "manager": ("bg-violet-50", "border-violet-400", "text-violet-900", "&#9733;"),  # star
}


def callout(kind: str, title, body, lang: str) -> str:
    bg, border, fg, mark = CALLOUT_STYLES[kind]
    return (
        '<div class="%s border-s-4 %s rounded-e-xl px-5 py-4 my-6">'
        '<p class="font-bold %s mb-1 flex gap-2 items-baseline">'
        '<span class="shrink-0" aria-hidden="true">%s</span><span>%s</span></p>'
        '<p class="text-sm %s leading-relaxed">%s</p></div>'
        % (bg, border, fg, mark, esc(pick(title, lang)), fg, esc(pick(body, lang)))
    )


def steps(items: Iterable[dict], lang: str) -> str:
    out = ['<ol class="space-y-3 my-6 step-block list-none p-0">']
    for i, item in enumerate(items, start=1):
        body = esc(pick(item["body"], lang)) if item.get("body") else ""
        body_html = (
            '<p class="text-sm text-stone-600 mt-1 leading-relaxed">%s</p>' % body if body else ""
        )
        out.append(
            '<li class="flex gap-4 bg-white rounded-xl border border-stone-200 p-4 shadow-sm">'
            '<span class="bg-brand text-white rounded-full w-8 h-8 flex items-center '
            'justify-center shrink-0 font-bold text-sm">%d</span>'
            '<div class="min-w-0"><p class="font-semibold text-stone-800">%s</p>%s</div></li>'
            % (i, esc(pick(item["title"], lang)), body_html)
        )
    out.append("</ol>")
    return "".join(out)


def bullets(items: Iterable, lang: str) -> str:
    out = ['<ul class="space-y-2 my-5 ps-1 list-none">']
    for item in items:
        out.append(
            '<li class="flex gap-3 text-stone-700 leading-relaxed">'
            '<span class="text-brand font-bold shrink-0">&bull;</span>'
            "<span>%s</span></li>" % esc(pick(item, lang))
        )
    out.append("</ul>")
    return "".join(out)


def table(headers: Iterable, rows: Iterable[Iterable], lang: str) -> str:
    head = "".join(
        '<th class="px-3 py-2 text-start font-semibold text-stone-700 '
        'border-b-2 border-stone-300">%s</th>' % esc(pick(h, lang))
        for h in headers
    )
    body = []
    for row in rows:
        cells = "".join(
            '<td class="px-3 py-2 align-top border-b border-stone-200 text-stone-700">%s</td>'
            % esc(pick(c, lang))
            for c in row
        )
        body.append("<tr>%s</tr>" % cells)
    return (
        '<div class="overflow-x-auto my-6 rounded-xl border border-stone-200 bg-white shadow-sm">'
        '<table class="w-full text-sm border-collapse"><thead class="bg-stone-50">'
        "<tr>%s</tr></thead><tbody>%s</tbody></table></div>" % (head, "".join(body))
    )


def faq(items: Iterable[dict], lang: str) -> str:
    """"The app said X" -> what it means and what to do about it."""
    out = ['<div class="space-y-3 my-6">']
    for item in items:
        out.append(
            '<details class="bg-white rounded-xl border border-stone-200 shadow-sm overflow-hidden">'
            '<summary class="cursor-pointer select-none px-4 py-3 font-semibold text-stone-800 '
            'hover:bg-stone-50 flex gap-2 items-start">'
            '<span class="text-brand shrink-0">&#9656;</span><span>%s</span></summary>'
            '<div class="px-4 pb-4 pt-3 text-sm text-stone-600 leading-relaxed '
            'border-t border-stone-100">%s</div></details>'
            % (esc(pick(item["q"], lang)), esc(pick(item["a"], lang)))
        )
    out.append("</div>")
    return "".join(out)


def cards(items: Iterable[dict], lang: str) -> str:
    out = ['<div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 my-6">']
    for item in items:
        out.append(
            '<a href="%s" class="bg-white rounded-xl border border-stone-200 p-5 '
            'hover:border-brand hover:shadow-md transition-all group">'
            '<div class="text-2xl mb-2">%s</div>'
            '<div class="font-bold text-stone-800 group-hover:text-brand">%s</div>'
            '<div class="text-sm text-stone-500 mt-1 leading-relaxed">%s</div></a>'
            % (item["href"], item["icon"], esc(pick(item["title"], lang)), esc(pick(item["body"], lang)))
        )
    out.append("</div>")
    return "".join(out)


def flow(items: Iterable, lang: str) -> str:
    """A horizontal chain of pills - the order lifecycle."""
    pills = []
    for i, item in enumerate(items):
        if i:
            pills.append('<span class="text-brand font-bold self-center px-1">&rarr;</span>')
        pills.append(
            '<span class="bg-white border-2 border-brand/30 text-stone-800 rounded-full '
            'px-3 py-1 text-sm font-semibold whitespace-nowrap">%s</span>' % esc(pick(item, lang))
        )
    return (
        '<div class="overflow-x-auto my-6 -mx-4 px-4">'
        '<div class="flex gap-1 items-stretch w-max">%s</div></div>' % "".join(pills)
    )


ROLE_BADGES = {
    "staff": ("bg-emerald-100 text-emerald-800 border-emerald-300",
              {"en": "Staff", "ar": "موظف"}),
    "line": ("bg-violet-100 text-violet-800 border-violet-300",
             {"en": "Line manager", "ar": "مدير خط"}),
}


def roles_bar(role_keys: Iterable[str], label, lang: str) -> str:
    chips = []
    for key in role_keys:
        cls, name = ROLE_BADGES[key]
        chips.append(
            '<span class="%s border rounded-full px-3 py-0.5 text-xs font-bold">%s</span>'
            % (cls, esc(pick(name, lang)))
        )
    return (
        '<div class="flex flex-wrap items-center gap-2 mb-6">'
        '<span class="text-xs uppercase tracking-wide text-stone-400 font-semibold">%s</span>'
        "%s</div>" % (esc(pick(label, lang)), "".join(chips))
    )


def _png_size(path: str):
    """Width/height straight out of the PNG IHDR, so the img can carry real
    dimensions and the page does not reflow as the shot loads."""
    with open(path, "rb") as handle:
        header = handle.read(24)
    if len(header) < 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG: %s" % path)
    width = int.from_bytes(header[16:20], "big")
    height = int.from_bytes(header[20:24], "big")
    return width, height


def figure(name: str, caption, lang: str, docs_root: str) -> str:
    """A generated app screenshot. ``name`` is the file under
    ``web/docs/assets/img/<lang>/``; the shot for the reader's own language is
    used, so an Arabic reader sees the Arabic app."""
    import os

    src = "../assets/img/%s/%s" % (lang, name)
    width, height = _png_size(os.path.join(docs_root, "assets", "img", lang, name))
    alt = esc(pick(caption, lang))
    return (
        '<figure class="my-6">'
        '<img src="%s" width="%d" height="%d" alt="%s" loading="lazy" '
        'class="rounded-xl border border-stone-300 shadow-sm mx-auto block '
        'max-w-full h-auto bg-white">'
        '<figcaption class="text-center text-xs text-stone-500 mt-2">%s</figcaption>'
        "</figure>" % (src, width, height, alt, alt)
    )


def toc(entries: Iterable[dict], label, lang: str) -> str:
    """Jump links for the headings on a long page."""
    links = "".join(
        '<a href="#%s" class="text-sm text-brand hover:underline whitespace-nowrap">%s</a>'
        % (e["anchor"], esc(pick(e["title"], lang)))
        for e in entries
    )
    return (
        '<nav class="bg-brand-light border border-brand/20 rounded-xl px-5 py-4 my-6 no-print">'
        '<p class="text-xs uppercase tracking-wide text-brand font-bold mb-2">%s</p>'
        '<div class="flex flex-wrap gap-x-4 gap-y-1">%s</div></nav>'
        % (esc(pick(label, lang)), links)
    )
