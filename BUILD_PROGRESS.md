# PDFverse — Build Progress

> **Read this file first when resuming work on this project**, then check `git log --oneline` to confirm what's actually committed. This file is updated in the same commit as the work it describes, so it should always match `HEAD`.

Full spec: `app_requirements.txt`. Architecture/plan: `/home/dell/.claude/plans/harmonic-sniffing-map.md` (may not exist on a different machine — this file is the source of truth if so).

## Decisions locked in (do not re-litigate)

- **PDF engine:** Syncfusion (`syncfusion_flutter_pdf` + `syncfusion_flutter_pdfviewer`), Community License. Confirmed with user.
- **Page rasterization** (thumbnails, PDF→Image, compression): `pdfx`.
- **Scanner:** `cunning_document_scanner` (Android ML Kit Document Scanner wrapper).
- **State mgmt:** plain Riverpod (`flutter_riverpod`, `Notifier`/`AsyncNotifier`), **no riverpod_generator** — kept simple to minimize build_runner surface.
- **Models:** `freezed` + `json_serializable`.
- **Hive:** boxes store plain `Map<dynamic, dynamic>` (via each model's `toJson()`/`fromJson()`), **no `hive_generator`/`TypeAdapter`s** — hive_generator conflicts with freezed's analyzer version constraint (verified during Phase 0; do not re-add it without re-checking this). See `lib/core/hive/hive_service.dart`.
- **App identity:** applicationId/namespace `com.pdfverse.app`, package folder `android/app/src/main/kotlin/com/pdfverse/app/`. minSdk follows `flutter.minSdkVersion` (currently **24**); core library desugaring + multidex are enabled in `android/app/build.gradle.kts`.
- Android-only project (`flutter create --platforms=android`).

## Phase checklist

- [x] **Phase 0 — Bootstrap.** `flutter create`, full pubspec (all deps resolved OK), Android manifest permissions (camera/storage/media/notifications), Gradle (minSdk 23, core library desugaring, multidex), analysis_options.yaml (strict lints), feature-first folder skeleton under `lib/`, git initialized, this file created.
- [x] **Phase 1a — Core infra & shared widgets.** `Failure`/`Result<T>` error types (`core/error/`), constants (`core/constants/app_constants.dart`: spacing/radius/durations/Hive box names), utils (file-size + relative-date formatting, `BuildContext` extensions), `HiveService` (Map-based boxes, no codegen), `PermissionService` (camera/photos/manage-external-storage with granted/denied/permanently-denied result), Material 3 `AppTheme` (light/dark, dynamic-color-ready via `dynamic_color`'s `harmonized()`, 20-28 corner radii, large type scale), shared-axis GoRouter page transition helper, shared widget kit (`AppCard`/`ActionCard`, `EmptyState`, `ErrorView`, shimmer skeletons, `SectionHeader`, bottom-sheet + dialog helpers). `flutter analyze`: clean.
- [x] **Phase 1b + Phase 2 — App shell, Home, Files, Tools, Settings.** (landed together so the shell never routed to a placeholder)
  - **Shell:** `shared/navigation/app_router.dart` (GoRouter `StatefulShellRoute.indexedStack`, route constants in `AppRoutes`), `app_shell.dart` (M3 `NavigationBar`, re-tap pops branch to root), `main.dart` (`ProviderScope` + `HiveService.init()` + `DynamicColorBuilder` + theme mode from settings).
  - **Files feature (full vertical slice):** `PdfFileEntry` entity, `PdfFileMetaModel` (Hive-persisted favorite/last-opened only; size+mtime read live), `LocalPdfDatasource` (recursive `/storage/emulated/0` scan, skips hidden + `Android/`, tolerates unreadable dirs), `FilesRepositoryImpl` (in-memory scan cache + metadata merge), 7 use cases, Riverpod providers, `PdfThumbnail` (pdfx first-page raster, static bytes cache, fixed 320px render independent of layout size), list tile + grid card, and `FilesScreen` (search, sort by name/date/size, list/grid toggle, All/Recent/Favorites filter, favorite toggle, share/rename/delete, permission empty-states, shimmer loading, pull-to-refresh).
  - **Home:** "Hello / PDF Toolkit" header, search bar → Files, recent-files horizontal rail, 8-card quick-actions grid with staggered `flutter_animate` entrance, tablet-responsive column count.
  - **Tools:** full tool catalogue grouped Organize / Convert / Edit & Protect.
  - **Settings:** theme (System/Light/Dark), default page view, default compression, language, rate/privacy/version — persisted to Hive, generic `RadioGroup` option bottom sheet.
  - Quick-action / tool cards for features not yet built call `context.showComingSoon(...)` (a real snackbar) rather than silently no-oping — replace each with real navigation as its phase lands.
  - **Verified:** `flutter analyze` clean, `flutter test` 15/15 passing (Result/Failure, file-size + relative-date extensions), **`flutter build apk --debug` succeeds**.
- [x] **Phase 3 — Viewer.** `SfPdfViewer.file`-based reader at route `/viewer?path=<encoded>` (outside the nav shell, so it's full-screen). Covers: open from Files / recent rail / Home's "Open PDF" picker, in-document text search with match counter + next/previous, jump-to-page dialog, user bookmarks (Hive-persisted, add/list/jump/delete via `PdfBookmarkEntry`), continuous↔horizontal scroll toggle seeded from the saved default-page-view setting, lazy page-thumbnail grid, zoom in/out clamped to the viewer's 1-3x range, share, print (`Printing.layoutPdf`), and a PDF-information sheet reading the document-info dictionary. Password-protected files prompt inline and reload via a password-keyed widget key. Opening a document records it into Recent Files.
  - Notable: `PageThumbnailsSheet` serializes renders through a single future chain — Android's PDF renderer rejects concurrent page renders on one document handle.
  - Added shared `PdfPicker` (`core/utils/pdf_picker.dart`) for PDF file selection; merge/split/compress should reuse it.
- [x] **Phase 4 — Merge & Split.** Both routed outside the nav shell (`/merge`, `/split`), reachable from Home quick actions and the Tools screen.
  - **Shared infra added here (reuse it for compress/watermark):**
    - `core/pdf/pdf_engine.dart` — Syncfusion operations run off the UI thread via `compute`. **This version of `syncfusion_flutter_pdf` has no page-import API**, so pages are copied with `createTemplate()` + `drawPdfTemplate`, sizing each destination page to the source page so dimensions/orientation survive. Exposes `merge`, `extractPages`, `pageCount`.
    - `core/utils/output_file_service.dart` — writes results to `Documents/PDFverse` (falls back to app-private storage), auto-suffixing ` (2)`, ` (3)`… so a run never silently overwrites an earlier result.
    - `shared/widgets/result_success_sheet.dart` — the standard "saved → open/share" ending for every tool.
  - **Merge:** multi-select via `PdfPicker`, drag-to-reorder (`ReorderableListView`, output order = list order), per-item remove, thumbnails, save-as dialog, progress bar, requires ≥2 files.
  - **Split:** modes are every-page / page-range / odd / even / custom (`1,3,5-8`), with a live result preview and inline validation. Page-selection parsing (`parse_page_selection.dart`) and mode→page-group mapping (`build_page_groups.dart`) are pure functions with **34 unit tests total** covering reversed ranges, dedup, whitespace, and out-of-bounds rejection.
  - **Verified:** `flutter analyze` clean, `flutter test` 34/34 passing, `flutter build apk --debug` succeeds.
- [x] **Phase 5 — Compress & Image↔PDF.** Routes `/compress`, `/image-to-pdf`, `/pdf-to-image`, wired into Home quick actions and Tools.
  - **Shared infra added here:** `core/image/image_processor.dart` (decode → rotate → downscale to 2400px longest edge → filter → JPEG re-encode, all via `compute`; the scanner should reuse this), and `PdfEngine.buildFromImages` / `PdfEngine.pageSizes`.
  - **Compress:** Low/Medium/High presets (render scale + JPEG quality), real per-page progress, and a before/after card showing original size, compressed size, and % saved. **Compression rasterizes pages** (Syncfusion can't re-encode embedded images in place), so output text is no longer selectable — the UI states this explicitly instead of silently degrading the file. `savingsPercent` clamps at 0 because re-encoding an already-optimized PDF can grow it; that case shows an honest "already well optimized" snackbar.
  - **Image→PDF:** multi-image pick, drag-reorder, per-image rotate / crop (`image_cropper`) / filter, apply-filter-to-all, page size (A4/Letter/Legal/A3/A5/fit-to-image), orientation, margins. Orientation is disabled for fit-to-image since each page follows its own image.
  - **PDF→Images:** per-page selection chips with select-all, JPEG/PNG, three quality levels, per-page progress, share sheet for the exported set. Pages render strictly one at a time (Android renderer constraint).
  - **Runtime bug caught and fixed here:** `image_cropper` does **not** contribute `com.yalantis.ucrop.UCropActivity` via manifest merge — it must be declared manually in `android/app/src/main/AndroidManifest.xml` or tapping Crop throws `ActivityNotFoundException`. Verified present in the merged manifest. **Don't remove that entry.**
  - **Verified:** `flutter analyze` clean, `flutter test` 46/46 passing, `flutter build apk --debug` succeeds.
- [ ] **Phase 6 — Scanner, Watermark, Signature, Password.**
- [ ] **Phase 7 — Polish & QA.** Share integrations, shimmer/animation pass, empty/error state audit, `flutter analyze` clean, V2 extension notes.

## Notes for whoever (or whatever session) resumes next

- Nothing is half-wired: each phase above is only checked off once it compiles and its screens are reachable from navigation with no placeholder content.
- Run `flutter pub get` and `flutter analyze` first to confirm the environment still resolves before adding feature code — dependency versions were chosen deliberately (see the Decisions section) to avoid re-triggering the freezed/hive_generator conflict.
- **After editing any `@freezed` model, re-run:** `dart run build_runner build --delete-conflicting-outputs`. `.freezed.dart`/`.g.dart` files are generated and are excluded from analysis.
- Home's quick-actions grid and the Tools screen currently call `context.showComingSoon(...)` for unbuilt features. When a feature phase lands, replace its `showComingSoon` call with real navigation (`lib/features/home/presentation/screens/home_screen.dart` `_quickActions`, and `tools_screen.dart` `_toolGroups`). Same for `_openFile` in `files_screen.dart` and the recent-files rail's `onTap`, which both await the Phase 3 viewer.
- **Disk space warning (2026-08-05):** this machine's root filesystem hit 100%. The user approved deleting `~/.gradle/caches/8.14` and `~/.gradle/caches/9.1.0` to free ~11G. Gradle re-downloads these on demand, so the first Android build after a cleanup is slow. If a build fails with "Could not read workspace metadata" after such a cleanup, kill stale daemons (`pkill -f GradleDaemon`) and rebuild. Do not delete `~/.android/avd` (emulator images) without asking.
