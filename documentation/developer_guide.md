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

## Local Deployment Testing

We are using **Netlify** for hosting the web application. On the free tier, there is a 300 minute limit for total build time. Testing the application production build via Netlify is not a viable approach.

Hence, do test the deployment locally first **before creating/pushing to the PR**. New updates to PRs automatically trigger a deployment preview via CICD (which is a good thing), and we need to ensure that we conserve our resources in the free tier.

### Steps

#### 1. Running the build command

The following build command defines the environment variables for static build releases.

```yaml
flutter build web --release \
      --dart-define=SUPABASE_URL=https://xvjvlscxsqbbtmhyiydp.supabase.co \
      --dart-define=SUPABASE_ANON_KEY=sb_publishable_g9-Hk52T8aMDL5ye-PLDng_zY9jwcEv \
      --dart-define=USER_PROFILE_TABLE_PROD=profiles \
      --dart-define=USER_PROFILE_BUCKET_PROD=avatars \
      --dart-define=BUSINESS_PROFILE_TABLE_PROD=business-profiles \
      --dart-define=BUSINESS_PROFILE_BUCKET_PROD=business-photos
```

#### 2. Serving on localhost

Prerequisite: make sure that you are within `build/web` directory. 

Run the following command to serve the build on localhost port 8000.

```bash
python3 -m http.server 8000  
```

You may view the local deployment at `http://localhost:8000`.
