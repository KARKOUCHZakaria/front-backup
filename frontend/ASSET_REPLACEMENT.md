Asset replacement & Figma export steps

This document explains how to replace placeholder images with your Figma exports and wire them into the Flutter app.

1) Export assets from Figma
- Open the Figma file and select the frame(s)/layers to export.
- In the right-hand panel select the export settings. Recommended formats:
  - PNG (for raster images)
  - SVG (for vector icons — Flutter's `flutter_svg` plugin required)
  - WebP (smaller raster images if supported)
- For multiple scale densities, export 1x and 2x or 3x as needed.
- Name files using kebab-case (e.g., `onboarding-hero.png`) to avoid surprises on Windows/macOS.

2) Where to put files
- Copy the exported assets into `assets/images/` inside the `frontend` workspace.
  - Example: `assets/images/onboarding-hero.png`
  - If `assets/images/` doesn't exist, create it at `frontend/assets/images/`.

3) Update `pubspec.yaml`
- Open `pubspec.yaml` and locate the `flutter:` → `assets:` section. Add entries or a directory glob:

  flutter:
    assets:
      - assets/images/

- Save the file and run:

```powershell
flutter pub get
```

4) Replace placeholders in code
- Search for hard-coded asset paths (examples: `assets/onboarding1.png`, `assets/images/placeholder.png`).
- Replace them with the new filenames under `assets/images/`.

5) Vector assets (SVG)
- If you exported SVGs, add `flutter_svg` to `pubspec.yaml` under `dependencies`:

```yaml
dependencies:
  flutter_svg: ^2.0.0
```

- Import and use in code:

```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset('assets/images/icon-illustration.svg');
```

6) Tips & troubleshooting
- If you don't see updated assets after replacing files, try `flutter clean` then `flutter pub get`.
- On Windows, ensure file names are not too long and avoid special characters.
- For pixel-perfect parity, export assets at the exact sizes used in Figma and double-check `BoxFit`/padding in widgets.

7) Want me to do it?
- I can update references in code if you provide exported filenames or a zip of the exported `assets/images/` folder.
- If you give me the exported file names now, I can patch the widgets to reference them.
