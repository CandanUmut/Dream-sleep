# Dream-Sleep

Dream-Sleep is a gentle, privacy-first sleep and dream companion built with Flutter. It helps you capture midnight insights, process nightmares with compassion, and learn lucid dreaming techniques at your own pace.

## Requirements

- Flutter 3.13+ (channel stable)
- Dart 3.1+

## Getting started

```bash
flutter pub get
flutter run
```

The application defaults to an immersive dark theme for late-night use. All dream data stays on device using local JSON storage. Audio recordings are kept locally unless you export them manually.

## Key capabilities

- **Voice-first dream logging** with optional on-device transcription.
- **Night capture mode** for quick, ultra-dark audio recording at 3 AM.
- **Fragment journaling** with fields for people, places, emotions, symbols, and notes.
- **Morning recall ritual** to log dreams, feelings, or “no recall today”.
- **Nightmare comfort flow** that offers grounding, spiritual reassurance, and gentle reframing prompts.
- **Lucid learning curriculum** paced across five stages with safety reminders.
- **Wind-down checklist** that blends science-backed sleep hygiene and optional Islamic practices.
- **Insights dashboard** that surfaces trends only from entries you mark as okay to analyze.
- **Privacy promise** front and center—no ads, no uploads, and a full local reset button.

## Project structure

```
lib/
  main.dart
  theme.dart
  models/
  providers/
  services/
  screens/
  widgets/
```

Each feature area (journal, flows, insights, settings) lives in its own screen folder. Shared state lives in `AppState`, persisted locally through a lightweight JSON storage helper.

## Tests

This repository does not yet include automated widget tests. Contributions that add golden tests or integration coverage are welcome.
