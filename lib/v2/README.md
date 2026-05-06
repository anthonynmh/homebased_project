# Homebased V2

V2 is the active frontend-only prototype for a small-seller storefront
experience. It focuses on food storefront discovery, subscriptions, catalog
browsing, owner management, and a simple storefront thread.

## Product Slice

- **Casual users:** use simulated login/signup, view storefronts inside a 2KM
  radius, subscribe or unsubscribe, open storefront details, browse food catalog
  items, and comment after subscribing.
- **Storefront owners:** switch to owner mode, create storefronts, edit basic
  storefront details, add or edit food catalog items, and post in the storefront
  thread.
- **Account:** update display name, switch user type, and perform simulated
  logout.

## Prototype Constraints

- Frontend-only prototype.
- No Supabase, auth service, storage, database, API calls, migrations, payments,
  delivery, or production persistence.
- Simulated auth stores only an in-memory demo user.
- Storefronts, catalog items, subscriptions, and comments are hardcoded or kept
  in memory through `V2AppController`.
- State resets when the app restarts.
- Location is mocked to a Singapore center point and filtered with a simple 2KM
  Haversine calculation.
- Ownership and commenting rules are UI-only prototype checks, not security.

## Frontend Stack

- Flutter and Dart.
- Material 3 components through Flutter's built-in Material library.
- `ChangeNotifier` for the v2 in-memory controller.
- `maplibre_gl` for the nearby storefront map.
- OpenFreeMap Positron map style:
  `https://tiles.openfreemap.org/styles/positron`
- `intl` remains available for formatting where needed.

No new packages are required for this prototype. The repository still contains
older Supabase-backed `mvp2` code, but `main.dart` boots directly into `V2App`.

On Flutter desktop targets where `maplibre_gl` does not support the platform,
the Nearby tab uses a lightweight storefront fallback surface instead of
constructing the native map widget. Web, iOS, and Android continue to use the
interactive map.

## Structure

- `v2_app.dart`: v2 app root and theme.
- `models/`: storefront, catalog item, subscription, comment, and user types.
- `data/`: hardcoded mock storefront/catalog/subscription/comment seed data.
- `state/`: `V2AppController`, the in-memory prototype store.
- `screens/`: auth gate, map, storefront list/manage, storefront detail,
  account, and shell screens.
- `widgets/`: reusable storefront cards, MapLibre map widget, and edit forms.
- `utils/`: small helpers, including distance and radius calculations.

## Development

```bash
flutter pub get
flutter analyze
flutter build web --release
```

For local static preview:

```bash
bash local_deployment/build_local.sh
bash local_deployment/deploy_local.sh
```

The Netlify build and local deployment scripts do not require `.env` files or
Supabase dart defines for v2.
