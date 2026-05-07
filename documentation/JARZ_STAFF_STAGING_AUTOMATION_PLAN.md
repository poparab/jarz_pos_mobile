# Jarz POS Staff Staging Automation Plan

## Goal

Build a repeatable staging test run that answers one question clearly:

`Can a Jarz POS Staff user do everything they should be allowed to do, and are they blocked from everything they should not be allowed to do?`

This plan is for automation first. It uses the current staging web deployment and produces artifacts that can be rerun after every staging refresh or release.

## Current Starting Point

The repo already has the first piece of the required test harness:

- a Playwright browser E2E harness in `jarz_pos/`
- staging and production Playwright projects in `playwright.config.js`
- environment-based credentials in `.env.e2e.local`
- a working UI login helper in `e2e/support/auth.js`
- existing smoke coverage for login and read-only navigation

Relevant files:

- `jarz_pos/e2e/README.md`
- `jarz_pos/playwright.config.js`
- `jarz_pos/e2e/specs/login.smoke.spec.js`
- `jarz_pos/e2e/specs/readonly-navigation.spec.js`
- `jarz_pos/.env.e2e.example`
- `jarz_pos/documentation/TESTING_SCENARIOS.md`
- `jarz_pos/documentation/ACCESS_MATRIX.md`

## Role Surface To Validate

Based on the access matrix and staging setup scripts, the staff role profile to validate is:

- Role Profile: `Jarz POS Staff`
- Roles included:
  - `POS User`
  - `Sales User`
  - `Accounts User`
- Module Profile: `Jarz POS Staff Modules`

This plan treats `Jarz POS Staff` as the canonical staff permission surface.

## Recommended Test Accounts

Do not automate against a personal day-to-day human account if it can be avoided.

Use dedicated staging-only users:

- one dedicated `Jarz POS Staff` automation user
- one dedicated manager user for setup and backend verification

Requirements for the staff automation user:

- enabled on staging
- assigned `Jarz POS Staff`
- assigned `Jarz POS Staff Modules`
- linked to exactly one known active POS Profile
- allowed to start and close shifts on that POS Profile
- not reused for manual exploratory work between automated runs

Credentials must stay outside git and be loaded through `.env.e2e.local`.

Suggested environment variables:

- `E2E_USER`
- `E2E_PASSWORD`
- `E2E_MANAGER_USER`
- `E2E_MANAGER_PASSWORD`
- `E2E_LOGIN_MODE`
- `E2E_BASE_URL`

## What The Automated Run Must Prove

The run should prove both sides of permissions:

1. allowed flows work end to end for staff
2. restricted flows are hidden or blocked for staff

That means this is not only a smoke test. It is a permission-aware workflow test.

## Scope For Phase 1

Phase 1 should automate the stable, high-value staff path on staging.

### Positive staff flows

Automate these first:

1. login through the real staging POS web app
2. POS profile selection shows only the staff-linked profile(s)
3. shift start works when required
4. item catalog loads and search works
5. add item to cart and update quantity
6. customer search works
7. create a new customer with minimum valid data
8. create a cash invoice successfully
9. create a settle-later invoice successfully
10. kanban route opens and order cards are visible
11. expense creation works for staff and remains pending approval
12. shift close works at the end of the run

### Negative permission assertions

Automate these in the same run:

1. manager dashboard route is not visible in normal staff navigation
2. purchase invoices route is not visible to staff
3. transfer order action is not visible on kanban cards for staff
4. cancel order action is not visible on kanban cards for staff
5. expense approval is blocked for staff
6. manager-only routes return a blocked state if directly opened

## Scope For Phase 2

Phase 2 should add deeper write-path validation once Phase 1 is stable:

1. bundle sales
2. Instapay payment with receipt upload
3. mobile wallet payment
4. delivery slot selection
5. pickup order path
6. courier balance visibility
7. Arabic and English display checks on the kanban and receipts

## Scope For Phase 3

Phase 3 should cover backend permission enforcement directly, not only UI behavior.

Add API-level checks for staff credentials against manager-only endpoints, including at least:

1. manager dashboard APIs
2. purchase APIs
3. stock transfer APIs
4. cash transfer APIs
5. report APIs

Expected result:

- staff receives the expected permission denial or hidden access behavior
- manager verification user can still access the same endpoint family successfully

## Test Architecture

### Layer 1: Browser workflow tests

Use Playwright against the deployed staging web app.

Why:

- this is already present in the repo
- Flutter web can be exercised reliably through Playwright
- this validates the real staging deployment instead of mocks

Files to extend:

- `jarz_pos/e2e/specs/login.smoke.spec.js`
- `jarz_pos/e2e/specs/readonly-navigation.spec.js`

Files to add later:

- `jarz_pos/e2e/specs/staff-profile-selection.spec.js`
- `jarz_pos/e2e/specs/staff-shift.spec.js`
- `jarz_pos/e2e/specs/staff-sales-flow.spec.js`
- `jarz_pos/e2e/specs/staff-kanban-permissions.spec.js`
- `jarz_pos/e2e/specs/staff-expenses.spec.js`
- `jarz_pos/e2e/specs/staff-route-blocks.spec.js`

### Layer 2: Backend verification

Each write test should verify the created ERP documents after the UI action completes.

Recommended verification methods:

1. staging manager API session for safe read verification
2. staging SQL or `bench execute` probes for exact document checks

Examples:

- after customer creation, verify `Customer`, `Address`, and `Contact`
- after cash checkout, verify `Sales Invoice` and `Payment Entry`
- after settle-later checkout, verify unpaid invoice without payment entry
- after expense creation, verify pending `Jarz Expense Request`
- after shift open or close, verify `POS Opening Entry` and `POS Closing Entry`

### Layer 3: Fixture and cleanup control

The automation must not depend on leftover staging state.

Before the test run, add a setup step that:

1. confirms the target staff user is enabled
2. confirms the role profile and module profile are correct
3. confirms the staff user is linked to the expected POS Profile
4. clears or closes any stale open shift for the automation user
5. creates or reuses deterministic test data prefixes for customers and invoices

After the run, add a cleanup step that:

1. closes the shift if the scenario opened one
2. records created document names in a run artifact
3. optionally cancels or archives the created test documents when safe

## Proposed Execution Flow

Every repeatable run should use this order:

1. preflight staging health
2. preflight staff account and POS profile assignment
3. preflight clean shift state
4. run read-only login and navigation smoke
5. run positive staff workflows
6. run negative permission assertions
7. run backend verification checks
8. run cleanup and shift close
9. publish artifacts and summary

## Preflight Checks

Before Playwright starts, the automation should verify:

1. staging URL returns HTTP `200`
2. required custom apps are installed
3. target staff user is enabled
4. target user still has `Jarz POS Staff`
5. target user still has the expected POS Profile link
6. no stale open shift exists for the target user, or it is explicitly handled
7. staging is still pointed to the demo Woo store and outbound sync is disabled

## Test Data Strategy

Use deterministic naming so every run is traceable.

Recommended pattern:

- customer name prefix: `E2E Staff <YYYYMMDD-HHMM>`
- customer phone prefix: reserved staging-only number range
- invoice note or customer reference: `E2E-STAFF-<timestamp>`

Rules:

- never use production-like phone numbers for generated customers
- never rely on random existing customers in staging
- always log every created document name in the test artifacts

## Artifact Requirements

Each run should produce:

1. Playwright HTML report
2. screenshots and traces on failure
3. JSON summary of created ERP documents
4. permission matrix result file with pass or fail by scenario
5. plain markdown execution summary for quick review

Suggested artifact folder:

- `jarz_pos/artifacts/e2e/staff/<run-id>/`

## Scenario Matrix For Automation

The following matrix is the recommended first automated set.

| Area | Scenario | Expected Outcome |
|---|---|---|
| Auth | Staff login succeeds | Session established, redirected away from login |
| Auth | Session restored after refresh | User remains authenticated |
| Profile | Only linked POS profile(s) shown | No unrelated profile visible |
| Shift | Start shift | Opening entry created |
| Catalog | Item grid and search | Items visible, search filters results |
| Cart | Add item and change quantity | Cart total updates correctly |
| Customer | Create minimal customer | Customer, address, contact created |
| Checkout | Cash invoice | Paid sales invoice and payment entry created |
| Checkout | Settle later invoice | Unpaid invoice created, no payment entry |
| Kanban | Open kanban | Staff can see own workflow board |
| Kanban | Transfer action hidden | Staff cannot transfer orders |
| Kanban | Cancel action hidden | Staff cannot cancel orders |
| Expenses | Create expense | Draft or pending approval expense request created |
| Expenses | Approval blocked | Staff cannot approve expense |
| Restricted UI | Manager dashboard hidden or blocked | Staff cannot use manager dashboard |
| Restricted UI | Purchase route hidden or blocked | Staff cannot use purchase invoices |
| Shift | End shift | Closing entry created and run closes cleanly |

## Mapping To Existing Manual Scenarios

The automation should draw from these sections in `TESTING_SCENARIOS.md` first:

1. Authentication & Session
2. POS Profile Selection
3. POS Screen — Item Grid
4. POS Screen — Cart Operations
5. Customer Management
6. Payment & Checkout
7. Kanban Board
8. Kanban — Role-Restricted Actions
13. Expenses
14. Shift Management
15. Manager Dashboard
16. Purchase Invoices

## Implementation Steps

### Step 1: Stabilize credentials and account selection

1. create or confirm one dedicated staging staff automation user
2. create or confirm one manager verification user
3. store credentials in `.env.e2e.local`
4. confirm the staff user has a single stable POS Profile assignment

### Step 2: Add test support helpers

Add helper modules for:

1. seeded customer names and phone numbers
2. opening and closing shifts
3. backend verification probes
4. artifact summary writing

### Step 3: Extend Playwright specs

Build specs in this order:

1. staff login and profile visibility
2. staff shift start
3. staff sales flow
4. staff kanban permission checks
5. staff expense creation and approval block
6. staff shift close

### Step 4: Add backend verification scripts

Create staging-safe verification helpers that can assert:

1. exact invoice creation
2. payment entry creation or absence
3. customer, address, and contact creation
4. expense request status
5. shift documents

### Step 5: Add repeatable commands

The final run should be a small number of commands, for example:

```bash
npm install
npm run e2e:install
npm run e2e:test:staging -- --grep @staff
```

And later a single wrapper command such as:

```bash
npm run e2e:test:staging:staff
```

## CI And Scheduling Plan

Do not run write-path staff tests against production.

Recommended scheduling:

1. run read-only smoke on every release candidate
2. run full staging staff workflow after every staging refresh
3. run full staging staff workflow after every staging deploy that changes POS behavior or permissions
4. optionally run nightly on staging if the test data cleanup is reliable

Production policy:

- production remains read-only smoke only
- all write-path permission validation stays on staging

## Exit Criteria

This automation plan is complete when all of the following are true:

1. one command runs the full staging staff suite
2. the suite logs in as a dedicated `Jarz POS Staff` user
3. the suite proves key allowed staff workflows still work
4. the suite proves key manager-only workflows are blocked
5. the suite verifies ERP documents after each write path
6. the suite closes or cleans the created staging state reliably
7. the suite emits artifacts that make failures easy to debug

## Recommended First Build Order

If this is implemented in small batches, build it in this order:

1. staff login plus profile visibility
2. manager dashboard and purchase route block checks
3. shift start and shift close
4. cash sale flow with backend verification
5. settle-later flow with backend verification
6. expense create plus approval block
7. kanban transfer and cancel visibility checks

This order gives the fastest confidence on permissions with the lowest setup risk.

## Notes

- Keep credentials out of git.
- Keep all staff write tests tagged for staging only.
- Reuse the existing Playwright harness instead of creating a second automation framework.
- Treat the staff permission suite as a release gate for staging after permission changes, POS routing changes, and major workflow changes.