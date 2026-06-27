---
name: utp-cover-page
description: "Use this skill whenever the user wants a UTP (Universidad Tecnológica del Perú) academic Word document — a 'carátula UTP', 'caratula de la UTP', 'trabajo UTP', 'informe UTP', or any report/essay/monografía that should carry the official UTP cover page. Trigger it even when the user only supplies a topic or a block of content and attaches this skill (e.g. 'dame un resumen sobre X' + this skill, or 'agrégale la carátula a esto'): the job is to produce a COMPLETE .docx with the filled UTP cover page PLUS body content, everything in Calibri, with Heading 1/2/3 styles so the ÍNDICE auto-generates, and 'Figura N' / 'Tabla N' captions feeding an índice de figuras and an índice de tablas. Do NOT use for non-UTP documents or for plain content with no cover page requested."
license: Proprietary.
---

# UTP cover page + academic document builder

## What this produces

A single `.docx` that contains, in order:

1. The official **UTP cover page** (carátula) from the bundled template — logo,
   faculty, career, **title**, INTEGRANTES, **DOCENTE**, **CURSO**, LIMA – PERÚ and
   the current **year** — with the placeholders filled in.
2. **ÍNDICE** (auto table of contents), then **ÍNDICE DE FIGURAS** and **ÍNDICE DE
   TABLAS** when the document has figures/tables.
3. The **body content** — Heading 1/2/3 sections, justified paragraphs, lists,
   tables (captioned "Tabla N") and figures (captioned "Figura N").

The whole document (everything except the cover, which is already styled) is forced
to **Calibri**. Headings are black, bold Calibri and use real heading styles so all
three indexes populate and stay correct.

## How it is normally used

This skill is usually attached to a content request. Two shapes:

- **Topic → full work:** "Dame un resumen sobre las leyes de la física" + this skill.
  You research/write the body yourself, then wrap it in the cover + indexes.
- **Content → wrap it:** the user pastes content and wants the cover added. Add the
  cover and indexes, and still structure their content with headings/captions so the
  indexes work.

Either way you ALWAYS return a complete document (cover + indexes + body). Never just
a bare cover.

## Step 0 — Gather the cover data (ask once, briefly)

You need four values for the cover. Three come from the user; one is automatic.

| Placeholder        | Source                                                        |
|--------------------|---------------------------------------------------------------|
| Título             | the work's title — propose one from the topic, confirm it     |
| DOCENTE (teacher)  | **ask the user** — required                                   |
| CURSO (course)     | **ask the user** — required                                   |
| Año (year)         | **automatic** — current year, do not ask                      |

INTEGRANTES stays exactly as in the template (`Carrascal Mejia, Wilber - U24230739`);
do not ask about it and do not change it.

If the teacher and course were not given, ask for them in one short message (you may
propose the title at the same time). Don't block on the year. Keep it to a single
round of questions, then build.

## Step 1 — Prepare the base (deterministic, scripted)

This fills the cover, forces Calibri everywhere, makes headings black/bold/Calibri,
adds the Caption style, sets fields to auto-update, and inserts the figure/table
indexes + a `__BODY_CONTENT__` marker. It leaves the document UNPACKED for editing.

```bash
python scripts/prepare_base.py \
  --template assets/Template.docx \
  --work /tmp/utp_work \
  --title "El título del trabajo" \
  --teacher "Nombre del Docente" \
  --course "Nombre del Curso"
# optional: --year 2026  (defaults to the current year)
# optional: --no-figure-index   (use when the body will have NO figures)
# optional: --no-table-index    (use when the body will have NO tables)
```

Long titles: pass `||` (or a newline) inside `--title` to force a two-line break,
e.g. `--title "Análisis de las Leyes||de Newton en Sistemas Reales"`. A long title
with no marker is auto-split near the middle.

**Decide the index flags up front:** if you already know the body has no tables, pass
`--no-table-index`; same for figures. An index with nothing in it looks unfinished.

The script prints `unpacked_dir=…/unpacked` and `document_xml=…/word/document.xml`.

## Step 2 — Write the body

Open `…/unpacked/word/document.xml` and **replace the entire `__BODY_CONTENT__`
paragraph**:

```xml
<w:p>…<w:t>__BODY_CONTENT__</w:t>…</w:p>
```

with the body. Read **`references/body-xml.md`** for ready-to-use, Calibri-correct
snippets (headings, justified paragraphs, lists, captioned tables, captioned
figures, image registration). Key rules:

- Use `Heading1` / `Heading2` / `Heading3` styles for every section title — this is
  what makes the ÍNDICE correct. Never fake a heading with bold body text.
- Captioned tables use a `SEQ Tabla` field; captioned figures use a `SEQ Figura`
  field. The sequence names must be exactly `Tabla` and `Figura` or the figure/table
  indexes won't collect them.
- For images: copy the file into `…/unpacked/word/media/`, declare its extension in
  `[Content_Types].xml`, add a relationship (`rId100`+) in
  `word/_rels/document.xml.rels`, then reference it — see §5 of the reference.
- Write substantive content. For a topic request, produce a real, well-organized
  document (intro, developed sections with H2/H3, conclusions), not a stub.

If it turns out there are no figures and/or no tables but you already inserted that
index, either go back and re-run Step 1 with the right `--no-*` flag, or delete the
corresponding `ÍNDICE DE …` heading + field paragraph from `document.xml`.

## Step 3 — Finalize (pack + validate)

```bash
python scripts/finalize.py \
  --work /tmp/utp_work \
  --original assets/Template.docx \
  --output /mnt/user-data/outputs/Trabajo_UTP.docx
```

This refuses to run while `__BODY_CONTENT__` is still present, and validates the
package. If validation fails, fix the reported XML in `…/unpacked/` and re-run.

## Step 4 — Populate the indexes (recommended, best-effort)

The finalized file already has `updateFields=true`, so Word refreshes the ÍNDICE,
índice de figuras and índice de tablas the moment it's opened. To ship a file whose
indexes are **already filled** (correct page numbers even in a preview/PDF), run:

```bash
python scripts/update_indexes.py /mnt/user-data/outputs/Trabajo_UTP.docx
```

This opens the file in headless LibreOffice, updates every index and field, and saves
back. It can take ~30–60 s and starts a `soffice` process — **run it in the
background and poll**, because a foreground call may exceed the shell time limit:

```bash
pkill -9 -f soffice; sleep 2   # clear any stale instance first
nohup python scripts/update_indexes.py /mnt/user-data/outputs/Trabajo_UTP.docx \
  > /tmp/upd.log 2>&1 &
# then poll: sleep, then `cat /tmp/upd.log` until it prints INDEXES_UPDATED
```

If LibreOffice/UNO isn't available or it fails, **keep the finalized file as-is** —
the indexes will still auto-update when the user opens it in Word. Don't block the
deliverable on this step.

## Step 5 — Deliver

Present the `.docx` with `present_files`. In one or two sentences mention the title,
teacher, course and year you used, and — only if Step 4 was skipped or failed — note
that the indexes refresh automatically when opened in Word.

## Quick verification (optional)

To eyeball the result, render to images (run soffice in the background as above):

```bash
python scripts/office/soffice.py --headless --convert-to pdf <file>.docx  # via docx skill
pdftoppm -jpeg -r 100 <file>.pdf page   # then view page-1.jpg (cover), page-2.jpg (índices)
```

## Notes / pitfalls

- The bundled `assets/Template.docx` carries the UTP logo, the cover layout and the
  ÍNDICE field. Always build from it via `prepare_base.py`; never recreate the cover
  by hand (you'd lose the logo and exact spacing).
- Don't touch the cover paragraphs other than the four placeholders.
- The scripts call the docx skill's `unpack.py` / `pack.py` automatically; you don't
  need to unpack/pack manually.
- Escape XML and use smart quotes in body text (see the reference).
