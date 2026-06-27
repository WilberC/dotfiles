#!/usr/bin/env python3
"""
prepare_base.py — Build the UTP base document from the bundled Template.docx.

This handles every DETERMINISTIC, repeatable transform so the body content is the
only thing left to write by hand:

  * Forces Calibri across the WHOLE document (theme major+minor + docDefaults),
    while the cover page keeps its explicit Calibri formatting untouched.
  * Makes Heading 1/2/3 black + bold + Calibri (so the auto TOC looks academic).
  * Adds a "Caption" paragraph style (used by "Figura N" / "Tabla N" captions).
  * Sets <w:updateFields w:val="true"/> so Word/LibreOffice refresh every index
    (ÍNDICE, índice de figuras, índice de tablas) when the file is opened.
  * Fills the cover placeholders: title, teacher, course, current year.
    (The INTEGRANTES line is intentionally left as-is per the template.)
  * Inserts "ÍNDICE DE FIGURAS" and/or "ÍNDICE DE TABLAS" fields right after the
    main ÍNDICE, then a page break, then a sentinel paragraph (__BODY_CONTENT__)
    marking exactly where the body XML must be inserted.

It leaves the document UNPACKED at <work>/unpacked so the caller can drop body
content into word/document.xml and then run finalize.py.

Usage:
  python prepare_base.py \
      --template /path/to/assets/Template.docx \
      --work /path/to/workdir \
      --title "Leyes Fundamentales de la Física" \
      --teacher "Juan Pérez Gonzales" \
      --course "Física General" \
      [--year 2026] \
      [--no-figure-index] [--no-table-index]

Title line breaks: pass a newline or "||" inside --title to force two lines,
otherwise a long title (> ~38 chars) is auto-split near the middle.
"""
import argparse
import datetime
import os
import re
import subprocess
import sys
from xml.sax.saxutils import escape

CAL = '<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>'


def run_unpack(template, work):
    unpacked = os.path.join(work, "unpacked")
    script = os.path.join(os.path.dirname(__file__), "office", "unpack.py")
    if not os.path.exists(script):
        # fall back to the docx skill's copy
        script = "/mnt/skills/public/docx/scripts/office/unpack.py"
    subprocess.run([sys.executable, script, template, unpacked], check=True)
    return unpacked


def force_calibri_theme(word_dir):
    theme = os.path.join(word_dir, "theme", "theme1.xml")
    s = open(theme, encoding="utf-8").read()
    # major + minor latin typefaces -> Calibri (order matters: longer string first)
    s = s.replace('typeface="Aptos Display"', 'typeface="Calibri"')
    s = s.replace('typeface="Aptos"', 'typeface="Calibri"')
    open(theme, "w", encoding="utf-8").write(s)


def force_calibri_defaults(word_dir):
    styles = os.path.join(word_dir, "styles.xml")
    s = open(styles, encoding="utf-8").read()
    # Inject explicit Calibri into docDefaults run props (belt and suspenders).
    s = s.replace(
        '<w:rFonts w:asciiTheme="minorHAnsi" w:eastAsiaTheme="minorHAnsi" '
        'w:hAnsiTheme="minorHAnsi" w:cstheme="minorBidi"/>',
        '<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri" '
        'w:asciiTheme="minorHAnsi" w:eastAsiaTheme="minorHAnsi" '
        'w:hAnsiTheme="minorHAnsi" w:cstheme="minorBidi"/>',
        1,
    )
    open(styles, "w", encoding="utf-8").write(s)


def style_headings_black(word_dir):
    """Heading 1/2/3 -> Calibri, bold, black. Keep template sizes."""
    styles = os.path.join(word_dir, "styles.xml")
    s = open(styles, encoding="utf-8").read()
    sizes = {"Heading1": 40, "Heading2": 32, "Heading3": 28}
    for sid, sz in sizes.items():
        new_rpr = (
            f"{CAL}<w:b/><w:bCs/><w:color w:val=\"000000\"/>"
            f"<w:sz w:val=\"{sz}\"/><w:szCs w:val=\"{sz}\"/>"
        )
        # paragraph style
        pattern = (
            r'(<w:style w:type="paragraph" w:styleId="' + sid + r'">.*?<w:rPr>)'
            r'.*?(</w:rPr>)'
        )
        s = re.sub(pattern, r"\1" + new_rpr + r"\2", s, count=1, flags=re.S)
        # linked character style (HeadingNChar)
        char_pattern = (
            r'(<w:style w:type="character" [^>]*w:styleId="' + sid + r'Char">.*?<w:rPr>)'
            r'.*?(</w:rPr>)'
        )
        s = re.sub(char_pattern, r"\1" + new_rpr + r"\2", s, count=1, flags=re.S)
        # H2/H3 are semiHidden by default; make them visible in the gallery.
        block_pat = r'(<w:style w:type="paragraph" w:styleId="' + sid + r'">)(.*?)(</w:style>)'
        m = re.search(block_pat, s, flags=re.S)
        if m:
            block = m.group(2).replace("<w:semiHidden/>", "")
            s = s[: m.start(2)] + block + s[m.end(2):]
    open(styles, "w", encoding="utf-8").write(s)


def add_caption_style(word_dir):
    styles = os.path.join(word_dir, "styles.xml")
    s = open(styles, encoding="utf-8").read()
    if 'w:styleId="Caption"' in s:
        return
    caption = (
        '<w:style w:type="paragraph" w:styleId="Caption">'
        '<w:name w:val="caption"/><w:basedOn w:val="Normal"/>'
        '<w:next w:val="Normal"/><w:uiPriority w:val="35"/><w:qFormat/>'
        '<w:pPr><w:spacing w:before="120" w:after="200"/><w:jc w:val="center"/></w:pPr>'
        '<w:rPr>' + CAL + '<w:color w:val="000000"/>'
        '<w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>'
    )
    s = s.replace("</w:styles>", caption + "</w:styles>", 1)
    open(styles, "w", encoding="utf-8").write(s)


def set_update_fields(word_dir):
    settings = os.path.join(word_dir, "settings.xml")
    s = open(settings, encoding="utf-8").read()
    if "<w:updateFields" in s:
        return
    tag = '<w:updateFields w:val="true"/>'
    # CT_Settings is an ordered sequence; updateFields must appear just before
    # this group. Insert before the first of these that exists.
    anchors = [
        "<w:hdrShapeDefaults", "<w:footnotePr", "<w:endnotePr", "<w:compat",
        "<w:rsids", "<w:mathPr", "<w:themeFontLang", "<w:clrSchemeMapping",
        "<w:shapeDefaults", "<w:decimalSymbol", "<w:listSeparator",
    ]
    for a in anchors:
        i = s.find(a)
        if i != -1:
            s = s[:i] + tag + s[i:]
            break
    else:
        # no anchor found; fall back to just before </w:settings>
        s = s.replace("</w:settings>", tag + "</w:settings>", 1)
    open(settings, "w", encoding="utf-8").write(s)


def split_title(title):
    title = title.replace("||", "\n").strip()
    if "\n" in title:
        parts = [p.strip() for p in title.split("\n", 1)]
        return parts[0], parts[1]
    if len(title) <= 38:
        return title, None
    # auto-split near the middle on a space
    mid = len(title) // 2
    left = title.rfind(" ", 0, mid)
    right = title.find(" ", mid)
    if left == -1 and right == -1:
        return title, None
    cut = right if (left == -1 or (right != -1 and right - mid < mid - left)) else left
    return title[:cut].strip(), title[cut:].strip()


def fill_cover(word_dir, title, teacher, course, year):
    doc = os.path.join(word_dir, "document.xml")
    s = open(doc, encoding="utf-8").read()

    line1, line2 = split_title(title)
    if line2:
        title_xml = (
            f'<w:t xml:space="preserve">{escape(line1)}</w:t>'
            f"<w:br/><w:t xml:space=\"preserve\">{escape(line2)}</w:t>"
        )
    else:
        title_xml = f'<w:t xml:space="preserve">{escape(line1)}</w:t>'

    replacements = {
        "<w:t>Fill with title</w:t>": title_xml,
        "<w:t>Fill with teacher</w:t>": f'<w:t xml:space="preserve">{escape(teacher)}</w:t>',
        "<w:t>Fill curso</w:t>": f'<w:t xml:space="preserve">{escape(course)}</w:t>',
        "<w:t>Current Year</w:t>": f"<w:t>{escape(str(year))}</w:t>",
    }
    for old, new in replacements.items():
        if old not in s:
            raise SystemExit(f"Placeholder not found in template: {old}")
        s = s.replace(old, new, 1)
    open(doc, "w", encoding="utf-8").write(s)


def _index_block(heading_text, seq_name):
    """A 'table of figures/tables' field keyed on a SEQ identifier."""
    return (
        '<w:p><w:pPr><w:pStyle w:val="TOCHeading"/><w:rPr>' + CAL +
        '<w:color w:val="auto"/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:pPr>'
        '<w:r><w:rPr>' + CAL + '<w:color w:val="auto"/>'
        '<w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr>'
        f'<w:t>{heading_text}</w:t></w:r></w:p>'
        '<w:p><w:pPr><w:rPr>' + CAL + '</w:rPr></w:pPr>'
        '<w:r><w:rPr>' + CAL + '</w:rPr><w:fldChar w:fldCharType="begin"/></w:r>'
        '<w:r><w:rPr>' + CAL + '</w:rPr>'
        f'<w:instrText xml:space="preserve"> TOC \\h \\z \\c &quot;{seq_name}&quot; </w:instrText></w:r>'
        '<w:r><w:rPr>' + CAL + '</w:rPr><w:fldChar w:fldCharType="separate"/></w:r>'
        '<w:r><w:rPr>' + CAL + '<w:noProof/></w:rPr>'
        '<w:t>Right-click and "Update Field" to populate this index.</w:t></w:r>'
        '<w:r><w:rPr>' + CAL + '<w:noProof/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p>'
    )


def insert_indexes_and_body_marker(word_dir, figure_index, table_index):
    doc = os.path.join(word_dir, "document.xml")
    s = open(doc, encoding="utf-8").read()

    blocks = ""
    if figure_index:
        blocks += _index_block("ÍNDICE DE FIGURAS", "Figura")
    if table_index:
        blocks += _index_block("ÍNDICE DE TABLAS", "Tabla")

    page_break = '<w:p><w:r><w:rPr>' + CAL + '</w:rPr><w:br w:type="page"/></w:r></w:p>'
    body_marker = (
        '<w:p><w:pPr><w:rPr>' + CAL + '</w:rPr></w:pPr>'
        '<w:r><w:rPr>' + CAL + '</w:rPr><w:t>__BODY_CONTENT__</w:t></w:r></w:p>'
    )

    insertion = blocks + page_break + body_marker
    # Insert right after the ÍNDICE structured-document-tag block.
    if "</w:sdt>" not in s:
        raise SystemExit("Could not find the ÍNDICE <w:sdt> block in the template.")
    s = s.replace("</w:sdt>", "</w:sdt>" + insertion, 1)
    open(doc, "w", encoding="utf-8").write(s)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--template", required=True)
    ap.add_argument("--work", required=True)
    ap.add_argument("--title", required=True)
    ap.add_argument("--teacher", required=True)
    ap.add_argument("--course", required=True)
    ap.add_argument("--year", default=str(datetime.date.today().year))
    ap.add_argument("--no-figure-index", action="store_true")
    ap.add_argument("--no-table-index", action="store_true")
    args = ap.parse_args()

    os.makedirs(args.work, exist_ok=True)
    unpacked = run_unpack(args.template, args.work)
    word_dir = os.path.join(unpacked, "word")

    force_calibri_theme(word_dir)
    force_calibri_defaults(word_dir)
    style_headings_black(word_dir)
    add_caption_style(word_dir)
    set_update_fields(word_dir)
    fill_cover(word_dir, args.title, args.teacher, args.course, args.year)
    insert_indexes_and_body_marker(
        word_dir,
        figure_index=not args.no_figure_index,
        table_index=not args.no_table_index,
    )

    print("BASE_READY")
    print("unpacked_dir=" + unpacked)
    print("document_xml=" + os.path.join(word_dir, "document.xml"))
    print("Replace the __BODY_CONTENT__ paragraph in document.xml with the body, "
          "then run finalize.py.")


if __name__ == "__main__":
    main()
