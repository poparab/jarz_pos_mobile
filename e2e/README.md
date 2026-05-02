# Browser E2E Harness

This repo uses Playwright for real browser E2E coverage of the Flutter web app.

## What It Covers

- UI login against the deployed web app
- Session cookie establishment
- Read-only authenticated navigation to stable routes such as Kanban and Manager Dashboard

## Why Playwright Here

Flutter `integration_test` does not support web devices. This harness drives Chromium directly against the real web deployment instead.

## Setup

1. Install Node dependencies:
   - `npm install`
2. Install the Playwright browser:
   - `npm run e2e:install`
3. Copy `.env.e2e.example` to `.env.e2e.local` and set credentials.

## Run

- Staging smoke:
  - `npm run e2e:test:staging`
- Production read-only smoke:
  - `npm run e2e:test:prod`
- Headed local debugging:
  - `npm run e2e:test:headed -- --project=staging-chromium`

## Environment Variables

- `E2E_USER` / `E2E_PASSWORD`: required for the shared login smoke
- `E2E_MANAGER_USER` / `E2E_MANAGER_PASSWORD`: optional manager route smoke
- `E2E_LOGIN_MODE`: optional post-login choice, `employee` or `line-manager`
- `E2E_BASE_URL`: optional override for local preview or ad hoc targets

## Defaults

- `staging-chromium` targets `https://erpstg.orderjarz.com`
- `production-chromium` targets `https://erp.orderjarz.com`

Production projects automatically exclude any future specs tagged `@write`.