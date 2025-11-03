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

Build scripts are contained within `homebased_project/local_deployment`.

### Steps

#### 1. Build the application

Run the build script to build the application for static release.

```bash
bash local_deployment/build_local.sh
```

#### 2. Deploy the application

Run the deploy script.

```bash
bash local_deployment/deploy_local.sh
```

You may view the local deployment at `http://localhost:8000`.

#### 3. Stopping the local server

You may interrupt to terminate the local server using `ctrl` + `c`.

## Integration Testing

### Web

Flutter's `integration_test` package does not run out-of-the-box for web applications. Read the official [documentation](https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser) to understand the workaround for web testing.

#### Steps

1. Install `chromedriver`.
``` bash
npx @puppeteer/browsers install chromedriver@stable
```

2. Launch `chromedriver`.
``` bash
chromedriver --port=4444
```

3. From the project root, run this command:
``` bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/ \
  -d chrome
```
