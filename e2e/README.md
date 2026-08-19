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

Three DISTINCT accounts, one per capability tier. `E2E_USER` and
`E2E_LINE_MANAGER_*` deliberately have **no** fallback to `STAGING_*`: aliasing
them collapsed all three tiers onto the owner account, so every "staff is denied
X" assertion was really testing the account that is allowed to do X. A tier
whose credentials are absent now SKIPS LOUDLY instead of quietly running as
somebody else.

- `E2E_USER` / `E2E_PASSWORD`: **staff** tier. A `Jarz POS Staff` account with no
  manager role. No alias.
- `E2E_LINE_MANAGER_USER` / `E2E_LINE_MANAGER_PASSWORD`: **line manager** tier. A
  `JARZ line manager` that is not also JARZ Manager / System Manager /
  Administrator / B2B Sales Rep / any production role. No alias. Drives
  `specs/line-manager.api.spec.js`.
- `E2E_MANAGER_USER` / `E2E_MANAGER_PASSWORD`: **manager** tier. Falls back to
  `STAGING_USER` / `STAGING_PASSWORD`, because the owner credential genuinely is
  this tier.
- `E2E_POS_PROFILE`: POS profile for the staff workflow suite. Falls back to
  `STAGING_POS_PROFILE`.
- `E2E_LOGIN_MODE`: optional post-login choice, `employee` or `line-manager`
- `E2E_STRICT_CREDENTIALS=1`: turn every "missing credentials" skip into a hard
  failure. Recommended in CI so a permission suite cannot go green off an empty
  `.env`.
- `E2E_BASE_URL`: optional override for local preview or ad hoc targets

## Defaults

- `staging-chromium` targets `https://erpstg.orderjarz.com`
- `production-chromium` targets `https://erp.orderjarz.com`

Production projects automatically exclude any future specs tagged `@write`.