#!/usr/bin/env python3
"""
update_indexes.py — Open a .docx in headless LibreOffice, update every index
(ÍNDICE / table of contents, índice de figuras, índice de tablas) and all fields,
then save back to .docx so the deliverable opens already populated.

This is optional but recommended: without it, the indexes still update the moment
the file is opened in Word (the document has <w:updateFields w:val="true"/>), but
running this means the user gets correct page numbers immediately, even in a PDF
export or a quick preview.

Usage:
  python update_indexes.py /path/to/Trabajo.docx

If LibreOffice/UNO is unavailable, this exits non-zero and the caller should just
keep the un-refreshed file (Word will refresh on open).
"""
import os
import subprocess
import sys
import time
import uuid


def _connect(socket):
    import uno
    from com.sun.star.beans import PropertyValue  # noqa: F401
    localContext = uno.getComponentContext()
    resolver = localContext.ServiceManager.createInstanceWithContext(
        "com.sun.star.bridge.UnoUrlResolver", localContext
    )
    url = (
        f"uno:socket,host=localhost,port={socket};urp;"
        "StarOffice.ComponentContext"
    )
    last = None
    for attempt in range(30):
        try:
            ctx = resolver.resolve(url)
            return ctx
        except Exception as e:  # noqa: BLE001
            last = e
            print(f"connect attempt {attempt+1}...", flush=True)
            time.sleep(1)
    raise RuntimeError(f"Could not connect to LibreOffice: {last}")


def main():
    if len(sys.argv) < 2:
        raise SystemExit("usage: update_indexes.py <file.docx>")
    path = os.path.abspath(sys.argv[1])
    if not os.path.exists(path):
        raise SystemExit(f"file not found: {path}")

    import uno
    from com.sun.star.beans import PropertyValue

    port = "2002"
    profile = f"/tmp/lo_profile_{uuid.uuid4().hex}"
    proc = subprocess.Popen([
        "soffice", "--headless", "--invisible", "--nodefault", "--norestore",
        "--nologo", "--nofirststartwizard",
        f"-env:UserInstallation=file://{profile}",
        f"--accept=socket,host=localhost,port={port};urp;",
    ])
    try:
        ctx = _connect(port)
        smgr = ctx.ServiceManager
        desktop = smgr.createInstanceWithContext(
            "com.sun.star.frame.Desktop", ctx
        )
        in_url = "file://" + path
        hidden = PropertyValue(); hidden.Name = "Hidden"; hidden.Value = True
        doc = desktop.loadComponentFromURL(in_url, "_blank", 0, (hidden,))

        # Update all text fields (e.g. SEQ caption numbers).
        try:
            doc.getTextFields().refresh()
        except Exception:  # noqa: BLE001
            pass
        # Update every index (TOC, table of figures, table of tables).
        indexes = doc.getDocumentIndexes()
        for i in range(indexes.getCount()):
            try:
                indexes.getByIndex(i).update()
            except Exception:  # noqa: BLE001
                pass

        # Save back as Word .docx.
        out = PropertyValue(); out.Name = "FilterName"
        out.Value = "MS Word 2007 XML"
        ow = PropertyValue(); ow.Name = "Overwrite"; ow.Value = True
        doc.storeToURL(in_url, (out, ow))
        doc.close(False)
        print("INDEXES_UPDATED")
    finally:
        proc.terminate()
        try:
            proc.wait(timeout=10)
        except Exception:  # noqa: BLE001
            proc.kill()


if __name__ == "__main__":
    main()
