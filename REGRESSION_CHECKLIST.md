# Release regression checklist (AR Magic Lens)

Run through this list before tagging a release or opening a merge-ready PR. Use a **physical Android or iOS device** for AR; emulators are unreliable for camera and AR.

## Environment

- [ ] `flutter pub get` completes with no resolver errors.
- [ ] `flutter build apk --debug` (Android) succeeds.
- [ ] Optional: `flutter build ios --debug` on macOS with signing configured.

## Auth and navigation

- [ ] Cold start: splash → login works.
- [ ] Email/password sign-in and sign-out.
- [ ] Google sign-in (if configured in Firebase).
- [ ] Forgot password flow opens and returns.
- [ ] Home: Scan, Track Progress, Parental Control, profile image picker, back navigation.

## 2D scan (`ARScanScreen` with AR toggle off)

- [ ] Camera permission granted; preview visible.
- [ ] Bounding boxes and labels update in reasonable lighting.
- [ ] Progress list does not grow with duplicate labels on every frame (same object should not spam the list).
- [ ] Tap area that navigates to Track Progress still works as expected.

## AR scan (toggle on)

- [ ] Unsupported platforms: Web/desktop should stay in 2D with a clear message (if applicable).
- [ ] Toggle AR on: 2D camera stops; AR view appears.
- [ ] Toggle AR off: AR session releases; 2D camera restarts without crash.
- [ ] AR init timeout (wait >10s on a broken device): app falls back to 2D without leaving a broken state.
- [ ] Detect an object in 2D, switch to AR: status shows ready-to-place; tap on a plane places content.
- [ ] Rapid taps: placements are throttled (no runaway object spam).
- [ ] Place more than 12 objects: oldest placements are evicted; app remains responsive.
- [ ] **Network**: default AR model loads from HTTPS; device needs connectivity for that remote GLB unless you change the URL to a bundled asset.

## Stress / cleanup

- [ ] Open scan → toggle AR several times → pop back: no crash, no stuck camera.
- [ ] Low battery / thermal: app should degrade gracefully (manual: watch for OOM or freezes).

## Documentation

- [ ] `README.md` AR section matches current `pubspec.yaml` (`ar_flutter_plugin`).
- [ ] Team is aware of any **local pub-cache Gradle edits** for plugins; prefer vendoring the plugin in-repo for reproducible CI.
