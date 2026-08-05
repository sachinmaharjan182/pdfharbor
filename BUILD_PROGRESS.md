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
- [ ] **Phase 3 — Viewer.** Open, search text, jump to page, bookmarks, recent files, continuous/horizontal scroll, thumbnails, zoom, share, print, PDF info.
- [ ] **Phase 4 — Merge & Split.**
- [ ] **Phase 5 — Compress & Image↔PDF.**
- [ ] **Phase 6 — Scanner, Watermark, Signature, Password.**
- [ ] **Phase 7 — Polish & QA.** Share integrations, shimmer/animation pass, empty/error state audit, `flutter analyze` clean, V2 extension notes.

## Notes for whoever (or whatever session) resumes next

- Nothing is half-wired: each phase above is only checked off once it compiles and its screens are reachable from navigation with no placeholder content.
- Run `flutter pub get` and `flutter analyze` first to confirm the environment still resolves before adding feature code — dependency versions were chosen deliberately (see the Decisions section) to avoid re-triggering the freezed/hive_generator conflict.
- **After editing any `@freezed` model, re-run:** `dart run build_runner build --delete-conflicting-outputs`. `.freezed.dart`/`.g.dart` files are generated and are excluded from analysis.
- Home's quick-actions grid and the Tools screen currently call `context.showComingSoon(...)` for unbuilt features. When a feature phase lands, replace its `showComingSoon` call with real navigation (`lib/features/home/presentation/screens/home_screen.dart` `_quickActions`, and `tools_screen.dart` `_toolGroups`). Same for `_openFile` in `files_screen.dart` and the recent-files rail's `onTap`, which both await the Phase 3 viewer.
- **Disk space warning (2026-08-05):** this machine's root filesystem hit 100%. The user approved deleting `~/.gradle/caches/8.14` and `~/.gradle/caches/9.1.0` to free ~11G. Gradle re-downloads these on demand, so the first Android build after a cleanup is slow. If a build fails with "Could not read workspace metadata" after such a cleanup, kill stale daemons (`pkill -f GradleDaemon`) and rebuild. Do not delete `~/.android/avd` (emulator images) without asking.
