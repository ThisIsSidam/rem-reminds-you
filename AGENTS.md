# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project

Rem is a Flutter reminder app (package name `rem`) that re-notifies the user repeatedly until a reminder is marked "Done". Key features: recurring reminders, auto-snooze, natural-language title parsing (e.g. "Take a nap in 15 minutes"), and drag-and-drop reminders between sections.

## Commands

The app has two build flavors, `dev` and `prod` — plain `flutter run`/`flutter build` will not work; the flavor must always be specified.

```bash
# Run
flutter run --flavor dev
flutter run --flavor prod

# Build
flutter build apk --flavor prod
flutter build apk --flavor dev

# Static analysis (uses very_good_analysis + custom rules in analysis_options.yaml)
flutter analyze

# Tests
flutter test
flutter test test/recurrence_strategy_test.dart      # single file
flutter test --plain-name "DailyStrategy"             # single group/test by name

# Regenerate code (freezed, riverpod_generator, json_serializable, objectbox_generator)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # while iterating

# Localization (arb-dir: lib/l10n, generates lib/l10n/app_localizations.dart)
flutter gen-l10n
```

VS Code launch configs for both flavors/modes are in `.vscode/launch.json`.

## Architecture

### Feature-based structure

Code lives under `lib/feature/<feature_name>/` with a consistent internal split:
- `data/` — `entities/` (ObjectBox persistence classes), `models/` (freezed domain models, often with `toEntity`/`toModel` conversion extensions), `repositories/`
- `domain/` — pure logic (strategies, factories) with no Flutter/persistence dependencies
- `presentation/` — `providers/` (Riverpod, code-gen'd into `providers/generated/`), `screens/`, `widgets/`

Features: `app_startup`, `home`, `permissions`, `recurrence`, `reminder`, `reminder_sheet`, `settings`. Cross-feature code goes in `lib/core/` (services, exceptions, extensions) or `lib/shared/` (generic widgets/utils used by multiple features), never duplicated per-feature.

Generated files (`*.g.dart`, `*.freezed.dart`, `providers/generated/*`) are excluded from lint/analysis and must be regenerated via `build_runner`, not hand-edited.

### State management: Riverpod + GetIt

- Riverpod (`hooks_riverpod` + `riverpod_annotation`, code-generated with `@riverpod`) is the app-wide state layer. Notifiers subscribe to repository streams in `build()` and expose derived/categorized state (see `RemindersNotifier` in `lib/feature/reminder/presentation/providers/reminders_provider.dart` for the canonical pattern: stream subscription set up in `build()`, cancelled via `ref.onDispose`).
- `GetIt` (global instance `getIt` in `lib/main.dart`) is used only for singleton infrastructure objects created at startup — `SharedPreferences`, the ObjectBox `Store`, and the repositories built from it (`RemindersRepository`, `NoRushRemindersRepository`). Providers pull these repositories out of `getIt` directly rather than through Riverpod providers.

### Persistence: ObjectBox

A single ObjectBox `Store` (opened in `main.dart` under `objectbox-activity-store` in the app documents directory) backs multiple entity boxes. Repositories (`lib/feature/*/data/repositories|repository/`) wrap a `Box<Entity>` and expose:
- a reactive stream via `box.query().watch(triggerImmediately: true)`
- basic CRUD (`saveReminder`, `getReminder`, `removeReminder`)
- JSON backup/restore (`getBackup`/`restoreBackup`) used by the settings backup feature

Entities (`data/entities/`) are the ObjectBox-annotated persistence layer; models (`data/models/`, freezed) are the domain-facing representation. Conversion happens via `toModel`/`toEntity` extensions — never pass entities into the presentation layer directly.

### Recurrence: Strategy pattern

`lib/feature/recurrence/data/strategies/` implements `RecurrenceStrategy` (`occursOn(base, target)`, `next(base)`) with one class per recurrence type: `NoRecurrenceStrategy`, `DailyStrategy`, `WeeklyStrategy`, `MonthlyStrategy`, `SelectedDaysStrategy`, `SelectedDatesStrategy`. `lib/feature/recurrence/domain/recurrence_factory.dart` maps a `RecurrenceRule` model to its strategy. When adding a new recurrence type, add both the rule model (`data/models/`) and its strategy, and wire it into the factory — `test/recurrence_strategy_test.dart` is the reference test shape for strategy behavior.

### Notifications

`lib/core/services/notification_service/` wraps `awesome_notifications` (local notifications) and `android_alarm_manager_plus`. Reminder scheduling/cancellation always goes through `NotificationService` (`scheduleReminder`, `cancelScheduledNotification`, `removeNotificationsByGroupKey`) rather than the plugin directly, and is always paired with the corresponding repository write so DB state and scheduled notifications never drift apart (see every mutation in `RemindersNotifier`). Notification action taps are routed through `reminder_actions_handler.dart`.

### Routing

Flat, non-nested routing via a `Map<String, WidgetBuilder>` (`lib/router/route_builder.dart`) keyed off the `AppRoute` enum (`lib/router/app_routes.dart`), set as `MaterialApp.routes`. Note routes are registered by `AppRoute.name` (enum identifier), not `AppRoute.path` — the `path` strings exist but aren't currently what's used for lookup. Add new screens by extending both the enum and the builder map.

### Title parsing

`lib/feature/reminder_sheet/presentation/widgets/title_parser/title_parser.dart` extracts a relative time expression from free-text reminder titles (e.g. "in 15 minutes") and splits it from the display title.
