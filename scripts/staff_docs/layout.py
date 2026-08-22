"""Page shell (head, nav, footer) for the staff / line-manager guide."""

from __future__ import annotations

from .render import esc, pick

NAV_LABEL = {
    "index": {"en": "Start here", "ar": "ابدأ من هنا"},
    "login": {"en": "Sign in", "ar": "الدخول"},
    "shift": {"en": "Shift", "ar": "الوردية"},
    "pos": {"en": "Take an order", "ar": "عمل طلب"},
    "kanban": {"en": "Order board", "ar": "بورد الطلبات"},
    "courier-balances": {"en": "Courier money", "ar": "حساب المندوب"},
    "trips": {"en": "Trips", "ar": "الرحلات"},
    "expenses": {"en": "Expenses & requests", "ar": "المصاريف والطلبات"},
    "line-manager": {"en": "Line manager", "ar": "مدير الخط"},
}

FOOTER = {
    "en": "Jarz POS &middot; Staff &amp; Line Manager Guide",
    "ar": "جارز POS &middot; دليل الموظفين ومديري الخطوط",
}

SWITCH_LANG = {"en": "العربية", "ar": "English"}

PRINT_HINT = {
    "en": "Printable &mdash; use your browser's Print for a paper copy.",
    "ar": "تقدر تطبعها &mdash; استخدم أمر الطباعة في المتصفح.",
}


def _nav(page_key: str, lang: str, pages) -> str:
    items = []
    for key, filename in pages:
        active = key == page_key
        cls = (
            "px-2.5 py-1 rounded bg-orange-800 font-semibold shrink-0"
            if active
            else "px-2.5 py-1 rounded hover:bg-orange-700 shrink-0"
        )
        items.append('<a href="%s" class="%s">%s</a>' % (filename, cls, esc(pick(NAV_LABEL[key], lang))))
    other = "ar" if lang == "en" else "en"
    other_href = "../%s/%s" % (other, dict(pages)[page_key])
    return (
        '<nav class="bg-brand text-white shadow-md sticky top-0 z-50 no-print">'
        '<div class="max-w-5xl mx-auto px-4 py-2.5 flex flex-wrap items-center gap-2 justify-between">'
        '<a href="index.html" class="font-bold text-lg tracking-wide shrink-0">JARZ POS</a>'
        '<div class="flex sm:flex-wrap gap-1 text-xs order-3 sm:order-2 w-full sm:w-auto '
        'overflow-x-auto whitespace-nowrap scrollbar-none -mx-1 px-1">%s</div>'
        '<a href="%s" class="text-xs bg-white text-brand px-2.5 py-1 rounded font-bold '
        'hover:bg-orange-50 order-2 sm:order-3 shrink-0">%s</a>'
        "</div></nav>" % ("".join(items), other_href, SWITCH_LANG[lang])
    )


def page(page_key: str, lang: str, title, icon: str, hero_title, hero_sub, body: str, pages) -> str:
    direction = "rtl" if lang == "ar" else "ltr"
    font_link = (
        '<link rel="preconnect" href="https://fonts.googleapis.com">'
        '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
        '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?'
        'family=Cairo:wght@400;600;700&display=swap">'
    )
    body_font = "font-cairo" if lang == "ar" else "font-sans"
    return (
        "<!DOCTYPE html>\n"
        '<html lang="%s" dir="%s">\n<head>\n'
        '<meta charset="UTF-8">\n'
        '<meta name="viewport" content="width=device-width, initial-scale=1.0">\n'
        "<title>%s</title>\n"
        '<script src="https://cdn.tailwindcss.com"></script>\n'
        "<script>tailwind.config={theme:{extend:{colors:{brand:{DEFAULT:'#E85D04',"
        "light:'#FFF7ED',dark:'#9A3412'}},fontFamily:{cairo:['Cairo','sans-serif']}}}}</script>\n"
        "%s\n"
        '<link rel="stylesheet" href="../assets/styles.css">\n'
        "</head>\n"
        '<body class="bg-stone-50 %s text-stone-800">\n'
        "%s\n"
        '<main class="max-w-3xl mx-auto px-4 py-8">\n'
        '<div class="flex items-center gap-3 mb-2">'
        '<span class="text-3xl">%s</span>'
        '<h1 class="text-2xl font-bold text-brand">%s</h1></div>\n'
        '<p class="text-stone-500 mb-6 leading-relaxed">%s</p>\n'
        "%s\n"
        "</main>\n"
        '<footer class="text-center text-xs text-stone-400 py-8 no-print">%s<br>'
        '<span class="text-stone-300">%s</span></footer>\n'
        "</body>\n</html>\n"
        % (
            lang,
            direction,
            esc(pick(title, lang)),
            font_link,
            body_font,
            _nav(page_key, lang, pages),
            icon,
            esc(pick(hero_title, lang)),
            esc(pick(hero_sub, lang)),
            body,
            FOOTER[lang],
            PRINT_HINT[lang],
        )
    )


LANDING = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Jarz POS &mdash; Staff Guide</title>
<script src="https://cdn.tailwindcss.com"></script>
<script>tailwind.config={theme:{extend:{colors:{brand:{DEFAULT:'#E85D04',light:'#FFF7ED',dark:'#9A3412'}}}}}</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap">
<link rel="stylesheet" href="assets/styles.css">
</head>
<body class="bg-brand-light min-h-screen flex items-center justify-center p-6">
<div class="max-w-sm w-full bg-white rounded-2xl shadow-lg overflow-hidden">
  <div class="bg-brand px-8 py-10 text-white text-center">
    <div class="text-3xl font-bold tracking-wide">JARZ POS</div>
    <div class="mt-1 text-orange-100 text-sm">Staff &amp; Line Manager Guide</div>
  </div>
  <div class="p-8 space-y-4">
    <p class="text-center text-stone-500 text-sm mb-6">Choose your language / اختار لغتك</p>
    <a href="en/index.html" class="flex items-center justify-between w-full bg-brand text-white font-semibold px-6 py-4 rounded-xl shadow hover:bg-brand-dark transition-colors">
      <span class="text-lg">English</span><span class="text-2xl">&rarr;</span>
    </a>
    <a href="ar/index.html" class="flex items-center justify-between w-full bg-white border-2 border-brand text-brand font-bold px-6 py-4 rounded-xl hover:bg-brand-light transition-colors" dir="rtl">
      <span class="text-lg" style="font-family:'Cairo',sans-serif">العربية</span><span class="text-2xl">&larr;</span>
    </a>
  </div>
  <p class="text-center text-stone-400 text-xs pb-6">Jarz POS mobile &amp; web app</p>
</div>
</body>
</html>
"""

STYLES = """/* Jarz POS Staff & Line Manager Guide - shared styles */

/* Arabic pages set font-cairo via Tailwind; this is the fallback. */
[dir="rtl"] body { font-family: 'Cairo', system-ui, sans-serif; }

/* Print */
@media print {
  nav, .no-print { display: none !important; }
  body { font-size: 11pt; color: #000; background: #fff; }
  a { color: #000; text-decoration: underline; }
  h1, h2, h3 { page-break-after: avoid; }
  .step-block, details { page-break-inside: avoid; }
  details { border: 1px solid #ccc; }
  details > div { display: block !important; }
  summary { list-style: none; font-weight: 700; }
  .print-page-break { page-break-before: always; }
}

/* RTL helpers (applied on <html dir="rtl">) */
[dir="rtl"] .ltr-only { display: none !important; }
[dir="ltr"] .rtl-only { display: none !important; }

html { scroll-behavior: smooth; }
:focus-visible { outline: 2px solid #E85D04; outline-offset: 2px; }

/* The nav links scroll sideways on a phone instead of wrapping into a
   three-line sticky header that eats a fifth of the screen. */
.scrollbar-none { scrollbar-width: none; -ms-overflow-style: none; }
.scrollbar-none::-webkit-scrollbar { display: none; }

/* Open the details marker rotation without JS */
details[open] > summary > span:first-child { transform: rotate(90deg); display: inline-block; }
"""
