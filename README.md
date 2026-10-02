# ArtLore

A private museum companion — scan a painting, read its story, look closer.
Flutter implementation of the ArtLore Claude Design (UI phase, mock data).

## Run

```sh
flutter pub get
flutter run
dart format . && flutter analyze && flutter test
```

## Structure

```
lib/
├── main.dart                 bootstrap (SharedPreferences → ProviderScope)
├── app/
│   ├── app.dart              MaterialApp.router, themes, reduce-motion, text scale
│   ├── router.dart           every route (go_router), tab shell
│   └── providers.dart        composition root — repository implementations
├── core/
│   ├── theme/                AppColors · AppPalette (dark/light) · AppTypography
│   │                         AppRadius (arch/leaf/sweep…) · AppShadows · AppMotion
│   ├── router/               AppRoutes, page transitions, TabShell
│   ├── media/                ArtImageSource (asset today, CDN URL later)
│   ├── widgets/              ArtImage, buttons, sheets, toast, tabs, bottom nav,
│   │                         icons (exact SVG paths from the design), motion
│   └── utils/
└── features/<feature>/{domain,data,presentation}
    onboarding · home · discover · scan · artwork (result, story, look closer,
    listen, detective, compare) · collections · history · journey · profile ·
    settings · paywall
```

Data flows **UI → Riverpod provider → repository interface → mock repository**.
To go live, implement the interfaces (e.g. `ArtworkRepository`,
`RecognitionRepository`, `PurchaseRepository`) and swap them in
`lib/app/providers.dart` — no screen changes.

## Notes

* Fonts (Cormorant Garamond, Manrope) and artwork images are bundled in
  `assets/` — nothing is fetched at runtime.
* Dark is the default theme; Light and System live in Settings → Appearance and
  persist locally. The scanner stays dark in both, like the iOS camera.
* Rule of the codebase: no Dart file over 300 lines (most are under 200).
