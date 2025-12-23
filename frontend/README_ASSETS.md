Assets import instructions

This project uses `assets/images/` for exported Figma assets. Follow these steps to replace the placeholder images with your Figma exports and wire them into the app.

1) Export from Figma
- Export each frame or vector as PNG (or SVG if your app supports it). Recommended sizes: export at @1x and @2x if you need retina variants.
- Use descriptive filenames matching the current `ImageAssets` mapping (recommended):
  - `node_10_2_illustration.png`
  - `node_13_17_explainable.png`
  - `node_13_41_financials.png`
  - `node_15_176_score.png`
  - `placeholder.png` (fallback)

2) Copy exports into repository
- Place exported files into `assets/images/`.
- Alternatively, use the helper script `scripts/import_figma_assets.ps1` to copy files from a source folder into `assets/images/` and run `flutter pub get`.

3) Verify pubspec
- `pubspec.yaml` already includes `assets/images/`. No edit is required if you put files under that directory.

4) Run the analyzer & app
```powershell
flutter pub get
flutter analyze
flutter run -d <device-id>
```

5) If you want to map different names, update `lib/src/widgets/image_assets.dart` to point to the new filenames. Screens reference `ImageAssets` where possible.

If you want, I can provide a sample export script for the Figma API. The script requires a Figma API token and the file key; I can add a sample if you want to automate exports.
