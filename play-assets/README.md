# Play Store assets

Generated 7 August 2026 for PDFHarbor 1.0.0 (`np.com.sachinmaharzan.pdfharbor`).

| File | Play Console field | Spec |
|---|---|---|
| `play-icon-512.png` | App icon | 512×512, 32-bit PNG, no alpha |
| `play-feature-graphic-1024x500.png` | Feature graphic | 1024×500, no alpha |
| `screenshots/01-home.png` … `05-tools.png` | Phone screenshots | 1080×1920 (1.78:1), PNG |

## How they were made

**Icon** — `images/app_logo.png` trimmed to its artwork bounding box, scaled to
480px, centred on a 512² white canvas. White matches
`res/values/ic_launcher_background.xml`, so the store icon and the launcher icon
read the same. Alpha is flattened because Play applies its own rounded mask.

**Feature graphic** — ImageMagick composite: vertical brand gradient
(`#4270FF` → `#1B39B5`), the logo at 290px, and a two-part text block. The
headline deliberately does **not** repeat "PDFHarbor" — the logo already
contains the wordmark.

**Screenshots** — captured from the **release** build running on a Galaxy S25
(1440×3120) over adb, then composited onto 1080×1920 canvases with captions.

Two crops are applied to every source capture before compositing:

- top 150px — removes the Samsung status bar, which carried personal
  notification icons (Messenger, Gmail, Instagram). Third-party logos do not
  belong in a store listing.
- below y=2910 — removes the Android navigation bar, leaving only app content.

## Screenshot content is deliberate

The Files tab lists **every PDF on the device**, and on the capture phone that
included real personal documents (tax forms, a transaction report). None of
those appear in these assets.

Instead, five neutral demo PDFs were generated (PostScript → Ghostscript, so
the text is real and searchable) and pushed to
`/sdcard/Documents/PDFHarbor/` on the phone:

```
Quarterly Report.pdf   Lease Agreement.pdf   Travel Itinerary.pdf
Project Proposal.pdf   Meeting Notes.pdf
```

The screenshots use the **Recent** filter and the Home screen's recents rail,
both of which only list files opened inside the app — so only the demo set is
visible. The "All" tab was never captured.

**These five files are still on the phone.** Delete them when you no longer
need them:

```bash
adb -s <device> shell rm "/sdcard/Documents/PDFHarbor/*.pdf"
```

To regenerate them, see `mkpdf.py` (reproduced below the fold in the session
notes) or write your own — nothing here depends on the exact content.

## Regenerating

The screenshots are not scripted end to end — capture involves driving the UI
by hand. The compositing step is scripted and re-runnable given fresh
`1440×3120` captures named `home.png`, `recent.png`, `viewer.png`, `split.png`,
`tools.png`.

## Still to do before publishing

- Host `../privacy-policy.html` at
  `https://sachinmaharzan.com.np/pdfharbor/privacy-policy.html` and put the same
  URL in the Play Console "Privacy policy" field.
- Replace the debug signing config in `android/app/build.gradle.kts` with a real
  upload key — the current release build is signed with debug keys and Play will
  reject it.
- Confirm the developer name in the privacy policy matches the Play Console
  developer name.
