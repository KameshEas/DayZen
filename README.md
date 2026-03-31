# DayZen — Offline AI Day Optimizer

A Flutter productivity app designed to help users plan, track, and reflect on their day with a calm, mindful approach. DayZen works fully offline — no accounts, no cloud sync, no tracking.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [State Management](#state-management)
- [Data Layer](#data-layer)
- [Navigation & Shell](#navigation--shell)
- [Security](#security)
- [Design System](#design-system)
- [Notifications](#notifications)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Dependencies](#dependencies)

---

## Overview

DayZen is a Flutter application targeting Android and iOS that combines task planning, journaling, and productivity analytics in a single offline-first app. It emphasises mindfulness, daily reflection, and consistent focus habits without requiring an internet connection or user account.

---

## Features

### Home
- Time-aware greeting (Good Morning / Afternoon / Evening).
- Today's date and a list of tasks scheduled for the current day.
- Real-time task completion counter and daily productivity score.
- Focus label derived from the highest-priority incomplete task.

### Planner
- Weekly calendar strip (Mon–Sun) with per-day task counts.
- Tap any day to view and manage tasks scheduled for that date.
- Tasks displayed chronologically by start time.

### Task Management
- Create tasks with a title, scheduled date, start/end time, category, and priority.
- **Priority levels:** High · Zen · Routine · Low — each with a distinct colour.
- **Categories:** Work · Personal · Mindful · Study.
- Mark tasks complete/incomplete; completed tasks update the productivity score immediately.
- Local notifications scheduled per task (with quiet-hour and focus-alert preferences).

### Insights
- Daily productivity score (0–100) calculated from task completion and priority weights.
- Weekly focus trend bar chart (Mon–Sun completion fractions).
- Weekly tasks completed counter.
- Journal entry streak for the current week.
- Motivational AI-style quotes derived from productivity score.
- Top category and mindfulness summary cards.

### Journal
- Write freeform journal entries with a title, body, and mood tag.
- **Mood options:** Happy · Peaceful · Inspired · Overwhelmed — each with icon and colour coding.
- Weekly reflection banner showing entry count and encouragement streak.
- Entries sorted newest-first; individual entries can be deleted.

### Settings
- **Theme:** Light / Dark / System default.
- **Accent colour:** Zen Green · Ocean Blue · Sunset Orange · Lavender.
- **Font size:** Small (14 px) · Standard (16 px) · Large (18 px).
- **Notifications:** Quiet hours toggle, focus-alert toggle.
- Data management: clear all tasks, clear all journal entries.

### Security & Authentication
- **PIN protection:** Optional 4-digit PIN set during onboarding or settings. Hashed and stored locally.
- **Biometric unlock:** Fingerprint / Face ID via `local_auth`. Automatically disabled when hardware becomes unavailable.
- **Priority order at startup:** Biometric → PIN → Direct access.
- All auth data stays on-device; no remote authentication is ever performed.

### Onboarding
- First-run flow that introduces core concepts and prompts the user to optionally set a PIN.

---

## Architecture

DayZen follows a **feature-first layered architecture** with a clear separation between data, business logic (controllers), and UI.

```
lib/
├── main.dart                  # App entry point, startup orchestration
├── core/
│   ├── app_prefs.dart         # SharedPreferences helpers (onboarding, PIN, biometric flags)
│   ├── notification_service.dart  # Singleton for local notification scheduling
│   └── data/
│       ├── task_repository.dart   # JSON serialise/deserialise tasks to SharedPreferences
│       └── journal_repository.dart
│   └── design_system/         # Tokens, components, theme
└── features/
    ├── app_data.dart           # InheritedWidget — root DI container
    ├── task_controller.dart    # Business logic for tasks
    ├── journal_controller.dart # Business logic for journal entries
    ├── home/                   # Today view
    ├── planner/                # Weekly calendar + task list
    ├── tasks/                  # New task creation form
    ├── insights/               # Productivity analytics
    ├── journal/                # Journal entries
    ├── settings/               # App preferences (UI + controller)
    ├── auth/                   # Login page
    ├── pin/                    # PIN setup and unlock pages
    ├── biometric/              # Biometric unlock page
    ├── onboarding/             # First-run flow
    └── shell/                  # Bottom-nav shell (MainShell)
```

### Layer responsibilities

| Layer | Role |
|---|---|
| **Repository** (`core/data/`) | Raw I/O only — reads/writes JSON from `SharedPreferences`. No business logic. |
| **Controller** (`features/*_controller.dart`) | `ChangeNotifier` classes that own in-memory state, expose derived queries, and delegate persistence to repositories. |
| **UI** (`features/*/`) | Stateless or minimal-state widgets that read controllers through `AppData` and call controller methods on user interaction. |

---

## State Management

DayZen uses **`ChangeNotifier` + `InheritedWidget`** — Flutter's built-in primitives, with no external state management package.

- `TaskController`, `JournalController`, and `SettingsController` each extend `ChangeNotifier`.
- `AppData` is an `InheritedWidget` placed at the root of the widget tree that holds references to all three controllers.
- Leaves of the tree call `AppData.of(context)` to obtain a controller, then wrap rebuild-sensitive subtrees in `ListenableBuilder` (or `ListenableBuilder` with `Listenable.merge` for multi-controller reactivity).

This approach keeps the dependency graph shallow, avoids code generation, and makes every state transition traceable to a single method call.

---

## Data Layer

All data is persisted **locally on-device** using `shared_preferences`.

| Data | Key | Format |
|---|---|---|
| Tasks | `dz_tasks` | JSON array of task objects |
| Journal entries | `dz_journal` | JSON array of entry objects |
| Settings | Various keys | Primitive values (bool, String) |
| PIN hash | `dz_pin` / `dz_pin_hash` | Hashed string |
| Onboarding flag | `dz_seen_onboarding` | bool |
| Biometric preference | `dz_biometric_enabled` | bool |

No network calls are ever made. The app functions identically with or without an internet connection.

---

## Navigation & Shell

Startup navigation is resolved in `main.dart` before `runApp` based on flags loaded from `SharedPreferences`:

```
showOnboarding=true  →  OnboardingRoot
biometricEnabled=true  →  BiometricUnlockRoot
hasPin=true  →  PinUnlockRoot
otherwise  →  AuthRoot  →  MainShell
```

Inside the authenticated session, `MainShell` renders a persistent `BottomNavigationBar` with five slots:

| Index | Tab | Page |
|---|---|---|
| 0 | Home | `HomePage` |
| 1 | Planner | `PlannerPage` |
| 2 | *(FAB)* | Opens `NewTaskPage` as a modal route |
| 3 | Insights | `InsightsPage` |
| 4 | Journal | `JournalPage` |

Page transitions use `MaterialPageRoute`. No routing package is used.

---

## Security

- **PIN storage:** The PIN is never stored in plaintext. Only a hash is persisted.
- **Biometric:** The `local_auth` package delegates to the OS biometric API; no biometric data is accessed or stored by the app.
- **No remote surface:** The absence of network code eliminates entire categories of web vulnerabilities (injection, CSRF, data exfiltration).
- **Device capability check:** Biometric preference is automatically disabled at startup if the device no longer reports biometric hardware, preventing a locked-out state.

---

## Design System

The `core/design_system/` directory contains a fully custom design system:

- **Tokens:** `DzColors`, `DzTextStyles`, `DzSpacing`, `DzDimensions`, `DzRadius`, `DzShadows`, `DzDuration`.
- **Theme:** `DzTheme.light()` / `DzTheme.dark()` accept a dynamic accent `Color` and build a complete `ThemeData` with a `ColorScheme`, typography, and component overrides.
- **Accent options:** Zen Green `#10B981` · Ocean Blue `#3B82F6` · Sunset Orange `#F97316` · Lavender `#8B5CF6`.
- **Typography:** Inter (body/labels) loaded from local assets.
- **Components:** `DzScaffold`, `DzAppBar`, `DzLogo`, and card/button primitives shared across pages.

---

## Notifications

`NotificationService` is a singleton backed by `flutter_local_notifications`.

- Initialised once at startup with timezone support (`timezone` package).
- Android 13+ notification permission is requested at launch.
- Tasks with a future `startTime` are scheduled as exact timezone-aware notifications.
- Notifications are cancelled when a task is deleted and rescheduled in bulk when notification preferences change.
- Quiet-hours and focus-alert toggles in Settings control whether notifications are active.

---

## Project Structure (abbreviated)

```
dayzen/
├── android/                  # Android host project
├── ios/                      # iOS host project
├── assets/
│   └── fonts/                # Inter & display font files
├── lib/
│   ├── main.dart
│   ├── core/                 # Shared services, repositories, design system
│   └── features/             # Feature modules (one folder per feature)
├── pubspec.yaml
└── analysis_options.yaml
```

---

## Getting Started

**Prerequisites:** Flutter SDK `^3.10.1`, Dart SDK `^3.10.1`.

```bash
# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run

# Build release APK
flutter build apk --release

# Build release IPA (requires macOS + Xcode)
flutter build ipa --release
```

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `shared_preferences` | ^2.3.2 | Local key-value persistence |
| `local_auth` | ^2.3.0 | Biometric / device credential authentication |
| `app_settings` | ^7.0.0 | Navigate to system settings (notification permissions) |
| `flutter_local_notifications` | ^21.0.0 | Schedule and deliver local push notifications |
| `timezone` | ^0.11.0 | IANA timezone database for accurate notification scheduling |

