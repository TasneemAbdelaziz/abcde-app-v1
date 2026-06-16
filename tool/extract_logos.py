"""
Extracts the hospital + AIU logos from the prototype HTML and saves them as
PNGs into assets/images/ — exactly the files BrandBar expects.

USAGE:
  1. Save the prototype file as  prototype.html  in the project root
     (the one whose CSS contains  --img-logo  and  --img-aiu ).
  2. Run:  python tool/extract_logos.py
  3. Run:  flutter pub get   (then hot-restart the app)

It reads the base64 straight from the file, so the logos come out pixel-perfect.
"""

import base64
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
HTML = ROOT / "prototype.html"
OUT = ROOT / "assets" / "images"

# CSS var name in the prototype  ->  output filename used by BrandBar
TARGETS = {
    "--img-logo": "hospital_logo.png",  # Alamein Model Hospital
    "--img-aiu": "aiu_logo.png",         # AIU
}


def main():
    if not HTML.exists():
        sys.exit(f"Save the prototype as {HTML} first, then re-run.")

    text = HTML.read_text(encoding="utf-8", errors="ignore")
    OUT.mkdir(parents=True, exist_ok=True)

    for var, filename in TARGETS.items():
        # matches:  --img-logo:url("data:image/png;base64,XXXX")
        m = re.search(
            re.escape(var) + r"\s*:\s*url\(\"data:image/[^;]+;base64,([^\"]+)\"\)",
            text,
        )
        if not m:
            print(f"  ! {var} not found in prototype.html — skipped")
            continue
        data = base64.b64decode(m.group(1))
        (OUT / filename).write_bytes(data)
        print(f"  ✓ {filename}  ({len(data) // 1024} KB)")

    print("Done. Now run: flutter pub get")


if __name__ == "__main__":
    main()
