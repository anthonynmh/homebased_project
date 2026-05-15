# AGENTS.md

Guidance for coding agents working in this repository.

Keep this file updated as the project evolves. When architecture, active
entrypoints, commands, dependencies, deployment steps, or major conventions
change, revise the relevant project context here so future agents start from
accurate assumptions.

## Project Snapshot

This is a Flutter/Dart app for Communitii, a storefront platform for home-based businesses.
prototype.

The active app entrypoint is `lib/main.dart`, which boots into the frontend-only
product MVP in `lib/v2`. The v2 app uses mock data, local state, and
`shared_preferences` persistence for storefront discovery, subscriptions,
activity notifications, product management, owner storefront editing, and
community discussion replies.

Older Supabase-backed code and documentation still exist under areas such as
`lib/mvp2`, `lib/backend`, and `documentation/backend`, but they are not part of
the active v2 prototype unless a task explicitly targets them.

## Important Paths

- `lib/main.dart`: app entrypoint.
- `lib/v2/v2_app.dart`: active v2 app root and theme.
- `lib/v2/state/v2_app_controller.dart`: in-memory prototype state.
- `lib/v2/models/`: v2 data models.
- `lib/v2/data/`: v2 mock data.
- `lib/v2/screens/`: v2 screens and shell.
- `lib/v2/widgets/`: reusable v2 UI widgets and forms.
- `lib/v2/utils/`: small v2 helpers such as geo calculations.
- `lib/v2/README.md`: current v2 product MVP notes and development commands.
- `assets/`: Flutter asset images.
- `test/`: Flutter tests.
- `documentation/`: project docs.
- `local_deployment/`: local web build/deploy scripts.

## Development Commands

Use these from the repository root:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

For local static deployment testing:

```bash
bash local_deployment/build_local.sh
bash local_deployment/deploy_local.sh
```

The active v2 prototype does not require `.env` files, Supabase dart defines,
database migrations, production auth, storage services, payments, real maps,
uploads, or API services.

## Coding Notes

- Follow the existing Flutter and Material 3 patterns in `lib/v2`.
- Prefer focused changes in the active v2 files unless the task clearly names
  older `mvp2`, backend, platform, or deployment code.
- Keep v2 behavior frontend-only unless the user explicitly asks to integrate a
  real backend.
- Use `ChangeNotifier`/`V2AppController` for v2 in-memory state.
- Use the existing model and mock-data shapes before introducing new ones.
- The active Discover MVP uses a mock explore/map surface; preserve existing
  MapLibre widgets only when a task explicitly touches them.
- Keep generated/platform files untouched unless the task requires platform
  configuration changes.

## Verification Expectations

Run the smallest useful check for the change. For most Dart/Flutter edits,
`flutter analyze` is the baseline. Run `flutter test` when changing state,
models, calculations, or behavior covered by tests. Run a web build when changes
touch deployment, assets, web behavior, or app initialization.

If a verification command cannot be run, note that clearly in the final response.
