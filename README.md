# Exam Readiness Checker

> Know where you stand. Prepare smarter.

A student-focused Flutter app that turns a few simple numbers about your exam
preparation into a clear **Readiness Score**, a list of strengths and weak
areas, and a short study plan. Everything runs **offline on your device** - no
backend, no Firebase, no API keys.

> **Disclaimer:** this is an educational productivity tool. The score and the
> preparation levels come from a simple, transparent formula. They are **not** a
> medical, psychological, professional or scientific assessment, and they cannot
> predict your real exam result.

## Problem statement

Students often feel unsure about "how ready am I?" before an exam. Syllabus
progress, mock-test scores, practice and revision are scattered across notes
and memory. This app gathers them in one place and gives a quick, easy-to-read
snapshot so the student can decide what to study next.

## Features

- Animated splash screen
- Dashboard with exam card, readiness score ring and quick statistics
- Exam setup with validated forms (exam name, date, subjects)
- Readiness assessment using sliders, number inputs and segmented controls
- Transparent score formula with a visual breakdown
- Strengths, weak areas and personalised suggestions
- Subject-wise progress cards (add, update, delete)
- Locally generated study plan with tick-able tasks
- Progress history with a custom line chart (no chart package)
- Local storage with `shared_preferences`
- Light and dark themes
- Demo data on first run, plus "Reload demo data" and "Clear all data"

## Screens

| # | Screen | Purpose |
|---|--------|---------|
| 1 | Splash | Logo, name, tagline, then opens Home |
| 2 | Home / Dashboard | Exam card, score, quick stats, main buttons |
| 3 | Exam Setup | Exam name, date, total subjects, subject list |
| 4 | Readiness Assessment | Enter preparation numbers |
| 5 | Results | Score, category, breakdown, strengths, suggestions |
| 6 | Subject Progress | One card per subject, update/delete |
| 7 | Study Plan | Today / Tomorrow / Day 3 / Until the exam |
| 8 | Progress History | Line chart and list of previous checks |
| 9 | Profile / Settings | Dark theme, edit exam, reset data, about |

## Screenshots

_Add your screenshots here after running the app._

| Home | Results | Subject Progress |
|------|---------|------------------|
| ![Home](screenshots/home.png) | ![Results](screenshots/results.png) | ![Progress](screenshots/progress.png) |

## Tech stack

- Flutter (Material 3) and Dart
- `shared_preferences` - local storage
- Built-in `ChangeNotifier` + `InheritedNotifier` - state management
- Built-in `CustomPainter` - history chart

## How the readiness score works

```
Readiness Score =
    30% x Syllabus completion
  + 25% x Mock test score
  + 20% x Practice questions   (solved / 300, capped at 100%)
  + 15% x Revision sessions    (completed / 10, capped at 100%)
  + 10% x Confidence           (1-5 converted to 20%-100%)
```

Practice questions and revision sessions are *normalised* so that they cannot
grow without limit (300+ questions or 10+ sessions both count as 100%).

| Score | Preparation level (app-generated) |
|-------|-----------------------------------|
| 80 - 100 | Highly Prepared |
| 60 - 79 | Moderately Prepared |
| 40 - 59 | Needs More Preparation |
| 0 - 39 | Early Preparation Stage |

Strengths are components scoring 70+, weak areas are components below 50.

## Installation

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install) and
VS Code with the Flutter extension.

This repository contains the app code (`lib/`, `test/`, `pubspec.yaml`). If the
platform folders (`android/`, `ios/`, `web/`, ...) are missing, generate them
once:

```bash
flutter create --project-name exam_readiness_checker .
```

(`flutter create .` never deletes your existing files.)

Then:

```bash
flutter pub get
```

## Running locally

```bash
flutter doctor        # check your setup
flutter devices       # list available devices
flutter run           # run on the selected device
```

Run the tests:

```bash
flutter test
```

## Project structure

```
lib/
  main.dart                      app entry point, theme, named routes
  models/                        plain data classes (Subject, Exam, ...)
  screens/                       one file per screen
  widgets/                       reusable UI pieces
  services/                      score calculator, study plan, storage
  state/                         AppState (ChangeNotifier) + AppScope
  utils/                         theme, validators, routes, sample data
test/
  readiness_calculator_test.dart unit tests for the formula
  widget_test.dart               app smoke test
```

## Future enhancements

- Separate mock-test entries with per-subject scores
- Local notifications / daily study reminders
- Multiple exams
- Export progress as PDF or CSV
- Cloud backup (optional, with sign-in)
- Localisation (more languages)
- Home-screen widget showing days left

## License

Educational project - add the license of your choice (for example MIT).
