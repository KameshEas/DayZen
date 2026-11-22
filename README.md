# DayZen

A calm day planner and journal for Android, built with Flutter. Plan your
day, close it without guilt, and reflect on what helps.

DayZen works fully offline. An account is optional: signing in adds sync and
backup of tasks and journal entries through the DayZen API
(`aspired2d-services`, `services/dayzen`).

---

## Features

- **Home:** today's tasks, a productivity score and a day optimizer that
  suggests an order for the day (rule-based, runs on the phone).
- **Planner:** week strip and a time-of-day timeline.
- **Tasks:** title, date, start/end time, priority (High · Zen · Routine ·
  Low) and category (Work · Personal · Mindful · Study).
- **Journal:** entries with a mood (Happy · Peaceful · Inspired ·
  Overwhelmed).
- **Insights:** computed on the phone from your tasks and journal.
- **Reminders:** 5 minutes before and at the start of each task, in the
  device's time zone. Optional quiet hours skip reminders inside a daily
  window (for example 22:00–07:00).
- **App lock:** optional 4-digit PIN and biometric unlock. The PIN never
  leaves the device.
- **Account (optional):** sign up, sign in, password reset by emailed code,
  sign out (revokes the session on the server) and in-app account deletion.

---

## Architecture

Feature-first layers with Flutter's built-in state primitives.

| Layer | Where | Notes |
|---|---|---|
| UI | `lib/features/*/` | Widgets read controllers through per-controller `InheritedNotifier` scopes (`lib/features/app_data.dart`), so a widget rebuilds only for the controller it depends on. |
| Controllers | `lib/features/*_controller.dart`, `lib/features/settings/` | `ChangeNotifier`s holding in-memory state. |
| Domain | `lib/core/domain/` | Pure Dart, unit-tested: analytics, planner dates, quiet hours. |
| Data | `lib/core/data/` | SQLite via drift (`lib/core/data/database/`). Local writes are single-row and mark rows dirty for sync. |
| Services | `lib/core/services/`, `lib/core/api/` | REST client (JWT), sync, auth, notifications. |

**Navigation:** go_router (`lib/core/routing/`). The start route depends on
onboarding, PIN and biometric state.

**Sync:** tasks and journal entries sync with the API (`/tasks/sync`,
`/journal/sync`): delta pulls, tombstones for deletes, and the server's copy
wins when a row was deleted there. Sync runs on app start, after local
changes, right after sign-in and when the app returns to the foreground. It
never runs while signed out. `test/contract/api_contract_test.dart` fails if
the app calls an API path the server doesn't serve.

**Secure storage:** one `flutter_secure_storage` configuration
(`lib/core/security/secure_storage.dart`) for both the PIN hash and the
session tokens.

**Crash reporting:** Firebase Crashlytics, crashes only. There is no analytics
SDK.

---

## Getting started

Prerequisites: Flutter (Dart `^3.10.1`) and JDK 21 for Android builds
(`flutter config --jdk-dir=<path to JDK 21>` if Android Studio's bundled JDK
is newer than the Gradle version supports).

```bash
flutter pub get
flutter test
```

### API base URL

The API URL is injected at build time with `--dart-define-from-file`:

| File | In git? | Purpose |
|---|---|---|
| `env/dev.json` | Yes | `http://localhost:8000/api/v1/dayzen` |
| `env/staging.json.example` | Template | Copy to `env/staging.json` |
| `env/prod.json.example` | Template | Copy to `env/prod.json` |

```bash
flutter run --dart-define-from-file=env/dev.json
flutter build apk --release --dart-define-from-file=env/prod.json
```

> **Careful:** a build with no `--dart-define-from-file` falls back to the
> production API (`https://api.aspired2d.cloud/api/v1/dayzen`, set in
> `lib/core/config/app_config.dart`).

### Testing against a local API on a phone

1. Start the API stack from `aspired2d-services` (`docker compose up -d
   postgres redis auth dayzen`; DayZen listens on port 8002).
2. Forward the phone's `localhost:8000` to it:
   `adb reverse tcp:8000 tcp:8002`.
3. Build with `env/dev.json`. Debug builds allow plain HTTP to `localhost`
   only (`android/app/src/debug/res/xml/network_security_config.xml`);
   release builds stay HTTPS-only.

If the phone already has a release DayZen with real data, build with
`DAYZEN_SIDE_BY_SIDE=1`. That debug build installs next to it as
"DayZen Dev" (`com.aspiredesignovation.dayzen.debug`) and never touches the
release app's data. It runs without Crashlytics.

On the Android emulator use `http://10.0.2.2:8000/api/v1/dayzen` instead of
`adb reverse`.

---

## Project structure

```
lib/
├── main.dart              # Startup: auth, DB, controllers, notifications, sync triggers
├── core/
│   ├── api/               # ApiClient (JWT headers, refresh-on-401, retries)
│   ├── config/            # AppConfig (API URL, copy strings)
│   ├── data/              # drift database, DAOs, repositories
│   ├── design_system/     # Tokens, theme, components
│   ├── domain/            # Pure business rules
│   ├── routing/           # go_router setup
│   ├── security/          # PIN hashing, password rule, secure storage config
│   └── services/          # Auth, sync, account deletion, password reset, …
└── features/              # One folder per screen/feature
test/                      # Unit, widget, contract, integration and performance tests
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `drift`, `path_provider`, `path` | SQLite persistence |
| `shared_preferences` | Small app flags and settings |
| `flutter_secure_storage`, `crypto` | Session tokens and PIN hash (PBKDF2) |
| `local_auth` | Biometric unlock |
| `http` | REST client |
| `go_router` | Navigation |
| `flutter_local_notifications`, `timezone`, `flutter_timezone` | Task reminders in the device time zone |
| `firebase_core`, `firebase_crashlytics` | Crash reporting |
| `app_settings` | Open system notification settings |
| `intl`, `flutter_localizations` | Formatting and localization |
| `flutter_svg`, `shimmer` | Illustrations and loading placeholders |
| `logger` | Debug logging |
