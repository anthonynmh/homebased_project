# Developer Guide

Follow the steps in this documentation to start set up your environment for development.

## Setting Up Dev Environment

### Installing Flutter

This project uses Flutter. The official Flutter docs has extensive instructions on how to install Flutter.

See [here](https://docs.flutter.dev/get-started/install).

### Local Development

If you have not already done so, clone this repo to your preferred local directory.

Afterwhich you may follow this tutorial on a quick Flutter crash course. It also includes instructions on how to run you can run this Flutter app locally.

See [here](https://codelabs.developers.google.com/codelabs/flutter-codelab-first#0)

## Current Frontend Prototype

`lib/main.dart` boots into the active `lib/v2` Flutter prototype. The v2 app is
frontend-only and uses:

- Flutter and Dart with Material 3 widgets.
- `ChangeNotifier` through `V2AppController` for in-memory state.
- Hardcoded mock storefronts, food catalog items, subscriptions, and comments.
- Simulated login/signup/logout with a local demo user.
- MapLibre GL with the OpenFreeMap Positron style for the nearby storefront map.
- A mocked Singapore center point and a simple 2KM radius calculation.

Flutter desktop targets that are not supported by `maplibre_gl` use a
storefront fallback surface on the Nearby tab instead of constructing the native
map widget.

The v2 prototype does not call Supabase, backend APIs, auth services, storage,
databases, migrations, payment services, or production persistence. Older
Supabase-backed `mvp2` services and backend documentation remain in the repo,
but they are not part of the active v2 storefront prototype.

Recommended development commands:

```bash
flutter pub get
flutter analyze
flutter build web --release
```

## Local Deployment Testing

We are using **Netlify** for hosting the web application. On the free tier, there is a 300 minute limit for total build time. Testing the application production build via Netlify is not a viable approach.

Hence, do test the deployment locally first **before creating/pushing to the PR**. New updates to PRs automatically trigger a deployment preview via CICD (which is a good thing), and we need to ensure that we conserve our resources in the free tier.

Build scripts are contained within `homebased_project/local_deployment`.

### Steps

#### 1. Build the application

Run the build script to build the application for static release.

```bash
bash local_deployment/build_local.sh
```

The v2 prototype is frontend-only, so the local build does not require a `.env` file or Supabase dart defines.

#### 2. Deploy the application

Run the deploy script.

```bash
bash local_deployment/deploy_local.sh
```

You may view the local deployment at `http://localhost:8000`.

#### 3. Stopping the local server

You may interrupt to terminate the local server using `ctrl` + `c`.
