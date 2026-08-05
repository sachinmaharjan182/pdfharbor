# PDFverse — Build Progress

> **Read this file first when resuming work on this project**, then check `git log --oneline` to confirm what's actually committed. This file is updated in the same commit as the work it describes, so it should always match `HEAD`.

Full spec: `app_requirements.txt`. Architecture/plan: `/home/dell/.claude/plans/harmonic-sniffing-map.md` (may not exist on a different machine — this file is the source of truth if so).

## Decisions locked in (do not re-litigate)

- **PDF engine:** Syncfusion (`syncfusion_flutter_pdf` + `syncfusion_flutter_pdfviewer`), Community License. Confirmed with user.
- **Page rasterization** (thumbnails, PDF→Image, compression): `pdfx`.
- **Scanner:** `cunning_document_scanner` (Android ML Kit Document Scanner wrapper).
- **State mgmt:** plain Riverpod (`flutter_riverpod`, `Notifier`/`AsyncNotifier`), **no riverpod_generator** — kept simple to minimize build_runner surface.
- **Models:** `freezed` + `json_serializable`.
- **Hive:** manual `TypeAdapter`s, **no `hive_generator`** — it conflicts with freezed's analyzer version constraint (verified during Phase 0; do not re-add hive_generator without re-checking this).
- **App identity:** applicationId/namespace `com.pdfverse.app`, minSdk 23, package folder `android/app/src/main/kotlin/com/pdfverse/app/`.
- Android-only project (`flutter create --platforms=android`).

## Phase checklist

- [x] **Phase 0 — Bootstrap.** `flutter create`, full pubspec (all deps resolved OK), Android manifest permissions (camera/storage/media/notifications), Gradle (minSdk 23, core library desugaring, multidex), analysis_options.yaml (strict lints), feature-first folder skeleton under `lib/`, git initialized, this file created.
- [ ] **Phase 1 — Core & shell.** Error/Result types, Hive boxes + manual adapters, Material 3 theme (light/dark + dynamic color), GoRouter shell (bottom nav: Home/Files/Tools/Settings) + shared-axis transitions, shared widget kit (AppCard, EmptyState, Shimmer skeleton, ConfirmDialog, ErrorView, BottomSheets), permission service.
- [ ] **Phase 2 — Home / Files / Settings.** Home (header, search, recent files, quick-actions grid — cards added only as their target feature goes live), File Manager (list/grid, sort, search, favorites), Settings (theme, defaults, about/rate/privacy/version).
- [ ] **Phase 3 — Viewer.** Open, search text, jump to page, bookmarks, recent files, continuous/horizontal scroll, thumbnails, zoom, share, print, PDF info.
- [ ] **Phase 4 — Merge & Split.**
- [ ] **Phase 5 — Compress & Image↔PDF.**
- [ ] **Phase 6 — Scanner, Watermark, Signature, Password.**
- [ ] **Phase 7 — Polish & QA.** Share integrations, shimmer/animation pass, empty/error state audit, `flutter analyze` clean, V2 extension notes.

## Notes for whoever (or whatever session) resumes next

- Nothing is half-wired: each phase above is only checked off once it compiles and its screens are reachable from navigation with no placeholder content.
- After Phase 0/1, run `flutter analyze` and `flutter pub get` to confirm the environment still resolves before adding feature code — dependency versions were pinned deliberately (see pubspec.yaml comments / this file's Decisions section) to avoid re-triggering the freezed/hive_generator conflict.
- Home screen's quick-actions grid should only link to features that exist yet — check this file's phase checklist before wiring a new card.
