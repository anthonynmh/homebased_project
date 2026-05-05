# Homebased V2

V2 is the new direction for Homebased: a mobile-first marketplace for future
listings. Listers can post products they may sell soon, and casual users can
discover nearby listings, subscribe to interest checks, or reject what is not
relevant.

## Product Direction

- **Primary surface:** map-first browsing on mobile phones.
- **Casual users:** view listings within a 2KM radius, subscribe to listings,
  and reject listings from their local feed.
- **Listers:** create listings and preview interested subscribers/community
  thread activity.
- **Listings:** products that may become available in a specified future window,
  used to gauge demand before the lister buys ingredients or inventory.

## Prototype Constraints

- Frontend-only prototype.
- No Supabase, auth, storage, or backend calls.
- All v2 state is in memory and resets on app restart.
- Location is mocked to a Singapore center point.
- Listing data is hardcoded for visualization and UX exploration.

## Map Stack

- Renderer: `maplibre_gl`
- Style: OpenFreeMap Positron
- Style URL: `https://tiles.openfreemap.org/styles/positron`

The map screen uses native MapLibre circle annotations for listing locations so
markers remain visible and tappable on web and mobile.

## Structure

- `v2_app.dart`: v2 app root and theme.
- `models/`: frontend-only listing, subscription, thread, and user-mode types.
- `data/`: hardcoded placeholder listing data.
- `state/`: in-memory app controller.
- `screens/`: map, listings, account, and shell screens.
- `widgets/`: reusable v2 UI widgets, including the MapLibre map and floating
  listing cards.
- `utils/`: small helpers, including distance and radius calculations.

## Deployment

`main.dart` boots directly into `V2App`, so Netlify builds and serves v2 by
default. The Netlify build does not require `.env` or Supabase environment
variables.

Before merging deployment changes, verify:

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
