# Communitii V2 Product MVP

V2 is the active frontend-only Flutter prototype for Communitii, a storefront
discovery and social commerce app for home-based food sellers. It
demonstrates the main product flows with mock data, local state, and
`shared_preferences` persistence.

## Product Slice

- **Auth:** first-launch simulated login/signup with email, password, mock
  Google sign-in, and account type selection.
- **Casual users:** discover storefronts, search stores/products, use category
  and nearby/popular filters, subscribe to stores, browse live and upcoming
  products, read discussion previews, view subscribed-store summaries, and mark
  activity notifications as read.
- **Storefront owners:** edit a storefront profile, view store stats, preview the
  casual storefront, create/edit/delete live and upcoming products, and manage
  community discussion replies.
- **Account:** edit display name, switch between casual and owner modes, logout,
  and use a mock delete-account confirmation that clears local prototype state.

## Navigation

Casual users see:

- `Discover`
- `Subscribed`
- `Activity`
- `Account`

Storefront owners see:

- `My Store`
- `Products`
- `Community`
- `Account`

Switching account type from the account screen resets navigation to the first
tab for the selected mode.

## Prototype Constraints

- Frontend-only prototype.
- No Supabase, auth service, storage service, database, API server, migrations,
  payments, delivery, real maps, real uploads, or real account deletion.
- Auth, Google login, subscriptions, product management, discussion replies,
  notifications, and delete account are simulated.
- Useful prototype state is persisted through `shared_preferences`, which uses
  localStorage on web.
- Ownership and commenting checks are UI-only prototype rules, not security.

## Frontend Stack

- Flutter and Dart.
- Material 3 components through Flutter's built-in Material library.
- `ChangeNotifier` through `V2AppController` for local app state.
- `shared_preferences` for local prototype persistence.
- Existing MapLibre widgets remain in the tree for older experiments, but the
  active Discover MVP uses a mock explore/map surface.

No new backend services or packages are required for the product MVP. The
repository still contains older Supabase-backed `mvp2` and `backend` code, but
`main.dart` boots directly into `V2App`.

## Structure

- `v2_app.dart`: v2 app root and theme.
- `models/`: user, storefront, product, subscription, discussion, comment, and
  notification models.
- `data/`: realistic mock storefront, product, subscription, discussion, and
  notification seed data.
- `state/`: `V2AppController`, the local prototype store and persistence layer.
- `screens/`: auth gate, casual tabs, owner tabs, storefront detail, thread
  detail, account, and shell screens.
- `widgets/`: reusable storefront cards and edit forms.
- `utils/`: small helpers, including distance and radius calculations.

## Development

Use these from the repository root:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

For local static preview after a web build:

```bash
python3 -m http.server 8080 --directory build/web
```

Then open `http://localhost:8080`.

For local deployment scripts:

```bash
bash local_deployment/build_local.sh
bash local_deployment/deploy_local.sh
```

The Netlify build and local deployment scripts do not require `.env` files or
Supabase dart defines for v2.
