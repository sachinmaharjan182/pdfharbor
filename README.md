# PDFverse

A premium, all-in-one PDF toolkit for Android, built with Flutter and Material 3.

## Features

| | |
|---|---|
| **Viewer** | Text search, jump-to-page, bookmarks, page thumbnails, zoom, continuous/horizontal scroll, share, print, document info, password-protected files |
| **Merge** | Multi-select, drag-to-reorder, save-as |
| **Split** | By page range, every page, odd, even, or a custom selection (`1,3,5-8`) with live preview |
| **Compress** | Low/Medium/High presets with before/after size and % saved |
| **Image → PDF** | Reorder, crop, rotate, filters, page size, orientation, margins |
| **PDF → Images** | Per-page selection, JPEG/PNG, quality levels |
| **Scanner** | Camera capture with automatic edge detection, perspective correction, multi-page, filters |
| **Watermark** | Text or image, with opacity/rotation/scale/position and a live preview |
| **Signature** | Draw or import, save for reuse, place on any page with size and rotation |
| **Password** | AES-256 encrypt, decrypt with validation |
| **Files** | Device-wide PDF browser with search, sort, list/grid, favorites, recents |

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates Freezed/JSON code
flutter run
```

Requires Flutter 3.41+ / Dart 3.11+. Android only (minSdk 24).

> **After editing any `@freezed` model, re-run `build_runner`.** `.freezed.dart` and `.g.dart` files are generated and excluded from analysis.

## Architecture

Clean Architecture with a feature-first layout. Each feature is a self-contained vertical slice:

```
lib/
  core/         # Result/Failure types, PDF + image engines, Hive, permissions, shared utils
  shared/       # theme, navigation (GoRouter), reusable widgets
  features/
    <feature>/
      data/         # repository implementations, datasources, DTOs
      domain/       # entities, repository interfaces, use cases
      presentation/ # screens, widgets, Riverpod providers
```

**Key conventions**

- Repositories and use cases return `Result<T>` (`Success` | `ResultFailure`) rather than throwing, so every failure a screen must render is known at compile time.
- No business logic in widgets — screens call use cases and switch on the result.
- Models are immutable (Freezed).
- All CPU-heavy PDF and image work runs off the UI thread via `compute`.

**Stack:** Riverpod · GoRouter · Hive · Freezed · Syncfusion PDF · pdfx · ML Kit document scanner

## Where output files go

Tool results are written to `Documents/PDFverse` (falling back to app-private storage if that isn't writable). Names auto-suffix — ` (2)`, ` (3)` — so a run never silently overwrites an earlier result. **Source files are never modified in place**; every tool writes a new copy.

## Notable implementation constraints

These are non-obvious and were discovered the hard way — see `BUILD_PROGRESS.md` for the full list.

- **Syncfusion has no page-import API** in this version. Pages are copied via `createTemplate()` + `drawPdfTemplate`, sizing the destination page to the source so geometry survives.
- **Android's PDF renderer rejects concurrent page renders** on one document handle. Thumbnail and export paths render strictly one page at a time.
- **Compression rasterizes pages**, so compressed output loses selectable text. The UI states this before you commit.
- **`hive_generator` conflicts with Freezed's analyzer constraint.** Hive stores plain maps via each model's `toJson`/`fromJson` — no `TypeAdapter`s.
- **`image_cropper` doesn't register `UCropActivity`** via manifest merge; it's declared manually in `AndroidManifest.xml`. Removing it breaks Crop at runtime.

## Extending to V2

The seams for the planned V2 features already exist:

- **OCR / AI summary / AI chat** — add `features/ocr/`, `features/ai_summary/`, etc. `PdfEngine.pageSizes` and the `pdfx` render path already give you page bitmaps to feed a recognizer or vision model. Put the network client behind a repository interface in `domain/` so the UI never sees the API.
- **Cloud sync** — `FilesRepository` is already an interface. Add a remote implementation and compose the two behind a sync-aware repository; nothing in `presentation/` changes.
- **Office conversion** — mirror the `image_to_pdf` slice: a converter service in `core/`, a repository + use case, one screen. Register its route in `AppRoutes` and add a `_Tool` entry in `tools_screen.dart`.
- **New tools generally** — copy any existing feature folder's shape. Add the route to `AppRoutes`, a `GoRoute` in `app_router.dart`, and a card in `tools_screen.dart` / `home_screen.dart`.

## Testing

```bash
flutter analyze     # clean
flutter test        # 59 tests
flutter build apk --debug
```

Tests cover the pure logic where correctness actually matters: page-selection parsing, split page-group construction, page-layout resolution, compression math, and `Result`/`Failure` behavior.
