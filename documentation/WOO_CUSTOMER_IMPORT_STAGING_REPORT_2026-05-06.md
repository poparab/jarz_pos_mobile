# Woo Customer Import Staging Report

Date: 2026-05-06

## Final Status

The staging customer cleanup is converged and verified.

- Canonical ERP customer and address state now matches the current Woo customer data for every safely resolvable customer.
- The remaining blockers are limited to 5 Woo customers that the cleanup intentionally refuses to merge unsafely.
- Staging health verification passed after the final cleanup rerun.

## Business Rules Applied

- ERPNext is the canonical system after import.
- WooCommerce is an upstream source only.
- Exact `woo_customer_id` is the first identity key.
- Unique normalized phone is the approved merge key when exact Woo ID does not resolve safely.
- Email-only and username-only conflicts must block instead of force-merging.
- Address dedupe is allowed only inside the same customer boundary.
- Cross-customer address reuse is forbidden.
- Cleanup correctness is judged by the canonical grouped audit, not by per-Woo record comparisons after approved phone merges.

## Final Deployed Code

### jarz_woocommerce_integration

Final cleanup commit deployed to staging:

- `3c5a618` Fix source-address normalization during cleanup

Important cleanup checkpoints reached during this staging cycle:

- `45cd3b9`
- `cccb7d8`
- `1a19d05`
- `3c5a618`

Final staging installed version:

- `jarz_woocommerce_integration 0.0.1 main (3c5a618)`

Implemented cleanup behavior now in use:

- one-time cleanup service in `jarz_woocommerce_integration/services/customer_cleanup.py`
- CLI wrapper in `jarz_woocommerce_integration/cli.py`
- page-window execution support for controlled reruns
- full desired-state computation across all Woo customers even when applying one page window at a time
- explicit DB reconnect after long Woo fetches before SQL work resumes
- source-address signature normalization aligned with persisted ERP fallback semantics, including `city="Unknown"` and default country resolution

### jarz_pos

Final staging installed version:

- `jarz_pos 0.0.1 main (f570185)`

## Runner Method That Worked Reliably

The reliable staging execution method was file-based and container-local:

1. Create local helper runners under `artifacts/2026-05-06/`.
2. Copy the runner to the staging host with `scp`.
3. Copy the runner into `erp-backend-1` with `docker cp`.
4. Execute the runner inside the backend container with env vars controlling the batch window and write output to stdout or a temp file.
5. Remove the temp files from both the host and the container after each run.

This worked consistently for:

- `customer_cleanup_batch_runner.py`
- `staging_customer_audit_runner.py`
- `staging_customer_canonical_audit_runner.py`
- `inspect_customer_cleanup_case.py`

This approach is the one to repeat on production. It avoided repeated quoting failures from long inline `bench execute` and nested PowerShell or SSH command strings.

## Validation Performed

### Local focused tests

Executed after the final normalization fix:

- `python -m unittest jarz_woocommerce_integration.tests.test_customer_cleanup`
- `python -m unittest jarz_woocommerce_integration.tests.test_customer_bulk_sync`

Result:

- passed with no failures

### Staging deployment verification

Final deployed heads on staging:

- `jarz_pos`: `f570185f9511e883c13f4906e764f528cd94dd20`
- `jarz_woocommerce_integration`: `3c5a61832c562fa511a116d5ac9319b95488c48d`

Live staging checks after final cleanup:

- `GET https://erpstg.orderjarz.com/api/method/ping` returned `200`
- staging verify script passed all critical checks
- all required containers were healthy
- both custom apps were installed

## Metrics

### Initial baseline before cleanup

- Woo customers: `5049`
- ERP customers: `4481`
- exact Woo-ID unique matches: `4051`
- phone-merge unique matches: `117`
- unresolved Woo customers: `881`
- deviated per-Woo address matches: `3899`
- duplicate canonical Woo-ID groups already present in ERP: `3` (`3357`, `3437`, `3753`)

### Intermediate state before final normalization fix

After cleanup logic hardening but before fixing source-address normalization, the remaining canonical drift was still large:

- resolved total: `5044`
- unresolved total: `5`
- exact canonical customer matches: `2776`
- deviated canonical customer matches: `2165`
- total missing union Woo addresses: `2319`
- total extra unique ERP addresses: `2228`
- total duplicate row surplus: `113`

Root cause identified from the concrete staging case `AMR` / Woo `11`:

- Woo billing and shipping payloads could arrive with blank `city` and blank `country`
- ERP persisted those same addresses with fallback values such as `city="Unknown"` and `country="Egypt"`
- cleanup compared raw blank source values to the stored fallback values, so those rows never converged and were repeatedly treated as missing or extra

### Final state after `3c5a618` and full apply rerun

Authoritative full apply rerun summary:

- `addresses_created: 0`
- `addresses_deleted: 180`
- `addresses_disabled: 0`

Canonical grouped audit after the final rerun:

- resolved ERP customers: `4941`
- unresolved Woo customers: `5`
- exact customer matches: `4941`
- deviated customer matches: `0`
- customers missing at least one union Woo address: `0`
- customers with extra unique ERP addresses: `0`
- customers with duplicate ERP address rows: `0`
- total missing union Woo addresses: `0`
- total extra unique ERP addresses: `0`
- total duplicate row surplus: `0`

Per-Woo audit after the final rerun:

- exact Woo-ID unique matches: `4928`
- phone-merge unique matches: `116`
- resolved total: `5044`
- unresolved total: `5`
- exact address matches: `4370`
- deviated address matches: `197`
- customers missing at least one current Woo address: `0`
- customers with extra unique ERP addresses: `197`
- total missing current Woo addresses: `0`
- total extra unique ERP addresses: `208`

## Interpreting the Final Per-Woo Deviation Count

The remaining `197` per-Woo address deviations are not cleanup failures.

They are expected cases where multiple Woo customer IDs safely merge to one ERP customer by phone, so a single Woo customer is being compared against the full union of addresses now owned by the merged ERP customer.

Evidence:

- the canonical grouped audit is fully clean
- the top remaining per-Woo deviation samples are predominantly `phone_merge` cases with `missing_count = 0` and only `extra_unique_count > 0`
- there are `0` shared active address rows across multiple ERP customers

Production cleanup sign-off should therefore use the canonical grouped audit as the correctness gate.

## What Worked Automatically

- exact Woo-ID resolution
- safe phone-based customer merges
- full desired-state preservation across merged Woo identities
- retirement of stale or duplicated customer address rows within the same customer boundary
- removal of extra ERP customer-address links not present in the unioned Woo state
- full cleanup convergence after aligning source signature normalization with persisted ERP fallback values
- preservation of the safety rule that unsafe identity conflicts must stay blocked

## What Did Not Auto-Resolve

The cleanup intentionally left 5 Woo customers unresolved because forcing them through would be unsafe:

- `187`: username conflict without safe email match
- `885`: email and username conflict without phone
- `3357`: duplicate canonical Woo ID already stamped across multiple ERP customers
- `3437`: duplicate canonical Woo ID already stamped across multiple ERP customers
- `3753`: duplicate canonical Woo ID already stamped across multiple ERP customers

These are the manual-resolution cases to review before or during the production wave. The cleanup rules should not be loosened to make these auto-pass.

## Production Reuse Steps

1. Deploy the same cleanup code path to production from GitHub. Do not run a server-only hotfix.
2. Reuse the same file-based runner method from `artifacts/2026-05-06/`.
3. Run the full apply with the same effective parameters used in the successful staging rerun:
  - `START_PAGE=1`
  - `MAX_PAGES=51`
  - `PER_PAGE=100`
  - `COMMIT_EVERY=200`
  - `DRY_RUN=0`
  - `HARD_DELETE_ORPHANS=1`
  - `SAMPLE_LIMIT=10`
4. Rerun both audits immediately after apply:
  - per-Woo audit for unresolved and phone-merge review
  - canonical grouped audit as the actual correctness gate
5. Stop production sign-off if the canonical grouped audit is not zeroed.
6. Resolve the blocked identity cases manually instead of weakening the cleanup rules.

## Conclusion

The staging cleanup is successful, reproducible, and now documented with the exact method that worked.

Production should reuse the final code on `3c5a618`, the same file-based runner approach, and the canonical grouped audit as the go or no-go decision point.