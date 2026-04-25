# AR implementation status (current)

Last aligned with the codebase as of the Day 1–7 integration pass.

## Completed

1. **2D pipeline** – TensorFlow Lite (SSD MobileNet), camera preview, bounding boxes, TTS, Firebase auth, progress tracking.
2. **Dual-mode scan UI** – `lib/3_scan_screen_ar.dart` toggles between 2D (`ScanController` from `3_scan_screen.dart`) and AR (`ARView` from `ar_flutter_plugin`).
3. **AR service** – `lib/services/ar_service.dart` wraps session/object/anchor managers: init, place on plane hit, remove all, pause session, max concurrent placements (12), FIFO eviction.
4. **Android build** – `minSdk` 24, AGP/Kotlin alignment, desugaring for newer notification plugin, NDK pin where required; legacy plugin namespace backfill in root `android/build.gradle`.
5. **Resilience** – AR unsupported (web) gate, AR init timeout fallback to 2D, stream subscription cleanup, `pauseARSession()` when leaving AR so native resources release.
6. **Performance** – Deduped progress writes from detection; capped bounding box list length in `ScanController`.

## Active AR stack

- **Package**: [`ar_flutter_plugin`](https://pub.dev/packages/ar_flutter_plugin) (`^0.7.3` in `pubspec.yaml`).
- **Not used in tree**: `arcore_flutter_plugin` (older docs may still mention it; prefer this file + README).

## Operational notes

- Default 3D placement uses a **remote GLB** (see `ARService.placeModelAtHit`); AR placement needs **network** unless you change the URI to a Flutter asset (`NodeType.localGLTF2` / bundled GLB) and register it in `pubspec.yaml`.
- For **reproducible CI and clean machines**, avoid relying on hand-edited files under `%LOCALAPPDATA%\Pub\Cache\...`; copy the plugin into a `packages/` path dependency or fork if Gradle patches are required after `flutter pub cache repair`.

## Quick verification

1. `flutter pub get`
2. `flutter build apk --debug`
3. Manual pass: [REGRESSION_CHECKLIST.md](REGRESSION_CHECKLIST.md)

## Legacy docs

Files such as `AR_IMPLEMENTATION_COMPLETE.md`, `AR_QUICK_START.md`, and `AR_IMPLEMENTATION_GUIDE.md` describe earlier `arcore_flutter_plugin` experiments. Treat **README**, **this file**, and **REGRESSION_CHECKLIST** as the maintained sources of truth unless those guides are explicitly refreshed.
