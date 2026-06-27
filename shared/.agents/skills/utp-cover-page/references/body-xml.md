# Body XML reference

Snippets for the body that replaces the `__BODY_CONTENT__` paragraph in
`unpacked/word/document.xml`. Everything below is already Calibri because the base
document's theme and defaults were switched to Calibri by `prepare_base.py`. Adding
the explicit `<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>` shown
below is belt-and-suspenders and recommended.

Always escape `&`→`&amp;`, `<`→`&lt;`, `>`→`&gt;` inside `<w:t>`. Use smart quotes
(`&#x201C;` `&#x201D;` `&#x2018;` `&#x2019;`) for quotation marks and apostrophes.

`CAL` below is shorthand for:
`<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>`

---

## 1. Headings (drive the ÍNDICE / table of contents)

Use `Heading1` / `Heading2` / `Heading3` styles — never fake headings with bold
text, or they will not appear in the auto TOC.

```xml
<w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
  <w:r><w:t xml:space="preserve">Introducción</w:t></w:r></w:p>

<w:p><w:pPr><w:pStyle w:val="Heading2"/></w:pPr>
  <w:r><w:t xml:space="preserve">Subsección</w:t></w:r></w:p>

<w:p><w:pPr><w:pStyle w:val="Heading3"/></w:pPr>
  <w:r><w:t xml:space="preserve">Sub-subsección</w:t></w:r></w:p>
```

The styles already carry the right font/size/color (Calibri, black, bold). Do not
add `<w:rPr>` overrides on heading runs.

---

## 2. Body paragraph (justified)

```xml
<w:p><w:pPr><w:jc w:val="both"/><w:rPr>CAL</w:rPr></w:pPr>
  <w:r><w:rPr>CAL</w:rPr><w:t xml:space="preserve">Texto del párrafo…</w:t></w:r></w:p>
```

For bold/italic inside a paragraph, add `<w:b/>` / `<w:i/>` to that run's `<w:rPr>`
(keep `CAL` in it).

---

## 3. Lists

Append this numbering once, just before `</w:numbering>` in
`unpacked/word/numbering.xml` (IDs 90/91 avoid the template's existing 0/1):

```xml
<w:abstractNum w:abstractNumId="90"><w:multiLevelType w:val="hybridMultilevel"/>
  <w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="bullet"/>
    <w:lvlText w:val="&#xF0B7;"/><w:lvlJc w:val="left"/>
    <w:pPr><w:ind w:left="720" w:hanging="360"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Symbol" w:hAnsi="Symbol" w:hint="default"/></w:rPr></w:lvl></w:abstractNum>
<w:abstractNum w:abstractNumId="91"><w:multiLevelType w:val="hybridMultilevel"/>
  <w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="decimal"/>
    <w:lvlText w:val="%1."/><w:lvlJc w:val="left"/>
    <w:pPr><w:ind w:left="720" w:hanging="360"/></w:pPr></w:lvl></w:abstractNum>
<w:num w:numId="90"><w:abstractNumId w:val="90"/></w:num>
<w:num w:numId="91"><w:abstractNumId w:val="91"/></w:num>
```

Bulleted item (`numId="90"`) / numbered item (`numId="91"`):

```xml
<w:p><w:pPr><w:pStyle w:val="ListParagraph"/>
  <w:numPr><w:ilvl w:val="0"/><w:numId w:val="90"/></w:numPr>
  <w:rPr>CAL</w:rPr></w:pPr>
  <w:r><w:rPr>CAL</w:rPr><w:t xml:space="preserve">Elemento de lista</w:t></w:r></w:p>
```

Never type literal `•` or `1.` characters — use the numbering above.

---

## 4. Tables with a "Tabla N" caption

Caption goes ABOVE the table (academic convention). The `SEQ Tabla` field is what
the ÍNDICE DE TABLAS collects, so the sequence name **must** be exactly `Tabla`.

```xml
<!-- caption -->
<w:p><w:pPr><w:pStyle w:val="Caption"/></w:pPr>
  <w:r><w:rPr>CAL<w:b/></w:rPr><w:t xml:space="preserve">Tabla </w:t></w:r>
  <w:r><w:rPr>CAL</w:rPr><w:fldChar w:fldCharType="begin"/></w:r>
  <w:r><w:rPr>CAL</w:rPr><w:instrText xml:space="preserve"> SEQ Tabla \* ARABIC </w:instrText></w:r>
  <w:r><w:rPr>CAL</w:rPr><w:fldChar w:fldCharType="separate"/></w:r>
  <w:r><w:rPr>CAL<w:b/><w:noProof/></w:rPr><w:t>1</w:t></w:r>
  <w:r><w:rPr>CAL</w:rPr><w:fldChar w:fldCharType="end"/></w:r>
  <w:r><w:rPr>CAL</w:rPr><w:t xml:space="preserve">: Descripción de la tabla</w:t></w:r></w:p>
<!-- table (content width on US Letter w/ 1in margins = 9360 dxa) -->
<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:jc w:val="center"/>
  <w:tblBorders>
    <w:top w:val="single" w:sz="4" w:color="000000"/><w:left w:val="single" w:sz="4" w:color="000000"/>
    <w:bottom w:val="single" w:sz="4" w:color="000000"/><w:right w:val="single" w:sz="4" w:color="000000"/>
    <w:insideH w:val="single" w:sz="4" w:color="000000"/><w:insideV w:val="single" w:sz="4" w:color="000000"/>
  </w:tblBorders></w:tblPr>
  <w:tblGrid><w:gridCol w:w="4680"/><w:gridCol w:w="4680"/></w:tblGrid>
  <w:tr>
    <w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/>
      <w:tcMar><w:top w:w="80"/><w:left w:w="120"/><w:bottom w:w="80"/><w:right w:w="120"/></w:tcMar></w:tcPr>
      <w:p><w:pPr><w:rPr>CAL<w:b/></w:rPr></w:pPr><w:r><w:rPr>CAL<w:b/></w:rPr><w:t>Encabezado A</w:t></w:r></w:p></w:tc>
    <w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/>
      <w:tcMar><w:top w:w="80"/><w:left w:w="120"/><w:bottom w:w="80"/><w:right w:w="120"/></w:tcMar></w:tcPr>
      <w:p><w:pPr><w:rPr>CAL<w:b/></w:rPr></w:pPr><w:r><w:rPr>CAL<w:b/></w:rPr><w:t>Encabezado B</w:t></w:r></w:p></w:tc>
  </w:tr>
  <w:tr>
    <w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/>
      <w:tcMar><w:top w:w="80"/><w:left w:w="120"/><w:bottom w:w="80"/><w:right w:w="120"/></w:tcMar></w:tcPr>
      <w:p><w:pPr><w:rPr>CAL</w:rPr></w:pPr><w:r><w:rPr>CAL</w:rPr><w:t>Dato 1</w:t></w:r></w:p></w:tc>
    <w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/>
      <w:tcMar><w:top w:w="80"/><w:left w:w="120"/><w:bottom w:w="80"/><w:right w:w="120"/></w:tcMar></w:tcPr>
      <w:p><w:pPr><w:rPr>CAL</w:rPr></w:pPr><w:r><w:rPr>CAL</w:rPr><w:t>Dato 2</w:t></w:r></w:p></w:tc>
  </w:tr>
</w:tbl>
<!-- always add an empty paragraph after a table -->
<w:p><w:pPr><w:rPr>CAL</w:rPr></w:pPr></w:p>
```

`columnWidths` must sum to `tblW`. For 3 columns use `3120` each; for N columns use
`9360 / N`. Set the same width on each cell's `<w:tcW>`.

---

## 5. Figures with a "Figura N" caption

Caption goes BELOW the figure. Sequence name **must** be exactly `Figura`.

### 5a. Register the image (do this once per image)

1. Copy the image into `unpacked/word/media/` (e.g. `image10.png`).
2. Ensure its extension is declared in `unpacked/[Content_Types].xml` (PNG/JPEG are
   usually already there; add if missing):
   `<Default Extension="png" ContentType="image/png"/>`
3. Add a relationship in `unpacked/word/_rels/document.xml.rels` with a fresh id
   (use `rId100`, `rId101`, … to avoid collisions):
   ```xml
   <Relationship Id="rId100"
     Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image"
     Target="media/image10.png"/>
   ```

### 5b. Insert the figure + caption

Compute EMU size: `cx = width_inches * 914400`, `cy = cx * (img_height / img_width)`.
A good default width is 4–5.5 inches. Example for 4 in on a 640×360 image:
`cx=3657600`, `cy=2057400`.

```xml
<w:p><w:pPr><w:jc w:val="center"/><w:rPr>CAL</w:rPr></w:pPr>
  <w:r><w:rPr>CAL<w:noProof/></w:rPr><w:drawing>
    <wp:inline distT="0" distB="0" distL="0" distR="0">
      <wp:extent cx="3657600" cy="2057400"/><wp:effectExtent l="0" t="0" r="0" b="0"/>
      <wp:docPr id="50" name="Figura1"/>
      <wp:cNvGraphicFramePr>
        <a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/>
      </wp:cNvGraphicFramePr>
      <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
        <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
          <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:nvPicPr><pic:cNvPr id="50" name="image10.png"/><pic:cNvPicPr/></pic:nvPicPr>
            <pic:blipFill><a:blip r:embed="rId100"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>
            <pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="3657600" cy="2057400"/></a:xfrm>
              <a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>
          </pic:pic>
        </a:graphicData>
      </a:graphic>
    </wp:inline>
  </w:drawing></w:r></w:p>
<!-- caption -->
<w:p><w:pPr><w:pStyle w:val="Caption"/></w:pPr>
  <w:r><w:rPr>CAL<w:b/></w:rPr><w:t xml:space="preserve">Figura </w:t></w:r>
  <w:r><w:rPr>CAL</w:rPr><w:fldChar w:fldCharType="begin"/></w:r>
  <w:r><w:rPr>CAL</w:rPr><w:instrText xml:space="preserve"> SEQ Figura \* ARABIC </w:instrText></w:r>
  <w:r><w:rPr>CAL</w:rPr><w:fldChar w:fldCharType="separate"/></w:r>
  <w:r><w:rPr>CAL<w:b/><w:noProof/></w:rPr><w:t>1</w:t></w:r>
  <w:r><w:rPr>CAL</w:rPr><w:fldChar w:fldCharType="end"/></w:r>
  <w:r><w:rPr>CAL</w:rPr><w:t xml:space="preserve">: Descripción de la figura</w:t></w:r></w:p>
```

Give every `wp:docPr` / `pic:cNvPr` a unique `id` (50, 51, 52 …).

---

## 6. Notes on the SEQ numbers

The literal `<w:t>1</w:t>` between `separate` and `end` is just a cached value; the
real numbers are recalculated by `update_indexes.py` (or by Word on open). You do not
need to hand-number figures/tables correctly — just keep one `SEQ Figura` per figure
and one `SEQ Tabla` per table, in document order.
