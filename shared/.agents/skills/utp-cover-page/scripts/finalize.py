#!/usr/bin/env python3
"""
finalize.py — Pack the prepared/edited unpacked directory back into a .docx.

Wraps the docx skill's pack.py (validation + auto-repair) and fails loudly if the
__BODY_CONTENT__ sentinel is still present (meaning body content was never added).

Usage:
  python finalize.py --work /path/to/workdir \
      --original /path/to/assets/Template.docx \
      --output /mnt/user-data/outputs/Trabajo.docx
"""
import argparse
import os
import subprocess
import sys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--work", required=True)
    ap.add_argument("--original", required=True)
    ap.add_argument("--output", required=True)
    ap.add_argument("--allow-empty-body", action="store_true",
                    help="Skip the __BODY_CONTENT__ sentinel check.")
    args = ap.parse_args()

    unpacked = os.path.join(args.work, "unpacked")
    doc = os.path.join(unpacked, "word", "document.xml")
    content = open(doc, encoding="utf-8").read()

    if "__BODY_CONTENT__" in content and not args.allow_empty_body:
        raise SystemExit(
            "ERROR: __BODY_CONTENT__ sentinel still present. Replace it with the "
            "document body before finalizing (or pass --allow-empty-body)."
        )

    pack = os.path.join(os.path.dirname(__file__), "office", "pack.py")
    if not os.path.exists(pack):
        pack = "/mnt/skills/public/docx/scripts/office/pack.py"

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    subprocess.run(
        [sys.executable, pack, unpacked, args.output, "--original", args.original],
        check=True,
    )
    print("WROTE " + args.output)


if __name__ == "__main__":
    main()
